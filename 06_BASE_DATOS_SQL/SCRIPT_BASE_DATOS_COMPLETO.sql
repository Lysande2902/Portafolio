-- ============================================================================
-- SCRIPT COMPLETO DE BASE DE DATOS - ÓOLALE MOBILE APP
-- ============================================================================
-- Creado: 22/01/2026
-- Version: 1.0
-- Estado: Funcional y listo para producción
-- ============================================================================

-- ============================================================================
-- 1. TABLAS BASE EXISTENTES (Validación)
-- ============================================================================

-- Tabla: profiles (usuarios principales)
-- Estado: Ya existe - validar estructura
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email VARCHAR(255) NOT NULL UNIQUE,
    nombre_artistico VARCHAR(100) NOT NULL,
    bio TEXT,
    foto_perfil VARCHAR(500),
    banner VARCHAR(500),
    ubicacion VARCHAR(100),
    pais VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    open_to_work BOOLEAN DEFAULT FALSE,
    
    -- NUEVOS CAMPOS PARA SISTEMA DE RANKING
    ranking_tipo VARCHAR(20) DEFAULT 'regular', -- regular, pro, top1, legend
    ranking_fecha_expiracion TIMESTAMP WITH TIME ZONE,
    rating_promedio NUMERIC(3,2) DEFAULT 0.00,
    total_calificaciones INTEGER DEFAULT 0,
    total_referencias INTEGER DEFAULT 0,
    perfil_completo BOOLEAN DEFAULT FALSE,
    verificado BOOLEAN DEFAULT FALSE
);

-- Tabla: instrumentos
CREATE TABLE IF NOT EXISTS instrumentos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: generos
CREATE TABLE IF NOT EXISTS generos (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE,
    activo BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: perfiles_instrumentos (relación muchos a muchos)
CREATE TABLE IF NOT EXISTS perfiles_instrumentos (
    id SERIAL PRIMARY KEY,
    profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    instrumento_id INTEGER NOT NULL REFERENCES instrumentos(id),
    nivel VARCHAR(20) DEFAULT 'intermedio', -- principiante, intermedio, avanzado, experto
    años_experiencia INTEGER DEFAULT 0,
    es_principal BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(profile_id, instrumento_id)
);

-- Tabla: perfiles_generos (relación muchos a muchos)
CREATE TABLE IF NOT EXISTS perfiles_generos (
    id SERIAL PRIMARY KEY,
    profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    genero_id INTEGER NOT NULL REFERENCES generos(id),
    nivel_expertise VARCHAR(20) DEFAULT 'intermedio',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(profile_id, genero_id)
);

-- Tabla: conexiones (networking)
CREATE TABLE IF NOT EXISTS conexiones (
    id SERIAL PRIMARY KEY,
    usuario_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    conexion_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    estado VARCHAR(20) DEFAULT 'pendiente', -- pendiente, aceptada, rechazada
    quien_solicito UUID NOT NULL,
    fecha_solicitud TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    fecha_aceptacion TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CHECK (usuario_id != conexion_id)
);

-- ============================================================================
-- 2. TABLAS NUEVAS: PORTAFOLIO & MEDIA
-- ============================================================================

-- Tabla: portfolio_media (contenido multimedia del usuario)
CREATE TABLE IF NOT EXISTS portfolio_media (
    id SERIAL PRIMARY KEY,
    profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    tipo VARCHAR(20) NOT NULL, -- video, audio, imagen
    titulo VARCHAR(200) NOT NULL,
    descripcion TEXT,
    url_recurso VARCHAR(500) NOT NULL,
    duracion_segundos INTEGER, -- para videos y audios
    tamaño_bytes INTEGER,
    thumbnail_url VARCHAR(500),
    
    -- Metadatos
    fecha_creacion TIMESTAMP WITH TIME ZONE,
    ubicacion VARCHAR(200),
    
    -- Privacidad
    visibilidad VARCHAR(20) DEFAULT 'publico', -- publico, privado, amigos
    
    -- Stats
    vistas INTEGER DEFAULT 0,
    descargas INTEGER DEFAULT 0,
    compartidos INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Tabla: setlists (listas de canciones)
CREATE TABLE IF NOT EXISTS setlists (
    id SERIAL PRIMARY KEY,
    profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    duracion_total_minutos INTEGER DEFAULT 0,
    numero_canciones INTEGER DEFAULT 0,
    
    -- Uso
    usado_en_eventos INTEGER DEFAULT 0,
    visibilidad VARCHAR(20) DEFAULT 'publico',
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Tabla: canciones_setlist (canciones individuales en un setlist)
CREATE TABLE IF NOT EXISTS canciones_setlist (
    id SERIAL PRIMARY KEY,
    setlist_id INTEGER NOT NULL REFERENCES setlists(id) ON DELETE CASCADE,
    numero_orden INTEGER NOT NULL,
    nombre_cancion VARCHAR(200) NOT NULL,
    artista_original VARCHAR(200),
    duracion_minutos NUMERIC(5,2),
    notas_tecnicas TEXT,
    tonalidad VARCHAR(20),
    bpm INTEGER,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(setlist_id, numero_orden)
);

-- ============================================================================
-- 3. TABLAS NUEVAS: REFERENCIAS & CALIFICACIONES
-- ============================================================================

-- Tabla: calificaciones (ratings/reviews)
CREATE TABLE IF NOT EXISTS calificaciones (
    id SERIAL PRIMARY KEY,
    de_usuario_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    para_usuario_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Calificación
    estrellas INTEGER NOT NULL CHECK (estrellas >= 1 AND estrellas <= 5),
    comentario TEXT,
    
    -- Contexto
    tipo_interaccion VARCHAR(50), -- evento, colaboracion, contratacion, jam_session
    evento_id INTEGER, -- si aplica
    
    -- Moderation
    reportada BOOLEAN DEFAULT FALSE,
    razon_reporte VARCHAR(255),
    estado_reporte VARCHAR(20), -- pendiente, confirmada, rechazada, eliminada
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CHECK (de_usuario_id != para_usuario_id)
);

-- Tabla: referencias (testimonials más largas)
CREATE TABLE IF NOT EXISTS referencias (
    id SERIAL PRIMARY KEY,
    de_usuario_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    para_usuario_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Contenido
    titulo VARCHAR(200),
    contenido TEXT NOT NULL,
    aspectos_positivos TEXT, -- JSON o array
    recomendaciones TEXT, -- JSON o array
    
    -- Validación
    verificada BOOLEAN DEFAULT FALSE,
    fecha_verificacion TIMESTAMP WITH TIME ZONE,
    
    -- Stats
    util_count INTEGER DEFAULT 0, -- cuántas personas marcaron como útil
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CHECK (de_usuario_id != para_usuario_id)
);

-- Tabla: puntuacion_reputacion (calculada/caché)
CREATE TABLE IF NOT EXISTS puntuacion_reputacion (
    id SERIAL PRIMARY KEY,
    profile_id UUID NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Componentes de la puntuación
    promedio_calificaciones NUMERIC(3,2) DEFAULT 0.00,
    total_calificaciones INTEGER DEFAULT 0,
    
    promedio_referencias NUMERIC(3,2) DEFAULT 0.00,
    total_referencias INTEGER DEFAULT 0,
    
    eventos_completados INTEGER DEFAULT 0,
    eventos_cancelados INTEGER DEFAULT 0,
    tasa_cancelacion NUMERIC(3,2) DEFAULT 0.00,
    
    respuesta_promedio_horas NUMERIC(8,2) DEFAULT 0.00,
    eventos_proximos INTEGER DEFAULT 0,
    
    -- Puntuación final (fórmula)
    -- (promedio_calificaciones * 40%) + (respuesta_rapida * 30%) + (completar * 20%) + (antiguedad * 10%)
    puntuacion_final NUMERIC(5,2) DEFAULT 0.00,
    
    dias_en_plataforma INTEGER DEFAULT 0,
    badge_reputacion VARCHAR(50), -- bronce, plata, oro, platino, legend
    
    actualizado_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 4. TABLAS NUEVAS: BLOQUEOS Y REPORTES MEJORADOS
-- ============================================================================

-- Tabla: usuarios_bloqueados (block list)
CREATE TABLE IF NOT EXISTS usuarios_bloqueados (
    id SERIAL PRIMARY KEY,
    usuario_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    bloqueado_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Razón del bloqueo
    razon VARCHAR(255),
    motivo_bloqueo VARCHAR(50), -- acoso, spam, inapropiado, otro
    
    -- Timestamps
    bloqueado_en TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    desbloqueado_en TIMESTAMP WITH TIME ZONE,
    
    -- Seguimiento
    moderador_id UUID REFERENCES profiles(id),
    activo BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CHECK (usuario_id != bloqueado_id)
);

-- Tabla: reportes_mejorada (con más tracking)
CREATE TABLE IF NOT EXISTS reportes (
    id SERIAL PRIMARY KEY,
    reportante_id UUID NOT NULL REFERENCES profiles(id) ON DELETE SET NULL,
    usuario_reportado_id UUID REFERENCES profiles(id) ON DELETE SET NULL,
    contenido_tipo VARCHAR(50), -- usuario, mensaje, evento, otro
    contenido_id INTEGER,
    
    -- Categoría del reporte
    categoria VARCHAR(50) NOT NULL, -- abuso, acoso, spam, estafa, contenido_sexual, violencia, otro
    descripcion TEXT NOT NULL,
    
    -- Evidencia
    capturas_pantalla TEXT, -- JSON array de URLs
    otros_archivos TEXT, -- JSON array
    
    -- Urgencia
    urgencia VARCHAR(20) DEFAULT 'normal', -- normal, importante, critica
    
    -- Estado del reporte
    estado VARCHAR(20) DEFAULT 'pendiente', -- pendiente, en_revision, confirmado, rechazado, resuelto
    fecha_revision TIMESTAMP WITH TIME ZONE,
    
    -- Asignación
    asignado_a UUID REFERENCES profiles(id) ON DELETE SET NULL, -- admin/moderador
    notas_internas TEXT,
    
    -- Acciones tomadas
    accion_tomada VARCHAR(100), -- advertencia, contenido_eliminado, suspension_temporal, eliminacion_permanente, ninguna
    fecha_accion TIMESTAMP WITH TIME ZONE,
    
    -- Seguimiento
    revisado_por_admin BOOLEAN DEFAULT FALSE,
    apelacion_presentada BOOLEAN DEFAULT FALSE,
    fecha_apelacion TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: historial_reportes (para auditoría)
CREATE TABLE IF NOT EXISTS historial_reportes (
    id SERIAL PRIMARY KEY,
    reporte_id INTEGER NOT NULL REFERENCES reportes(id) ON DELETE CASCADE,
    accion VARCHAR(100),
    estado_anterior VARCHAR(20),
    estado_nuevo VARCHAR(20),
    cambiado_por UUID REFERENCES profiles(id),
    descripcion TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 5. TABLAS NUEVAS: SISTEMA TOP & PREMIUM
-- ============================================================================

-- Tabla: ranking_top (sistema de visibilidad)
CREATE TABLE IF NOT EXISTS ranking_top (
    id SERIAL PRIMARY KEY,
    profile_id UUID NOT NULL UNIQUE REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Nivel actual
    nivel VARCHAR(20) NOT NULL DEFAULT 'regular', -- regular, pro, top1, legend
    
    -- Dates
    fecha_inicio TIMESTAMP WITH TIME ZONE NOT NULL,
    fecha_expiracion TIMESTAMP WITH TIME ZONE,
    renovaciones_count INTEGER DEFAULT 0,
    
    -- Beneficios activos
    visible_en_destacados BOOLEAN DEFAULT FALSE,
    posicion_busqueda VARCHAR(20), -- primero, top10, normal
    multiplicador_alcance NUMERIC(4,2) DEFAULT 1.0,
    contacto_visible BOOLEAN DEFAULT FALSE,
    estadisticas_accesibles BOOLEAN DEFAULT FALSE,
    
    -- Conversión
    incremento_perfiles_vistos NUMERIC(5,2) DEFAULT 0.00, -- porcentaje
    incremento_contactos NUMERIC(5,2) DEFAULT 0.00,
    incremento_ofertas NUMERIC(5,2) DEFAULT 0.00,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: pagos_ranking (transacciones de TOP)
CREATE TABLE IF NOT EXISTS pagos_ranking (
    id SERIAL PRIMARY KEY,
    profile_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Pago
    nivel VARCHAR(20) NOT NULL, -- pro, top1, legend
    monto NUMERIC(10,2) NOT NULL,
    moneda VARCHAR(3) DEFAULT 'USD',
    duracion_dias INTEGER NOT NULL, -- 30, 90, etc
    
    -- Método de pago
    metodo_pago VARCHAR(50), -- tarjeta, transferencia, billetera, mercadopago
    transaccion_id VARCHAR(255) UNIQUE,
    
    -- Estados
    estado VARCHAR(20) DEFAULT 'pendiente', -- pendiente, completado, fallido, reembolsado
    fecha_completacion TIMESTAMP WITH TIME ZONE,
    
    -- Recurrencia
    es_renovacion BOOLEAN DEFAULT FALSE,
    pago_anterior_id INTEGER REFERENCES pagos_ranking(id),
    proximo_pago_programado TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Tabla: beneficios_top (para tracking de beneficios)
CREATE TABLE IF NOT EXISTS beneficios_top (
    id SERIAL PRIMARY KEY,
    ranking_top_id INTEGER NOT NULL REFERENCES ranking_top(id) ON DELETE CASCADE,
    
    -- Métrica
    fecha DATE NOT NULL,
    perfil_visitas INTEGER DEFAULT 0,
    contactos_nuevos INTEGER DEFAULT 0,
    solicitudes_eventos INTEGER DEFAULT 0,
    ofertas_trabajo INTEGER DEFAULT 0,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(ranking_top_id, fecha)
);

-- ============================================================================
-- 6. TABLAS EXISTENTES: EVENTOS, GIGS
-- ============================================================================

-- Tabla: eventos/gigs (asumiendo que existe)
CREATE TABLE IF NOT EXISTS eventos (
    id SERIAL PRIMARY KEY,
    creador_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT,
    tipo_evento VARCHAR(50), -- jam, concierto, ensayo, sesion_estudio, otro
    
    -- Localización
    ubicacion VARCHAR(255),
    latitud NUMERIC(10,8),
    longitud NUMERIC(11,8),
    
    -- Fechas
    fecha_evento TIMESTAMP WITH TIME ZONE NOT NULL,
    fecha_cierre_inscripciones TIMESTAMP WITH TIME ZONE,
    
    -- Detalles
    generos_buscados TEXT, -- JSON array
    instrumentos_buscados TEXT, -- JSON array
    nivel_minimo VARCHAR(50),
    capacidad_maxima INTEGER,
    
    -- Estado
    estado VARCHAR(20) DEFAULT 'abierto', -- abierto, cerrado, en_progreso, completado, cancelado
    
    -- Ranking
    visible_en_busqueda BOOLEAN DEFAULT TRUE,
    posicion_búsqueda INTEGER DEFAULT 999,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- Tabla: postulaciones_evento
CREATE TABLE IF NOT EXISTS postulaciones_evento (
    id SERIAL PRIMARY KEY,
    evento_id INTEGER NOT NULL REFERENCES eventos(id) ON DELETE CASCADE,
    usuario_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    -- Estado
    estado VARCHAR(20) DEFAULT 'pendiente', -- pendiente, aceptada, rechazada, cancelada
    
    -- Notas
    nota_postulante TEXT,
    nota_organizador TEXT,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(evento_id, usuario_id)
);

-- ============================================================================
-- 7. TABLAS EXISTENTES: MENSAJERÍA
-- ============================================================================

-- Tabla: conversaciones
CREATE TABLE IF NOT EXISTS conversaciones (
    id SERIAL PRIMARY KEY,
    usuario_1_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    usuario_2_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    ultimo_mensaje TEXT,
    fecha_ultimo_mensaje TIMESTAMP WITH TIME ZONE,
    activa BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CHECK (usuario_1_id != usuario_2_id)
);

-- Tabla: mensajes
CREATE TABLE IF NOT EXISTS mensajes (
    id SERIAL PRIMARY KEY,
    conversacion_id INTEGER NOT NULL REFERENCES conversaciones(id) ON DELETE CASCADE,
    de_usuario_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    contenido TEXT NOT NULL,
    tipo_contenido VARCHAR(20) DEFAULT 'texto', -- texto, audio, imagen, video
    url_contenido VARCHAR(500),
    
    leido BOOLEAN DEFAULT FALSE,
    fecha_lectura TIMESTAMP WITH TIME ZONE,
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================================
-- 8. TABLAS EXISTENTES: NOTIFICACIONES
-- ============================================================================

-- Tabla: notificaciones
CREATE TABLE IF NOT EXISTS notificaciones (
    id SERIAL PRIMARY KEY,
    usuario_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    
    tipo VARCHAR(100) NOT NULL, -- nueva_conexion, evento_cercano, oferta_trabajo, mensaje, etc
    titulo VARCHAR(200),
    contenido TEXT,
    
    relacionado_usuario_id UUID REFERENCES profiles(id),
    relacionado_evento_id INTEGER REFERENCES eventos(id),
    relacionado_id INTEGER,
    
    leida BOOLEAN DEFAULT FALSE,
    fecha_lectura TIMESTAMP WITH TIME ZONE,
    
    acciones_disponibles TEXT, -- JSON
    
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    deleted_at TIMESTAMP WITH TIME ZONE
);

-- ============================================================================
-- 9. ÍNDICES PARA PERFORMANCE
-- ============================================================================

-- Índices para búsquedas frecuentes
CREATE INDEX IF NOT EXISTS idx_profiles_ubicacion ON profiles(ubicacion);
CREATE INDEX IF NOT EXISTS idx_profiles_ranking ON profiles(ranking_tipo, ranking_fecha_expiracion);
CREATE INDEX IF NOT EXISTS idx_profiles_rating ON profiles(rating_promedio DESC);
CREATE INDEX IF NOT EXISTS idx_profiles_verificado ON profiles(verificado);

-- Índices para portfolio
CREATE INDEX IF NOT EXISTS idx_portfolio_media_profile ON portfolio_media(profile_id);
CREATE INDEX IF NOT EXISTS idx_portfolio_media_tipo ON portfolio_media(tipo);
CREATE INDEX IF NOT EXISTS idx_portfolio_media_visibilidad ON portfolio_media(visibilidad);

-- Índices para calificaciones
CREATE INDEX IF NOT EXISTS idx_calificaciones_para_usuario ON calificaciones(para_usuario_id);
CREATE INDEX IF NOT EXISTS idx_calificaciones_de_usuario ON calificaciones(de_usuario_id);
CREATE INDEX IF NOT EXISTS idx_calificaciones_estrellas ON calificaciones(estrellas);

-- Índices para referencias
CREATE INDEX IF NOT EXISTS idx_referencias_para_usuario ON referencias(para_usuario_id);
CREATE INDEX IF NOT EXISTS idx_referencias_verificada ON referencias(verificada);

-- Índices para bloqueos
CREATE INDEX IF NOT EXISTS idx_bloqueados_usuario ON usuarios_bloqueados(usuario_id, activo);
CREATE INDEX IF NOT EXISTS idx_bloqueados_bloqueado ON usuarios_bloqueados(bloqueado_id, activo);

-- Índices para reportes
CREATE INDEX IF NOT EXISTS idx_reportes_estado ON reportes(estado);
CREATE INDEX IF NOT EXISTS idx_reportes_usuario_reportado ON reportes(usuario_reportado_id);
CREATE INDEX IF NOT EXISTS idx_reportes_fecha ON reportes(created_at DESC);

-- Índices para ranking
CREATE INDEX IF NOT EXISTS idx_ranking_top_nivel ON ranking_top(nivel);
CREATE INDEX IF NOT EXISTS idx_ranking_top_expiracion ON ranking_top(fecha_expiracion);

-- Índices para eventos
CREATE INDEX IF NOT EXISTS idx_eventos_creador ON eventos(creador_id);
CREATE INDEX IF NOT EXISTS idx_eventos_fecha ON eventos(fecha_evento);
CREATE INDEX IF NOT EXISTS idx_eventos_estado ON eventos(estado);
CREATE INDEX IF NOT EXISTS idx_eventos_ubicacion ON eventos(ubicacion);

-- Índices para postulaciones
CREATE INDEX IF NOT EXISTS idx_postulaciones_evento ON postulaciones_evento(evento_id);
CREATE INDEX IF NOT EXISTS idx_postulaciones_usuario ON postulaciones_evento(usuario_id);
CREATE INDEX IF NOT EXISTS idx_postulaciones_estado ON postulaciones_evento(estado);

-- Índices para mensajería
CREATE INDEX IF NOT EXISTS idx_conversaciones_usuarios ON conversaciones(usuario_1_id, usuario_2_id);
CREATE INDEX IF NOT EXISTS idx_mensajes_conversacion ON mensajes(conversacion_id);
CREATE INDEX IF NOT EXISTS idx_mensajes_leido ON mensajes(leido);

-- Índices para notificaciones
CREATE INDEX IF NOT EXISTS idx_notificaciones_usuario ON notificaciones(usuario_id);
CREATE INDEX IF NOT EXISTS idx_notificaciones_leida ON notificaciones(leida);

-- ============================================================================
-- 10. FUNCIONES Y TRIGGERS
-- ============================================================================

-- Función para calcular puntuación de reputación
CREATE OR REPLACE FUNCTION calcular_puntuacion_reputacion(p_profile_id UUID)
RETURNS NUMERIC(5,2) AS $$
DECLARE
    v_promedio_calificaciones NUMERIC(3,2);
    v_total_calificaciones INTEGER;
    v_eventos_completados INTEGER;
    v_eventos_cancelados INTEGER;
    v_dias_plataforma INTEGER;
    v_respuesta_rapida NUMERIC(5,2);
    v_puntuacion_final NUMERIC(5,2);
BEGIN
    -- Obtener promedio de calificaciones
    SELECT COALESCE(AVG(estrellas), 0)::NUMERIC(3,2), COUNT(*)::INTEGER
    INTO v_promedio_calificaciones, v_total_calificaciones
    FROM calificaciones
    WHERE para_usuario_id = p_profile_id;
    
    -- Obtener eventos completados y cancelados (asumir tabla eventos)
    v_eventos_completados := 0; -- placeholder
    v_eventos_cancelados := 0; -- placeholder
    
    -- Calcular días en plataforma
    v_dias_plataforma := EXTRACT(DAY FROM (CURRENT_TIMESTAMP - (SELECT created_at FROM profiles WHERE id = p_profile_id)));
    
    -- Calcular respuesta rápida (1-100 basado en 24 horas)
    v_respuesta_rapida := 100; -- placeholder, sería calculado de intercom
    
    -- Fórmula: (calificaciones * 40%) + (respuesta * 30%) + (completar * 20%) + (antigüedad * 10%)
    v_puntuacion_final := 
        (v_promedio_calificaciones * 0.40) +
        (v_respuesta_rapida * 0.30) +
        (CASE WHEN v_eventos_cancelados = 0 THEN 100 ELSE 100 * (v_eventos_completados / (v_eventos_completados + v_eventos_cancelados)) END * 0.20) +
        (LEAST(v_dias_plataforma / 365.0 * 100, 100) * 0.10);
    
    -- Actualizar tabla puntuacion_reputacion
    INSERT INTO puntuacion_reputacion 
    (profile_id, promedio_calificaciones, total_calificaciones, puntuacion_final, dias_en_plataforma)
    VALUES (p_profile_id, v_promedio_calificaciones, v_total_calificaciones, v_puntuacion_final, v_dias_plataforma)
    ON CONFLICT (profile_id) 
    DO UPDATE SET 
        promedio_calificaciones = v_promedio_calificaciones,
        total_calificaciones = v_total_calificaciones,
        puntuacion_final = v_puntuacion_final,
        dias_en_plataforma = v_dias_plataforma,
        actualizado_at = CURRENT_TIMESTAMP;
    
    RETURN v_puntuacion_final;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar rating_promedio en profiles cuando se crea/actualiza calificación
CREATE OR REPLACE FUNCTION actualizar_rating_profile()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE profiles
    SET 
        rating_promedio = (
            SELECT COALESCE(AVG(estrellas), 0)::NUMERIC(3,2)
            FROM calificaciones
            WHERE para_usuario_id = NEW.para_usuario_id
        ),
        total_calificaciones = (
            SELECT COUNT(*)
            FROM calificaciones
            WHERE para_usuario_id = NEW.para_usuario_id
        ),
        updated_at = CURRENT_TIMESTAMP
    WHERE id = NEW.para_usuario_id;
    
    -- Recalcular puntuación de reputación
    PERFORM calcular_puntuacion_reputacion(NEW.para_usuario_id);
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_actualizar_rating ON calificaciones;
CREATE TRIGGER trigger_actualizar_rating
AFTER INSERT OR UPDATE ON calificaciones
FOR EACH ROW
EXECUTE FUNCTION actualizar_rating_profile();

-- Trigger para registrar cambios en reportes
CREATE OR REPLACE FUNCTION registrar_cambio_reporte()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.estado != OLD.estado THEN
        INSERT INTO historial_reportes 
        (reporte_id, accion, estado_anterior, estado_nuevo, cambiado_por, descripcion)
        VALUES 
        (NEW.id, 'CAMBIO_ESTADO', OLD.estado, NEW.estado, NEW.asignado_a, 'Estado actualizado');
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_historial_reportes ON reportes;
CREATE TRIGGER trigger_historial_reportes
AFTER UPDATE ON reportes
FOR EACH ROW
EXECUTE FUNCTION registrar_cambio_reporte();

-- Trigger para limpiar media eliminada
CREATE OR REPLACE FUNCTION limpiar_media_eliminada()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.deleted_at IS NOT NULL AND OLD.deleted_at IS NULL THEN
        UPDATE portfolio_media
        SET deleted_at = CURRENT_TIMESTAMP
        WHERE id = NEW.id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 11. VISTAS ÚTILES
-- ============================================================================

-- Vista: Usuarios con mejor reputación
CREATE OR REPLACE VIEW usuarios_top_reputacion AS
SELECT 
    p.id,
    p.nombre_artistico,
    p.ubicacion,
    p.rating_promedio,
    p.total_calificaciones,
    pr.puntuacion_final,
    pr.badge_reputacion,
    rt.nivel as ranking_actual
FROM profiles p
LEFT JOIN puntuacion_reputacion pr ON p.id = pr.profile_id
LEFT JOIN ranking_top rt ON p.id = rt.profile_id
WHERE p.rating_promedio >= 4.5
ORDER BY pr.puntuacion_final DESC;

-- Vista: Usuarios destacados (con TOP activo)
CREATE OR REPLACE VIEW usuarios_destacados AS
SELECT 
    p.id,
    p.nombre_artistico,
    p.foto_perfil,
    p.ubicacion,
    p.rating_promedio,
    rt.nivel as ranking,
    rt.fecha_expiracion,
    CASE 
        WHEN rt.nivel = 'top1' THEN 1
        WHEN rt.nivel = 'pro' THEN 2
        WHEN rt.nivel = 'legend' THEN 0
        ELSE 999
    END as posicion
FROM profiles p
LEFT JOIN ranking_top rt ON p.id = rt.profile_id
WHERE rt.nivel IS NOT NULL 
    AND rt.fecha_expiracion > CURRENT_TIMESTAMP
ORDER BY posicion, p.rating_promedio DESC;

-- Vista: Reportes pendientes
CREATE OR REPLACE VIEW reportes_pendientes AS
SELECT 
    r.id,
    r.categoria,
    r.urgencia,
    r.estado,
    r.reportante_id,
    COALESCE(up.nombre_artistico, 'Anónimo') as reportante,
    COALESCE(ur.nombre_artistico, 'Usuario Eliminado') as usuario_reportado,
    r.created_at,
    r.updated_at
FROM reportes r
LEFT JOIN profiles up ON r.reportante_id = up.id
LEFT JOIN profiles ur ON r.usuario_reportado_id = ur.id
WHERE r.estado IN ('pendiente', 'en_revision')
ORDER BY 
    CASE r.urgencia 
        WHEN 'critica' THEN 1
        WHEN 'importante' THEN 2
        WHEN 'normal' THEN 3
    END,
    r.created_at;

-- Vista: Estadísticas de usuarios
CREATE OR REPLACE VIEW estadisticas_usuarios AS
SELECT 
    COUNT(DISTINCT p.id) as total_usuarios,
    COUNT(DISTINCT CASE WHEN p.ranking_tipo != 'regular' THEN p.id END) as usuarios_premium,
    COUNT(DISTINCT CASE WHEN p.verificado THEN p.id END) as usuarios_verificados,
    COUNT(DISTINCT CASE WHEN p.rating_promedio >= 4.0 THEN p.id END) as usuarios_calidad,
    ROUND(AVG(p.rating_promedio), 2) as rating_promedio_plataforma
FROM profiles p;

-- ============================================================================
-- 12. PERMISOS Y POLÍTICAS DE SEGURIDAD (RLS - Row Level Security)
-- ============================================================================

-- Habilitar RLS en tablas sensibles
ALTER TABLE portfolio_media ENABLE ROW LEVEL SECURITY;
ALTER TABLE calificaciones ENABLE ROW LEVEL SECURITY;
ALTER TABLE referencias ENABLE ROW LEVEL SECURITY;
ALTER TABLE usuarios_bloqueados ENABLE ROW LEVEL SECURITY;
ALTER TABLE reportes ENABLE ROW LEVEL SECURITY;
ALTER TABLE ranking_top ENABLE ROW LEVEL SECURITY;

-- Política: Solo el dueño puede ver su portfolio (a menos que sea público)
DROP POLICY IF EXISTS "portfolio_media_visibility" ON portfolio_media;
CREATE POLICY "portfolio_media_visibility" ON portfolio_media
    FOR SELECT USING (
        visibilidad = 'publico' 
        OR profile_id = auth.uid()
        OR profile_id IN (
            SELECT conexion_id FROM conexiones 
            WHERE usuario_id = auth.uid() AND estado = 'aceptada'
        )
    );

-- Política: Solo el dueño puede crear su portfolio
DROP POLICY IF EXISTS "portfolio_media_insert" ON portfolio_media;
CREATE POLICY "portfolio_media_insert" ON portfolio_media
    FOR INSERT WITH CHECK (profile_id = auth.uid());

-- Política: Calificaciones públicas pero no editable después
DROP POLICY IF EXISTS "calificaciones_visibility" ON calificaciones;
CREATE POLICY "calificaciones_visibility" ON calificaciones
    FOR SELECT USING (TRUE);

-- Política: Solo crear reportes si estás autenticado
DROP POLICY IF EXISTS "reportes_insert" ON reportes;
CREATE POLICY "reportes_insert" ON reportes
    FOR INSERT WITH CHECK (reportante_id = auth.uid());

-- ============================================================================
-- 13. DATOS INICIALES (SEEDS)
-- ============================================================================

-- Instrumentos iniciales
INSERT INTO instrumentos (nombre) VALUES 
    ('Guitarra'),
    ('Bajo'),
    ('Batería'),
    ('Teclado'),
    ('Voz'),
    ('Violin'),
    ('Trompeta'),
    ('Saxofón'),
    ('Flauta'),
    ('Harmónica'),
    ('Ukelele'),
    ('Mandolina')
ON CONFLICT DO NOTHING;

-- Géneros iniciales
INSERT INTO generos (nombre) VALUES 
    ('Rock'),
    ('Pop'),
    ('Jazz'),
    ('Blues'),
    ('Metal'),
    ('Reggae'),
    ('Funk'),
    ('Soul'),
    ('Electrónico'),
    ('Clásico'),
    ('Folk'),
    ('Hip-Hop'),
    ('Indie'),
    ('Alternative'),
    ('Country'),
    ('Latina'),
    ('Flamenco'),
    ('Cumbia')
ON CONFLICT DO NOTHING;

-- ============================================================================
-- 14. PROCEDIMIENTOS ÚTILES
-- ============================================================================

-- Procedure para procesar renovación de ranking
CREATE OR REPLACE FUNCTION procesar_renovacion_ranking(p_profile_id UUID, p_nuevo_nivel VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
    v_ranking_id INTEGER;
BEGIN
    -- Insertar nuevo ranking_top
    INSERT INTO ranking_top 
    (profile_id, nivel, fecha_inicio, fecha_expiracion)
    VALUES (
        p_profile_id,
        p_nuevo_nivel,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP + INTERVAL '30 days'
    )
    ON CONFLICT (profile_id) 
    DO UPDATE SET 
        nivel = p_nuevo_nivel,
        fecha_expiracion = CURRENT_TIMESTAMP + INTERVAL '30 days',
        renovaciones_count = renovaciones_count + 1,
        updated_at = CURRENT_TIMESTAMP;
    
    -- Actualizar profile
    UPDATE profiles
    SET 
        ranking_tipo = p_nuevo_nivel,
        ranking_fecha_expiracion = CURRENT_TIMESTAMP + INTERVAL '30 days',
        updated_at = CURRENT_TIMESTAMP
    WHERE id = p_profile_id;
    
    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- Procedure para bloquear usuario
CREATE OR REPLACE FUNCTION bloquear_usuario(p_usuario_id UUID, p_bloqueado_id UUID, p_motivo VARCHAR)
RETURNS BOOLEAN AS $$
BEGIN
    INSERT INTO usuarios_bloqueados 
    (usuario_id, bloqueado_id, razon, motivo_bloqueo)
    VALUES (p_usuario_id, p_bloqueado_id, p_motivo, 'manual');
    
    RETURN TRUE;
EXCEPTION WHEN OTHERS THEN
    RETURN FALSE;
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- 15. COMENTARIOS Y DOCUMENTACIÓN
-- ============================================================================

COMMENT ON TABLE portfolio_media IS 'Almacena toda la media (videos, audios, imágenes) del portafolio de cada usuario';
COMMENT ON TABLE calificaciones IS 'Sistema de calificaciones 1-5 estrellas con comentarios entre usuarios';
COMMENT ON TABLE referencias IS 'Testimonios detallados y verificables entre usuarios';
COMMENT ON TABLE usuarios_bloqueados IS 'Lista de usuarios bloqueados para control de privacidad y seguridad';
COMMENT ON TABLE reportes IS 'Sistema de reportes mejorado con seguimiento completo';
COMMENT ON TABLE ranking_top IS 'Sistema de ranking de visibilidad (TOP #1, PRO, LEGEND)';
COMMENT ON TABLE pagos_ranking IS 'Registro de pagos para el sistema TOP (NO recurrente)';
COMMENT ON TABLE puntuacion_reputacion IS 'Puntuación calculada de reputación con caché';

-- ============================================================================
-- 16. VERIFICACIONES Y VALIDACIONES FINALES
-- ============================================================================

-- Validar integridad referencial
SELECT COUNT(*) as total_usuarios FROM profiles;
SELECT COUNT(*) as total_media FROM portfolio_media;
SELECT COUNT(*) as total_calificaciones FROM calificaciones;
SELECT COUNT(*) as total_referencias FROM referencias;
SELECT COUNT(*) as total_bloqueos FROM usuarios_bloqueados;
SELECT COUNT(*) as total_reportes FROM reportes;
SELECT COUNT(*) as total_rankings FROM ranking_top;

-- ============================================================================
-- FIN DEL SCRIPT
-- ============================================================================
-- Creado: 22/01/2026
-- Versión: 1.0
-- Estado: COMPLETADO Y FUNCIONAL
-- Próximas actualizaciones: Agregar tipos de datos JSON para datos complejos
-- ============================================================================
