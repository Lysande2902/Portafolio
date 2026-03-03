# Design Document: Perfeccionamiento Óolale al 100%

## Overview

Este documento describe el diseño técnico para llevar la aplicación móvil Óolale del 80% al 100% de completitud. Óolale es una plataforma Flutter/Supabase para músicos que permite networking, colaboración y gestión de eventos. Los 10 sistemas base ya están implementados y funcionando. Este diseño se enfoca en las funcionalidades avanzadas necesarias para el lanzamiento en producción: mensajería mejorada, eventos completos, perfiles avanzados, portafolio multimedia, optimización y preparación para stores.

**Contexto Técnico Actual:**
- Frontend: Flutter 3.10+ con Dart 3.0+
- Backend: Supabase (PostgreSQL, Storage, Realtime)
- State Management: Provider Pattern
- Routing: GoRouter 17.0
- ~5,000 líneas de código Dart
- 40+ pantallas funcionales
- 10+ servicios implementados

## Architecture

### High-Level Architecture

La aplicación mantiene la arquitectura existente de 3 capas:

```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Screens, Widgets, Providers)          │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Business Logic Layer            │
│  (Services, Models, Validators)         │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│         Data Layer                      │
│  (Supabase Client, Storage, Realtime)   │
└─────────────────────────────────────────┘
```

### New Components

Las nuevas funcionalidades se integran en la arquitectura existente:

**Services Layer (Nuevos/Mejorados):**
- `RealtimeService` - Mejorado con reconexión automática y typing indicators
- `MediaService` - Mejorado con compresión y validación
- `EventService` - Extendido con invitaciones y calendario
- `ProfileService` - Extendido con cálculo de completitud
- `OptimizationService` - Nuevo para caché y paginación
- `AnalyticsService` - Nuevo para Firebase Analytics
- `PushNotificationService` - Nuevo para FCM

**Screens (Nuevas):**
- `EventHistoryScreen` - Historial de eventos pasados
- `EventCalendarScreen` - Calendario de eventos
- `EventInvitationsScreen` - Gestión de invitaciones
- `ProfileCompletionScreen` - Wizard de completitud de perfil
- `MediaGalleryScreen` - Galería multimedia mejorada

**Widgets (Nuevos):**
- `TypingIndicator` - Indicador de "escribiendo..."
- `ReadReceiptIcon` - Iconos de estado de lectura
- `MediaPreview` - Preview de multimedia antes de enviar
- `ProfileCompletionBar` - Barra de progreso de perfil
- `EventCalendarWidget` - Widget de calendario personalizado
- `MediaLightbox` - Visor de imágenes fullscreen

## Components and Interfaces

### 1. Realtime Messaging Service (Mejorado)

**Responsabilidad:** Gestionar comunicación en tiempo real con reconexión automática

```dart
class RealtimeService {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;
  Timer? _reconnectTimer;
  bool _isConnected = false;
  
  // Suscribirse a mensajes de un chat
  Future<void> subscribeToChat(String chatId, Function(Message) onMessage);
  
  // Enviar indicador de "escribiendo..."
  Future<void> sendTypingIndicator(String chatId, String userId);
  
  // Escuchar indicadores de escritura
  Stream<TypingEvent> listenToTyping(String chatId);
  
  // Reconexión automática
  Future<void> _handleReconnection();
  
  // Verificar estado de conexión
  bool get isConnected => _isConnected;
  
  // Limpiar recursos
  Future<void> dispose();
}

class TypingEvent {
  final String userId;
  final String chatId;
  final DateTime timestamp;
}
```

**Integración con Supabase Realtime:**
- Canal: `chat:{chatId}`
- Eventos: `INSERT` para mensajes nuevos, `BROADCAST` para typing indicators
- Reconexión: Retry exponencial (1s, 2s, 4s, 8s, max 30s)

### 2. Media Service (Mejorado)

**Responsabilidad:** Gestionar subida, compresión y validación de multimedia

```dart
class MediaService {
  final SupabaseClient _supabase;
  final ImageCompressor _compressor;
  
  // Subir imagen con compresión
  Future<String> uploadImage(File image, {
    required String bucket,
    required String path,
    int quality = 85,
    int maxWidth = 1920,
  });
  
  // Subir video con validación
  Future<String> uploadVideo(File video, {
    required String bucket,
    required String path,
    int maxSizeMB = 100,
  });
  
  // Subir audio con validación
  Future<String> uploadAudio(File audio, {
    required String bucket,
    required String path,
    int maxSizeMB = 50,
  });
  
  // Validar tipo de archivo
  bool validateFileType(File file, List<String> allowedExtensions);
  
  // Validar tamaño de archivo
  bool validateFileSize(File file, int maxSizeMB);
  
  // Comprimir imagen
  Future<File> compressImage(File image, int quality);
  
  // Generar thumbnail de video
  Future<File> generateVideoThumbnail(File video);
}
```

**Configuración de Compresión:**
- Imágenes: JPEG quality 85%, max width 1920px
- Videos: Max 100MB, formatos: mp4, mov
- Audios: Max 50MB, formatos: mp3, wav, m4a

### 3. Event Service (Extendido)

**Responsabilidad:** Gestionar eventos, invitaciones y calendario

```dart
class EventService {
  final SupabaseClient _supabase;
  
  // Obtener historial de eventos pasados
  Future<List<Event>> getEventHistory(String userId);
  
  // Obtener eventos por fecha
  Future<List<Event>> getEventsForDate(DateTime date);
  
  // Obtener eventos del mes (para calendario)
  Future<Map<DateTime, List<Event>>> getEventsForMonth(int year, int month);
  
  // Enviar invitaciones a músicos
  Future<void> sendInvitations(String eventId, List<String> musicianIds);
  
  // Responder a invitación
  Future<void> respondToInvitation(String invitationId, bool accept);
  
  // Obtener invitaciones pendientes
  Future<List<EventInvitation>> getPendingInvitations(String userId);
  
  // Confirmar asistencia (agregar a lineup)
  Future<void> confirmAttendance(String eventId, String userId);
  
  // Obtener participantes para calificar
  Future<List<Profile>> getParticipantsToRate(String eventId, String userId);
  
  // Verificar si puede calificar evento
  Future<bool> canRateEvent(String eventId, String userId);
  
  // Trigger automático de calificación post-evento
  Future<void> triggerPostEventRating(String eventId);
}

class EventInvitation {
  final String id;
  final String eventId;
  final String musicianId;
  final String organizerId;
  final String status; // 'pending', 'accepted', 'declined'
  final DateTime createdAt;
  final Event? event; // Populated
}
```

### 4. Profile Service (Extendido)

**Responsabilidad:** Gestionar perfiles completos con cálculo de completitud

```dart
class ProfileService {
  final SupabaseClient _supabase;
  
  // Calcular porcentaje de completitud
  Future<int> calculateProfileCompletion(String userId);
  
  // Obtener campos faltantes
  Future<List<String>> getMissingFields(String userId);
  
  // Actualizar géneros musicales
  Future<void> updateGenres(String userId, List<String> genres);
  
  // Actualizar experiencia
  Future<void> updateExperience(String userId, int years, String level);
  
  // Actualizar disponibilidad
  Future<void> updateAvailability(String userId, Map<String, bool> availability);
  
  // Actualizar tarifas
  Future<void> updateRates(String userId, double baseRate, String currency);
  
  // Actualizar redes sociales
  Future<void> updateSocialLinks(String userId, Map<String, String> links);
  
  // Actualizar idiomas
  Future<void> updateLanguages(String userId, List<String> languages);
}

class ProfileCompletionResult {
  final int percentage;
  final List<String> completedFields;
  final List<String> missingFields;
  final Map<String, int> fieldWeights;
}
```

**Campos para Completitud (11 campos, ~9% cada uno):**
1. Nombre completo (required)
2. Bio/Descripción (required)
3. Ubicación/País (required)
4. Instrumento principal (required)
5. Avatar (required)
6. Géneros musicales (min 1)
7. Años de experiencia
8. Disponibilidad (min 1 día)
9. Tarifa base
10. Redes sociales (min 1)
11. Portafolio multimedia (min 3 items)

### 5. Optimization Service (Nuevo)

**Responsabilidad:** Gestionar caché, paginación y optimización

```dart
class OptimizationService {
  final SharedPreferences _prefs;
  final Map<String, dynamic> _memoryCache = {};
  
  // Caché de perfiles
  Future<Profile?> getCachedProfile(String userId);
  Future<void> cacheProfile(Profile profile);
  Future<void> clearProfileCache();
  
  // Caché de conexiones
  Future<List<Connection>?> getCachedConnections(String userId);
  Future<void> cacheConnections(String userId, List<Connection> connections);
  
  // Paginación genérica
  Future<PaginatedResult<T>> paginate<T>({
    required Future<List<T>> Function(int offset, int limit) fetcher,
    required int page,
    int pageSize = 20,
  });
  
  // Lazy loading de imágenes
  Widget buildLazyImage(String url, {Widget? placeholder});
  
  // Limpiar caché completo
  Future<void> clearAllCache();
  
  // Obtener tamaño de caché
  Future<int> getCacheSize();
}

class PaginatedResult<T> {
  final List<T> items;
  final int currentPage;
  final int totalPages;
  final bool hasMore;
}
```

### 6. Analytics Service (Nuevo)

**Responsabilidad:** Tracking de eventos con Firebase Analytics

```dart
class AnalyticsService {
  final FirebaseAnalytics _analytics;
  
  // Eventos de autenticación
  Future<void> logSignUp(String method);
  Future<void> logLogin(String method);
  Future<void> logLogout();
  
  // Eventos de perfil
  Future<void> logProfileView(String userId);
  Future<void> logProfileEdit();
  Future<void> logProfileCompletion(int percentage);
  
  // Eventos de conexiones
  Future<void> logConnectionRequest(String targetUserId);
  Future<void> logConnectionAccept(String userId);
  
  // Eventos de mensajes
  Future<void> logMessageSent(String type); // 'text', 'image', 'audio'
  Future<void> logChatOpened(String chatId);
  
  // Eventos de eventos
  Future<void> logEventCreated(String eventType);
  Future<void> logEventInvitation(String eventId);
  Future<void> logEventAttendance(String eventId);
  
  // Eventos de búsqueda
  Future<void> logSearch(String query, int resultsCount);
  Future<void> logFilterApplied(Map<String, dynamic> filters);
  
  // Eventos de multimedia
  Future<void> logMediaUpload(String type, int sizeMB);
  Future<void> logMediaView(String type);
  
  // Propiedades de usuario
  Future<void> setUserProperties(Map<String, dynamic> properties);
}
```

### 7. Push Notification Service (Nuevo)

**Responsabilidad:** Gestionar notificaciones push con FCM

```dart
class PushNotificationService {
  final FirebaseMessaging _messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  
  // Inicializar FCM
  Future<void> initialize();
  
  // Solicitar permisos
  Future<bool> requestPermissions();
  
  // Obtener token FCM
  Future<String?> getToken();
  
  // Guardar token en Supabase
  Future<void> saveTokenToDatabase(String userId, String token);
  
  // Manejar mensajes en foreground
  void handleForegroundMessage(RemoteMessage message);
  
  // Manejar mensajes en background
  static Future<void> handleBackgroundMessage(RemoteMessage message);
  
  // Manejar tap en notificación
  void handleNotificationTap(RemoteMessage message);
  
  // Mostrar notificación local
  Future<void> showLocalNotification({
    required String title,
    required String body,
    String? payload,
  });
  
  // Cancelar todas las notificaciones
  Future<void> cancelAllNotifications();
}
```

## Data Models

### Extended Message Model

```dart
class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String? text;
  final String? mediaUrl;
  final String? mediaType; // 'image', 'audio', 'video'
  final bool isRead;
  final DateTime? readAt;
  final DateTime? deliveredAt;
  final DateTime createdAt;
  
  // Estado de lectura
  MessageStatus get status {
    if (readAt != null) return MessageStatus.read;
    if (deliveredAt != null) return MessageStatus.delivered;
    return MessageStatus.sent;
  }
}

enum MessageStatus {
  sent,      // ✓
  delivered, // ✓✓
  read,      // ✓✓ (color)
}
```

### Event Invitation Model

```dart
class EventInvitation {
  final String id;
  final String eventId;
  final String musicianId;
  final String organizerId;
  final InvitationStatus status;
  final String? role; // 'headliner', 'support', 'guest'
  final DateTime createdAt;
  final DateTime? respondedAt;
  
  // Relaciones
  final Event? event;
  final Profile? musician;
  final Profile? organizer;
}

enum InvitationStatus {
  pending,
  accepted,
  declined,
  cancelled,
}
```

### Extended Profile Model

```dart
class Profile {
  // Campos existentes...
  final String id;
  final String name;
  final String? bio;
  final String? location;
  final String? instrument;
  final String? avatarUrl;
  
  // Nuevos campos
  final List<String> genres;
  final int? yearsExperience;
  final String? skillLevel; // 'beginner', 'intermediate', 'advanced', 'professional'
  final Map<String, bool>? availability; // {'monday': true, 'tuesday': false, ...}
  final double? baseRate;
  final String? currency;
  final List<String>? eventTypes; // ['concert', 'wedding', 'studio', ...]
  final Map<String, String>? socialLinks; // {'instagram': 'url', 'youtube': 'url', ...}
  final int profileCompletion; // 0-100
  final String? country;
  final List<String>? languages;
  
  // Método helper
  bool get isProfileComplete => profileCompletion >= 60;
}
```

### Portfolio Media Model (Extended)

```dart
class PortfolioMedia {
  final String id;
  final String userId;
  final String url;
  final String type; // 'image', 'video', 'audio'
  final String? title;
  final String? description;
  final int order;
  final bool isFeatured; // Foto de portada
  final String? albumId; // Para agrupar en álbumes
  final DateTime createdAt;
  
  // Metadata
  final int? fileSizeMB;
  final int? durationSeconds; // Para audio/video
  final String? thumbnailUrl; // Para videos
}

class MediaAlbum {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final int mediaCount;
  final String? coverUrl;
  final DateTime createdAt;
}
```

## Database Schema Changes

### New Tables

```sql
-- Tabla de invitaciones a eventos
CREATE TABLE event_invitations (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_id UUID REFERENCES gigs(id) ON DELETE CASCADE,
  musician_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  organizer_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  status VARCHAR(20) DEFAULT 'pending',
  role VARCHAR(50),
  created_at TIMESTAMP DEFAULT NOW(),
  responded_at TIMESTAMP,
  UNIQUE(event_id, musician_id)
);

-- Tabla de álbumes de portafolio
CREATE TABLE media_albums (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  description TEXT,
  cover_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Tabla de tokens FCM
CREATE TABLE fcm_tokens (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  device_type VARCHAR(20), -- 'android', 'ios'
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id, token)
);

-- Tabla de configuración de caché
CREATE TABLE cache_settings (
  user_id UUID PRIMARY KEY REFERENCES profiles(id) ON DELETE CASCADE,
  auto_download_media VARCHAR(20) DEFAULT 'wifi', -- 'always', 'wifi', 'never'
  image_quality VARCHAR(20) DEFAULT 'high', -- 'high', 'medium', 'low'
  cache_size_mb INTEGER DEFAULT 0,
  last_cleared_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);
```

### Modified Tables

```sql
-- Agregar columnas a profiles
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS years_experience INTEGER;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS skill_level VARCHAR(50);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS availability JSONB;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS base_rate DECIMAL(10,2);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS currency VARCHAR(3) DEFAULT 'MXN';
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS event_types TEXT[];
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS social_links JSONB;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS profile_completion INTEGER DEFAULT 0;
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS country VARCHAR(100);
ALTER TABLE profiles ADD COLUMN IF NOT EXISTS languages TEXT[];

-- Agregar columnas a intercom (mensajes)
ALTER TABLE intercom ADD COLUMN IF NOT EXISTS media_url TEXT;
ALTER TABLE intercom ADD COLUMN IF NOT EXISTS media_type VARCHAR(20);
ALTER TABLE intercom ADD COLUMN IF NOT EXISTS read_at TIMESTAMP;
ALTER TABLE intercom ADD COLUMN IF NOT EXISTS delivered_at TIMESTAMP;

-- Agregar columnas a gigs (eventos)
ALTER TABLE gigs ADD COLUMN IF NOT EXISTS lineup UUID[];
ALTER TABLE gigs ADD COLUMN IF NOT EXISTS event_photos TEXT[];
ALTER TABLE gigs ADD COLUMN IF NOT EXISTS roles JSONB; -- {'user_id': 'headliner', ...}

-- Agregar columnas a portfolio_media
ALTER TABLE portfolio_media ADD COLUMN IF NOT EXISTS title VARCHAR(200);
ALTER TABLE portfolio_media ADD COLUMN IF NOT EXISTS description TEXT;
ALTER TABLE portfolio_media ADD COLUMN IF NOT EXISTS order_index INTEGER DEFAULT 0;
ALTER TABLE portfolio_media ADD COLUMN IF NOT EXISTS is_featured BOOLEAN DEFAULT FALSE;
ALTER TABLE portfolio_media ADD COLUMN IF NOT EXISTS album_id UUID REFERENCES media_albums(id);
ALTER TABLE portfolio_media ADD COLUMN IF NOT EXISTS thumbnail_url TEXT;
```

### Indexes for Performance

```sql
-- Índices para mensajes
CREATE INDEX IF NOT EXISTS idx_messages_receiver_unread 
  ON intercom(destinatario_id) WHERE leido = FALSE;

CREATE INDEX IF NOT EXISTS idx_messages_conversation 
  ON intercom(remitente_id, destinatario_id, created_at DESC);

-- Índices para eventos
CREATE INDEX IF NOT EXISTS idx_events_date ON gigs(fecha_gig);
CREATE INDEX IF NOT EXISTS idx_events_organizer ON gigs(organizador_id);
CREATE INDEX IF NOT EXISTS idx_event_invitations_musician 
  ON event_invitations(musician_id, status);

-- Índices para perfiles
CREATE INDEX IF NOT EXISTS idx_profiles_completion 
  ON profiles(profile_completion DESC);
CREATE INDEX IF NOT EXISTS idx_profiles_country ON profiles(country);
CREATE INDEX IF NOT EXISTS idx_profiles_genres ON profiles USING GIN(genres);

-- Índices para portafolio
CREATE INDEX IF NOT EXISTS idx_portfolio_user_type 
  ON portfolio_media(user_id, type, order_index);
CREATE INDEX IF NOT EXISTS idx_portfolio_featured 
  ON portfolio_media(user_id) WHERE is_featured = TRUE;
```

### Database Functions

```sql
-- Función para calcular completitud de perfil
CREATE OR REPLACE FUNCTION calculate_profile_completion(user_id UUID)
RETURNS INTEGER AS $$
DECLARE
  completion INTEGER := 0;
  field_weight INTEGER := 9; -- 11 campos = ~9% cada uno
BEGIN
  SELECT 
    (CASE WHEN name IS NOT NULL AND name != '' THEN field_weight ELSE 0 END) +
    (CASE WHEN bio IS NOT NULL AND bio != '' THEN field_weight ELSE 0 END) +
    (CASE WHEN location IS NOT NULL AND location != '' THEN field_weight ELSE 0 END) +
    (CASE WHEN instrument IS NOT NULL AND instrument != '' THEN field_weight ELSE 0 END) +
    (CASE WHEN avatar_url IS NOT NULL THEN field_weight ELSE 0 END) +
    (CASE WHEN array_length(genres, 1) > 0 THEN field_weight ELSE 0 END) +
    (CASE WHEN years_experience IS NOT NULL THEN field_weight ELSE 0 END) +
    (CASE WHEN availability IS NOT NULL THEN field_weight ELSE 0 END) +
    (CASE WHEN base_rate IS NOT NULL THEN field_weight ELSE 0 END) +
    (CASE WHEN social_links IS NOT NULL AND jsonb_object_keys(social_links) IS NOT NULL THEN field_weight ELSE 0 END) +
    (CASE WHEN (SELECT COUNT(*) FROM portfolio_media WHERE user_id = $1) >= 3 THEN field_weight ELSE 0 END)
  INTO completion
  FROM profiles
  WHERE id = user_id;
  
  RETURN COALESCE(completion, 0);
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar completitud automáticamente
CREATE OR REPLACE FUNCTION update_profile_completion()
RETURNS TRIGGER AS $$
BEGIN
  NEW.profile_completion := calculate_profile_completion(NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_profile_completion
  BEFORE INSERT OR UPDATE ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_profile_completion();

-- Función para trigger de calificación post-evento
CREATE OR REPLACE FUNCTION trigger_post_event_rating()
RETURNS TRIGGER AS $$
BEGIN
  -- Si el evento acaba de pasar (fecha_gig < NOW())
  IF NEW.fecha_gig < NOW() AND OLD.fecha_gig >= NOW() THEN
    -- Crear notificaciones para todos los participantes
    INSERT INTO notifications (user_id, type, title, body, reference_id, reference_type)
    SELECT 
      unnest(NEW.lineup),
      'event_rating',
      'Califica el evento',
      'El evento "' || NEW.titulo_bolo || '" ha finalizado. Califica a los participantes.',
      NEW.id,
      'event'
    WHERE NEW.lineup IS NOT NULL;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_event_rating_notification
  AFTER UPDATE ON gigs
  FOR EACH ROW
  EXECUTE FUNCTION trigger_post_event_rating();
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

