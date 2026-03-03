-- ============================================
-- FIX SUPABASE SIMPLE - OOLALE MOBILE
-- ============================================
-- Script simplificado compatible con Supabase SQL Editor
-- Fecha: 6 de Febrero, 2026
-- ============================================

-- PARTE 1: Agregar columnas a tabla perfiles
ALTER TABLE perfiles ADD COLUMN IF NOT EXISTS en_linea BOOLEAN DEFAULT false;
ALTER TABLE perfiles ADD COLUMN IF NOT EXISTS ultima_conexion TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Inicializar valores
UPDATE perfiles 
SET 
    en_linea = false,
    ultima_conexion = NOW()
WHERE en_linea IS NULL OR ultima_conexion IS NULL;

-- PARTE 2: Agregar columna updated_at a conexiones
ALTER TABLE conexiones ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Actualizar registros existentes
UPDATE conexiones 
SET updated_at = created_at 
WHERE updated_at IS NULL;

-- PARTE 3: Crear función para actualizar updated_at
CREATE OR REPLACE FUNCTION update_conexiones_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- PARTE 4: Crear trigger para updated_at
DROP TRIGGER IF EXISTS trigger_update_conexiones_updated_at ON conexiones;
CREATE TRIGGER trigger_update_conexiones_updated_at
    BEFORE UPDATE ON conexiones
    FOR EACH ROW
    EXECUTE FUNCTION update_conexiones_updated_at();

-- PARTE 5: Crear función para conexiones bidireccionales
CREATE OR REPLACE FUNCTION crear_conexion_bidireccional()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.estatus = 'accepted' AND OLD.estatus = 'pending' THEN
        INSERT INTO conexiones (usuario_id, conectado_id, estatus, created_at, updated_at)
        VALUES (NEW.conectado_id, NEW.usuario_id, 'accepted', NOW(), NOW())
        ON CONFLICT DO NOTHING;
        
        UPDATE conexiones
        SET estatus = 'accepted', updated_at = NOW()
        WHERE usuario_id = NEW.conectado_id 
          AND conectado_id = NEW.usuario_id
          AND estatus != 'accepted';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- PARTE 6: Crear trigger para conexiones bidireccionales
DROP TRIGGER IF EXISTS trigger_conexion_bidireccional ON conexiones;
CREATE TRIGGER trigger_conexion_bidireccional
    AFTER UPDATE ON conexiones
    FOR EACH ROW
    EXECUTE FUNCTION crear_conexion_bidireccional();

-- PARTE 7: Crear índice único
DROP INDEX IF EXISTS idx_conexiones_unique;
CREATE UNIQUE INDEX idx_conexiones_unique ON conexiones(usuario_id, conectado_id);

-- PARTE 8: Reparar conexiones existentes
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

-- PARTE 9: Función de prueba para notificaciones
CREATE OR REPLACE FUNCTION test_notification_realtime(target_user_id UUID)
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
    RETURN true;
END;
$$ LANGUAGE plpgsql;

-- PARTE 10: Función para actualizar rating promedio
CREATE OR REPLACE FUNCTION actualizar_rating_promedio()
RETURNS TRIGGER AS $$
DECLARE
    avg_rating NUMERIC;
    total_count INTEGER;
BEGIN
    SELECT 
        COALESCE(AVG(puntuacion), 0),
        COUNT(*)
    INTO avg_rating, total_count
    FROM referencias
    WHERE evaluado_id = COALESCE(NEW.evaluado_id, OLD.evaluado_id)
    AND puntuacion IS NOT NULL;
    
    UPDATE perfiles
    SET 
        rating_promedio = avg_rating,
        total_calificaciones = total_count,
        total_referencias = total_count,
        updated_at = NOW()
    WHERE id = COALESCE(NEW.evaluado_id, OLD.evaluado_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- PARTE 11: Trigger para actualizar rating
DROP TRIGGER IF EXISTS trigger_actualizar_rating ON referencias;
CREATE TRIGGER trigger_actualizar_rating
    AFTER INSERT OR UPDATE OR DELETE ON referencias
    FOR EACH ROW
    EXECUTE FUNCTION actualizar_rating_promedio();

-- PARTE 12: Notificación de solicitud de conexión
CREATE OR REPLACE FUNCTION notificar_solicitud_conexion()
RETURNS TRIGGER AS $$
DECLARE
    nombre_solicitante TEXT;
BEGIN
    IF NEW.estatus = 'pending' THEN
        SELECT nombre_artistico INTO nombre_solicitante
        FROM perfiles
        WHERE id = NEW.usuario_id;
        
        INSERT INTO notificaciones (user_id, tipo, titulo, mensaje, leido, data)
        VALUES (
            NEW.conectado_id,
            'connection_request',
            'Nueva solicitud de conexión',
            nombre_solicitante || ' quiere conectar contigo',
            false,
            jsonb_build_object('sender_id', NEW.usuario_id, 'connection_id', NEW.id)
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_notificar_solicitud_conexion ON conexiones;
CREATE TRIGGER trigger_notificar_solicitud_conexion
    AFTER INSERT ON conexiones
    FOR EACH ROW
    EXECUTE FUNCTION notificar_solicitud_conexion();

-- PARTE 13: Notificación de conexión aceptada
CREATE OR REPLACE FUNCTION notificar_conexion_aceptada()
RETURNS TRIGGER AS $$
DECLARE
    nombre_aceptante TEXT;
BEGIN
    IF NEW.estatus = 'accepted' AND OLD.estatus = 'pending' THEN
        SELECT nombre_artistico INTO nombre_aceptante
        FROM perfiles
        WHERE id = NEW.conectado_id;
        
        INSERT INTO notificaciones (user_id, tipo, titulo, mensaje, leido, data)
        VALUES (
            NEW.usuario_id,
            'connection_accepted',
            'Solicitud aceptada',
            nombre_aceptante || ' aceptó tu solicitud de conexión',
            false,
            jsonb_build_object('sender_id', NEW.conectado_id)
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_notificar_conexion_aceptada ON conexiones;
CREATE TRIGGER trigger_notificar_conexion_aceptada
    AFTER UPDATE ON conexiones
    FOR EACH ROW
    EXECUTE FUNCTION notificar_conexion_aceptada();

-- PARTE 14: Notificación de nuevo mensaje
CREATE OR REPLACE FUNCTION notificar_nuevo_mensaje()
RETURNS TRIGGER AS $$
DECLARE
    nombre_remitente TEXT;
BEGIN
    SELECT nombre_artistico INTO nombre_remitente
    FROM perfiles
    WHERE id = NEW.remitente_id;
    
    INSERT INTO notificaciones (user_id, tipo, titulo, mensaje, leido, data)
    VALUES (
        NEW.destinatario_id,
        'new_message',
        'Nuevo mensaje',
        nombre_remitente || ' te envió un mensaje',
        false,
        jsonb_build_object('sender_id', NEW.remitente_id, 'message_id', NEW.id)
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_notificar_nuevo_mensaje ON conversaciones;
CREATE TRIGGER trigger_notificar_nuevo_mensaje
    AFTER INSERT ON conversaciones
    FOR EACH ROW
    EXECUTE FUNCTION notificar_nuevo_mensaje();

-- PARTE 15: Notificación de nueva calificación
CREATE OR REPLACE FUNCTION notificar_nueva_calificacion()
RETURNS TRIGGER AS $$
DECLARE
    nombre_evaluador TEXT;
BEGIN
    SELECT nombre_artistico INTO nombre_evaluador
    FROM perfiles
    WHERE id = NEW.evaluador_id;
    
    INSERT INTO notificaciones (user_id, tipo, titulo, mensaje, leido, data)
    VALUES (
        NEW.evaluado_id,
        'new_rating',
        'Nueva calificación',
        nombre_evaluador || ' te dejó una calificación de ' || NEW.puntuacion || ' estrellas',
        false,
        jsonb_build_object('evaluador_id', NEW.evaluador_id, 'puntuacion', NEW.puntuacion)
    );
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_notificar_nueva_calificacion ON referencias;
CREATE TRIGGER trigger_notificar_nueva_calificacion
    AFTER INSERT ON referencias
    FOR EACH ROW
    EXECUTE FUNCTION notificar_nueva_calificacion();

-- PARTE 16: Función de verificación
CREATE OR REPLACE FUNCTION verificar_sistema_completo()
RETURNS TABLE(
    componente TEXT,
    estado TEXT,
    detalles TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        'Tabla conexiones'::TEXT,
        CASE 
            WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'conexiones' AND column_name = 'updated_at')
            THEN '✅ OK'::TEXT
            ELSE '❌ ERROR'::TEXT
        END,
        'Columna updated_at'::TEXT;
    
    RETURN QUERY
    SELECT 
        'Triggers conexiones'::TEXT,
        CASE 
            WHEN EXISTS (SELECT 1 FROM pg_trigger WHERE tgname = 'trigger_conexion_bidireccional')
            THEN '✅ OK'::TEXT
            ELSE '❌ ERROR'::TEXT
        END,
        'Trigger bidireccional'::TEXT;
    
    RETURN QUERY
    SELECT 
        'Tabla notificaciones'::TEXT,
        CASE 
            WHEN EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'notificaciones')
            THEN '✅ OK'::TEXT
            ELSE '❌ ERROR'::TEXT
        END,
        'Tabla existe'::TEXT;
    
    RETURN QUERY
    SELECT 
        'Tabla referencias'::TEXT,
        CASE 
            WHEN EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'referencias' AND column_name = 'evaluador_id')
            THEN '✅ OK'::TEXT
            ELSE '❌ ERROR'::TEXT
        END,
        'Columnas correctas'::TEXT;
    
    RETURN QUERY
    SELECT 
        'Triggers notificaciones'::TEXT,
        CASE 
            WHEN EXISTS (SELECT 1 FROM pg_trigger WHERE tgname LIKE 'trigger_notificar%')
            THEN '✅ OK'::TEXT
            ELSE '❌ ERROR'::TEXT
        END,
        'Triggers automáticos'::TEXT;
    
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
-- VERIFICACIÓN FINAL
-- ============================================

SELECT '✅ SCRIPT EJECUTADO COMPLETAMENTE' as resultado;
SELECT '🔍 Ejecuta: SELECT * FROM verificar_sistema_completo();' as siguiente_paso;
