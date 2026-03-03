-- ============================================================================
-- QUERIES PRÁCTICAS - EJEMPLOS DE USO DE LA BASE DE DATOS
-- ============================================================================
-- Archivo: QUERIES_PRACTICAS.sql
-- Fecha: 22/01/2026
-- Descripción: Ejemplos reales de queries para las operaciones más comunes
-- 
-- ⚠️  ADVERTENCIA: Este archivo contiene EJEMPLOS con placeholders
-- ⚠️  NO ejecutar directamente - Reemplaza los UUIDs de ejemplo primero
-- ⚠️  Placeholders: 'user-uuid-here', 'usuario-a-uuid', etc.
-- 
-- ✅  Para verificar estructura, usa: VERIFICAR_ESTRUCTURA_REFERENCIAS.sql
-- ============================================================================

-- ============================================================================
-- 1. QUERIES: GESTIÓN DE PERFILES
-- ============================================================================

-- Query 1.1: Obtener perfil completo de un usuario
SELECT 
    p.id,
    p.nombre_artistico,
    p.bio,
    p.foto_perfil,
    p.ubicacion,
    p.rating_promedio,
    p.total_calificaciones,
    p.ranking_tipo,
    p.ranking_fecha_expiracion,
    r.puntuacion_final,
    r.badge_reputacion
FROM profiles p
LEFT JOIN puntuacion_reputacion r ON p.id = r.profile_id
WHERE p.id = 'user-uuid-here'
LIMIT 1;

-- Query 1.2: Actualizar perfil de usuario
UPDATE profiles 
SET 
    bio = 'Guitarrista profesional con 15 años de experiencia',
    ubicacion = 'Buenos Aires, Argentina',
    updated_at = CURRENT_TIMESTAMP
WHERE id = 'user-uuid-here'
RETURNING *;

-- Query 1.3: Obtener todos los instrumentos de un usuario
SELECT 
    pi.instrumento_id,
    i.nombre,
    pi.nivel,
    pi.años_experiencia,
    pi.es_principal
FROM perfiles_instrumentos pi
JOIN instrumentos i ON pi.instrumento_id = i.id
WHERE pi.profile_id = 'user-uuid-here'
ORDER BY pi.es_principal DESC, pi.nivel DESC;

-- Query 1.4: Agregar instrumento a un usuario
INSERT INTO perfiles_instrumentos 
(profile_id, instrumento_id, nivel, años_experiencia, es_principal)
VALUES 
('user-uuid-here', 1, 'avanzado', 15, TRUE)
ON CONFLICT (profile_id, instrumento_id) 
DO UPDATE SET 
    nivel = 'avanzado',
    años_experiencia = 15
RETURNING *;

-- Query 1.5: Marcar perfil como completo
UPDATE profiles 
SET perfil_completo = TRUE 
WHERE id = 'user-uuid-here';

-- ============================================================================
-- 2. QUERIES: PORTAFOLIO & MEDIA
-- ============================================================================

-- Query 2.1: Obtener todo el portafolio de un usuario
SELECT 
    tipo,
    COUNT(*) as cantidad,
    SUM(vistas) as total_vistas,
    SUM(descargas) as total_descargas
FROM portfolio_media
WHERE profile_id = 'user-uuid-here' 
    AND deleted_at IS NULL
GROUP BY tipo;

-- Query 2.2: Subir video al portafolio
INSERT INTO portfolio_media 
(profile_id, tipo, titulo, descripcion, url_recurso, duracion_segundos, tamaño_bytes, visibilidad)
VALUES 
(
    'user-uuid-here',
    'video',
    'Cover: Stairway to Heaven',
    'Mi versión de la famosa canción de Led Zeppelin',
    'https://cdn.oolale.app/videos/xxxxx.mp4',
    180,
    524288000,
    'publico'
)
RETURNING id, titulo, url_recurso;

-- Query 2.3: Subir audio al portafolio
INSERT INTO portfolio_media 
(profile_id, tipo, titulo, descripcion, url_recurso, duracion_segundos, visibilidad)
VALUES 
(
    'user-uuid-here',
    'audio',
    'Improvisación en guitarra - Jam Session',
    'Sesión de jam en Blues menor',
    'https://cdn.oolale.app/audios/xxxxx.mp3',
    300,
    'publico'
)
RETURNING id, titulo;

-- Query 2.4: Obtener media pública de un usuario
SELECT 
    id,
    tipo,
    titulo,
    url_recurso,
    duracion_segundos,
    vistas,
    descargas,
    created_at
FROM portfolio_media
WHERE profile_id = 'user-uuid-here' 
    AND visibilidad = 'publico'
    AND deleted_at IS NULL
ORDER BY created_at DESC;

-- Query 2.5: Incrementar vistas de un media
UPDATE portfolio_media 
SET vistas = vistas + 1 
WHERE id = 123
RETURNING vistas;

-- Query 2.6: Crear setlist
INSERT INTO setlists 
(profile_id, nombre, descripcion, numero_canciones)
VALUES 
(
    'user-uuid-here',
    'Mi setlist Rock Clásico',
    'Las mejores canciones de rock de los 70s y 80s',
    0
)
RETURNING id, nombre;

-- Query 2.7: Agregar canciones a un setlist
INSERT INTO canciones_setlist 
(setlist_id, numero_orden, nombre_cancion, artista_original, duracion_minutos, tonalidad, bpm)
VALUES 
(1, 1, 'Stairway to Heaven', 'Led Zeppelin', 8.02, 'Am', 82),
(1, 2, 'Black Dog', 'Led Zeppelin', 5.16, 'E', 120),
(1, 3, 'Whole Lotta Love', 'Led Zeppelin', 5.33, 'E', 95)
RETURNING setlist_id, numero_orden, nombre_cancion;

-- Query 2.8: Obtener todas las canciones de un setlist
SELECT 
    numero_orden,
    nombre_cancion,
    artista_original,
    duracion_minutos,
    tonalidad,
    bpm,
    notas_tecnicas
FROM canciones_setlist
WHERE setlist_id = 1
ORDER BY numero_orden;

-- Query 2.9: Actualizar duracion total del setlist
UPDATE setlists 
SET 
    numero_canciones = (SELECT COUNT(*) FROM canciones_setlist WHERE setlist_id = 1),
    duracion_total_minutos = (SELECT COALESCE(SUM(duracion_minutos), 0) FROM canciones_setlist WHERE setlist_id = 1)
WHERE id = 1
RETURNING nombre, numero_canciones, duracion_total_minutos;

-- ============================================================================
-- 3. QUERIES: CALIFICACIONES & REFERENCIAS
-- ============================================================================

-- Query 3.1: Calificar a un usuario (después de un evento)
INSERT INTO calificaciones 
(de_usuario_id, para_usuario_id, estrellas, comentario, tipo_interaccion, evento_id)
VALUES 
(
    'usuario-a-uuid',
    'usuario-b-uuid',
    5,
    'Excelente baterista, muy profesional y puntual. Lo contrataría en cualquier momento.',
    'evento',
    42
)
RETURNING id, estrellas, comentario;

-- Query 3.2: Obtener todas las calificaciones de un usuario
SELECT 
    c.estrellas,
    c.comentario,
    c.tipo_interaccion,
    c.created_at,
    p.nombre_artistico as de_usuario,
    p.foto_perfil
FROM calificaciones c
JOIN profiles p ON c.de_usuario_id = p.id
WHERE c.para_usuario_id = 'user-uuid-here'
ORDER BY c.created_at DESC;

-- Query 3.3: Obtener distribución de calificaciones
SELECT 
    estrellas,
    COUNT(*) as cantidad,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM calificaciones WHERE para_usuario_id = 'user-uuid-here'), 2) as porcentaje
FROM calificaciones
WHERE para_usuario_id = 'user-uuid-here'
GROUP BY estrellas
ORDER BY estrellas DESC;

-- Query 3.4: Dejar una referencia
INSERT INTO referencias 
(evaluador_id, evaluado_id, puntuacion, comentario, tipo_interaccion, verificado)
VALUES 
(
    'usuario-a-uuid',
    'usuario-b-uuid',
    5,
    'Trabajé con Juan en varias sesiones de estudio. Es un excelente músico con gran técnica y muy profesional.',
    'colaboracion',
    FALSE
)
RETURNING id, puntuacion, comentario;

-- Query 3.5: Obtener referencias de un usuario
SELECT 
    r.puntuacion,
    r.comentario,
    r.tipo_interaccion,
    r.verificado,
    r.created_at,
    p.nombre_artistico as evaluador,
    p.foto_perfil
FROM referencias r
JOIN profiles p ON r.evaluador_id = p.id
WHERE r.evaluado_id = 'user-uuid-here'
ORDER BY r.created_at DESC;

-- Query 3.6: Verificar una referencia (solo admin)
UPDATE referencias 
SET verificada = TRUE 
WHERE id = 1
RETURNING titulo, verificada;

-- Query 3.7: Marcar referencia como útil
UPDATE referencias 
SET util_count = util_count + 1 
WHERE id = 1
RETURNING titulo, util_count;

-- Query 3.8: Calcular puntuación de reputación
SELECT calcular_puntuacion_reputacion('user-uuid-here');

-- Query 3.9: Obtener puntuación de reputación actualizada
SELECT 
    profile_id,
    promedio_calificaciones,
    total_calificaciones,
    eventos_completados,
    eventos_cancelados,
    puntuacion_final,
    badge_reputacion
FROM puntuacion_reputacion
WHERE profile_id = 'user-uuid-here';

-- ============================================================================
-- 4. QUERIES: BLOQUEOS
-- ============================================================================

-- Query 4.1: Bloquear un usuario
SELECT bloquear_usuario(
    'usuario-a-uuid',
    'usuario-b-uuid',
    'Este usuario envía mensajes inapropiados constantemente'
);

-- Query 4.2: Obtener lista de usuarios bloqueados
SELECT 
    ub.id,
    ub.bloqueado_id,
    p.nombre_artistico,
    p.foto_perfil,
    ub.motivo_bloqueo,
    ub.razon,
    ub.bloqueado_en
FROM usuarios_bloqueados ub
JOIN profiles p ON ub.bloqueado_id = p.id
WHERE ub.usuario_id = 'user-uuid-here' 
    AND ub.activo = TRUE
ORDER BY ub.bloqueado_en DESC;

-- Query 4.3: Desbloquear un usuario
UPDATE usuarios_bloqueados 
SET 
    activo = FALSE,
    desbloqueado_en = CURRENT_TIMESTAMP
WHERE usuario_id = 'user-uuid-here' 
    AND bloqueado_id = 'bloqueado-uuid'
RETURNING bloqueado_id, desbloqueado_en;

-- Query 4.4: Verificar si estás bloqueado por alguien
SELECT COUNT(*) > 0 as estoy_bloqueado
FROM usuarios_bloqueados
WHERE bloqueado_id = 'mi-uuid' 
    AND usuario_id = 'otro-usuario-uuid'
    AND activo = TRUE;

-- Query 4.5: Obtener total de usuarios bloqueados
SELECT COUNT(*) as total_bloqueados
FROM usuarios_bloqueados
WHERE usuario_id = 'user-uuid-here' AND activo = TRUE;

-- ============================================================================
-- 5. QUERIES: REPORTES
-- ============================================================================

-- Query 5.1: Reportar un usuario (completo)
INSERT INTO reportes 
(reportante_id, usuario_reportado_id, contenido_tipo, categoria, descripcion, urgencia, estado)
VALUES 
(
    'usuario-a-uuid',
    'usuario-b-uuid',
    'usuario',
    'acoso',
    'Este usuario me envía mensajes constantemente después de rechazar su solicitud de conexión. Los mensajes son de naturaleza sexual inapropiada.',
    'importante',
    'pendiente'
)
RETURNING id, categoria, urgencia, estado;

-- Query 5.2: Reportar desde mensaje
INSERT INTO reportes 
(reportante_id, usuario_reportado_id, contenido_tipo, contenido_id, categoria, descripcion, urgencia)
VALUES 
(
    'usuario-a-uuid',
    'usuario-b-uuid',
    'mensaje',
    12345,
    'contenido_sexual',
    'El usuario envió este mensaje inapropiado en el chat privado',
    'critica'
)
RETURNING id;

-- Query 5.3: Obtener reportes pendientes
SELECT 
    r.id,
    r.categoria,
    r.urgencia,
    r.descripcion,
    p1.nombre_artistico as reportante,
    p2.nombre_artistico as reportado,
    r.created_at
FROM reportes r
LEFT JOIN profiles p1 ON r.reportante_id = p1.id
LEFT JOIN profiles p2 ON r.usuario_reportado_id = p2.id
WHERE r.estado IN ('pendiente', 'en_revision')
ORDER BY 
    CASE r.urgencia 
        WHEN 'critica' THEN 1
        WHEN 'importante' THEN 2
        ELSE 3
    END,
    r.created_at;

-- Query 5.4: Asignar reporte a un moderador
UPDATE reportes 
SET 
    asignado_a = 'admin-uuid',
    estado = 'en_revision',
    updated_at = CURRENT_TIMESTAMP
WHERE id = 1
RETURNING id, asignado_a, estado;

-- Query 5.5: Confirmar reporte y tomar acción
UPDATE reportes 
SET 
    estado = 'confirmado',
    accion_tomada = 'advertencia',
    fecha_accion = CURRENT_TIMESTAMP,
    notas_internas = 'Se envió advertencia al usuario. Segunda violación en 30 días.',
    updated_at = CURRENT_TIMESTAMP
WHERE id = 1
RETURNING id, estado, accion_tomada;

-- Query 5.6: Obtener historial de cambios de un reporte
SELECT 
    h.accion,
    h.estado_anterior,
    h.estado_nuevo,
    h.descripcion,
    p.nombre_artistico as cambiado_por,
    h.created_at
FROM historial_reportes h
LEFT JOIN profiles p ON h.cambiado_por = p.id
WHERE h.reporte_id = 1
ORDER BY h.created_at DESC;

-- Query 5.7: Obtener estadísticas de reportes
SELECT 
    estado,
    categoria,
    COUNT(*) as cantidad,
    AVG(EXTRACT(DAY FROM (updated_at - created_at))) as dias_promedio_resolucion
FROM reportes
GROUP BY estado, categoria
ORDER BY cantidad DESC;

-- Query 5.8: Ver reportes de un usuario reportado
SELECT 
    r.id,
    r.categoria,
    r.estado,
    r.accion_tomada,
    COUNT(*) OVER () as total_reportes_contra_este_usuario
FROM reportes r
WHERE r.usuario_reportado_id = 'usuario-uuid'
ORDER BY r.created_at DESC;

-- ============================================================================
-- 6. QUERIES: SISTEMA TOP & PREMIUM
-- ============================================================================

-- Query 6.1: Procesar renovación de ranking (TOP #1)
SELECT procesar_renovacion_ranking('user-uuid-here', 'top1');

-- Query 6.2: Registrar pago de TOP
INSERT INTO pagos_ranking 
(profile_id, nivel, monto, moneda, duracion_dias, metodo_pago, transaccion_id, estado)
VALUES 
(
    'user-uuid-here',
    'top1',
    99.00,
    'USD',
    30,
    'mercadopago',
    'MP-TXN-12345678',
    'completado'
)
RETURNING id, nivel, monto, estado;

-- Query 6.3: Obtener ranking actual de un usuario
SELECT 
    rt.profile_id,
    rt.nivel,
    rt.fecha_inicio,
    rt.fecha_expiracion,
    rt.renovaciones_count,
    DATEDIFF(DAY, CURRENT_TIMESTAMP, rt.fecha_expiracion) as dias_restantes,
    rt.multiplicador_alcance,
    rt.contacto_visible,
    rt.estadisticas_accesibles
FROM ranking_top rt
WHERE rt.profile_id = 'user-uuid-here';

-- Query 6.4: Listar todos los usuarios TOP activos
SELECT 
    p.id,
    p.nombre_artistico,
    p.foto_perfil,
    p.ubicacion,
    p.rating_promedio,
    rt.nivel,
    rt.fecha_expiracion,
    DATEDIFF(DAY, CURRENT_TIMESTAMP, rt.fecha_expiracion) as dias_restantes
FROM ranking_top rt
JOIN profiles p ON rt.profile_id = p.id
WHERE rt.fecha_expiracion > CURRENT_TIMESTAMP
ORDER BY rt.nivel ASC, p.rating_promedio DESC;

-- Query 6.5: Registrar beneficio diario de TOP
INSERT INTO beneficios_top 
(ranking_top_id, fecha, perfil_visitas, contactos_nuevos, solicitudes_eventos, ofertas_trabajo)
VALUES 
(
    1,
    CURRENT_DATE,
    45,
    3,
    2,
    1
)
ON CONFLICT (ranking_top_id, fecha) 
DO UPDATE SET 
    perfil_visitas = 45,
    contactos_nuevos = 3,
    solicitudes_eventos = 2,
    ofertas_trabajo = 1;

-- Query 6.6: Ver beneficios de TOP en últimos 30 días
SELECT 
    fecha,
    perfil_visitas,
    contactos_nuevos,
    solicitudes_eventos,
    ofertas_trabajo,
    (perfil_visitas + contactos_nuevos + solicitudes_eventos + ofertas_trabajo) as total_interacciones
FROM beneficios_top
WHERE ranking_top_id = 1 
    AND fecha >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY fecha DESC;

-- Query 6.7: Calcular ROI de TOP para un usuario
SELECT 
    rt.nivel,
    COUNT(DISTINCT bt.fecha) as dias_activo,
    SUM(bt.perfil_visitas) as total_visitas,
    SUM(bt.contactos_nuevos) as total_contactos,
    SUM(bt.solicitudes_eventos) as total_solicitudes,
    SUM(bt.ofertas_trabajo) as total_ofertas,
    pr.monto as costo,
    ROUND((SUM(bt.ofertas_trabajo) * 500) / pr.monto, 2) as roi_estimado -- asumiendo $500 por oferta
FROM ranking_top rt
LEFT JOIN beneficios_top bt ON rt.id = bt.ranking_top_id
LEFT JOIN pagos_ranking pr ON rt.profile_id = pr.profile_id AND pr.estado = 'completado'
WHERE rt.profile_id = 'user-uuid-here'
GROUP BY rt.nivel, pr.monto;

-- ============================================================================
-- 7. QUERIES: BÚSQUEDAS Y FILTROS
-- ============================================================================

-- Query 7.1: Buscar músicos por instrumento y ubicación
SELECT 
    p.id,
    p.nombre_artistico,
    p.foto_perfil,
    p.bio,
    p.ubicacion,
    p.rating_promedio,
    rt.nivel as ranking,
    ARRAY_AGG(DISTINCT g.nombre) as generos,
    ARRAY_AGG(DISTINCT i.nombre) as instrumentos
FROM profiles p
LEFT JOIN perfiles_generos pg ON p.id = pg.profile_id
LEFT JOIN generos g ON pg.genero_id = g.id
LEFT JOIN perfiles_instrumentos pi ON p.id = pi.profile_id
LEFT JOIN instrumentos i ON pi.instrumento_id = i.id
LEFT JOIN ranking_top rt ON p.id = rt.profile_id AND rt.fecha_expiracion > CURRENT_TIMESTAMP
WHERE p.ubicacion ILIKE '%Buenos Aires%'
    AND EXISTS (
        SELECT 1 FROM perfiles_instrumentos pi2
        JOIN instrumentos i2 ON pi2.instrumento_id = i2.id
        WHERE pi2.profile_id = p.id AND i2.nombre = 'Guitarra'
    )
GROUP BY p.id, rt.nivel
ORDER BY rt.nivel DESC, p.rating_promedio DESC
LIMIT 20;

-- Query 7.2: Buscar usuarios con mejor reputación
SELECT * FROM usuarios_top_reputacion LIMIT 10;

-- Query 7.3: Ver usuarios destacados (TOP activo)
SELECT * FROM usuarios_destacados;

-- Query 7.4: Buscar por género musical
SELECT 
    p.id,
    p.nombre_artistico,
    COUNT(DISTINCT pi.instrumento_id) as cantidad_instrumentos,
    p.rating_promedio
FROM profiles p
LEFT JOIN perfiles_generos pg ON p.id = pg.profile_id
LEFT JOIN generos g ON pg.genero_id = g.id
LEFT JOIN perfiles_instrumentos pi ON p.id = pi.profile_id
WHERE g.nombre = 'Rock'
    AND p.open_to_work = TRUE
GROUP BY p.id
ORDER BY p.rating_promedio DESC;

-- ============================================================================
-- 8. QUERIES: CONEXIONES
-- ============================================================================

-- Query 8.1: Enviar solicitud de conexión
INSERT INTO conexiones 
(usuario_id, conexion_id, estado, quien_solicito)
VALUES 
('usuario-a-uuid', 'usuario-b-uuid', 'pendiente', 'usuario-a-uuid')
RETURNING id, estado;

-- Query 8.2: Aceptar solicitud de conexión
UPDATE conexiones 
SET 
    estado = 'aceptada',
    fecha_aceptacion = CURRENT_TIMESTAMP
WHERE usuario_id IN ('usuario-a-uuid', 'usuario-b-uuid')
    AND conexion_id IN ('usuario-a-uuid', 'usuario-b-uuid')
    AND estado = 'pendiente'
RETURNING usuario_id, conexion_id, estado;

-- Query 8.3: Obtener conexiones activas
SELECT 
    CASE 
        WHEN usuario_id = 'user-uuid-here' THEN conexion_id 
        ELSE usuario_id 
    END as conexion_uuid,
    p.nombre_artistico,
    p.foto_perfil,
    p.rating_promedio,
    c.fecha_aceptacion
FROM conexiones c
JOIN profiles p ON (CASE WHEN c.usuario_id = 'user-uuid-here' THEN p.id = c.conexion_id ELSE p.id = c.usuario_id END)
WHERE (c.usuario_id = 'user-uuid-here' OR c.conexion_id = 'user-uuid-here')
    AND c.estado = 'aceptada'
ORDER BY c.fecha_aceptacion DESC;

-- ============================================================================
-- 9. QUERIES: REPORTES Y ESTADÍSTICAS
-- ============================================================================

-- Query 9.1: Obtener estadísticas generales
SELECT * FROM estadisticas_usuarios;

-- Query 9.2: Usuarios por ranking
SELECT 
    ranking_tipo,
    COUNT(*) as cantidad,
    ROUND(AVG(rating_promedio), 2) as rating_promedio
FROM profiles
WHERE ranking_tipo IS NOT NULL
GROUP BY ranking_tipo
ORDER BY cantidad DESC;

-- Query 9.3: Top 10 usuarios más descargados (media)
SELECT 
    p.nombre_artistico,
    COUNT(pm.id) as total_media,
    SUM(pm.descargas) as total_descargas,
    SUM(pm.vistas) as total_vistas
FROM profiles p
LEFT JOIN portfolio_media pm ON p.id = pm.profile_id AND pm.deleted_at IS NULL
GROUP BY p.id
HAVING SUM(pm.descargas) > 0
ORDER BY total_descargas DESC
LIMIT 10;

-- Query 9.4: Distribución de ranking
SELECT 
    nivel,
    COUNT(*) as cantidad,
    ROUND(AVG(DATEDIFF(DAY, CURRENT_TIMESTAMP, fecha_expiracion)), 0) as dias_promedio_activo
FROM ranking_top
WHERE fecha_expiracion > CURRENT_TIMESTAMP
GROUP BY nivel;

-- ============================================================================
-- FIN DE QUERIES PRÁCTICAS
-- ============================================================================
