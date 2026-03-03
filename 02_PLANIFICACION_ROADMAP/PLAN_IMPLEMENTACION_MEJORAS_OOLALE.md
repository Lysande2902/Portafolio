# 🚀 PLAN DE IMPLEMENTACIÓN - MEJORAS CRÍTICAS ÓOLALE MOBILE
## De 6.5/10 a 8.5+/10

**Creado:** 22/01/2026  
**Prioridad:** ALTA - Implementación de 8 semanas  
**Objetivo:** Transformar app de "limitada" a "competitiva"

---

## 📋 FASES DE IMPLEMENTACIÓN

### FASE 1: URGENTE (Semanas 1-2) 🔴
Implementar las 3 características que impiden retención

```
├─ Semana 1: Portfolio Multimedia
├─ Semana 2: Sistema de Reputación
└─ Semana 2: Mejorar UX de Búsqueda
```

### FASE 2: IMPORTANTE (Semanas 3-5) 🟠
Implementar modelo de negocio y beneficios

```
├─ Semana 3-4: Integración Mercado Pago
├─ Semana 4: Ranking TOP con beneficios
└─ Semana 5: Notificaciones push mejoradas
```

### FASE 3: MEDIANO PLAZO (Semanas 6-8) 🟡
Mejorar experiencia y visibilidad

```
├─ Semana 6: Sistema de reportes mejorado
├─ Semana 7: Analytics básico
└─ Semana 8: Testing y optimizaciones
```

---

## ⚡ FASE 1: URGENTE (Semanas 1-2)

### 1️⃣ PORTFOLIO MULTIMEDIA

#### Componentes Flutter a Crear:

**lib/screens/portfolio/portfolio_screen.dart**
```dart
// Pantalla principal de portfolio con:
// - Grid de media (videos, audios, imágenes)
// - Botón de upload
// - Filtros por tipo
// - Stats (vistas, descargas, compartidos)
```

**lib/screens/portfolio/upload_media_screen.dart**
```dart
// Pantalla de upload con:
// - Seleccionar archivo (video/audio/imagen)
// - Captura de foto/video
// - Grabación de audio
// - Progreso de upload
// - Privacidad (público/privado/amigos)
```

**lib/widgets/media_card.dart**
```dart
// Widget para mostrar cada media con:
// - Thumbnail/Preview
// - Play button para videos/audios
// - Botones de: compartir, descargar, eliminar
// - Contador de vistas
```

**lib/services/portfolio_service.dart**
```dart
// Servicio para:
// - Subir archivo a Supabase Storage
// - Crear registro en tabla portfolio_media
// - Obtener lista de media del usuario
// - Eliminar media
```

#### Backend (Node.js):

**POST /portfolio/media** - Upload
```javascript
// Recibe: FormData con archivo + metadata
// Sube a S3/Supabase Storage
// Crea registro en DB
// Retorna: URL del recurso + id
```

**GET /portfolio/media/:userId** - Obtener media
```javascript
// Retorna: Lista de media del usuario
// Con privacidad respetada (RLS policy)
```

#### Base de Datos - Queries Necesarias:

```sql
-- Obtener media del usuario
SELECT * FROM portfolio_media 
WHERE profile_id = $1 
ORDER BY created_at DESC;

-- Incrementar vistas
UPDATE portfolio_media 
SET vistas = vistas + 1 
WHERE id = $1;

-- Top 10 media más visto
SELECT * FROM portfolio_media 
WHERE visibilidad = 'publico'
ORDER BY vistas DESC 
LIMIT 10;
```

#### Actividades:

- [ ] Crear pantalla de portfolio
- [ ] Crear pantalla de upload
- [ ] Implementar camera/galería
- [ ] Integrar con Supabase Storage
- [ ] Crear backend endpoints
- [ ] Testing de upload
- [ ] Optimizar performance de carga

---

### 2️⃣ SISTEMA DE REPUTACIÓN FUNCIONAL

#### Componentes Flutter:

**lib/screens/ratings/ratings_screen.dart**
```dart
// Mostrar:
// - Promedio de estrellas (grande y visible)
// - Distribución de ratings (5★, 4★, 3★, 2★, 1★)
// - Lista de comentarios
// - Botón para dejar calificación
```

**lib/screens/ratings/leave_rating_screen.dart**
```dart
// Formulario para:
// - Seleccionar 1-5 estrellas (interactivo)
// - Escribir comentario
// - Seleccionar tipo de interacción (evento, colaboración)
// - Enviar
```

**lib/widgets/reputation_badge.dart**
```dart
// Widget que muestra:
// - Badge de reputación (Bronce/Plata/Oro/Platino/Legend)
// - Número de estrellas
// - Número de referencias
// - Visualización bonita y destacada
```

**lib/services/ratings_service.dart**
```dart
// Servicios para:
// - Obtener calificaciones de usuario
// - Crear nueva calificación
// - Obtener puntuación de reputación
```

#### Backend Endpoints:

**GET /calificaciones/:userId**
```javascript
// Retorna: {
//   promedio: 4.5,
//   total: 24,
//   distribucion: { 5: 18, 4: 4, 3: 2, 2: 0, 1: 0 },
//   lista: [...]
// }
```

**POST /calificaciones**
```javascript
// Crear nueva calificación
// El trigger automáticamente actualiza:
// - profiles.rating_promedio
// - profiles.total_calificaciones
// - puntuacion_reputacion
```

**GET /reputacion/:userId**
```javascript
// Retorna: {
//   puntuacion_final: 78.5,
//   badge: "Oro",
//   dias_en_plataforma: 180,
//   tasa_respuesta: 94,
//   eventos_completados: 12
// }
```

#### Queries SQL:

```sql
-- Obtener detalles de reputación
SELECT 
  rating_promedio,
  total_calificaciones,
  total_referencias,
  (SELECT COUNT(*) FROM referencias WHERE para_usuario_id = profiles.id) as referencias,
  (SELECT AVG(estrellas) FROM calificaciones WHERE para_usuario_id = profiles.id) as promedio_estrellas
FROM profiles 
WHERE id = $1;

-- Distribución de ratings
SELECT estrellas, COUNT(*) as cantidad
FROM calificaciones
WHERE para_usuario_id = $1
GROUP BY estrellas
ORDER BY estrellas DESC;
```

#### Actividades:

- [ ] Crear pantalla de ratings
- [ ] Implementar star rating widget
- [ ] Crear formulario de calificación
- [ ] Implementar badges de reputación
- [ ] Backend endpoints
- [ ] Conexión con triggers SQL
- [ ] Testing de calificaciones

---

### 3️⃣ MEJORAR UX DE BÚSQUEDA

#### Nuevas Pantallas:

**lib/screens/search/advanced_search_screen.dart**
```dart
// Búsqueda avanzada con filtros:
// 1. Ubicación (autocompletar)
// 2. Géneros (checkbox multi-select)
// 3. Instrumentos (checkbox multi-select)
// 4. Nivel (principiante/intermedio/avanzado/experto)
// 5. Ranking (regular/pro/top1/legend)
// 6. Reputación mínima (slider 0-5 estrellas)
// 7. Verificado (toggle)
// 8. Open to work (toggle)
```

**lib/screens/search/search_results_screen.dart**
```dart
// Resultados mejorados con:
// - Cards grandes con foto, nombre, ubicación
// - Rating visible ⭐4.5
// - 2-3 instrumentos principales
// - Badge de ranking TOP si aplica
// - Botón de contacto directo
// - Ordenamiento: Relevancia/Rating/Reciente
```

**lib/widgets/profile_card_search.dart**
```dart
// Tarjeta de perfil optimizada para búsqueda:
// - Foto de perfil grande
// - Nombre artístico (tamaño 16)
// - Ubicación + distancia
// - ⭐ 4.8 (24 calificaciones)
// - 🎸 Guitarra, 🎹 Teclado, 🥁 Batería
// - Badge TOP si aplica
// - Bio de 2-3 líneas
```

#### Backend - Endpoint de Búsqueda:

**POST /search/advanced**
```javascript
Body: {
  q: "string",
  filtros: {
    ubicacion: "Buenos Aires",
    generos: [1, 3, 5],
    instrumentos: [1, 2],
    nivel: "intermedio",
    ranking: "pro",
    reputacion_minima: 4.0,
    verificado: true,
    open_to_work: true
  },
  ordenar: "rating",
  page: 1,
  limit: 20
}

Response: {
  total: 342,
  page: 1,
  data: [
    {
      id: "uuid",
      nombre_artistico: "Juan García",
      foto_perfil: "url",
      ubicacion: "CABA",
      rating_promedio: 4.8,
      total_calificaciones: 24,
      ranking_tipo: "pro",
      instrumentos: [
        { id: 1, nombre: "Guitarra", nivel: "avanzado" },
        ...
      ],
      generos: [
        { id: 1, nombre: "Jazz", expertise: "avanzado" },
        ...
      ],
      bio: "Guitarrista jazz...",
      verificado: true,
      open_to_work: true
    }
  ]
}
```

#### Queries SQL:

```sql
-- Búsqueda avanzada optimizada
WITH usuarios_filtrados AS (
  SELECT DISTINCT p.id, p.nombre_artistico, p.foto_perfil, p.ubicacion,
         p.rating_promedio, p.total_calificaciones, p.ranking_tipo,
         pr.puntuacion_final, ROUND(p.rating_promedio::numeric, 1) as rating
  FROM profiles p
  LEFT JOIN puntuacion_reputacion pr ON p.id = pr.profile_id
  WHERE 1=1
    AND (p.ubicacion ILIKE $1 OR $1 IS NULL)
    AND p.verificado = COALESCE($2, p.verificado)
    AND p.open_to_work = COALESCE($3, p.open_to_work)
    AND p.rating_promedio >= COALESCE($4, 0)
)
SELECT * FROM usuarios_filtrados
LEFT JOIN perfiles_instrumentos pi ON usuarios_filtrados.id = pi.profile_id
LEFT JOIN perfiles_generos pg ON usuarios_filtrados.id = pg.profile_id
ORDER BY CASE WHEN ranking_tipo = 'legend' THEN 0
              WHEN ranking_tipo = 'top1' THEN 1
              WHEN ranking_tipo = 'pro' THEN 2
              ELSE 3 END,
         rating DESC
LIMIT 20 OFFSET $5;
```

#### Actividades:

- [ ] Crear pantalla de búsqueda avanzada
- [ ] Implementar filtros
- [ ] Crear cards optimizadas
- [ ] Backend de búsqueda avanzada
- [ ] Optimizar queries SQL
- [ ] Agregar índices faltantes
- [ ] Testing de búsqueda

---

## 🟠 FASE 2: IMPORTANTE (Semanas 3-5)

### 4️⃣ INTEGRACIÓN MERCADO PAGO

#### Componentes Flutter:

**lib/screens/payments/upgrade_screen.dart**
```dart
// Mostrar:
// - 3 opciones: PRO ($9.99), TOP#1 ($29.99), LEGEND ($99.99)
// - Beneficios de cada nivel
// - Duración (30/90/180/365 días)
// - Botón "Comprar ahora"
```

**lib/screens/payments/payment_screen.dart**
```dart
// WebView de Mercado Pago
// Redirigir a preferencia URL
// Capturar resultado de pago
```

#### Backend - Integración Mercado Pago:

**POST /ranking/upgrade**
```javascript
Body: {
  nivel: "pro",
  duracion_dias: 30,
  metodo_pago: "mercadopago"
}

Response: {
  id: 123,
  url_pago: "https://mercadopago.com/...",
  transaccion_id: "MP-xxxxx"
}
```

**POST /webhook/mercadopago**
```javascript
// Webhook que recibe confirmación de pago
// Actualiza tabla pagos_ranking
// Crea registro en ranking_top
// Actualiza profiles.ranking_tipo
// Envía notificación al usuario
```

#### Queries SQL:

```sql
-- Procesar pago aprobado
BEGIN;

-- 1. Actualizar estado de pago
UPDATE pagos_ranking 
SET estado = 'completado', fecha_completacion = NOW()
WHERE transaccion_id = $1;

-- 2. Crear/actualizar ranking_top
INSERT INTO ranking_top 
(profile_id, nivel, fecha_inicio, fecha_expiracion, renovaciones_count)
VALUES ($2, $3, NOW(), NOW() + INTERVAL '30 days', 1)
ON CONFLICT (profile_id) 
DO UPDATE SET 
  nivel = $3,
  fecha_expiracion = NOW() + INTERVAL '30 days',
  renovaciones_count = renovaciones_count + 1;

-- 3. Actualizar profile
UPDATE profiles
SET ranking_tipo = $3, ranking_fecha_expiracion = NOW() + INTERVAL '30 days'
WHERE id = $2;

-- 4. Insertar beneficios_top para tracking
INSERT INTO beneficios_top (ranking_top_id, fecha)
SELECT id, CURRENT_DATE FROM ranking_top WHERE profile_id = $2;

COMMIT;
```

#### Actividades:

- [ ] Configurar credenciales Mercado Pago
- [ ] Crear pantalla de opciones
- [ ] Integrar Mercado Pago SDK
- [ ] Crear backend endpoints
- [ ] Implementar webhook
- [ ] Crear queries SQL
- [ ] Testing de pagos (sandbox)

---

### 5️⃣ RANKING TOP CON BENEFICIOS REALES

#### Pantalla de Beneficios:

**lib/screens/ranking/top_benefits_screen.dart**
```dart
// Mostrar para usuario TOP:
// 1. Posición en ranking (Top #45)
// 2. Beneficios activos:
//    - ✅ Visible en búsquedas destacadas
//    - ✅ Contacto visible (no requiere conexión)
//    - ✅ Acceso a estadísticas
//    - ✅ Multiplicador de alcance (3x)
// 3. Estadísticas acumuladas:
//    - Perfiles vistos: +342%
//    - Contactos recibidos: +189%
//    - Ofertas: +278%
// 4. Renovación próxima en: 12 días
```

#### Cambios en Búsqueda:

```dart
// Mostrar TOP users en posición destacada
// Badge TOP#1 / PRO visible
// Multiplicador de visibilidad en resultados
```

#### Queries SQL:

```sql
-- Ver ranking actual del usuario
SELECT 
  p.nombre_artistico,
  p.foto_perfil,
  rt.nivel,
  rt.fecha_expiracion,
  ROW_NUMBER() OVER (PARTITION BY rt.nivel ORDER BY pr.puntuacion_final DESC) as posicion,
  pr.puntuacion_final,
  ROUND(100.0 * (SELECT COUNT(DISTINCT perfil_visitas) FROM beneficios_top WHERE ranking_top_id = rt.id AND fecha >= CURRENT_DATE - INTERVAL '30 days') / NULLIF((SELECT COUNT(DISTINCT perfil_visitas) FROM beneficios_top WHERE ranking_top_id = rt.id AND fecha >= CURRENT_DATE - INTERVAL '60 days'), 0) * 100, 1) as incremento_visibilidad
FROM profiles p
JOIN ranking_top rt ON p.id = rt.profile_id
JOIN puntuacion_reputacion pr ON p.id = pr.profile_id
WHERE p.id = $1 AND rt.fecha_expiracion > NOW();

-- Ranking TOP #1 global
SELECT 
  p.id,
  p.nombre_artistico,
  p.foto_perfil,
  p.rating_promedio,
  rt.nivel,
  ROW_NUMBER() OVER (ORDER BY pr.puntuacion_final DESC) as posicion
FROM profiles p
JOIN ranking_top rt ON p.id = rt.profile_id
JOIN puntuacion_reputacion pr ON p.id = pr.profile_id
WHERE rt.nivel = 'top1' AND rt.fecha_expiracion > NOW()
ORDER BY posicion
LIMIT 10;
```

#### Actividades:

- [ ] Crear pantalla de beneficios
- [ ] Mostrar badge TOP en búsquedas
- [ ] Implementar multiplicador de alcance
- [ ] Crear queries de ranking
- [ ] Dashboard de beneficios
- [ ] Testing de beneficios

---

### 6️⃣ NOTIFICACIONES PUSH MEJORADAS

#### Tipos de Notificaciones:

```
1. CONEXIONES
   └─ "Juan García quiere conectar contigo"
   
2. EVENTOS CERCANOS (10km)
   └─ "Jam Session - CABA - Hoy a las 19:00"
   
3. MENSAJES
   └─ "María: ¿Podemos colaborar?"
   
4. OPORTUNIDADES
   └─ "Necesitan baterista en Málaga para evento el 25/01"
   
5. RANKINGS
   └─ "¡Subiste a Oro! Ahora tienes 4.8⭐"
   
6. PROMOCIONES
   └─ "Upgrade a TOP #1 y recibe 3x visibilidad"
```

#### Firebase Cloud Messaging Setup:

**lib/services/fcm_service.dart**
```dart
// Configurar FCM
// Obtener token
// Guardar en DB
// Listener para notificaciones
```

**lib/screens/notifications/notifications_screen.dart**
```dart
// Pantalla de notificaciones:
// - Lista de todas las notificaciones
// - Filtrar por tipo
// - Marcar como leído
// - Acciones rápidas desde notificación
```

#### Backend - Disparo de Notificaciones:

**Cuando nuevos eventos cercanos:**
```javascript
// 1. Obtener usuarios en radio de 10km
// 2. Filtrar por instrumentos/géneros buscados
// 3. Enviar notificación via FCM
```

**Cuando cambio de ranking:**
```javascript
// Enviar celebración
// "¡Felicidades! Ascendiste a Oro 🏅"
```

#### Actividades:

- [ ] Configurar Firebase FCM
- [ ] Crear pantalla de notificaciones
- [ ] Backend de disparo de notificaciones
- [ ] Filtros inteligentes
- [ ] Testing de FCM

---

## 🟡 FASE 3: MEDIANO PLAZO (Semanas 6-8)

### 7️⃣ SISTEMA DE REPORTES MEJORADO

#### Pantalla de Reporte:

**lib/screens/report_screen.dart**
```dart
// Formulario con:
// - Usuario reportado (auto-completar)
// - Categoría (acoso, spam, estafa, etc)
// - Descripción detallada
// - Captura de pantalla
// - Fotos/videos como evidencia
// - Enviar
```

#### Dashboard de Moderador:

**lib/screens/admin/reports_dashboard.dart**
```dart
// Solo admin ve:
// - Reportes pendientes
// - Filtrar por categoría, urgencia
// - Ver evidencia
// - Acciones: warning, suspensión, eliminación
// - Comentarios privados
// - Historial de cambios
```

#### Queries SQL:

```sql
-- Ver reportes por resolver
SELECT 
  r.id,
  r.categoria,
  r.urgencia,
  r.estado,
  (SELECT nombre_artistico FROM profiles WHERE id = r.reportante_id) as reportante,
  (SELECT nombre_artistico FROM profiles WHERE id = r.usuario_reportado_id) as reportado,
  r.descripcion,
  r.created_at,
  COUNT(hr.id) as cambios_estado
FROM reportes r
LEFT JOIN historial_reportes hr ON r.id = hr.reporte_id
WHERE r.estado IN ('pendiente', 'en_revision')
GROUP BY r.id
ORDER BY CASE r.urgencia 
  WHEN 'critica' THEN 1
  WHEN 'importante' THEN 2
  WHEN 'normal' THEN 3
END, r.created_at;
```

#### Actividades:

- [ ] Crear pantalla de reporte
- [ ] Dashboard de moderador
- [ ] Backend endpoints
- [ ] Historial de reportes
- [ ] Notificaciones a moderadores

---

### 8️⃣ ANALYTICS BÁSICO

#### Dashboard de Usuario:

**lib/screens/analytics/user_analytics_screen.dart**
```dart
// Mostrar al usuario:
// - Perfil visto X veces hoy
// - Conexiones recibidas (últimos 7 días)
// - Clicks en portfolio
// - Mensajes recibidos
// - Ubicación de quiénes te ven
// - Instrumentos más buscados
```

#### Dashboard de Admin:

**lib/screens/admin/platform_analytics_screen.dart**
```dart
// KPIs principales:
// - Usuarios activos hoy
// - Nuevos usuarios (hoy/semana/mes)
// - Usuarios TOP activos
// - Eventos creados
// - Conexiones realizadas
// - Ingresos Mercado Pago
// - Retención (Day 1, Day 7, Day 30)
```

#### Queries SQL - Analytics:

```sql
-- Usuarios activos últimas 24 horas
SELECT COUNT(DISTINCT id) as activos_hoy
FROM profiles
WHERE updated_at > NOW() - INTERVAL '24 hours';

-- Ingresos últimos 30 días
SELECT 
  DATE_TRUNC('day', created_at) as fecha,
  SUM(monto) as ingresos,
  COUNT(*) as transacciones
FROM pagos_ranking
WHERE estado = 'completado'
  AND created_at > NOW() - INTERVAL '30 days'
GROUP BY fecha
ORDER BY fecha DESC;

-- Top usuarios con más rating
SELECT 
  p.nombre_artistico,
  p.rating_promedio,
  COUNT(c.id) as total_calificaciones,
  rt.nivel as ranking
FROM profiles p
LEFT JOIN calificaciones c ON p.id = c.para_usuario_id
LEFT JOIN ranking_top rt ON p.id = rt.profile_id
GROUP BY p.id
ORDER BY p.rating_promedio DESC
LIMIT 20;
```

#### Actividades:

- [ ] Crear dashboards
- [ ] Queries de analytics
- [ ] Visualización de datos
- [ ] Exportar reports

---

## 📊 RESUMEN TIMELINE

```
SEMANA 1-2: URGENTE ⚠️
├─ Portfolio Multimedia
├─ Sistema de Reputación
└─ Búsqueda Avanzada

SEMANA 3-5: IMPORTANTE 🔥
├─ Mercado Pago
├─ Ranking TOP
└─ Notificaciones Push

SEMANA 6-8: MEDIANO PLAZO 📈
├─ Reportes Mejorados
├─ Analytics
└─ Testing/Optimizaciones

RESULTADO ESPERADO: 6.5 → 8.5/10 ⭐
```

---

## ✅ CRITERIOS DE ÉXITO

Por cada feature:

| Feature | Criterio de Éxito |
|---------|---|
| **Portfolio** | Upload/download funcionando, 95% uptime |
| **Reputación** | Badges visibles, calificaciones guardadas |
| **Búsqueda** | Queries < 200ms, 5+ filtros |
| **Mercado Pago** | Pagos procesando correctamente |
| **TOP Ranking** | Usuarios viendo beneficios reales |
| **Notificaciones** | Entrega en < 5 segundos |
| **Reportes** | Moderadores resolviendo en < 24h |
| **Analytics** | Dashboards cargando en < 2s |

---

**Comenzamos con FASE 1 ahora?**
