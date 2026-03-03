# 🔧 ANÁLISIS TÉCNICO DETALLADO: Web Admin vs Mobile

**Fecha:** 22 de Enero 2026  
**Tipo:** Especificación Técnica para Alineación de Funcionalidades

---

## 📐 COMPARACIÓN DE ARQUITECTURA

### WEB (JAMConnect_Web)

```
Architecture: MVC Backend
│
├── Frontend
│   └── EJS Templates (Server-side rendering)
│       ├── admin_layout.ejs (Master layout)
│       ├── admin/
│       │   ├── login.ejs
│       │   ├── dashboard.ejs
│       │   ├── users.ejs
│       │   ├── catalog.ejs
│       │   ├── reports.ejs
│       │   ├── notes.ejs
│       │   ├── audit_log.ejs
│       │   └── change_password.ejs
│       └── public/ (Landing page)
│
├── Backend
│   ├── Express.js (Framework)
│   ├── Routes
│   │   ├── admin.js (926+ líneas - Toda la lógica)
│   │   ├── api.js (250+ líneas - APIs para mobile)
│   │   └── index.js (Landing)
│   ├── Models
│   │   └── (Basados en tablas Supabase)
│   └── Middleware
│       ├── isAdmin
│       ├── loginLimiter (rate limiting)
│       ├── verifyToken (JWT)
│       └── Helmet (seguridad headers)
│
└── Database: Supabase PostgreSQL
    ├── Usuarios
    ├── Géneros
    ├── Instrumentos
    ├── Servicios
    ├── Reportes
    ├── Audit_Log
    ├── Admin_Notes
    └── 10+ tablas de catálogos
```

### MÓVIL (oolale_mobile)

```
Architecture: Provider + Screens
│
├── Frontend (Flutter)
│   ├── Screens (19 pantallas)
│   │   ├── auth/ (login, register)
│   │   ├── dashboard/ (home, search)
│   │   ├── profile/ (view, edit)
│   │   ├── discovery/
│   │   ├── connections/
│   │   ├── events/ (3 pantallas)
│   │   ├── messages/ (2 pantallas)
│   │   ├── notifications/
│   │   ├── hiring/
│   │   ├── premium/
│   │   ├── reports/
│   │   └── settings/
│   ├── Providers (State Management)
│   │   ├── auth_provider
│   │   ├── profile_provider
│   │   └── (+ otros según necesario)
│   ├── Services (API Layer)
│   │   ├── auth_service.dart
│   │   ├── api_service.dart
│   │   └── supabase_service.dart
│   ├── Models (Data classes)
│   ├── Widgets (Componentes reutilizables)
│   └── Config
│       └── (Constantes, configuración)
│
└── Backend: Supabase
    ├── Authentication (Auth nativa)
    ├── Database
    │   ├── profiles
    │   ├── crews
    │   ├── gigs
    │   ├── gig_lineup
    │   ├── intercom
    │   ├── reports
    │   ├── notifications
    │   ├── hirings
    │   ├── tickets_pagos
    │   ├── suscripciones (falta crear)
    │   └── bloqueados (falta crear)
    └── Realtime (para chat)
```

---

## 🗄️ DIFERENCIAS EN LA BASE DE DATOS

### Tablas Solo en Web (Admin)

| Tabla | Propósito | Campos |
|-------|----------|--------|
| `Usuarios` | Gestión de usuarios admin | id, email, contraseña, nombre, es_admin, fecha_último_acceso |
| `Audit_Log` | Registro de auditoría | id, usuario_id, acción, entidad, id_entidad, detalles, timestamp |
| `Admin_Notes` | Notas internas admin | id, usuario_id, titulo, contenido, created_at, updated_at |
| `Géneros` | Catálogo de géneros | id, nombre, descripción |
| `Instrumentos` | Catálogo de instrumentos | id, nombre, descripción |
| `Servicios` | Catálogo de servicios | id, nombre, precio |
| `Géneros_Eventos` | Géneros para eventos | id, nombre |
| `Tipos_Evento` | Tipos de evento | id, nombre |
| `Géneros_Gear` | Géneros de equipamiento | id, nombre |

### Tablas Compartidas (Web + Mobile)

| Tabla | Usado por | Operaciones |
|-------|----------|-------------|
| `profiles` | Ambos | Web: CRUD admin / Mobile: User read/update |
| `crews` | Ambos | Web: (podría) / Mobile: CRUD |
| `gigs` | Ambos | Web: (podría) / Mobile: CRUD |
| `gig_lineup` | Ambos | Web: (podría) / Mobile: CRUD |
| `reports` | Ambos | Web: Read/Update status / Mobile: Insert |
| `notifications` | Ambos | Web: (podría) / Mobile: Read/Update |
| `intercom` | Ambos | Web: (no) / Mobile: CRUD + Realtime |

### Tablas Faltantes en Mobile (Crear)

| Tabla | Necesidad | Campos |
|-------|----------|--------|
| `bloqueados` | Seguridad | id, bloqueador_id, bloqueado_id, razon, fecha |
| `reporte_estados` | Tracking | id, reporte_id, estado, comentario, fecha |
| `suscripciones` | Premium | id, usuario_id, plan, estado, fecha_inicio, fecha_vencimiento, mp_id |
| `retiradas` | Pagos | id, usuario_id, monto, banco, estado, fecha, mp_id |
| `beneficios_premium` | Premium | id, suscripcion_id, beneficio, activo |

---

## 🔐 COMPARACIÓN DE SEGURIDAD

### WEB - Medidas Implementadas

```javascript
// 1. RATE LIMITING
const loginLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 5,  // 5 intentos cada 15 minutos
    message: 'Too many attempts...'
});
// Aplicado a: POST /admin/login

// 2. BCRYPT (10 salt rounds)
const hashedPassword = await bcrypt.hash(password, 10);
const passwordMatch = await bcrypt.compare(password, user.contraseña);

// 3. HELMET (Headers HTTP seguros)
router.use(helmet({
    contentSecurityPolicy: false,
    crossOriginEmbedderPolicy: false
}));

// 4. SESSION MANAGEMENT
req.session.adminUser = {
    id: user.id_usuario,
    email: user.correo_electronico,
    name: user.nombre_completo,
    role: 'admin'
};

// 5. JWT para APIs
const token = jwt.sign(payload, JWT_SECRET, { expiresIn: '24h' });
const verifyToken = (req, res, next) => {
    const token = req.headers['authorization'].split(' ')[1];
    jwt.verify(token, JWT_SECRET, (err, user) => {
        if (err) return res.status(403).json({ error: 'Token invalid' });
        req.user = user;
        next();
    });
};

// 6. AUDIT LOGGING
async function logAdminAction(req, accion, entidad, idEntidad, detalles) {
    await supabase.from('Audit_Log').insert({
        usuario_id: req.session.adminUser.id,
        accion,
        entidad,
        id_entidad: idEntidad,
        detalles: JSON.stringify(detalles),
        timestamp: new Date().toISOString()
    });
}

// 7. CACHÉ (performance)
const cache = new NodeCache({ stdTTL: 300 });
const cachedData = cache.get('dashboard_data');
if (cachedData) return cachedData;
```

### MÓVIL - Medidas Implementadas

```dart
// 1. SUPABASE AUTH
final authResponse = await supabase.auth.signInWithPassword(
    email: email,
    password: password
);

// 2. SECURE STORAGE
final storage = FlutterSecureStorage();
await storage.write(key: 'auth_token', value: token);
final token = await storage.read(key: 'auth_token');

// 3. TOKEN MANAGEMENT
// Los tokens de Supabase se manejan automáticamente
// Refresh automático incluido

// 4. Falta: RATE LIMITING en cliente
// Falta: 2FA
// Falta: Logout en otras sesiones
```

### ⚠️ DIFERENCIAS CRÍTICAS

| Aspecto | Web | Móvil | Falta |
|--------|-----|-------|-------|
| Rate Limiting | ✅ Sí | ❌ No | Implementar en cliente |
| Bcrypt | ✅ Sí | ✅ Supabase Auth | Consistente |
| 2FA | ❌ No | ❌ No | Ambas |
| Audit Log | ✅ Completo | ❌ No | Implementar en móvil |
| Session Management | ✅ Expreso | ✅ Supabase | Compatible |
| CORS | ✅ Configurado | N/A | OK |
| CSP Headers | ✅ Deshabilitado | N/A | OK |

---

## 🔄 FLUJOS DE AUTENTICACIÓN

### WEB - Flujo de Login

```
1. Usuario entra a /admin/login
2. Envía POST /admin/login con email/password
3. Server valida contra tabla Usuarios
4. Verifica bcrypt contraseña
5. Verifica flag es_admin = true
6. Crea sesión (req.session.adminUser)
7. Registra acceso en Audit_Log
8. Redirecciona a /admin/dashboard

Logout: GET /admin/logout → destroy session
```

### MÓVIL - Flujo de Login

```
1. Usuario entra a LoginScreen
2. Envía credenciales a Supabase Auth
3. Supabase genera JWT access token
4. Mobile almacena en flutter_secure_storage
5. Auto-crea perfil en profiles (trigger SQL)
6. Redirecciona a HomeScreen
7. Sesión persiste automáticamente

Logout: user = await supabase.auth.signOut()
```

### ❌ FALTA EN MÓVIL

```
1. Change Password
   - UI no existe
   - Endpoint no existe
   - Necesita validar contraseña actual

2. Forgot Password
   - No hay flujo de recuperación
   - No hay email de reset
   - Usuarios bloqueados si olvidan

3. Validación en Client
   - No hay rate limiting en app
   - Múltiples intentos sin restricción
```

---

## 📊 OPERACIONES CRUD POR TABLA

### Profiles (Perfiles de Usuario)

**WEB - Admin CRUD:**
```javascript
// READ
GET /admin/users?page=1&search=query
SELECT * FROM profiles LIMIT 50 OFFSET 0;

// CREATE
POST /admin/users/create
INSERT INTO profiles (...) VALUES (...);

// UPDATE
POST /admin/users/edit/:id
UPDATE profiles SET ... WHERE id = :id;

// DELETE
POST /admin/users/delete/:id
DELETE FROM profiles WHERE id = :id;
```

**MÓVIL - User R/W:**
```dart
// READ OWN
final profile = await supabase
    .from('profiles')
    .select()
    .eq('id', user.id)
    .single();

// UPDATE OWN
await supabase
    .from('profiles')
    .update(updates)
    .eq('id', user.id);

// READ OTHERS (Discovery)
final users = await supabase
    .from('profiles')
    .select()
    .ilike('nombre_artistico', '%query%')
    .limit(50);
```

### Crews (Conexiones)

**WEB - Nada:**
```javascript
// No implementado
```

**MÓVIL - CRUD:**
```dart
// CREATE (conectar)
await supabase.from('crews').insert({
    'usuario_1_id': myId,
    'usuario_2_id': otherUserId,
    'estado': 'pendiente',
    'fecha_solicitud': DateTime.now()
});

// READ
final connections = await supabase
    .from('crews')
    .select()
    .or("usuario_1_id.eq.$myId,usuario_2_id.eq.$myId")
    .eq('estado', 'activo');

// UPDATE (aceptar)
await supabase
    .from('crews')
    .update({'estado': 'activo'})
    .eq('id', crewId);

// DELETE (rechazar)
await supabase
    .from('crews')
    .delete()
    .eq('id', crewId);
```

---

## 🔌 ENDPOINTS API DISPONIBLES

### En Web (api.js)

```javascript
POST   /api/auth/login
POST   /api/auth/register
POST   /api/auth/logout

PUT    /api/profile/pro  (upgrade a pro)

GET    /api/gear/:id_perfil
POST   /api/gear

POST   /api/report
POST   /api/block

GET    /api/search
```

### Faltando en Web (pero móvil necesita)

```javascript
POST   /api/auth/change-password
POST   /api/auth/forgot-password
POST   /api/auth/reset-password

PUT    /api/profile  (editar perfil)

POST   /api/crews  (crear conexión)
GET    /api/crews  (listar)
DELETE /api/crews/:id

POST   /api/gigs
GET    /api/gigs
GET    /api/gigs/:id

POST   /api/gig-lineup
GET    /api/gig-lineup

POST   /api/messages
GET    /api/messages
GET    /api/chat/:userId

POST   /api/subscribe
GET    /api/subscription

POST   /api/payment
GET    /api/wallet

POST   /api/block
GET    /api/blocked

GET    /api/reports/:id/status
```

---

## 🎯 PUNTOS DE SINCRONIZACIÓN

### Datos que DEBEN estar sincronizados

| Dato | Web Admin | Móvil | Sincronización |
|------|-----------|-------|-----------------|
| Perfil Usuario | Tabla `profiles` | Tabla `profiles` | ✅ Automática Supabase |
| Reportes | Crea/Resuelve | Crea/Ve Estado | ❌ FALTA implementar estado |
| Conexiones | (No maneja) | CRUD | ✅ Solo móvil |
| Eventos | (No maneja) | CRUD | ✅ Solo móvil |
| Catálogos | Admin CRUD | Read-only | ✅ Consistente |
| Notificaciones | No | Read/Update | ✅ Triggers SQL |

---

## ⚡ PERFORMANCE

### WEB

```javascript
// Caché implementado
const cache = new NodeCache({ stdTTL: 300 });

// Dashboard data se cachea 5 minutos
router.get('/dashboard', isAdmin, async (req, res) => {
    const cachedData = cache.get('dashboard_data');
    if (cachedData) {
        return res.render('admin/dashboard', cachedData);
    }
    // Fetch from DB and cache...
});

// Paginación en listados
const ITEMS_PER_PAGE = 50;
const offset = (page - 1) * ITEMS_PER_PAGE;
```

### MÓVIL

```dart
// FutureBuilder para datos
FutureBuilder<List<Profile>>(
    future: getDiscoveryUsers(),
    builder: (context, snapshot) { ... }
);

// ListView.builder para listas largas
ListView.builder(
    itemCount: items.length,
    itemBuilder: (context, index) => ...
);

// StreamBuilder para realtime (chat)
StreamBuilder<List<Message>>(
    stream: getMessagesStream(),
    builder: (context, snapshot) { ... }
);

// Provider para state management
// Evita rebuilds innecesarios
```

---

## 🚀 ROADMAP DE ALINEACIÓN

### Fase 1: Seguridad (Semana 1)
- [ ] Implementar change-password en móvil
- [ ] Implementar forgot-password en móvil
- [ ] Agregar validaciones en backend
- [ ] Testing de seguridad

### Fase 2: Pagos (Semana 2-3)
- [ ] Setup Mercado Pago SDK
- [ ] Crear tablas `suscripciones`, `retiradas`
- [ ] Implementar payment flow
- [ ] Webhooks de Mercado Pago

### Fase 3: Seguridad Avanzada (Semana 4)
- [ ] Bloqueo de usuarios
- [ ] Seguimiento de reportes
- [ ] Rate limiting en móvil

### Fase 4: Otras (Semana 5+)
- [ ] 2FA
- [ ] Sesiones múltiples
- [ ] Exportar datos

---

## 📱 DISPOSITIVOS SOPORTADOS

### Web
- Desktop (Chrome, Firefox, Safari, Edge)
- Responsive design
- Mobile browser (complementario)

### Móvil
- iOS 11+
- Android 5.0+ (API level 21+)
- Tabletas Android/iOS

### Sincronización
- Mismo backend Supabase
- APIs REST compartidas
- JWT tokens compatibles

---

**Documento generado:** 22 de Enero 2026  
**Clasificación:** Técnico  
**Público:** Equipo de Desarrollo
