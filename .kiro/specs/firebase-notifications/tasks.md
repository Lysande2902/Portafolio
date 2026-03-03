# Tasks: Sistema de Notificaciones Push con Firebase

## Estado General
- **Spec**: firebase-notifications
- **Estado**: En Progreso
- **Fecha Inicio**: 28 Enero 2026

---

## 1. Configuración de Firebase

### 1.1 Configuración de Android
- [x] Crear proyecto en Firebase Console
- [x] Agregar app Android con Bundle ID `com.oolale.oolale_mobile`
- [x] Descargar y copiar `google-services.json` a `android/app/`
- [x] Configurar `android/build.gradle.kts` con plugin de Google Services
- [x] Configurar `android/app/build.gradle.kts` con dependencias Firebase
- [x] Configurar `AndroidManifest.xml` con servicio de mensajería

### 1.2 Configuración de iOS
- [x] Agregar app iOS con Bundle ID `com.oolale.oolaleMobile`
- [x] Descargar y copiar `GoogleService-Info.plist` a `ios/Runner/`
- [x] Configurar `Info.plist` con permisos de notificaciones
- [ ] Habilitar Push Notifications en Xcode capabilities
- [ ] Habilitar Background Modes en Xcode capabilities

### 1.3 Dependencias Flutter
- [x] Agregar `firebase_core: ^2.24.2` en pubspec.yaml
- [x] Agregar `firebase_messaging: ^14.7.9` en pubspec.yaml
- [x] Agregar `flutter_local_notifications: ^16.3.0` en pubspec.yaml
- [x] Ejecutar `flutter pub get`

---

## 2. Implementación de NotificationService

### 2.1 Estructura Base
- [x] Actualizar `lib/services/notification_service.dart` con implementación completa
- [ ] Implementar método `initialize()`
- [ ] Implementar método `_requestPermissions()`
- [ ] Implementar método `_setupLocalNotifications()`
- [ ] Implementar método `_saveDeviceToken()`
- [ ] Implementar método `_setupMessageHandlers()`

### 2.2 Manejo de Mensajes
- [ ] Implementar handler para foreground (`onMessage`)
- [ ] Implementar handler para background (`onMessageOpenedApp`)
- [ ] Implementar handler para terminated (`getInitialMessage`)
- [ ] Implementar método `_showLocalNotification()`
- [ ] Implementar método `_handleNotificationTap()` con navegación

### 2.3 Gestión de Tokens
- [ ] Implementar guardado de token en Supabase
- [ ] Implementar listener `onTokenRefresh`
- [ ] Implementar eliminación de token al cerrar sesión

### 2.4 Métodos de Utilidad
- [ ] Implementar `getUnreadCount()`
- [ ] Implementar `markAsRead(notificationId)`
- [ ] Implementar `markAllAsRead()`

---

## 3. Base de Datos Supabase

### 3.1 Tabla device_tokens
- [ ] Crear tabla `device_tokens` con campos: id, user_id, token, platform, created_at, updated_at
- [ ] Crear índice en `user_id`
- [ ] Crear índice en `token`
- [ ] Crear constraint UNIQUE en (user_id, token)
- [ ] Habilitar RLS en tabla
- [ ] Crear policy "Users can manage their own tokens"

### 3.2 Tabla notifications
- [ ] Crear tabla `notifications` con campos: id, user_id, type, title, body, data, read, read_at, created_at
- [ ] Crear índice en `user_id`
- [ ] Crear índice en `read`
- [ ] Crear índice en `created_at DESC`
- [ ] Habilitar RLS en tabla
- [ ] Crear policy "Users can view their own notifications"
- [ ] Crear policy "Users can update their own notifications"
- [ ] Crear policy "System can create notifications"

---

## 4. Inicialización en main.dart

### 4.1 Imports y Setup
- [x] Agregar imports de Firebase en `main.dart`
- [x] Crear función `_firebaseMessagingBackgroundHandler`
- [x] Inicializar Firebase con `Firebase.initializeApp()`
- [x] Configurar background handler con `FirebaseMessaging.onBackgroundMessage`
- [x] Inicializar NotificationService con `NotificationService.initialize()`

---

## 5. UI: Pantalla de Notificaciones

### 5.1 NotificationsScreen
- [ ] Crear `lib/screens/notifications/notifications_screen.dart`
- [ ] Implementar carga de notificaciones desde Supabase
- [ ] Implementar lista de notificaciones con scroll
- [ ] Implementar pull-to-refresh
- [ ] Implementar estado vacío (sin notificaciones)
- [ ] Implementar botón "Marcar todas como leídas"
- [ ] Implementar navegación al tocar notificación

### 5.2 NotificationTile Widget
- [ ] Crear widget `NotificationTile`
- [ ] Mostrar ícono según tipo de notificación
- [ ] Mostrar título y cuerpo
- [ ] Mostrar fecha/hora formateada
- [ ] Destacar notificaciones no leídas (fondo azul claro)
- [ ] Mostrar punto azul para no leídas
- [ ] Implementar onTap para marcar como leída y navegar

### 5.3 NotificationBadge Widget
- [ ] Crear widget `NotificationBadge`
- [ ] Mostrar contador en círculo rojo
- [ ] Mostrar "99+" si contador > 99
- [ ] Ocultar badge si contador = 0

---

## 6. Integración con HomeScreen

### 6.1 Badge en AppBar
- [ ] Agregar ícono de notificaciones en AppBar
- [ ] Implementar `_loadUnreadCount()` en HomeScreen
- [ ] Implementar `_setupRealtimeListener()` para actualizar contador
- [ ] Envolver ícono con `NotificationBadge`
- [ ] Navegar a NotificationsScreen al tocar ícono
- [ ] Recargar contador al regresar de NotificationsScreen

---

## 7. Configuración de Navegación

### 7.1 Rutas
- [ ] Verificar que ruta `/notifications` existe en GoRouter
- [ ] Agregar ruta `/connections/requests` si no existe
- [ ] Verificar rutas de mensajes `/messages/:id`
- [ ] Verificar rutas de ratings `/ratings/:userId`
- [ ] Verificar rutas de eventos `/gig/:id`

### 7.2 GlobalKey para Navegación
- [ ] Crear `GlobalKey<NavigatorState>` en main.dart
- [ ] Pasar navigatorKey a MaterialApp.router
- [ ] Usar navigatorKey en `_handleNotificationTap()`

---

## 8. Tipos de Notificaciones

### 8.1 Implementar Notificaciones de Conexión
- [ ] Crear notificación al enviar solicitud de conexión
- [ ] Crear notificación al aceptar solicitud
- [ ] Implementar navegación a pantalla de solicitudes

### 8.2 Implementar Notificaciones de Mensajes
- [ ] Crear notificación al recibir mensaje nuevo
- [ ] Implementar navegación a chat específico
- [ ] Evitar notificación si usuario está en el chat

### 8.3 Implementar Notificaciones de Calificaciones
- [ ] Crear notificación al recibir calificación
- [ ] Implementar navegación a pantalla de ratings

### 8.4 Implementar Notificaciones de Eventos
- [ ] Crear notificación de invitación a evento
- [ ] Crear notificación de recordatorio de evento
- [ ] Implementar navegación a detalle de evento

---

## 9. Testing

### 9.1 Tests Unitarios
- [ ] Test: `initialize()` configura todos los componentes
- [ ] Test: `getUnreadCount()` retorna contador correcto
- [ ] Test: `markAsRead()` actualiza notificación
- [ ] Test: `markAllAsRead()` actualiza todas las notificaciones
- [ ] Test: Token persiste después de guardar
- [ ] Test: Token se actualiza en refresh

### 9.2 Tests de Widget
- [ ] Test: NotificationsScreen muestra lista de notificaciones
- [ ] Test: NotificationBadge muestra contador correcto
- [ ] Test: NotificationTile muestra información correcta
- [ ] Test: Notificaciones no leídas tienen fondo destacado

### 9.3 Tests de Integración
- [ ] Test: Flujo completo de recibir notificación
- [ ] Test: Badge se actualiza al recibir notificación
- [ ] Test: Tocar notificación navega correctamente
- [ ] Test: Marcar como leída actualiza UI

---

## 10. Pruebas Manuales

### 10.1 Pruebas en Android
- [ ] Compilar app en Android
- [ ] Verificar que se obtiene token FCM
- [ ] Enviar notificación de prueba desde Firebase Console
- [ ] Verificar notificación en foreground
- [ ] Verificar notificación en background
- [ ] Verificar notificación con app cerrada
- [ ] Verificar navegación al tocar notificación

### 10.2 Pruebas en iOS
- [ ] Compilar app en iOS
- [ ] Verificar que se obtiene token FCM
- [ ] Enviar notificación de prueba desde Firebase Console
- [ ] Verificar notificación en foreground
- [ ] Verificar notificación en background
- [ ] Verificar notificación con app cerrada
- [ ] Verificar navegación al tocar notificación

---

## 11. Documentación

### 11.1 Actualizar Documentación
- [ ] Actualizar `FUNCIONALIDADES_FALTANTES.md` marcando notificaciones como completas
- [ ] Actualizar `IMPLEMENTACION_MEDIA_PRIORIDAD_COMPLETA.md`
- [ ] Crear documento de troubleshooting para notificaciones
- [ ] Documentar proceso de envío de notificaciones desde backend

---

## 12. Optimizaciones

### 12.1 Performance
- [ ] Implementar caché de contador de notificaciones
- [ ] Implementar paginación en lista de notificaciones
- [ ] Optimizar queries con índices apropiados

### 12.2 UX
- [ ] Agregar animaciones al mostrar notificaciones
- [ ] Agregar sonido personalizado para notificaciones
- [ ] Implementar vibración al recibir notificación
- [ ] Agregar swipe-to-delete en lista de notificaciones

---

## Notas de Implementación

### Prioridad de Tareas:
1. **Alta**: Secciones 1-4 (Configuración e implementación base)
2. **Media**: Secciones 5-7 (UI y navegación)
3. **Baja**: Secciones 8-12 (Tipos específicos, testing, optimizaciones)

### Dependencias:
- Sección 2 depende de Sección 1
- Sección 4 depende de Secciones 1 y 2
- Sección 5 depende de Secciones 2 y 3
- Sección 6 depende de Sección 5
- Sección 8 depende de Secciones 2-7

### Estimación de Tiempo:
- Configuración (Sección 1): 1-2 horas
- Implementación base (Secciones 2-4): 3-4 horas
- UI (Secciones 5-6): 2-3 horas
- Integración completa (Secciones 7-8): 2-3 horas
- Testing y optimizaciones (Secciones 9-12): 2-3 horas
- **Total estimado**: 10-15 horas

---

**Última actualización**: 28 Enero 2026
