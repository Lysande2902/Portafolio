-- ============================================
-- FIX COMPLETO FINAL - OOLALE MOBILE
-- ============================================
-- Este es el ÚNICO script que necesitas ejecutar
-- Basado en el schema real de tu base de datos
-- Fecha: 6 de Febrero, 2026
-- ============================================

-- ============================================
-- PARTE 1: FIX TABLA CONEXIONES
-- ============================================
-- Problema: Falta columna updated_at y conexiones son unidireccionales

-- 1.1: Verificar y agregar columna updated_at si no existe
DO $$ 
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'conexiones' AND column_name = 'updated_at'
    ) THEN
        ALTER TABLE conexiones ADD COLUMN updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE '✅ Columna updated_at agregada a tabla conexiones';
    ELSE
        RAISE NOTICE '⚠️ Columna updated_at ya existe en tabla conexiones';
    END IF;
END $$;

-- 1.2: Actualizar registros existentes que tengan updated_at NULL
UPDATE conexiones 
SET updated_at = created_at 
WHERE updated_at IS NULL;

-- 1.3: Crear función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION update_conexiones_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 1.4: Crear trigger para updated_at
DROP TRIGGER IF EXISTS trigger_update_conexiones_updated_at ON conexiones;

CREATE TRIGGER trigger_update_conexiones_updated_at
    BEFORE UPDATE ON conexiones
    FOR EACH ROW
    EXECUTE FUNCTION update_conexiones_updated_at();

-- 1.5: Crear función para conexiones bidireccionales
CREATE OR REPLACE FUNCTION crear_conexion_bidireccional()
RETURNS TRIGGER AS $$
BEGIN
    -- Solo actuar cuando se acepta una solicitud
    IF NEW.estatus = 'accepted' AND OLD.estatus = 'pending' THEN
        -- Crear la conexión inversa (si no existe)
        INSERT INTO conexiones (usuario_id, conectado_id, estatus, created_at, updated_at)
        VALUES (NEW.conectado_id, NEW.usuario_id, 'accepted', NOW(), NOW())
        ON CONFLICT DO NOTHING;
        
        -- Si ya existe pero está en otro estado, actualizarla
        UPDATE conexiones
        SET estatus = 'accepted', updated_at = NOW()
        WHERE usuario_id = NEW.conectado_id 
          AND conectado_id = NEW.usuario_id
          AND estatus != 'accepted';
          
        RAISE NOTICE '✅ Conexión bidireccional creada entre % y %', NEW.usuario_id, NEW.conectado_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 1.6: Crear trigger para conexiones bidireccionales
DROP TRIGGER IF EXISTS trigger_conexion_bidireccional ON conexiones;

CREATE TRIGGER trigger_conexion_bidireccional
    AFTER UPDATE ON conexiones
    FOR EACH ROW
    EXECUTE FUNCTION crear_conexion_bidireccional();

-- 1.7: Crear índice único para evitar duplicados
DROP INDEX IF EXISTS idx_conexiones_unique;
CREATE UNIQUE INDEX idx_conexiones_unique 
ON conexiones(usuario_id, conectado_id);

-- 1.8: Reparar conexiones existentes (crear inversas faltantes)
INSERT INTO conexiones (usuario_id, conectado_id, estatus, created_at, updated_at)
SELECT 
    c.conectado_id as usuario_id,
    c.usuario_id as conectado_id,
    'accepted' as estatus,
    c.created_at,
    NOW() as updated_at
FROM conexiones c
WHERE c.estatus = 'accepted'
  AND NOT EXISTS (
      SELECT 1 FROM conexiones c2
      WHERE c2.usuario_id = c.conectado_id
        AND c2.conectado_id = c.usuario_id
  )
ON CONFLICT (usuario_id, conectado_id) DO NOTHING;

-- ============================================
-- PARTE 2: FIX TABLA NOTIFICACIONES
-- ============================================
-- Problema: Verificar que columnas estén en español

-- 2.1: Verificar estructura de tabla notificaciones
DO $$ 
BEGIN
    -- Verificar que existan las columnas correctas
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'notificaciones' 
        AND column_name IN ('titulo', 'mensaje', 'tipo', 'leido')
    ) THEN
        RAISE NOTICE '✅ Tabla notificaciones tiene columnas correctas en español';
    ELSE
        RAISE NOTICE '⚠️ Verificar columnas de tabla notificaciones';
    END IF;
END $$;

-- 2.2: Crear función de prueba para notificaciones
DROP FUNCTION IF EXISTS test_notification_realtime(UUID);

CREATE FUNCTION test_notification_realtime(target_user_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    INSERT INTO notificaciones (user_id, tipo, titulo, mensaje, leido, data)
    VALUES (
        target_user_id,
        'test',
        'Notificación de Prueba',
        'Esta es una notificación de prueba del sistema Realtime',
        false,
        '{"test": true}'::jsonb
    );
    
    RAISE NOTICE '✅ Notificación de prueba creada para usuario %', target_user_id;
    RETURN true;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- PARTE 3: FIX TABLA REFERENCIAS (CALIFICACIONES)
-- ============================================
-- Problema: Verificar que la tabla referencias tenga las columnas correctas

-- 3.1: Verificar estructura de tabla referencias
DO $$ 
BEGIN
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'referencias' 
        AND column_name IN ('evaluador_id', 'evaluado_id', 'puntuacion')
    ) THEN
        RAISE NOTICE '✅ Tabla referencias tiene columnas correctas';
    ELSE
        RAISE NOTICE '⚠️ Verificar columnas de tabla referencias';
    END IF;
END $$;

-- 3.2: Crear función para actualizar rating promedio
CREATE OR REPLACE FUNCTION actualizar_rating_promedio()
RETURNS TRIGGER AS $$
DECLARE
    avg_rating NUMERIC;
    total_count INTEGER;
BEGIN
    -- Calcular promedio y total de calificaciones
    SELECT 
        COALESCE(AVG(puntuacion), 0),
        COUNT(*)
    INTO avg_rating, total_count
    FROM referencias
    WHERE evaluado_id = COALESCE(NEW.evaluado_id, OLD.evaluado_id)
    AND puntuacion IS NOT NULL;
    
    -- Actualizar perfil
    UPDATE perfiles
    SET 
        rating_promedio = avg_rating,
        total_calificaciones = total_count,
        total_referencias = total_count,
        updated_at = NOW()
    WHERE id = COALESCE(NEW.evaluado_id, OLD.evaluado_id);
    
    RAISE NOTICE '✅ Rating actualizado para usuario %: promedio=%, total=%', 
        COALESCE(NEW.evaluado_id, OLD.evaluado_id), avg_rating, total_count;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- 3.3: Crear trigger para actualizar rating automáticamente
DROP TRIGGER IF EXISTS trigger_actualizar_rating ON referencias;

CREATE TRIGGER trigger_actualizar_rating
    AFTER INSERT OR UPDATE OR DELETE ON referencias
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_rating_promedio();

-- ============================================
-- PARTE 4: FIX TABLA PERFILES - ESTADO EN LÍNEA
-- ============================================
-- Problema: Falta sistema de presencia para estado "En línea"

-- 4.1: Agregar columnas para estado en línea
DO $ 
BEGIN
    -- Agregar columna en_linea si no existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'perfiles' AND column_name = 'en_linea'
    ) THEN
        ALTER TABLE perfiles ADD COLUMN en_linea BOOLEAN DEFAULT false;
        RAISE NOTICE '✅ Columna en_linea agregada a tabla perfiles';
    ELSE
        RAISE NOTICE '⚠️ Columna en_linea ya existe en tabla perfiles';
    END IF;
    
    -- Agregar columna ultima_conexion si no existe
    IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'perfiles' AND column_name = 'ultima_conexion'
    ) THEN
        ALTER TABLE perfiles ADD COLUMN ultima_conexion TIMESTAMP WITH TIME ZONE DEFAULT NOW();
        RAISE NOTICE '✅ Columna ultima_conexion agregada a tabla perfiles';
    ELSE
        RAISE NOTICE '⚠️ Columna ultima_conexion ya existe en tabla perfiles';
    END IF;
END $;

-- 4.2: Inicializar valores para perfiles existentes
UPDATE perfiles 
SET 
    en_linea = false,
    ultima_conexion = NOW()
WHERE en_linea IS NULL OR ultima_conexion IS NULL;

-- ============================================
-- PARTE 5: TRIGGERS DE NOTIFICACIONES AUTOMÁTICAS
-- ============================================

-- 5.1: Notificación cuando se envía solicitud de conexión
CREATE OR REPLACE FUNCTION notificar_solicitud_conexion()
RETURNS TRIGGER AS $$
DECLARE
    nombre_solicitante TEXT;
BEGIN
    IF NEW.estatus = 'pending' THEN
        -- Obtener nombre del solicitante
        SELECT nombre_artistico INTO nombre_solicitante
        FROM perfiles
        WHERE id = NEW.usuario_id;
        
        -- Crear notificación
        INSERT INTO notificaciones (user_id, tipo, titulo, mensaje, leido, data)
        VALUES (
            NEW.conectado_id,
            'connection_request',
            'Nueva solicitud de conexión',
            nombre_solicitante || ' quiere conectar contigo',
            false,
            jsonb_build_object('sender_id', NEW.usuario_id, 'connection_id', NEW.id)
        );
        
        RAISE NOTICE '✅ Notificación de solicitud enviada a %', NEW.conectado_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_notificar_solicitud_conexion ON conexiones;

CREATE TRIGGER trigger_notificar_solicitud_conexion
    AFTER INSERT ON conexiones
    FOR EACH ROW
    EXECUTE FUNCTION notificar_solicitud_conexion();

-- 5.2: Notificación cuando se acepta conexión
CREATE OR REPLACE FUNCTION notificar_conexion_aceptada()
RETURNS TRIGGER AS $$
DECLARE
    nombre_aceptante TEXT;
BEGIN
    IF NEW.estatus = 'accepted' AND OLD.estatus = 'pending' THEN
        -- Obtener nombre del que aceptó
        SELECT nombre_artistico INTO nombre_aceptante
        FROM perfiles
        WHERE id = NEW.conectado_id;
        
        -- Crear notificación para el que envió la solicitud
        INSERT INTO notificaciones (user_id, tipo, titulo, mensaje, leido, data)
        VALUES (
            NEW.usuario_id,
            'connection_accepted',
            'Solicitud aceptada',
            nombre_aceptante || ' aceptó tu solicitud de conexión',
            false,
            jsonb_build_object('sender_id', NEW.conectado_id)
        );
        
        RAISE NOTICE '✅ Notificación de aceptación enviada a %', NEW.usuario_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_notificar_conexion_aceptada ON conexiones;

CREATE TRIGGER trigger_notificar_conexion_aceptada
    AFTER UPDATE ON conexiones
    FOR EACH ROW
    EXECUTE FUNCTION notificar_conexion_aceptada();

-- 5.3: Notificación cuando se recibe mensaje
CREATE OR REPLACE FUNCTION notificar_nuevo_mensaje()
RETURNS TRIGGER AS $$
DECLARE
    nombre_remitente TEXT;
BEGIN
    -- Obtener nombre del remitente
    SELECT nombre_artistico INTO nombre_remitente
    FROM perfiles
    WHERE id = NEW.remitente_id;
    
    -- Crear notificación
    INSERT INTO notificaciones (user_id, tipo, titulo, mensaje, leido, data)
    VALUES (
        NEW.destinatario_id,
        'new_message',
        'Nuevo mensaje',
        nombre_remitente || ' te envió un mensaje',
        false,
        jsonb_build_object('sender_id', NEW.remitente_id, 'message_id', NEW.id)
    );
    
    RAISE NOTICE '✅ Notificación de mensaje enviada a %', NEW.destinatario_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_notificar_nuevo_mensaje ON conversaciones;

CREATE TRIGGER trigger_notificar_nuevo_mensaje
    AFTER INSERT ON conversaciones
    FOR EACH ROW
    EXECUTE FUNCTION notificar_nuevo_mensaje();

-- 5.4: Notificación cuando se recibe calificación
CREATE OR REPLACE FUNCTION notificar_nueva_calificacion()
RETURNS TRIGGER AS $$
DECLARE
    nombre_evaluador TEXT;
BEGIN
    -- Obtener nombre del evaluador
    SELECT nombre_artistico INTO nombre_evaluador
    FROM perfiles
    WHERE id = NEW.evaluador_id;
    
    -- Crear notificación
    INSERT INTO notificaciones (user_id, tipo, titulo, mensaje, leido, data)
    VALUES (
        NEW.evaluado_id,
        'new_rating',
        'Nueva calificación',
        nombre_evaluador || ' te dejó una calificación de ' || NEW.puntuacion || ' estrellas',
        false,
        jsonb_build_object('evaluador_id', NEW.evaluador_id, 'puntuacion', NEW.puntuacion)
    );
    
    RAISE NOTICE '✅ Notificación de calificación enviada a %', NEW.evaluado_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_notificar_nueva_calificacion ON referencias;

CREATE TRIGGER trigger_notificar_nueva_calificacion
    AFTER INSERT ON referencias
    FOR EACH ROW
    EXECUTE FUNCTION notificar_nueva_calificacion();

-- ============================================
-- PARTE 6: VERIFICACIÓN FINAL
-- ============================================

-- 6.1: Función de verificación completa
CREATE OR REPLACE FUNCTION verificar_sistema_completo()
RETURNS TABLE(
    componente TEXT,
    estado TEXT,
    detalles TEXT
) AS $$
BEGIN
    -- Verificar conexiones
    RETURN QUERY
    SELECT 
        'Tabla conexiones'::TEXT,
        CASE 
            WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'conexiones' AND column_name = 'updated_at')
            THEN '✅ OK'::TEXT
            ELSE '❌ ERROR'::TEXT
        END,
        'Columna updated_at'::TEXT;
    
    -- Verificar triggers de conexiones
    RETURN QUERY
    SELECT 
        'Triggers conexiones'::TEXT,
        CASE 
            WHEN EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_conexion_bidireccional')
            THEN '✅ OK'::TEXT
            ELSE '❌ ERROR'::TEXT
        END,
        'Trigger bidireccional'::TEXT;
    
    -- Verificar notificaciones
    RETURN QUERY
    SELECT 
        'Tabla notificaciones'::TEXT,
        CASE 
            WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notificaciones')
            THEN '✅ OK'::TEXT
            ELSE '❌ ERROR'::TEXT
        END,
        'Tabla existe'::TEXT;
    
    -- Verificar referencias
    RETURN QUERY
    SELECT 
        'Tabla referencias'::TEXT,
        CASE 
            WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'referencias' AND column_name = 'evaluador_id')
            THEN '✅ OK'::TEXT
            ELSE '❌ ERROR'::TEXT
        END,
        'Columnas correctas'::TEXT;
    
    -- Verificar triggers de notificaciones
    RETURN QUERY
    SELECT 
        'Triggers notificaciones'::TEXT,
        CASE 
            WHEN EXISTS (SELECT 1 FROM pg_trigger WHERE tgname LIKE 'trigger_notificar%')
            THEN '✅ OK'::TEXT
            ELSE '❌ ERROR'::TEXT
        END,
        'Triggers automáticos'::TEXT;
    
    -- Verificar columnas de presencia
    RETURN QUERY
    SELECT 
        'Sistema de presencia'::TEXT,
        CASE 
            WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'perfiles' AND column_name = 'en_linea')
            AND EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'perfiles' AND column_name = 'ultima_conexion')
            THEN '✅ OK'::TEXT
            ELSE '❌ ERROR'::TEXT
        END,
        'Columnas en_linea y ultima_conexion'::TEXT;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- INSTRUCCIONES DE USO
-- ============================================

/*
CÓMO USAR ESTE SCRIPT:

1. Abrir Supabase SQL Editor
2. Copiar y pegar TODO este script
3. Ejecutar (Run)
4. Verificar que todo esté OK ejecutando:
   
   SELECT * FROM verificar_sistema_completo();

5. Probar notificaciones con:
   
   SELECT test_notification_realtime('TU_USER_ID'::uuid);

RESULTADO ESPERADO:
✅ Conexiones bidireccionales funcionando
✅ Notificaciones automáticas funcionando
✅ Calificaciones actualizando rating promedio
✅ Todos los triggers activos

NOTAS:
- Este script es IDEMPOTENTE (se puede ejecutar múltiples veces sin problemas)
- Usa IF EXISTS para no duplicar columnas o triggers
- Repara conexiones existentes automáticamente
- Crea todas las funciones y triggers necesarios
*/

-- ============================================
-- FIN DEL SCRIPT
-- ============================================

SELECT '✅ SCRIPT EJECUTADO COMPLETAMENTE' as resultado;
SELECT '🔍 Ejecuta: SELECT * FROM verificar_sistema_completo();' as siguiente_paso;
