# 📋 CHECKLIST DE DESARROLLO: QUÉ IMPLEMENTAR EN LA MÓVIL

**Fecha:** 22 de Enero 2026  
**Basado en:** Comparación Web vs Mobile  
**Responsable:** Equipo de Desarrollo Mobile

---

## 🔴 BLOQUE 1: CRÍTICO - Debe Hacerse YA

### 1.1 Cambio de Contraseña
**Estado:** ❌ NO IMPLEMENTADO  
**Urgencia:** 🔴 CRÍTICA  
**Impacto:** Alto - Usuarios no pueden recuperarse si la olvidan

- [ ] Crear pantalla `change_password_screen.dart`
- [ ] Agregar ruta en `settings_screen.dart`
- [ ] Implementar validación de contraseña actual
- [ ] Implementar validación de nueva contraseña
- [ ] Agregar confirmación de nueva contraseña
- [ ] Usar Supabase Auth para actualizar contraseña
- [ ] Mostrar feedback de éxito/error
- [ ] Manejar excepciones

**Archivo a Modificar:** `lib/screens/settings/`  
**Tablas:** auth (Supabase Auth)  
**Endpoint:** Usar `supabase.auth.updateUser()`

---

### 1.2 Recuperación de Contraseña (Forgot Password)
**Estado:** ❌ NO IMPLEMENTADO  
**Urgencia:** 🔴 CRÍTICA  
**Impacto:** Alto - Usuarios bloqueados si olvidan clave

- [ ] Crear pantalla `forgot_password_screen.dart`
- [ ] Agregar enlace en `login_screen.dart`
- [ ] Implementar formulario de recuperación por email
- [ ] Integrar con Supabase Auth recovery
- [ ] Enviar email de reseteo
- [ ] Crear pantalla de reset password
- [ ] Validar tokens de recuperación
- [ ] Guardar nueva contraseña

**Archivo a Modificar:** `lib/screens/auth/`  
**Tablas:** auth (Supabase Auth)  
**Endpoint:** `supabase.auth.resetPasswordForEmail(email)`

---

## 🟠 BLOQUE 2: ALTA PRIORIDAD - Integración de Pagos

### 2.1 Integración de Mercado Pago - Wallet
**Estado:** ⚠️ UI LISTA, SIN INTEGRACIÓN  
**Urgencia:** 🟠 ALTA  
**Impacto:** Alto - Necesario para monetizar

#### 2.1.1 Agregar Fondos
- [ ] Implementar conexión con Mercado Pago SDK
- [ ] Crear checkout para agregar fondos
- [ ] Manejar webhooks de pago
- [ ] Actualizar saldo en `tickets_pagos`
- [ ] Guardar transacción
- [ ] Mostrar confirmación
- [ ] Manejar errores de pago

**Archivo a Modificar:** `lib/screens/settings/wallet_screen.dart`  
**Tabla:** `tickets_pagos`  
**Variables Necesarias en `.env`:**
```
MERCADO_PAGO_ACCESS_TOKEN=tu_token
MERCADO_PAGO_PUBLIC_KEY=tu_clave_publica
```

#### 2.1.2 Retirar Fondos
- [ ] Validar saldo mínimo
- [ ] Solicitar datos bancarios (si no están)
- [ ] Crear solicitud de retiro
- [ ] Guardar en tabla `retiradas` o similar
- [ ] Implementar estado de retiro (pendiente, completado)
- [ ] Mostrar historial de retiros
- [ ] Notificar cuando se complete

**Tabla:** `retiradas` (crear)

#### 2.1.3 Historial de Transacciones
- [ ] Mostrar historial desde `tickets_pagos`
- [ ] Filtrar por tipo (depósito, retiro)
- [ ] Filtrar por fecha
- [ ] Mostrar estado de cada transacción
- [ ] Mostrar detalles al tocar

---

### 2.2 Integración de Premium - Suscripciones
**Estado:** ⚠️ UI LISTA, SIN INTEGRACIÓN  
**Urgencia:** 🟠 ALTA  
**Impacto:** Alto - Modelo de monetización principal

#### 2.2.1 Planes de Suscripción
- [ ] Configurar planes en Mercado Pago Subscriptions
- [ ] Crear tabla `suscripciones` en Supabase:
  ```sql
  CREATE TABLE suscripciones (
    id UUID PRIMARY KEY,
    id_usuario UUID REFERENCES profiles(id),
    plan VARCHAR (monthly, annual, lifetime),
    estado VARCHAR (activo, cancelado, suspendido),
    fecha_inicio TIMESTAMP,
    fecha_vencimiento TIMESTAMP,
    es_activo BOOLEAN,
    mercado_pago_id VARCHAR,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
  );
  ```

#### 2.2.2 Comprar Suscripción
- [ ] Integrar Mercado Pago Subscriptions
- [ ] Mostrar planes en `subscription_screen.dart`
- [ ] Crear checkout
- [ ] Guardar en tabla `suscripciones`
- [ ] Activar beneficios premium
- [ ] Manejar webhooks de renovación
- [ ] Manejar webhooks de cancelación

#### 2.2.3 Gestionar Suscripción
- [ ] Mostrar plan activo
- [ ] Mostrar fecha de vencimiento
- [ ] Botón para cambiar plan
- [ ] Botón para cancelar suscripción
- [ ] Mostrar beneficios activos
- [ ] Recordatorio de renovación

**Tablas:** `suscripciones`, `beneficios_premium`

---

## 🟡 BLOQUE 3: MEDIA PRIORIDAD - Seguridad y Experiencia

### 3.1 Cambiar Contraseña - Opción desde Settings
**Estado:** ⚠️ NECESITA UI EN SETTINGS  
**Urgencia:** 🟡 MEDIA

- [ ] Agregar botón en `settings_screen.dart`
- [ ] Redirigir a `change_password_screen.dart`
- [ ] Validar contraseña actual
- [ ] Validar nueva contraseña
- [ ] Guardar en Supabase Auth

**Asociado con:** 1.1

---

### 3.2 Bloquear Usuarios
**Estado:** ❌ NO IMPLEMENTADO  
**Urgencia:** 🟡 MEDIA  
**Impacto:** Seguridad

- [ ] Crear tabla `bloqueados`:
  ```sql
  CREATE TABLE bloqueados (
    id UUID PRIMARY KEY,
    id_usuario_que_bloquea UUID,
    id_usuario_bloqueado UUID,
    razon VARCHAR,
    fecha TIMESTAMP,
    UNIQUE(id_usuario_que_bloquea, id_usuario_bloqueado)
  );
  ```
- [ ] Agregar opción en perfil de usuario (menu)
- [ ] Implementar bloquear/desbloquear
- [ ] Validar en discovery (no mostrar bloqueados)
- [ ] Validar en mensajes (no permitir chat)
- [ ] Validar en eventos (no permitir postulación)

**Archivos a Modificar:**
- `lib/screens/discovery/discovery_screen.dart`
- `lib/screens/profile/` (agregar menu)
- `lib/services/api_service.dart`

---

### 3.3 Seguimiento de Reportes
**Estado:** ❌ NO IMPLEMENTADO  
**Urgencia:** 🟡 MEDIA  
**Impacto:** UX

- [ ] Agregar tabla `reporte_estados`:
  ```sql
  CREATE TABLE reporte_estados (
    id UUID PRIMARY KEY,
    id_reporte UUID REFERENCES reports(id),
    estado VARCHAR (nuevo, asignado, investigando, resuelto, rechazado),
    fecha TIMESTAMP,
    comentario_admin TEXT
  );
  ```
- [ ] Mostrar estado del reporte en pantalla de reportes
- [ ] Notificar cuando estado cambie
- [ ] Historial de estados

**Archivo a Crear:** `lib/screens/reports/my_reports_screen.dart`

---

## 🟢 BLOQUE 4: BAJA PRIORIDAD - Mejoras Futuras

### 4.1 Autenticación de Dos Factores (2FA)
**Estado:** ❌ NO IMPLEMENTADO  
**Urgencia:** 🟢 BAJA  
**Impacto:** Seguridad avanzada

- [ ] Usar Supabase MFA
- [ ] Agregar opción en settings
- [ ] SMS o Email como segundo factor
- [ ] Validar en login

---

### 4.2 Gestión de Sesiones Múltiples
**Estado:** ❌ NO IMPLEMENTADO  
**Urgencia:** 🟢 BAJA  
**Impacto:** UX avanzada

- [ ] Listar dispositivos conectados
- [ ] Cerrar sesión en otros dispositivos
- [ ] Ver última actividad

---

### 4.3 Exportar Mis Datos
**Estado:** ❌ NO IMPLEMENTADO  
**Urgencia:** 🟢 BAJA  
**Impacto:** Cumplimiento legal (GDPR)

- [ ] Exportar perfil a JSON
- [ ] Exportar conexiones
- [ ] Exportar eventos participados
- [ ] Exportar chat

---

## 📊 MATRIZ DE IMPLEMENTACIÓN

### Semana 1: Crítico
| Tarea | Tiempo Est. | Dev |
|-------|-------------|-----|
| Cambio de Contraseña | 4 horas | |
| Recuperación de Contraseña | 6 horas | |
| Testing | 4 horas | |
| **TOTAL** | **14 horas** | |

### Semana 2-3: Pagos Fase 1
| Tarea | Tiempo Est. | Dev |
|-------|-------------|-----|
| Setup Mercado Pago SDK | 4 horas | |
| Agregar Fondos | 8 horas | |
| Testing de Pagos | 6 horas | |
| **TOTAL** | **18 horas** | |

### Semana 3-4: Premium Fase 1
| Tarea | Tiempo Est. | Dev |
|-------|-------------|-----|
| Setup Suscripciones MP | 4 horas | |
| Comprar Plan | 8 horas | |
| Gestionar Suscripción | 6 horas | |
| Testing | 4 horas | |
| **TOTAL** | **22 horas** | |

### Semana 5: Seguridad
| Tarea | Tiempo Est. | Dev |
|-------|-------------|-----|
| Bloquear Usuarios | 6 horas | |
| Seguimiento Reportes | 4 horas | |
| Testing | 4 horas | |
| **TOTAL** | **14 horas** | |

---

## 🛠️ HERRAMIENTAS Y PAQUETES NECESARIOS

### Pagos
```yaml
# pubspec.yaml
mercado_pago_flutter: ^X.X.X
stripe_flutter: ^X.X.X (alternativa)
```

### Seguridad
```yaml
local_auth: ^2.X.X (biométrico)
flutter_secure_storage: ^10.0.0 (ya existe)
```

### Notificaciones
```yaml
firebase_messaging: ^14.X.X (push notifications)
```

---

## 📝 TAREAS ESPECÍFICAS POR COMPONENTE

### Auth Service
**Archivo:** `lib/services/auth_service.dart`

```dart
// Agregar estos métodos:
Future<bool> changePassword(String oldPassword, String newPassword);
Future<void> resetPassword(String email);
Future<void> confirmPasswordReset(String token, String newPassword);
Future<bool> enable2FA();
Future<bool> verify2FACode(String code);
```

### API Service
**Archivo:** `lib/services/api_service.dart`

```dart
// Agregar estos endpoints:
Future<Map> getPaymentMethods();
Future<Map> createPayment(double amount, String description);
Future<Map> subscribePlan(String planId);
Future<Map> blockUser(String userId, String reason);
Future<List> getMyReports();
Future<Map> getReportStatus(String reportId);
Future<Map> getBlockedUsers();
```

### Profile Provider
**Archivo:** `lib/providers/profile_provider.dart`

```dart
// Agregar estos getters:
bool get isPremium;
DateTime? get premiumExpiryDate;
double get walletBalance;
List<Map> get blockedUsers;
bool get isUserBlocked(String userId);
```

---

## ✅ CHECKLIST DE TESTING

### Por cada feature:

- [ ] Unit tests
- [ ] Widget tests
- [ ] Integration tests
- [ ] Testing manual en Android
- [ ] Testing manual en iOS
- [ ] Testing offline
- [ ] Testing con red lenta
- [ ] Testing con tokens expirados

---

## 🎯 CRITERIOS DE ACEPTACIÓN

### Feature Cambio de Contraseña
- [ ] Usuario puede cambiar su contraseña
- [ ] Se valida contraseña actual
- [ ] Se valida nueva contraseña (min 8 caracteres)
- [ ] Se muestra error si contraseña actual es incorrecta
- [ ] Se muestra confirmación al cambiar
- [ ] Sesión se mantiene después del cambio
- [ ] Admin no puede ver contraseñas

### Feature Recuperación de Contraseña
- [ ] Usuario recibe email con enlace reset
- [ ] Enlace es válido por 1 hora
- [ ] Puede cambiar contraseña con enlace
- [ ] Enlace se invalida después de usar
- [ ] Se muestra error si enlace expiró

### Feature Pagos
- [ ] Transacción se procesa correctamente
- [ ] Saldo se actualiza inmediatamente
- [ ] Se crea registro en BD
- [ ] Se notifica al usuario
- [ ] Se valida saldo disponible para retiros
- [ ] Historial se muestra correctamente

### Feature Premium
- [ ] Plan se activa inmediatamente
- [ ] Beneficios están disponibles
- [ ] Se calcula renovación correctamente
- [ ] Recordatorio antes de vencer
- [ ] Se puede cambiar de plan
- [ ] Se puede cancelar

---

## 📞 CONTACTOS PARA INTEGRACIÓN

### Mercado Pago
- Documentación: https://developers.mercadopago.com
- API Subscriptions: https://developers.mercadopago.com/es/reference/subscriptions/_subscriptions/post
- Webhooks: https://developers.mercadopago.com/es/guides/webhooks/v2/webhooks

### Supabase Auth
- Documentación: https://supabase.com/docs/guides/auth
- Cambio de contraseña: https://supabase.com/docs/reference/dart/auth-update
- Recovery email: https://supabase.com/docs/reference/dart/auth-resetpasswordforemail

---

## 🚀 DEPLOY CHECKLIST

Antes de hacer push a producción:

- [ ] Todos los tests pasan
- [ ] No hay warnings en console
- [ ] Credenciales están en .env (no en código)
- [ ] Variables de Mercado Pago configuradas
- [ ] Webhooks configurados
- [ ] Base de datos actualizada (migrations)
- [ ] Emails de confirmación testeados
- [ ] App versioning actualizado
- [ ] Build APK/IPA testeado
- [ ] Store listings actualizados

---

**Documento generado:** 22 de Enero 2026  
**Mantenedor:** Equipo de Desarrollo  
**Última actualización:** Checklist completo de implementación
