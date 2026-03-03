# Sistema de Notificaciones Push con Firebase

## 1. Descripción General

Implementar un sistema completo de notificaciones push utilizando Firebase Cloud Messaging (FCM) para la aplicación móvil Óolale. El sistema debe permitir a los usuarios recibir notificaciones en tiempo real sobre eventos importantes como solicitudes de conexión, mensajes nuevos, calificaciones recibidas, y actualizaciones de eventos.

## 2. Objetivos

- Configurar Firebase Cloud Messaging en la aplicación Flutter
- Implementar manejo de notificaciones en foreground, background y terminated
- Crear UI para visualizar historial de notificaciones
- Implementar badges con contador de notificaciones no leídas
- Guardar tokens de dispositivos en Supabase
- Crear sistema de notificaciones persistentes en base de datos

## 3. User Stories

### US-1: Como usuario, quiero recibir notificaciones push
**Como** usuario de la aplicación
**Quiero** recibir notificaciones push en mi dispositivo
**Para** estar informado de eventos importantes en tiempo real

**Criterios de Aceptación:**
- El usuario debe otorgar permisos de notificaciones al iniciar la app
- Las notificaciones deben mostrarse cuando la app está en foreground
- Las notificaciones deben mostrarse cuando la app está en background
- Las notificaciones deben mostrarse cuando la app está cerrada (terminated)
- Al tocar una notificación, debe navegar a la pantalla correspondiente

### US-2: Como usuario, quiero ver mi historial de notificaciones
**Como** usuario de la aplicación
**Quiero** ver todas mis notificaciones en una pantalla dedicada
**Para** revisar notificaciones pasadas que pude haber perdido

**Criterios de Aceptación:**
- Debe existir una pantalla de notificaciones accesible desde el dashboard
- Las notificaciones deben mostrar: ícono, título, mensaje, fecha/hora
- Las notificaciones no leídas deben destacarse visualmente
- Debe haber un badge con el contador de notificaciones no leídas
- El usuario puede marcar notificaciones como leídas
- El usuario puede marcar todas las notificaciones como leídas

### US-3: Como usuario, quiero recibir notificaciones de conexiones
**Como** usuario de la aplicación
**Quiero** recibir notificaciones cuando alguien me envía una solicitud de conexión
**Para** responder rápidamente a nuevas conexiones

**Criterios de Aceptación:**
- Notificación cuando recibo una solicitud de conexión
- Notificación cuando aceptan mi solicitud de conexión
- Al tocar la notificación, navega a la pantalla de solicitudes de conexión
- El mensaje debe incluir el nombre del usuario

### US-4: Como usuario, quiero recibir notificaciones de mensajes
**Como** usuario de la aplicación
**Quiero** recibir notificaciones cuando recibo un mensaje nuevo
**Para** responder rápidamente a mis contactos

**Criterios de Aceptación:**
- Notificación cuando recibo un mensaje nuevo
- El mensaje debe incluir el nombre del remitente y preview del mensaje
- Al tocar la notificación, navega al chat con ese usuario
- No debe notificar si ya estoy en el chat con ese usuario

### US-5: Como usuario, quiero recibir notificaciones de calificaciones
**Como** usuario de la aplicación
**Quiero** recibir notificaciones cuando alguien me deja una calificación
**Para** ver el feedback que recibo

**Criterios de Aceptación:**
- Notificación cuando recibo una nueva calificación
- El mensaje debe incluir el nombre del evaluador y las estrellas
- Al tocar la notificación, navega a mi pantalla de calificaciones

### US-6: Como desarrollador, quiero gestionar tokens FCM
**Como** desarrollador
**Quiero** guardar y actualizar tokens FCM de dispositivos
**Para** poder enviar notificaciones push a los usuarios

**Criterios de Aceptación:**
- Los tokens FCM deben guardarse en Supabase al iniciar sesión
- Los tokens deben actualizarse cuando cambian (onTokenRefresh)
- Debe guardarse la plataforma (android/ios)
- Los tokens antiguos deben eliminarse al cerrar sesión

## 4. Requisitos Funcionales

### RF-1: Configuración de Firebase
- Integrar Firebase SDK en la aplicación Flutter
- Configurar google-services.json para Android
- Configurar GoogleService-Info.plist para iOS
- Inicializar Firebase en main.dart

### RF-2: Permisos de Notificaciones
- Solicitar permisos de notificaciones al usuario
- Manejar estados de permisos (granted, denied, provisional)
- Mostrar diálogo explicativo antes de solicitar permisos

### RF-3: Manejo de Notificaciones
- Implementar handler para notificaciones en foreground
- Implementar handler para notificaciones en background
- Implementar handler para notificaciones cuando app está terminated
- Implementar navegación al tocar notificaciones

### RF-4: Notificaciones Locales
- Mostrar notificaciones locales cuando la app está en foreground
- Configurar canal de notificaciones para Android
- Configurar sonido, vibración y badge

### RF-5: Gestión de Tokens
- Obtener token FCM al iniciar la app
- Guardar token en tabla device_tokens de Supabase
- Actualizar token cuando cambia (onTokenRefresh)
- Eliminar token al cerrar sesión

### RF-6: Base de Datos
- Crear tabla device_tokens en Supabase
- Crear tabla notifications en Supabase
- Implementar RLS policies para ambas tablas
- Crear índices para optimizar queries

### RF-7: UI de Notificaciones
- Crear pantalla NotificationsScreen
- Mostrar lista de notificaciones con scroll infinito
- Implementar pull-to-refresh
- Mostrar badge con contador en ícono de notificaciones
- Implementar botón "Marcar todas como leídas"

### RF-8: Tipos de Notificaciones
- connection_request: Solicitud de conexión
- connection_accepted: Conexión aceptada
- new_message: Mensaje nuevo
- new_rating: Calificación nueva
- event_invitation: Invitación a evento
- event_reminder: Recordatorio de evento

## 5. Requisitos No Funcionales

### RNF-1: Performance
- Las notificaciones deben mostrarse en menos de 2 segundos
- La pantalla de notificaciones debe cargar en menos de 1 segundo
- El contador de badges debe actualizarse en tiempo real

### RNF-2: Seguridad
- Los tokens FCM deben estar protegidos con RLS
- Solo el usuario puede ver sus propias notificaciones
- Los tokens deben eliminarse al cerrar sesión

### RNF-3: Usabilidad
- Las notificaciones deben ser claras y concisas
- Los íconos deben ser descriptivos del tipo de notificación
- El badge debe ser visible pero no intrusivo

### RNF-4: Compatibilidad
- Debe funcionar en Android 6.0+
- Debe funcionar en iOS 12.0+
- Debe manejar correctamente permisos denegados

### RNF-5: Confiabilidad
- Las notificaciones no deben duplicarse
- Los tokens deben actualizarse automáticamente
- Debe manejar errores de red gracefully

## 6. Restricciones Técnicas

- Usar Firebase Cloud Messaging (FCM)
- Usar flutter_local_notifications para notificaciones locales
- Usar Supabase para almacenar tokens y notificaciones
- Seguir las guías de diseño Material Design 3
- Mantener consistencia con el tema actual de la app

## 7. Dependencias

### Paquetes Flutter Requeridos:
- firebase_core: ^2.24.2
- firebase_messaging: ^14.7.9
- flutter_local_notifications: ^16.3.0

### Configuración Externa:
- Proyecto Firebase configurado
- google-services.json descargado
- GoogleService-Info.plist descargado (iOS)

### Tablas Supabase:
- device_tokens
- notifications

## 8. Casos de Uso Detallados

### CU-1: Recibir Notificación de Conexión
1. Usuario B envía solicitud de conexión a Usuario A
2. Sistema crea registro en tabla notifications
3. Sistema obtiene token FCM de Usuario A
4. Sistema envía notificación push vía FCM
5. Usuario A recibe notificación en su dispositivo
6. Usuario A toca la notificación
7. App navega a pantalla de solicitudes de conexión

### CU-2: Ver Historial de Notificaciones
1. Usuario abre la app
2. Usuario toca ícono de notificaciones (con badge "3")
3. App carga notificaciones desde Supabase
4. App muestra lista de notificaciones
5. Notificaciones no leídas tienen fondo destacado
6. Usuario toca una notificación
7. App marca como leída y navega a pantalla correspondiente

### CU-3: Marcar Todas como Leídas
1. Usuario está en pantalla de notificaciones
2. Usuario toca botón "Marcar todas como leídas"
3. App actualiza todas las notificaciones a read=true
4. Badge desaparece
5. Notificaciones ya no tienen fondo destacado

## 9. Flujo de Datos

```
Usuario A realiza acción
  ↓
Backend crea notificación en tabla notifications
  ↓
Backend obtiene token FCM de Usuario B
  ↓
Backend envía notificación push vía FCM
  ↓
FCM entrega notificación a dispositivo de Usuario B
  ↓
App muestra notificación (foreground/background/terminated)
  ↓
Usuario B toca notificación
  ↓
App navega a pantalla correspondiente
  ↓
App marca notificación como leída
```

## 10. Criterios de Éxito

- ✅ Usuario puede recibir notificaciones en todos los estados de la app
- ✅ Usuario puede ver historial de notificaciones
- ✅ Badge muestra contador correcto de notificaciones no leídas
- ✅ Tocar notificación navega a la pantalla correcta
- ✅ Tokens FCM se guardan y actualizan correctamente
- ✅ Notificaciones se muestran en menos de 2 segundos
- ✅ UI es intuitiva y consistente con el diseño de la app

## 11. Riesgos y Mitigaciones

### Riesgo 1: Permisos Denegados
**Mitigación:** Mostrar diálogo explicativo y permitir reactivar en configuración

### Riesgo 2: Token FCM Inválido
**Mitigación:** Implementar onTokenRefresh y reintentar envío

### Riesgo 3: Notificaciones Duplicadas
**Mitigación:** Usar IDs únicos y verificar antes de crear

### Riesgo 4: Batería del Dispositivo
**Mitigación:** Usar canales de notificación apropiados y no abusar de notificaciones

## 12. Notas Adicionales

- Las notificaciones deben respetar el tema (light/dark) de la app
- Los textos deben estar en español
- Debe haber logging detallado para debugging
- La configuración de Firebase debe estar documentada en la guía existente
