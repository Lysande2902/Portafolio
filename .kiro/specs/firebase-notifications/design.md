# Diseño: Sistema de Notificaciones Push con Firebase

## 1. Arquitectura General

### 1.1 Componentes Principales

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter App                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌──────────────────┐      ┌──────────────────┐           │
│  │ NotificationService│────│ Firebase Messaging│           │
│  └──────────────────┘      └──────────────────┘           │
│           │                         │                       │
│           │                         │                       │
│  ┌──────────────────┐      ┌──────────────────┐           │
│  │ LocalNotifications│      │  Navigation      │           │
│  └──────────────────┘      └──────────────────┘           │
│           │                         │                       │
└───────────┼─────────────────────────┼───────────────────────┘
            │                         │
            ▼                         ▼
┌─────────────────────────────────────────────────────────────┐
│                      Supabase                               │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────────┐      ┌──────────────────┐           │
│  │  device_tokens   │      │  notifications   │           │
│  └──────────────────┘      └──────────────────┘           │
└─────────────────────────────────────────────────────────────┘
            │                         │
            ▼                         ▼
┌─────────────────────────────────────────────────────────────┐
│                Firebase Cloud Messaging                     │
└─────────────────────────────────────────────────────────────┘
```

### 1.2 Flujo de Notificaciones

```
[Usuario A] realiza acción
     ↓
[Backend] crea registro en notifications
     ↓
[Backend] obtiene token FCM de Usuario B
     ↓
[Backend] envía a FCM
     ↓
[FCM] entrega a dispositivo
     ↓
[App] recibe notificación
     ├─ Foreground → Muestra notificación local
     ├─ Background → Sistema muestra notificación
     └─ Terminated → Sistema muestra notificación
     ↓
[Usuario B] toca notificación
     ↓
[App] navega a pantalla correspondiente
     ↓
[App] marca como leída en Supabase
```

## 2. Estructura de Datos

### 2.1 Tabla: device_tokens

```sql
CREATE TABLE device_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  platform TEXT CHECK (platform IN ('android', 'ios', 'web')),
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, token)
);

CREATE INDEX idx_device_tokens_user ON device_tokens(user_id);
CREATE INDEX idx_device_tokens_token ON device_tokens(token);
```

**Campos:**
- `id`: Identificador único
- `user_id`: Usuario propietario del dispositivo
- `token`: Token FCM del dispositivo
- `platform`: Plataforma (android/ios/web)
- `created_at`: Fecha de creación
- `updated_at`: Fecha de última actualización

### 2.2 Tabla: notifications

```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB,
  read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_notifications_user ON notifications(user_id);
CREATE INDEX idx_notifications_read ON notifications(read);
CREATE INDEX idx_notifications_created ON notifications(created_at DESC);
```

**Campos:**
- `id`: Identificador único
- `user_id`: Usuario destinatario
- `type`: Tipo de notificación (connection_request, new_message, etc.)
- `title`: Título de la notificación
- `body`: Cuerpo del mensaje
- `data`: Datos adicionales en formato JSON
- `read`: Si fue leída o no
- `read_at`: Fecha/hora de lectura
- `created_at`: Fecha de creación

### 2.3 Tipos de Notificaciones

```dart
enum NotificationType {
  connectionRequest('connection_request'),
  connectionAccepted('connection_accepted'),
  newMessage('new_message'),
  newRating('new_rating'),
  eventInvitation('event_invitation'),
  eventReminder('event_reminder');

  final String value;
  const NotificationType(this.value);
}
```

### 2.4 Modelo de Notificación

```dart
class NotificationModel {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final bool read;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    required this.read,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      userId: json['user_id'],
      type: NotificationType.values.firstWhere(
        (e) => e.value == json['type'],
      ),
      title: json['title'],
      body: json['body'],
      data: json['data'],
      read: json['read'] ?? false,
      readAt: json['read_at'] != null 
        ? DateTime.parse(json['read_at']) 
        : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
```

## 3. Implementación de NotificationService

### 3.1 Estructura del Servicio

```dart
class NotificationService {
  // Instancias
  static final FirebaseMessaging _firebaseMessaging;
  static final FlutterLocalNotificationsPlugin _localNotifications;
  static final _supabase = Supabase.instance.client;

  // Métodos públicos
  static Future<void> initialize();
  static Future<int> getUnreadCount();
  static Future<void> markAsRead(String notificationId);
  static Future<void> markAllAsRead();
  
  // Métodos privados
  static Future<void> _requestPermissions();
  static Future<void> _setupLocalNotifications();
  static Future<void> _saveDeviceToken();
  static void _setupMessageHandlers();
  static Future<void> _showLocalNotification(RemoteMessage message);
  static void _handleNotificationTap(Map<String, dynamic> data);
}
```

### 3.2 Inicialización

```dart
static Future<void> initialize() async {
  // 1. Solicitar permisos
  await _requestPermissions();
  
  // 2. Configurar notificaciones locales
  await _setupLocalNotifications();
  
  // 3. Obtener y guardar token FCM
  await _saveDeviceToken();
  
  // 4. Configurar listeners
  _setupMessageHandlers();
}
```

### 3.3 Manejo de Mensajes

```dart
static void _setupMessageHandlers() {
  // Foreground
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _showLocalNotification(message);
  });

  // Background (app abierta pero en segundo plano)
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _handleNotificationTap(message.data);
  });

  // Terminated (app cerrada completamente)
  _firebaseMessaging.getInitialMessage().then((RemoteMessage? message) {
    if (message != null) {
      _handleNotificationTap(message.data);
    }
  });
}
```

### 3.4 Navegación desde Notificaciones

```dart
static void _handleNotificationTap(Map<String, dynamic> data) {
  final type = data['type'];
  final context = navigatorKey.currentContext;
  
  if (context == null) return;
  
  switch (type) {
    case 'connection_request':
      context.push('/connections/requests');
      break;
    case 'connection_accepted':
      context.push('/connections');
      break;
    case 'new_message':
      final userId = data['user_id'];
      final userName = data['user_name'];
      context.push('/messages/$userId', extra: userName);
      break;
    case 'new_rating':
      final userId = data['user_id'];
      context.push('/ratings/$userId');
      break;
    case 'event_invitation':
      final eventId = data['event_id'];
      context.push('/gig/$eventId');
      break;
  }
}
```

## 4. UI: Pantalla de Notificaciones

### 4.1 Estructura de NotificationsScreen

```dart
class NotificationsScreen extends StatefulWidget {
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }
  
  Future<void> _loadNotifications() async {
    // Cargar desde Supabase
  }
  
  Future<void> _markAsRead(String id) async {
    // Marcar como leída
  }
  
  Future<void> _markAllAsRead() async {
    // Marcar todas como leídas
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notificaciones'),
        actions: [
          if (_notifications.any((n) => !n.read))
            TextButton(
              onPressed: _markAllAsRead,
              child: Text('Marcar todas como leídas'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadNotifications,
        child: _buildNotificationsList(),
      ),
    );
  }
}
```

### 4.2 Widget de Notificación Individual

```dart
class NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  
  @override
  Widget build(BuildContext context) {
    return Container(
      color: notification.read ? null : Colors.blue.withOpacity(0.1),
      child: ListTile(
        leading: _buildIcon(),
        title: Text(
          notification.title,
          style: TextStyle(
            fontWeight: notification.read 
              ? FontWeight.normal 
              : FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(notification.body),
            SizedBox(height: 4),
            Text(
              _formatDate(notification.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: !notification.read 
          ? Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            )
          : null,
        onTap: onTap,
      ),
    );
  }
  
  Widget _buildIcon() {
    IconData icon;
    Color color;
    
    switch (notification.type) {
      case NotificationType.connectionRequest:
        icon = Icons.person_add;
        color = Colors.blue;
        break;
      case NotificationType.connectionAccepted:
        icon = Icons.check_circle;
        color = Colors.green;
        break;
      case NotificationType.newMessage:
        icon = Icons.message;
        color = Colors.purple;
        break;
      case NotificationType.newRating:
        icon = Icons.star;
        color = Colors.amber;
        break;
      case NotificationType.eventInvitation:
        icon = Icons.event;
        color = Colors.orange;
        break;
      case NotificationType.eventReminder:
        icon = Icons.alarm;
        color = Colors.red;
        break;
    }
    
    return CircleAvatar(
      backgroundColor: color.withOpacity(0.2),
      child: Icon(icon, color: color),
    );
  }
}
```

### 4.3 Badge de Contador

```dart
class NotificationBadge extends StatelessWidget {
  final int count;
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: 20,
                minHeight: 20,
              ),
              child: Text(
                count > 99 ? '99+' : count.toString(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
```

## 5. Integración con HomeScreen

### 5.1 Agregar Badge en AppBar

```dart
class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _unreadCount = 0;
  
  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    _setupRealtimeListener();
  }
  
  Future<void> _loadUnreadCount() async {
    final count = await NotificationService.getUnreadCount();
    setState(() => _unreadCount = count);
  }
  
  void _setupRealtimeListener() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;
    
    Supabase.instance.client
      .from('notifications')
      .stream(primaryKey: ['id'])
      .eq('user_id', userId)
      .listen((data) {
        _loadUnreadCount();
      });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: NotificationBadge(
              count: _unreadCount,
              child: Icon(Icons.notifications),
            ),
            onPressed: () {
              context.push('/notifications').then((_) {
                _loadUnreadCount();
              });
            },
          ),
        ],
      ),
      // ...
    );
  }
}
```

## 6. RLS Policies

### 6.1 Policies para device_tokens

```sql
-- Usuarios pueden gestionar sus propios tokens
CREATE POLICY "Users can manage their own tokens"
  ON device_tokens
  FOR ALL
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
```

### 6.2 Policies para notifications

```sql
-- Usuarios pueden ver sus propias notificaciones
CREATE POLICY "Users can view their own notifications"
  ON notifications
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- Usuarios pueden actualizar sus propias notificaciones
CREATE POLICY "Users can update their own notifications"
  ON notifications
  FOR UPDATE
  TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Sistema puede crear notificaciones para cualquier usuario
CREATE POLICY "System can create notifications"
  ON notifications
  FOR INSERT
  TO authenticated
  WITH CHECK (true);
```

## 7. Propiedades de Correctitud

### Propiedad 1: Token Persistence
**Descripción:** Un token FCM guardado debe persistir hasta que sea explícitamente eliminado o actualizado.

**Validación:**
```dart
// Test: Guardar token y verificar que persiste
test('Token persists after save', () async {
  final token = 'test_token_123';
  await NotificationService._saveDeviceToken(token);
  
  final saved = await _supabase
    .from('device_tokens')
    .select()
    .eq('token', token)
    .single();
  
  expect(saved['token'], equals(token));
});
```

### Propiedad 2: Notification Uniqueness
**Descripción:** No deben existir notificaciones duplicadas para el mismo evento.

**Validación:**
```dart
// Test: Crear notificación dos veces no debe duplicar
test('Notifications are unique', () async {
  final data = {
    'user_id': 'user123',
    'type': 'connection_request',
    'title': 'Test',
    'body': 'Test',
  };
  
  await _supabase.from('notifications').insert(data);
  
  // Intentar insertar de nuevo debe fallar o ser ignorado
  try {
    await _supabase.from('notifications').insert(data);
  } catch (e) {
    // Esperado
  }
  
  final count = await _supabase
    .from('notifications')
    .select()
    .eq('user_id', 'user123')
    .eq('type', 'connection_request');
  
  expect(count.length, equals(1));
});
```

### Propiedad 3: Read State Consistency
**Descripción:** Una notificación marcada como leída debe permanecer leída y tener read_at establecido.

**Validación:**
```dart
// Test: Marcar como leída establece read=true y read_at
test('Read state is consistent', () async {
  final notificationId = 'notif123';
  
  await NotificationService.markAsRead(notificationId);
  
  final notification = await _supabase
    .from('notifications')
    .select()
    .eq('id', notificationId)
    .single();
  
  expect(notification['read'], isTrue);
  expect(notification['read_at'], isNotNull);
});
```

### Propiedad 4: Badge Count Accuracy
**Descripción:** El contador de badges debe reflejar exactamente el número de notificaciones no leídas.

**Validación:**
```dart
// Test: Badge count matches unread notifications
test('Badge count is accurate', () async {
  final userId = 'user123';
  
  // Crear 3 notificaciones no leídas
  for (int i = 0; i < 3; i++) {
    await _supabase.from('notifications').insert({
      'user_id': userId,
      'type': 'test',
      'title': 'Test $i',
      'body': 'Test',
      'read': false,
    });
  }
  
  final count = await NotificationService.getUnreadCount();
  expect(count, equals(3));
  
  // Marcar una como leída
  final notifications = await _supabase
    .from('notifications')
    .select()
    .eq('user_id', userId)
    .limit(1);
  
  await NotificationService.markAsRead(notifications[0]['id']);
  
  final newCount = await NotificationService.getUnreadCount();
  expect(newCount, equals(2));
});
```

### Propiedad 5: Navigation Correctness
**Descripción:** Tocar una notificación debe navegar a la pantalla correcta según el tipo.

**Validación:**
```dart
// Test: Navigation routes match notification types
test('Navigation is correct for each type', () {
  final testCases = {
    'connection_request': '/connections/requests',
    'new_message': '/messages/user123',
    'new_rating': '/ratings/user123',
    'event_invitation': '/gig/123',
  };
  
  testCases.forEach((type, expectedRoute) {
    final data = {'type': type, 'user_id': 'user123', 'event_id': '123'};
    final route = NotificationService._getRouteForType(data);
    expect(route, equals(expectedRoute));
  });
});
```

### Propiedad 6: Token Refresh Handling
**Descripción:** Cuando un token FCM cambia, el nuevo token debe reemplazar al antiguo.

**Validación:**
```dart
// Test: Token refresh updates existing token
test('Token refresh updates correctly', () async {
  final userId = 'user123';
  final oldToken = 'old_token';
  final newToken = 'new_token';
  
  // Guardar token inicial
  await _supabase.from('device_tokens').insert({
    'user_id': userId,
    'token': oldToken,
    'platform': 'android',
  });
  
  // Simular refresh
  await NotificationService._saveDeviceToken(newToken);
  
  // Verificar que solo existe el nuevo token
  final tokens = await _supabase
    .from('device_tokens')
    .select()
    .eq('user_id', userId);
  
  expect(tokens.length, equals(1));
  expect(tokens[0]['token'], equals(newToken));
});
```

## 8. Testing Framework

### 8.1 Unit Tests

```dart
// test/services/notification_service_test.dart
void main() {
  group('NotificationService', () {
    test('initialize sets up all components', () async {
      await NotificationService.initialize();
      // Verificar que todos los componentes están configurados
    });
    
    test('getUnreadCount returns correct count', () async {
      // Test implementado en Propiedad 4
    });
    
    test('markAsRead updates notification', () async {
      // Test implementado en Propiedad 3
    });
    
    test('markAllAsRead updates all notifications', () async {
      // Implementar test
    });
  });
}
```

### 8.2 Widget Tests

```dart
// test/screens/notifications_screen_test.dart
void main() {
  testWidgets('NotificationsScreen displays notifications', (tester) async {
    await tester.pumpWidget(MaterialApp(home: NotificationsScreen()));
    await tester.pumpAndSettle();
    
    expect(find.byType(NotificationTile), findsWidgets);
  });
  
  testWidgets('Badge shows correct count', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: NotificationBadge(count: 5, child: Icon(Icons.notifications)),
    ));
    
    expect(find.text('5'), findsOneWidget);
  });
}
```

### 8.3 Integration Tests

```dart
// integration_test/notifications_flow_test.dart
void main() {
  testWidgets('Complete notification flow', (tester) async {
    // 1. Iniciar app
    await tester.pumpWidget(MyApp());
    await tester.pumpAndSettle();
    
    // 2. Simular recepción de notificación
    // 3. Verificar que badge se actualiza
    // 4. Tocar notificación
    // 5. Verificar navegación correcta
    // 6. Verificar que se marca como leída
  });
}
```

## 9. Manejo de Errores

### 9.1 Errores de Permisos

```dart
static Future<void> _requestPermissions() async {
  try {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      debugPrint('⚠️ Permisos de notificaciones denegados');
      // Mostrar diálogo explicativo
      _showPermissionDialog();
    }
  } catch (e) {
    debugPrint('❌ Error solicitando permisos: $e');
  }
}
```

### 9.2 Errores de Red

```dart
static Future<void> _saveDeviceToken() async {
  try {
    final token = await _firebaseMessaging.getToken();
    if (token == null) throw Exception('Token is null');
    
    await _supabase.from('device_tokens').upsert({
      'user_id': _supabase.auth.currentUser?.id,
      'token': token,
      'platform': Platform.isAndroid ? 'android' : 'ios',
    });
  } on PostgrestException catch (e) {
    debugPrint('❌ Error de base de datos: ${e.message}');
    // Reintentar después de 5 segundos
    Future.delayed(Duration(seconds: 5), _saveDeviceToken);
  } catch (e) {
    debugPrint('❌ Error guardando token: $e');
  }
}
```

### 9.3 Errores de Navegación

```dart
static void _handleNotificationTap(Map<String, dynamic> data) {
  try {
    final context = navigatorKey.currentContext;
    if (context == null) {
      debugPrint('⚠️ Context is null, cannot navigate');
      return;
    }
    
    final type = data['type'];
    if (type == null) {
      debugPrint('⚠️ Notification type is null');
      return;
    }
    
    // Navegar según tipo
    _navigateToScreen(context, type, data);
  } catch (e) {
    debugPrint('❌ Error navegando: $e');
  }
}
```

## 10. Performance Optimizations

### 10.1 Caché de Contador

```dart
class NotificationService {
  static int? _cachedUnreadCount;
  static DateTime? _lastCacheUpdate;
  
  static Future<int> getUnreadCount() async {
    // Usar caché si es reciente (< 30 segundos)
    if (_cachedUnreadCount != null && 
        _lastCacheUpdate != null &&
        DateTime.now().difference(_lastCacheUpdate!) < Duration(seconds: 30)) {
      return _cachedUnreadCount!;
    }
    
    // Obtener de base de datos
    final count = await _fetchUnreadCount();
    _cachedUnreadCount = count;
    _lastCacheUpdate = DateTime.now();
    return count;
  }
}
```

### 10.2 Paginación de Notificaciones

```dart
class _NotificationsScreenState extends State<NotificationsScreen> {
  static const int _pageSize = 20;
  int _currentPage = 0;
  bool _hasMore = true;
  
  Future<void> _loadNotifications() async {
    if (!_hasMore) return;
    
    final data = await _supabase
      .from('notifications')
      .select()
      .eq('user_id', _userId)
      .order('created_at', ascending: false)
      .range(_currentPage * _pageSize, (_currentPage + 1) * _pageSize - 1);
    
    if (data.length < _pageSize) {
      _hasMore = false;
    }
    
    setState(() {
      _notifications.addAll(data.map((e) => NotificationModel.fromJson(e)));
      _currentPage++;
    });
  }
}
```

## 11. Configuración de Firebase

### 11.1 Android Configuration

**android/app/build.gradle.kts:**
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("com.google.gms.google-services") // Agregar
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-messaging-ktx")
}
```

**android/build.gradle.kts:**
```kotlin
plugins {
    id("com.google.gms.google-services") version "4.4.0" apply false
}
```

**android/app/src/main/AndroidManifest.xml:**
```xml
<application>
    <service
        android:name="com.google.firebase.messaging.FirebaseMessagingService"
        android:exported="false">
        <intent-filter>
            <action android:name="com.google.firebase.MESSAGING_EVENT" />
        </intent-filter>
    </service>
    
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_channel_id"
        android:value="high_importance_channel" />
</application>
```

### 11.2 iOS Configuration

**ios/Runner/Info.plist:**
```xml
<key>UIBackgroundModes</key>
<array>
    <string>remote-notification</string>
</array>
```

## 12. Criterios de Aceptación

- ✅ Usuario puede recibir notificaciones en foreground, background y terminated
- ✅ Badge muestra contador correcto de notificaciones no leídas
- ✅ Tocar notificación navega a la pantalla correcta
- ✅ Notificaciones se pueden marcar como leídas individualmente
- ✅ Todas las notificaciones se pueden marcar como leídas de una vez
- ✅ Tokens FCM se guardan y actualizan correctamente
- ✅ RLS policies protegen los datos de notificaciones
- ✅ UI es consistente con el diseño de la app
- ✅ Todas las propiedades de correctitud pasan los tests

## 13. Documentación Adicional

- Guía de configuración: `GUIA_CONFIGURACION_FIREBASE_NOTIFICACIONES.md`
- Documentación de Firebase: https://firebase.google.com/docs/cloud-messaging
- Documentación de flutter_local_notifications: https://pub.dev/packages/flutter_local_notifications
