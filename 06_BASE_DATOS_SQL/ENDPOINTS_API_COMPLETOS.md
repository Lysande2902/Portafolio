// ============================================================================
// API ENDPOINTS - JAMCONNECT / ÓOLALE MOBILE
// ============================================================================
// Documentación completa de todos los endpoints del backend
// Versión: 1.0 - Creado: 22/01/2026

/**
 * BASE URL: http://localhost:3001/api/v1
 * Authentication: Bearer Token en header Authorization
 * Content-Type: application/json
 */

// ============================================================================
// 1. AUTENTICACIÓN
// ============================================================================

POST /auth/register
Body: {
  email: string (required)
  password: string (required, min 8 chars)
  nombre_artistico: string (required)
  pais: string (optional)
  foto_perfil: string (optional, URL)
}
Response: {
  success: boolean
  user: { id, email, nombre_artistico, created_at }
  token: string
  refreshToken: string
}

POST /auth/login
Body: {
  email: string (required)
  password: string (required)
}
Response: {
  success: boolean
  user: { id, email, nombre_artistico, ranking_tipo, rating_promedio }
  token: string
  refreshToken: string
  expiresIn: number (seconds)
}

POST /auth/refresh-token
Body: {
  refreshToken: string (required)
}
Response: {
  token: string
  refreshToken: string
  expiresIn: number
}

POST /auth/logout
Headers: Authorization: Bearer token
Response: { success: boolean }

POST /auth/forgot-password
Body: { email: string }
Response: { success: boolean, message: string }

POST /auth/reset-password
Body: {
  token: string (from email)
  newPassword: string
}
Response: { success: boolean }

// ============================================================================
// 2. PERFILES (USERS)
// ============================================================================

GET /profiles/me
Headers: Authorization: Bearer token
Response: {
  id: UUID
  email: string
  nombre_artistico: string
  bio: string
  foto_perfil: string
  banner: string
  ubicacion: string
  pais: string
  ranking_tipo: string (regular|pro|top1|legend)
  rating_promedio: number
  total_calificaciones: number
  total_referencias: number
  perfil_completo: boolean
  verificado: boolean
  open_to_work: boolean
  instrumentos: Array<{ id, nombre, nivel, es_principal }>
  generos: Array<{ id, nombre, nivel_expertise }>
  created_at: timestamp
  updated_at: timestamp
}

PUT /profiles/me
Headers: Authorization: Bearer token
Body: {
  nombre_artistico?: string
  bio?: string
  foto_perfil?: string
  banner?: string
  ubicacion?: string
  pais?: string
  open_to_work?: boolean
}
Response: { success: boolean, profile: {...} }

DELETE /profiles/me
Headers: Authorization: Bearer token
Body: { password: string (for confirmation) }
Response: { success: boolean, message: string }

GET /profiles/:userId
Response: {
  id: UUID
  nombre_artistico: string
  bio: string
  foto_perfil: string
  banner: string
  ubicacion: string
  pais: string
  rating_promedio: number
  total_calificaciones: number
  total_referencias: number
  ranking_tipo: string
  instrumento: Array<{...}>
  generos: Array<{...}>
  reputacion_badge: string
  verified: boolean
}

GET /profiles/search
Query: {
  q?: string (búsqueda por nombre)
  ubicacion?: string
  genero?: string
  instrumento?: string
  nivel?: string
  solo_verificados?: boolean
  page?: number
  limit?: number (default 20, max 100)
}
Response: {
  total: number
  page: number
  limit: number
  data: Array<{...}>
}

// ============================================================================
// 3. INSTRUMENTOS Y GÉNEROS
// ============================================================================

GET /instrumentos
Query: { activo?: boolean }
Response: Array<{ id: number, nombre: string, activo: boolean }>

GET /generos
Query: { activo?: boolean }
Response: Array<{ id: number, nombre: string, activo: boolean }>

POST /profiles/me/instrumentos
Headers: Authorization: Bearer token
Body: {
  instrumento_id: number
  nivel: string (principiante|intermedio|avanzado|experto)
  años_experiencia: number
  es_principal: boolean
}
Response: { success: boolean, instrumento: {...} }

PUT /profiles/me/instrumentos/:instrumentId
Headers: Authorization: Bearer token
Body: { nivel?, años_experiencia?, es_principal? }
Response: { success: boolean, instrumento: {...} }

DELETE /profiles/me/instrumentos/:instrumentId
Headers: Authorization: Bearer token
Response: { success: boolean }

POST /profiles/me/generos
Headers: Authorization: Bearer token
Body: {
  genero_id: number
  nivel_expertise: string
}
Response: { success: boolean, genero: {...} }

DELETE /profiles/me/generos/:generoId
Headers: Authorization: Bearer token
Response: { success: boolean }

// ============================================================================
// 4. PORTAFOLIO & MEDIA
// ============================================================================

POST /portfolio/media
Headers: Authorization: Bearer token
Body: FormData {
  archivo: File (mp3, mp4, jpg, etc)
  tipo: string (video|audio|imagen)
  titulo: string
  descripcion?: string
  visibilidad?: string (publico|privado|amigos)
  duracion_segundos?: number
}
Response: {
  id: number
  profile_id: UUID
  tipo: string
  titulo: string
  url_recurso: string
  thumbnail_url?: string
  vistas: number
  created_at: timestamp
}

GET /portfolio/media/me
Headers: Authorization: Bearer token
Query: { tipo?: string, page?: number, limit?: number }
Response: {
  total: number
  data: Array<{...}>
}

GET /portfolio/media/:userId
Query: { tipo?: string, page?: number, limit?: number }
Response: {
  total: number
  data: Array<{...}>
}

PUT /portfolio/media/:mediaId
Headers: Authorization: Bearer token
Body: { titulo?, descripcion?, visibilidad? }
Response: { success: boolean, media: {...} }

DELETE /portfolio/media/:mediaId
Headers: Authorization: Bearer token
Response: { success: boolean }

GET /portfolio/media/:mediaId/info
Response: {
  id: number
  titulo: string
  vistas: number
  descargas: number
  compartidos: number
  url_recurso: string
}

// ============================================================================
// 5. SETLISTS
// ============================================================================

POST /setlists
Headers: Authorization: Bearer token
Body: {
  nombre: string
  descripcion?: string
  canciones: Array<{
    numero_orden: number
    nombre_cancion: string
    artista_original?: string
    duracion_minutos?: number
    tonalidad?: string
    bpm?: number
    notas_tecnicas?: string
  }>
}
Response: { id: number, nombre: string, numero_canciones: number, created_at }

GET /setlists/me
Headers: Authorization: Bearer token
Query: { page?: number, limit?: number }
Response: { total: number, data: Array<{...}> }

GET /setlists/:userId
Query: { page?: number, limit?: number }
Response: { total: number, data: Array<{...}> }

GET /setlists/:setlistId
Response: {
  id: number
  nombre: string
  descripcion: string
  numero_canciones: number
  duracion_total_minutos: number
  canciones: Array<{...}>
  usado_en_eventos: number
}

PUT /setlists/:setlistId
Headers: Authorization: Bearer token
Body: { nombre?, descripcion?, canciones? }
Response: { success: boolean, setlist: {...} }

DELETE /setlists/:setlistId
Headers: Authorization: Bearer token
Response: { success: boolean }

// ============================================================================
// 6. CALIFICACIONES (RATINGS)
// ============================================================================

POST /calificaciones
Headers: Authorization: Bearer token
Body: {
  para_usuario_id: UUID
  estrellas: number (1-5)
  comentario: string
  tipo_interaccion?: string (evento|colaboracion|contratacion|jam_session)
  evento_id?: number
}
Response: {
  id: number
  estrellas: number
  comentario: string
  created_at: timestamp
}

GET /calificaciones/:userId
Query: { page?: number, limit?: number, ordenar?: string }
Response: {
  total: number
  promedio: number
  distribucion: { 5: number, 4: number, 3: number, 2: number, 1: number }
  data: Array<{
    id: number
    de_usuario: { id, nombre_artistico, foto_perfil }
    estrellas: number
    comentario: string
    tipo_interaccion: string
    created_at: timestamp
  }>
}

PUT /calificaciones/:calificacionId
Headers: Authorization: Bearer token
Body: { estrellas?, comentario? }
Response: { success: boolean, calificacion: {...} }

DELETE /calificaciones/:calificacionId
Headers: Authorization: Bearer token
Response: { success: boolean }

// ============================================================================
// 7. REFERENCIAS (TESTIMONIALS)
// ============================================================================

POST /referencias
Headers: Authorization: Bearer token
Body: {
  para_usuario_id: UUID
  titulo?: string
  contenido: string
  aspectos_positivos?: Array<string>
  recomendaciones?: Array<string>
}
Response: { id: number, titulo: string, created_at: timestamp }

GET /referencias/:userId
Query: { solo_verificadas?: boolean, page?: number, limit?: number }
Response: { total: number, data: Array<{...}> }

PUT /referencias/:referenciaId
Headers: Authorization: Bearer token
Body: { titulo?, contenido?, aspectos_positivos?, recomendaciones? }
Response: { success: boolean, referencia: {...} }

DELETE /referencias/:referenciaId
Headers: Authorization: Bearer token
Response: { success: boolean }

// ============================================================================
// 8. BLOQUEOS
// ============================================================================

POST /bloqueos
Headers: Authorization: Bearer token
Body: {
  bloqueado_id: UUID
  razon: string
  motivo_bloqueo: string (acoso|spam|inapropiado|otro)
}
Response: { success: boolean, bloqueo: {...} }

GET /bloqueos/me
Headers: Authorization: Bearer token
Query: { page?: number, limit?: number }
Response: { total: number, data: Array<{ bloqueado_id, nombre, razon, created_at }> }

DELETE /bloqueos/:bloqueadoId
Headers: Authorization: Bearer token
Response: { success: boolean }

GET /bloqueos/me/tengo-bloqueado/:usuarioId
Headers: Authorization: Bearer token
Response: { bloqueado: boolean }

// ============================================================================
// 9. REPORTES
// ============================================================================

POST /reportes
Headers: Authorization: Bearer token
Body: {
  usuario_reportado_id?: UUID
  categoria: string (abuso|acoso|spam|estafa|contenido_sexual|violencia|otro)
  descripcion: string
  contenido_tipo?: string
  urgencia?: string (normal|importante|critica)
  capturas_pantalla?: Array<URL>
}
Response: { id: number, estado: string, created_at: timestamp }

GET /reportes/mis-reportes
Headers: Authorization: Bearer token
Query: { page?: number, limit?: number, estado?: string }
Response: { total: number, data: Array<{...}> }

GET /reportes/stats
Headers: Authorization: Bearer token
Query: { periodo?: string }
Response: {
  total_reportes: number
  pendientes: number
  resueltos: number
  categoria_mas_comun: string
}

// ADMIN ONLY
GET /reportes
Headers: Authorization: Bearer token (admin required)
Query: { estado?: string, categoria?: string, pagina?: number, limit?: number }
Response: { total: number, data: Array<{...}> }

PUT /reportes/:reporteId
Headers: Authorization: Bearer token (admin required)
Body: {
  estado?: string
  accion_tomada?: string
  notas_internas?: string
}
Response: { success: boolean, reporte: {...} }

// ============================================================================
// 10. RANKING & TOP SYSTEM
// ============================================================================

GET /ranking
Query: {
  nivel?: string (pro|top1|legend)
  ordenar?: string (puntuacion|rating|reciente)
  page?: number
  limit?: number
}
Response: {
  total: number
  data: Array<{
    profile_id: UUID
    nombre_artistico: string
    foto_perfil: string
    nivel: string
    rating_promedio: number
    posicion: number
    fecha_expiracion: timestamp
  }>
}

GET /ranking/me
Headers: Authorization: Bearer token
Response: {
  nivel: string
  fecha_inicio: timestamp
  fecha_expiracion: timestamp
  posicion: number
  beneficios: {
    visible_destacados: boolean
    multiplicador_alcance: number
    contacto_visible: boolean
    estadisticas_accesibles: boolean
  }
  beneficios_acumulados: {
    incremento_perfiles_vistos: number
    incremento_contactos: number
    incremento_ofertas: number
  }
}

POST /ranking/upgrade
Headers: Authorization: Bearer token
Body: {
  nivel: string (pro|top1|legend)
  duracion_dias: number (30|90|180|365)
  metodo_pago: string (tarjeta|mercadopago)
}
Response: {
  id: number
  monto: number
  moneda: string
  estado: string
  url_pago?: string (para Mercado Pago)
  transaccion_id: string
}

GET /ranking/beneficios/:userId
Response: {
  fecha_inicio: timestamp
  fecha_fin: timestamp
  beneficios_totales: {
    perfiles_vistos: number
    contactos: number
    ofertas: number
  }
  desglose_diario: Array<{
    fecha: date
    perfil_visitas: number
    contactos: number
    solicitudes_eventos: number
    ofertas_trabajo: number
  }>
}

// ============================================================================
// 11. CONEXIONES (NETWORKING)
// ============================================================================

POST /conexiones/solicitar
Headers: Authorization: Bearer token
Body: {
  conexion_id: UUID
}
Response: { success: boolean, conexion: { id, estado: "pendiente", created_at } }

GET /conexiones/pendientes
Headers: Authorization: Bearer token
Query: { page?: number, limit?: number }
Response: {
  total: number
  data: Array<{
    id: number
    usuario: { id, nombre_artistico, foto_perfil, ubicacion }
    fecha_solicitud: timestamp
  }>
}

POST /conexiones/:conexionId/aceptar
Headers: Authorization: Bearer token
Response: { success: boolean }

POST /conexiones/:conexionId/rechazar
Headers: Authorization: Bearer token
Response: { success: boolean }

GET /conexiones
Headers: Authorization: Bearer token
Query: { page?: number, limit?: number }
Response: {
  total: number
  data: Array<{
    id: UUID
    nombre_artistico: string
    foto_perfil: string
    ubicacion: string
    ranking_tipo: string
  }>
}

DELETE /conexiones/:conexionId
Headers: Authorization: Bearer token
Response: { success: boolean }

// ============================================================================
// 12. EVENTOS
// ============================================================================

POST /eventos
Headers: Authorization: Bearer token
Body: {
  titulo: string
  descripcion: string
  tipo_evento: string
  ubicacion: string
  latitud: number
  longitud: number
  fecha_evento: timestamp
  generos_buscados: Array<number>
  instrumentos_buscados: Array<number>
  nivel_minimo?: string
  capacidad_maxima: number
}
Response: { id: number, titulo: string, estado: string, created_at: timestamp }

GET /eventos
Query: {
  ubicacion?: string
  genero?: string
  instrumento?: string
  tipo?: string
  fecha_desde?: date
  fecha_hasta?: date
  solo_abiertos?: boolean
  page?: number
  limit?: number
}
Response: { total: number, data: Array<{...}> }

GET /eventos/:eventoId
Response: {
  id: number
  titulo: string
  descripcion: string
  ubicacion: string
  fecha_evento: timestamp
  creador: { id, nombre_artistico, foto_perfil, rating_promedio }
  postulantes: number
  aceptados: number
  estado: string
}

PUT /eventos/:eventoId
Headers: Authorization: Bearer token
Body: { titulo?, descripcion?, estado? }
Response: { success: boolean }

DELETE /eventos/:eventoId
Headers: Authorization: Bearer token
Response: { success: boolean }

// ============================================================================
// 13. POSTULACIONES
// ============================================================================

POST /postulaciones
Headers: Authorization: Bearer token
Body: {
  evento_id: number
  nota_postulante?: string
}
Response: { id: number, estado: "pendiente", created_at: timestamp }

GET /postulaciones/mis-solicitudes
Headers: Authorization: Bearer token
Query: { estado?: string, page?: number, limit?: number }
Response: { total: number, data: Array<{...}> }

GET /eventos/:eventoId/postulaciones
Headers: Authorization: Bearer token
Query: { estado?: string, page?: number, limit?: number }
Response: { total: number, data: Array<{...}> }

PUT /postulaciones/:postulacionId
Headers: Authorization: Bearer token
Body: { estado: string (aceptada|rechazada) }
Response: { success: boolean }

// ============================================================================
// 14. MENSAJERÍA
// ============================================================================

POST /mensajes
Headers: Authorization: Bearer token
Body: {
  usuario_destinatario_id: UUID
  contenido: string
  tipo_contenido?: string (texto|audio|imagen|video)
  url_contenido?: string
}
Response: { id: number, created_at: timestamp }

GET /conversaciones
Headers: Authorization: Bearer token
Query: { page?: number, limit?: number }
Response: {
  total: number
  data: Array<{
    id: number
    otro_usuario: { id, nombre_artistico, foto_perfil }
    ultimo_mensaje: string
    fecha_ultimo_mensaje: timestamp
    sin_leer: number
  }>
}

GET /conversaciones/:usuarioId/mensajes
Headers: Authorization: Bearer token
Query: { page?: number, limit?: number }
Response: {
  usuario: { id, nombre_artistico, foto_perfil }
  mensajes: Array<{
    id: number
    de_usuario_id: UUID
    contenido: string
    leido: boolean
    created_at: timestamp
  }>
}

PUT /mensajes/:mensajeId/marcar-leido
Headers: Authorization: Bearer token
Response: { success: boolean }

// ============================================================================
// 15. NOTIFICACIONES
// ============================================================================

GET /notificaciones
Headers: Authorization: Bearer token
Query: { no_leidas?: boolean, page?: number, limit?: number }
Response: {
  total: number
  no_leidas: number
  data: Array<{
    id: number
    tipo: string
    titulo: string
    contenido: string
    leida: boolean
    created_at: timestamp
  }>
}

PUT /notificaciones/:notificacionId/marcar-leida
Headers: Authorization: Bearer token
Response: { success: boolean }

POST /notificaciones/marcar-todas-leidas
Headers: Authorization: Bearer token
Response: { success: boolean }

DELETE /notificaciones/:notificacionId
Headers: Authorization: Bearer token
Response: { success: boolean }

// ============================================================================
// 16. ESTADÍSTICAS
// ============================================================================

GET /estadisticas/plataforma
Response: {
  total_usuarios: number
  usuarios_premium: number
  usuarios_verificados: number
  usuarios_calidad: number
  rating_promedio_plataforma: number
  total_eventos: number
  total_conexiones: number
}

GET /estadisticas/me
Headers: Authorization: Bearer token
Response: {
  perfil_vistas: number
  conexiones_recibidas: number
  ofertas_recibidas: number
  tasa_respuesta: number
  miembros_desde_dias: number
}

// ============================================================================
// 17. BÚSQUEDA AVANZADA
// ============================================================================

POST /busqueda/avanzada
Body: {
  q: string (búsqueda general)
  filtros: {
    ubicacion?: string
    generos?: Array<number>
    instrumentos?: Array<number>
    nivel?: string
    ranking?: string (regular|pro|top1|legend)
    verificado?: boolean
    tipo: string (usuarios|eventos|ambos)
  }
  ordenar?: string (relevancia|rating|reciente)
  page?: number
  limit?: number
}
Response: {
  usuarios: Array<{...}>
  eventos: Array<{...}>
  total: number
}

// ============================================================================
// 18. SALUD DE LA API
// ============================================================================

GET /health
Response: {
  status: string (ok|error)
  timestamp: timestamp
  database: string (connected|disconnected)
  version: string
}

GET /health/db
Response: {
  connected: boolean
  latency_ms: number
  total_tables: number
  total_users: number
}

// ============================================================================
// CÓDIGOS DE ERROR ESTÁNDAR
// ============================================================================

200 OK - Solicitud exitosa
201 CREATED - Recurso creado
204 NO CONTENT - Respuesta vacía (eliminación)
400 BAD REQUEST - Error en los datos enviados
401 UNAUTHORIZED - Token ausente o inválido
403 FORBIDDEN - Acceso denegado
404 NOT FOUND - Recurso no encontrado
409 CONFLICT - Conflicto (ej. duplicado)
422 UNPROCESSABLE ENTITY - Validación fallida
429 TOO MANY REQUESTS - Rate limit excedido
500 INTERNAL SERVER ERROR - Error del servidor
502 BAD GATEWAY - Servidor no disponible

// ============================================================================
// EJEMPLO DE RESPUESTA DE ERROR
// ============================================================================

Response 400:
{
  "error": {
    "code": "INVALID_INPUT",
    "message": "El email es requerido",
    "field": "email",
    "details": {...}
  }
}

// ============================================================================
// TOKENS Y AUTENTICACIÓN
// ============================================================================

Header: Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

Token contiene:
- id (UUID del usuario)
- email
- nombre_artistico
- ranking_tipo
- iat (issued at)
- exp (expiration)

Validez: 7 días
Refresh: 30 días

// ============================================================================
// FIN DE DOCUMENTACIÓN
// ============================================================================
