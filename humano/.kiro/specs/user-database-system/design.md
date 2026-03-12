# Design Document - User Database System

## Overview

El sistema de base de datos multi-usuario proporciona una capa de persistencia completa para todos los datos individuales de cada jugador. Utiliza Firebase Firestore como backend, implementando una arquitectura de repositorios y providers que garantiza la separación de responsabilidades, sincronización en tiempo real y manejo robusto de errores.

El diseño sigue el patrón Repository para abstraer el acceso a datos y el patrón Provider (ChangeNotifier) para gestionar el estado de la aplicación y notificar cambios a la UI.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         UI Layer                             │
│  (Screens, Widgets - consume providers via Provider.of)     │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                    Provider Layer                            │
│  - UserDataProvider (ChangeNotifier)                        │
│  - ArcProgressProvider (ChangeNotifier)                     │
│  - StoreProvider (ChangeNotifier)                           │
│  - SettingsProvider (ChangeNotifier)                        │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                  Repository Layer                            │
│  - UserRepository (CRUD operations)                         │
│  - Handles Firestore interactions                           │
│  - Error handling & retry logic                             │
└────────────────────┬────────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────────┐
│                   Firestore Database                         │
│  Collection: users/{userId}                                 │
│    - arcProgress: Map<String, ArcProgress>                  │
│    - inventory: PlayerInventory                             │
│    - stats: UserStats                                       │
│    - settings: GameSettings                                 │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

1. **User Authentication** → AuthProvider detecta cambio → UserDataProvider inicializa
2. **Data Load** → UserRepository.getUser() → Firestore fetch → Provider actualiza estado
3. **Real-time Updates** → Firestore listener → Provider notifica → UI se actualiza
4. **User Actions** → UI llama método del Provider → Repository escribe a Firestore → Listener detecta cambio → UI se actualiza

## Components and Interfaces

### 1. UserRepository

Responsable de todas las operaciones CRUD con Firestore para documentos de usuario.

```dart
class UserRepository {
  final FirebaseFirestore _firestore;
  
  // Obtener documento de usuario
  Future<UserData?> getUser(String userId);
  
  // Crear nuevo usuario con datos iniciales
  Future<void> createUser(String userId, UserData initialData);
  
  // Actualizar progreso de arco específico
  Future<void> updateArcProgress(String userId, String arcId, ArcProgress progress);
  
  // Actualizar inventario completo
  Future<void> updateInventory(String userId, PlayerInventory inventory);
  
  // Actualizar configuraciones
  Future<void> updateSettings(String userId, GameSettings settings);
  
  // Actualizar estadísticas
  Future<void> updateStats(String userId, UserStats stats);
  
  // Agregar evidencia a un arco
  Future<void> addEvidenceToArc(String userId, String arcId, String evidenceId);
  
  // Listener en tiempo real para cambios del usuario
  Stream<UserData?> watchUser(String userId);
  
  // Transacción atómica para compras
  Future<bool> purchaseItem(String userId, String itemId, int price);
}
```

### 2. UserDataProvider

Provider principal que gestiona el estado completo del usuario autenticado.

```dart
class UserDataProvider extends ChangeNotifier {
  final UserRepository _repository;
  final AuthProvider _authProvider;
  
  UserData? _userData;
  bool _isLoading = false;
  String? _errorMessage;
  StreamSubscription? _userSubscription;
  
  // Getters
  UserData? get userData;
  bool get isLoading;
  String? get errorMessage;
  PlayerInventory get inventory;
  GameSettings get settings;
  UserStats get stats;
  Map<String, ArcProgress> get arcProgress;
  
  // Inicializar listener cuando usuario se autentica
  Future<void> initialize(String userId);
  
  // Actualizar progreso de arco
  Future<void> updateArcProgress(String arcId, ArcProgress progress);
  
  // Agregar evidencia
  Future<void> addEvidence(String arcId, String evidenceId);
  
  // Actualizar inventario
  Future<void> updateInventory(PlayerInventory inventory);
  
  // Comprar item (transacción atómica)
  Future<bool> purchaseItem(String itemId, int price);
  
  // Actualizar configuraciones
  Future<void> updateSettings(GameSettings settings);
  
  // Actualizar estadísticas
  Future<void> updateStats(UserStats stats);
  
  // Limpiar al cerrar sesión
  void dispose();
}
```

### 3. UserData Model

Modelo que encapsula todos los datos de un usuario.

```dart
class UserData {
  final String userId;
  final Map<String, ArcProgress> arcProgress;
  final PlayerInventory inventory;
  final GameSettings settings;
  final UserStats stats;
  final DateTime lastUpdated;
  
  const UserData({
    required this.userId,
    required this.arcProgress,
    required this.inventory,
    required this.settings,
    required this.stats,
    required this.lastUpdated,
  });
  
  factory UserData.initial(String userId);
  factory UserData.fromFirestore(DocumentSnapshot doc);
  Map<String, dynamic> toFirestore();
  UserData copyWith({...});
}
```

## Data Models

### Firestore Document Structure

```json
{
  "users": {
    "{userId}": {
      "userId": "string",
      "lastUpdated": "timestamp",
      
      "arcProgress": {
        "arc_gluttony": {
          "arcId": "arc_gluttony",
          "status": "inProgress",
          "progressPercent": 45.5,
          "lastPlayed": "2025-11-25T10:30:00Z",
          "attemptsCount": 3,
          "evidencesCollected": ["evidence_1", "evidence_2"]
        },
        "arc_greed": {
          "arcId": "arc_greed",
          "status": "completed",
          "progressPercent": 100.0,
          "lastPlayed": "2025-11-24T15:20:00Z",
          "attemptsCount": 5,
          "evidencesCollected": ["evidence_1", "evidence_2", "evidence_3"]
        }
      },
      
      "inventory": {
        "coins": 5000,
        "ownedItems": ["skin_player_detective", "consumable_shield"],
        "hasBattlePass": false,
        "battlePassLevel": 0
      },
      
      "settings": {
        "musicVolume": 0.7,
        "sfxVolume": 0.8,
        "ambientVolume": 0.5,
        "vhsEffectsEnabled": true,
        "glitchEffectsEnabled": true,
        "screenShakeEnabled": true
      },
      
      "stats": {
        "userId": "string",
        "totalPlayTimeMinutes": 120,
        "accountCreatedAt": "2025-11-20T08:00:00Z",
        "arcsCompleted": 2,
        "totalAttempts": 8
      }
    }
  }
}
```

### Model Relationships

```
UserData
├── userId: String
├── arcProgress: Map<String, ArcProgress>
│   └── [arcId]: ArcProgress
│       ├── arcId: String
│       ├── status: ArcStatus (enum)
│       ├── progressPercent: double
│       ├── lastPlayed: DateTime?
│       ├── attemptsCount: int
│       └── evidencesCollected: List<String>
├── inventory: PlayerInventory
│   ├── coins: int
│   ├── ownedItems: Set<String>
│   ├── hasBattlePass: bool
│   └── battlePassLevel: int
├── settings: GameSettings
│   ├── musicVolume: double
│   ├── sfxVolume: double
│   ├── ambientVolume: double
│   ├── vhsEffectsEnabled: bool
│   ├── glitchEffectsEnabled: bool
│   └── screenShakeEnabled: bool
├── stats: UserStats
│   ├── userId: String
│   ├── totalPlayTimeMinutes: int
│   ├── accountCreatedAt: DateTime
│   ├── arcsCompleted: int
│   └── totalAttempts: int
└── lastUpdated: DateTime
```

## 
#
# Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Acceptance Criteria Testing Prework

1.1 WHEN un usuario se autentica exitosamente THEN el sistema SHALL crear o recuperar su documento de usuario en Firestore
Thoughts: Este es un comportamiento que debe ocurrir para todos los usuarios autenticados. Podemos generar usuarios aleatorios, autenticarlos, y verificar que existe un documento en Firestore con su userId.
Testable: yes - property

1.2 WHEN un usuario inicia sesión por primera vez THEN el sistema SHALL inicializar su documento con valores por defecto (5000 monedas, 0 arcos completados, configuraciones predeterminadas)
Thoughts: Este es un caso específico de inicialización. Es importante pero es un ejemplo específico del primer inicio de sesión.
Testable: yes - example

1.3 WHEN un usuario realiza cambios en su progreso THEN el sistema SHALL sincronizar automáticamente los cambios con Firestore
Thoughts: Este comportamiento debe aplicarse a cualquier cambio de progreso. Podemos generar cambios aleatorios y verificar que se reflejan en Firestore.
Testable: yes - property

1.4 WHEN un usuario cierra sesión THEN el sistema SHALL mantener todos sus datos persistidos en Firestore
Thoughts: Este es un comportamiento que debe aplicarse a todos los usuarios. Podemos generar datos aleatorios, cerrar sesión, y verificar que los datos persisten.
Testable: yes - property

1.5 WHEN un usuario inicia sesión desde otro dispositivo THEN el sistema SHALL cargar su progreso más reciente desde Firestore
Thoughts: Este es un comportamiento de sincronización que debe funcionar para cualquier usuario. Es una propiedad de round-trip: guardar → cerrar sesión → iniciar sesión → cargar debe retornar los mismos datos.
Testable: yes - property

2.1 WHEN un usuario inicia un arco THEN el sistema SHALL crear o actualizar el registro de progreso para ese arco con estado "inProgress"
Thoughts: Este comportamiento debe aplicarse a cualquier combinación de usuario y arco. Podemos generar usuarios y arcos aleatorios y verificar el estado.
Testable: yes - property

2.2 WHEN un usuario recolecta una evidencia THEN el sistema SHALL agregar el ID de la evidencia a la lista de evidencias recolectadas del arco
Thoughts: Este es un comportamiento que debe funcionar para cualquier evidencia en cualquier arco. Podemos verificar que la lista crece y contiene el ID.
Testable: yes - property

2.3 WHEN un usuario completa un arco THEN el sistema SHALL actualizar el estado del arco a "completed" y actualizar el contador de arcos completados
Thoughts: Este comportamiento debe aplicarse a cualquier arco completado. Podemos verificar ambas actualizaciones ocurren atómicamente.
Testable: yes - property

2.4 WHEN un usuario abandona un arco THEN el sistema SHALL guardar el porcentaje de progreso actual y la fecha de última jugada
Thoughts: Este comportamiento debe funcionar para cualquier arco en progreso. Podemos verificar que ambos campos se guardan correctamente.
Testable: yes - property

2.5 WHEN un usuario consulta su progreso THEN el sistema SHALL retornar el estado actualizado de todos los arcos desde Firestore
Thoughts: Este es un comportamiento de lectura que debe funcionar para cualquier usuario. Es una propiedad de consistencia: lo que se escribe debe poder leerse.
Testable: yes - property

3.1 WHEN un usuario compra un item en la tienda THEN el sistema SHALL deducir las monedas del inventario y agregar el item a la lista de items poseídos
Thoughts: Este es un comportamiento transaccional que debe funcionar para cualquier compra válida. Podemos verificar que ambas operaciones ocurren atómicamente.
Testable: yes - property

3.2 WHEN un usuario recibe monedas como recompensa THEN el sistema SHALL incrementar el balance de monedas en Firestore inmediatamente
Thoughts: Este comportamiento debe funcionar para cualquier cantidad de monedas. Podemos verificar que el balance aumenta correctamente.
Testable: yes - property

3.3 WHEN un usuario compra el battle pass THEN el sistema SHALL actualizar el campo hasBattlePass a true y establecer el nivel inicial
Thoughts: Este es un caso específico de compra. Es un ejemplo importante pero específico.
Testable: yes - example

3.4 WHEN un usuario equipa un item THEN el sistema SHALL actualizar el estado de equipamiento del item en Firestore
Thoughts: Este comportamiento debe funcionar para cualquier item equipable. Podemos generar items aleatorios y verificar el estado.
Testable: yes - property

3.5 WHEN ocurre un error en una transacción THEN el sistema SHALL revertir los cambios locales y mantener la consistencia con Firestore
Thoughts: Este es un comportamiento de manejo de errores que debe funcionar para cualquier transacción fallida. Es una propiedad de atomicidad.
Testable: yes - property

4.1 WHEN un usuario ajusta el volumen de música THEN el sistema SHALL actualizar el valor de musicVolume en Firestore
Thoughts: Este comportamiento debe funcionar para cualquier valor de volumen válido (0.0 - 1.0). Podemos generar valores aleatorios y verificar la actualización.
Testable: yes - property

4.2 WHEN un usuario ajusta el volumen de efectos de sonido THEN el sistema SHALL actualizar el valor de sfxVolume en Firestore
Thoughts: Similar a 4.1, este comportamiento debe funcionar para cualquier valor válido.
Testable: yes - property

4.3 WHEN un usuario activa o desactiva efectos VHS THEN el sistema SHALL actualizar el campo vhsEffectsEnabled en Firestore
Thoughts: Este comportamiento debe funcionar para ambos valores booleanos. Podemos verificar que el toggle funciona correctamente.
Testable: yes - property

4.4 WHEN un usuario activa o desactiva efectos de glitch THEN el sistema SHALL actualizar el campo glitchEffectsEnabled en Firestore
Thoughts: Similar a 4.3, debe funcionar para cualquier valor booleano.
Testable: yes - property

4.5 WHEN un usuario inicia sesión THEN el sistema SHALL cargar sus configuraciones guardadas y aplicarlas a la aplicación
Thoughts: Este es un comportamiento de round-trip: guardar configuraciones → cerrar sesión → iniciar sesión → cargar debe retornar las mismas configuraciones.
Testable: yes - property

5.1 WHEN un usuario completa una sesión de juego THEN el sistema SHALL incrementar el tiempo total de juego en minutos
Thoughts: Este comportamiento debe funcionar para cualquier duración de sesión. Podemos verificar que el tiempo se acumula correctamente.
Testable: yes - property

5.2 WHEN un usuario completa un arco THEN el sistema SHALL incrementar el contador de arcos completados
Thoughts: Este comportamiento debe funcionar para cualquier arco. Podemos verificar que el contador aumenta en 1.
Testable: yes - property

5.3 WHEN un usuario intenta un arco THEN el sistema SHALL incrementar el contador de intentos totales
Thoughts: Este comportamiento debe funcionar para cualquier intento. Podemos verificar que el contador aumenta correctamente.
Testable: yes - property

5.4 WHEN un usuario consulta sus estadísticas THEN el sistema SHALL retornar los valores actualizados desde Firestore
Thoughts: Este es un comportamiento de consistencia de lectura que debe funcionar para cualquier usuario.
Testable: yes - property

5.5 WHEN se crea una cuenta nueva THEN el sistema SHALL inicializar las estadísticas con valores en cero y la fecha de creación actual
Thoughts: Este es un caso específico de inicialización de cuenta nueva.
Testable: yes - example

6.1 WHEN ocurre un error de red durante una escritura THEN el sistema SHALL reintentar la operación automáticamente hasta 3 veces
Thoughts: Este es un comportamiento de resiliencia que debe funcionar para cualquier operación de escritura. Podemos simular errores de red y verificar los reintentos.
Testable: yes - property

6.2 WHEN falla la conexión a Firestore THEN el sistema SHALL notificar al usuario y mantener los datos locales hasta que se restablezca la conexión
Thoughts: Este es un comportamiento de manejo de errores offline. Es importante pero difícil de testear automáticamente en unit tests.
Testable: no

6.3 WHEN se detecta un conflicto de datos THEN el sistema SHALL priorizar los datos más recientes basándose en timestamps
Thoughts: Este es un comportamiento de resolución de conflictos que debe funcionar para cualquier conflicto. Podemos generar conflictos y verificar la resolución.
Testable: yes - property

6.4 WHEN se restaura la conexión THEN el sistema SHALL sincronizar automáticamente todos los cambios pendientes
Thoughts: Este es un comportamiento de sincronización offline-to-online. Es importante pero difícil de testear en unit tests.
Testable: no

6.5 WHEN ocurre un error crítico de base de datos THEN el sistema SHALL registrar el error y mostrar un mensaje apropiado al usuario
Thoughts: Este es un comportamiento de manejo de errores. Es importante pero es más sobre logging y UX que lógica testeable.
Testable: no

7.1 WHEN se inicializa el provider de usuario THEN el sistema SHALL establecer un listener en tiempo real al documento del usuario
Thoughts: Este es un comportamiento de inicialización que debe ocurrir para cualquier usuario. Podemos verificar que el listener se establece.
Testable: yes - property

7.2 WHEN cambian las monedas del usuario en Firestore THEN el sistema SHALL actualizar automáticamente la UI sin requerir refresh manual
Thoughts: Este es un comportamiento de reactividad del listener. Podemos verificar que los cambios se propagan automáticamente.
Testable: yes - property

7.3 WHEN cambia el progreso de un arco en Firestore THEN el sistema SHALL notificar a los listeners y actualizar la UI correspondiente
Thoughts: Similar a 7.2, este es un comportamiento de reactividad que debe funcionar para cualquier cambio de progreso.
Testable: yes - property

7.4 WHEN el usuario cierra sesión THEN el sistema SHALL cancelar todos los listeners activos para liberar recursos
Thoughts: Este es un comportamiento de limpieza que debe ocurrir para cualquier cierre de sesión. Podemos verificar que los listeners se cancelan.
Testable: yes - property

7.5 WHEN se detecta un cambio en el documento del usuario THEN el sistema SHALL actualizar el estado local y notificar a todos los widgets suscritos
Thoughts: Este es un comportamiento general de sincronización que debe funcionar para cualquier cambio. Es similar a 7.2 y 7.3.
Testable: yes - property

8.1 WHEN un usuario recolecta una evidencia durante el gameplay THEN el sistema SHALL agregar el ID de la evidencia a la lista del arco correspondiente
Thoughts: Este comportamiento debe funcionar para cualquier evidencia en cualquier arco. Es similar a 2.2.
Testable: yes - property

8.2 WHEN un usuario consulta las evidencias de un arco THEN el sistema SHALL retornar la lista completa de IDs de evidencias recolectadas
Thoughts: Este es un comportamiento de lectura que debe funcionar para cualquier arco. Es una propiedad de consistencia.
Testable: yes - property

8.3 WHEN un usuario completa un arco THEN el sistema SHALL mantener la lista de evidencias recolectadas para referencia futura
Thoughts: Este es un comportamiento de persistencia que debe funcionar para cualquier arco completado. Es una propiedad de inmutabilidad.
Testable: yes - property

8.4 WHEN un usuario reinicia un arco THEN el sistema SHALL preservar las evidencias previamente recolectadas
Thoughts: Este es un comportamiento específico de reinicio. Es una propiedad de preservación de datos.
Testable: yes - property

8.5 WHEN un usuario visualiza el archivo THEN el sistema SHALL mostrar todas las evidencias recolectadas de todos los arcos
Thoughts: Este es un comportamiento de agregación de lectura que debe funcionar para cualquier usuario.
Testable: yes - property

9.1 WHEN se diseña la estructura de Firestore THEN el sistema SHALL usar una colección "users" con documentos identificados por userId
Thoughts: Este es un requisito de diseño estructural, no un comportamiento testeable en runtime.
Testable: no

9.2 WHEN se almacenan datos de arcos THEN el sistema SHALL usar un mapa "arcProgress" con claves de arcId dentro del documento de usuario
Thoughts: Este es un requisito de diseño estructural, no un comportamiento testeable en runtime.
Testable: no

9.3 WHEN se almacenan configuraciones THEN el sistema SHALL usar un objeto anidado "settings" dentro del documento de usuario
Thoughts: Este es un requisito de diseño estructural, no un comportamiento testeable en runtime.
Testable: no

9.4 WHEN se almacenan estadísticas THEN el sistema SHALL usar un objeto anidado "stats" dentro del documento de usuario
Thoughts: Este es un requisito de diseño estructural, no un comportamiento testeable en runtime.
Testable: no

9.5 WHEN se almacena el inventario THEN el sistema SHALL usar un objeto anidado "inventory" dentro del documento de usuario
Thoughts: Este es un requisito de diseño estructural, no un comportamiento testeable en runtime.
Testable: no

10.1 WHEN se implementa la persistencia de usuario THEN el sistema SHALL crear un UserRepository que maneje todas las operaciones CRUD del documento de usuario
Thoughts: Este es un requisito de arquitectura, no un comportamiento testeable en runtime.
Testable: no

10.2 WHEN se implementa la lógica de negocio THEN el sistema SHALL crear un UserDataProvider que use el UserRepository y notifique cambios
Thoughts: Este es un requisito de arquitectura, no un comportamiento testeable en runtime.
Testable: no

10.3 WHEN se necesita acceder a datos de usuario THEN el sistema SHALL usar el UserDataProvider en lugar de acceder directamente a Firestore
Thoughts: Este es un requisito de arquitectura, no un comportamiento testeable en runtime.
Testable: no

10.4 WHEN se agregan nuevas funcionalidades THEN el sistema SHALL extender los repositorios y providers existentes manteniendo la separación de responsabilidades
Thoughts: Este es un requisito de mantenibilidad, no un comportamiento testeable en runtime.
Testable: no

10.5 WHEN se escriben pruebas THEN el sistema SHALL permitir inyectar mocks de repositorios para facilitar el testing
Thoughts: Este es un requisito de testabilidad, no un comportamiento testeable en runtime.
Testable: no

### Property Reflection

Revisando las propiedades identificadas, encontramos algunas redundancias:

- **Propiedades 2.2 y 8.1** son idénticas (agregar evidencia a lista de arco)
- **Propiedades 2.5 y 5.4** son similares (consultar datos actualizados desde Firestore)
- **Propiedades 4.1 y 4.2** son casos específicos de una propiedad más general (actualizar configuraciones)
- **Propiedades 4.3 y 4.4** son casos específicos de la misma propiedad general
- **Propiedades 7.2, 7.3 y 7.5** son casos específicos de la misma propiedad de reactividad

Consolidaremos estas propiedades redundantes en propiedades más generales y completas.

### Correctness Properties

**Property 1: User document creation on authentication**
*For any* authenticated user, when they sign in, the system should either create a new user document in Firestore or retrieve their existing document
**Validates: Requirements 1.1**

**Property 2: Data persistence round-trip**
*For any* user data changes (progress, inventory, settings, stats), saving the data then loading it should return equivalent data
**Validates: Requirements 1.3, 1.4, 1.5, 2.5, 4.5, 5.4**

**Property 3: Arc status transitions**
*For any* arc, when a user starts it the status should be "inProgress", and when completed the status should be "completed"
**Validates: Requirements 2.1, 2.3**

**Property 4: Evidence collection accumulation**
*For any* arc and evidence, when a user collects an evidence, the evidence ID should be added to the arc's evidence list and the list size should increase by 1
**Validates: Requirements 2.2, 8.1, 8.2**

**Property 5: Arc completion increments counter**
*For any* arc completion, the user's arcsCompleted counter should increase by exactly 1
**Validates: Requirements 2.3, 5.2**

**Property 6: Purchase transaction atomicity**
*For any* valid purchase, either both the coin deduction and item addition succeed, or neither occurs (atomic transaction)
**Validates: Requirements 3.1, 3.5**

**Property 7: Coin balance monotonicity**
*For any* sequence of coin operations (purchases and rewards), the final balance should equal initial balance minus purchases plus rewards
**Validates: Requirements 3.2**

**Property 8: Settings update persistence**
*For any* settings field (musicVolume, sfxVolume, vhsEffectsEnabled, etc.), updating the value should persist it to Firestore and subsequent reads should return the updated value
**Validates: Requirements 4.1, 4.2, 4.3, 4.4**

**Property 9: Stats accumulation**
*For any* user, completing sessions and arcs should monotonically increase totalPlayTimeMinutes, arcsCompleted, and totalAttempts (never decrease)
**Validates: Requirements 5.1, 5.2, 5.3**

**Property 10: Retry on network failure**
*For any* write operation that fails due to network error, the system should retry up to 3 times before reporting failure
**Validates: Requirements 6.1**

**Property 11: Conflict resolution by timestamp**
*For any* data conflict between local and remote, the system should keep the version with the most recent timestamp
**Validates: Requirements 6.3**

**Property 12: Real-time listener reactivity**
*For any* change to user data in Firestore, the UserDataProvider should receive the update and notify all listeners within a reasonable time window
**Validates: Requirements 7.2, 7.3, 7.5**

**Property 13: Listener cleanup on logout**
*For any* user logout, all active Firestore listeners should be cancelled and no further updates should be processed
**Validates: Requirements 7.4**

**Property 14: Evidence preservation on arc restart**
*For any* arc that is restarted, the previously collected evidences should remain in the evidencesCollected list
**Validates: Requirements 8.4**

## Error Handling

### Error Categories

1. **Network Errors**
   - Connection timeout
   - No internet connection
   - Firestore service unavailable
   - **Handling**: Retry with exponential backoff (max 3 attempts), maintain local state, notify user

2. **Authentication Errors**
   - User not authenticated
   - Token expired
   - Permission denied
   - **Handling**: Redirect to login, clear local state, show appropriate error message

3. **Data Validation Errors**
   - Invalid data format
   - Missing required fields
   - Type mismatch
   - **Handling**: Log error, use default values, notify developer

4. **Transaction Errors**
   - Insufficient funds
   - Item already owned
   - Concurrent modification
   - **Handling**: Rollback transaction, show user-friendly error, maintain data consistency

5. **Listener Errors**
   - Listener disconnected
   - Permission changed
   - Document deleted
   - **Handling**: Attempt reconnection, fallback to polling, notify user if persistent

### Retry Strategy

```dart
class RetryStrategy {
  static const int maxRetries = 3;
  static const Duration initialDelay = Duration(milliseconds: 500);
  static const double backoffMultiplier = 2.0;
  
  Future<T> executeWithRetry<T>(Future<T> Function() operation) async {
    int attempts = 0;
    Duration delay = initialDelay;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) rethrow;
        
        if (e is FirebaseException && !_isRetriableError(e)) {
          rethrow;
        }
        
        await Future.delayed(delay);
        delay *= backoffMultiplier;
      }
    }
    
    throw Exception('Max retries exceeded');
  }
  
  bool _isRetriableError(FirebaseException e) {
    return e.code == 'unavailable' || 
           e.code == 'deadline-exceeded' ||
           e.code == 'resource-exhausted';
  }
}
```

### Error Recovery Flows

```
Network Error During Write:
1. Catch FirebaseException
2. Check if retriable error
3. If yes: Retry with exponential backoff
4. If max retries exceeded: Store in pending queue
5. Notify user of offline mode
6. On reconnection: Flush pending queue

Transaction Conflict:
1. Detect concurrent modification
2. Fetch latest data from Firestore
3. Merge changes intelligently
4. Retry transaction with merged data
5. If conflict persists: Use timestamp to resolve

Listener Disconnection:
1. Detect listener error
2. Attempt to reestablish listener
3. If fails: Fall back to periodic polling
4. Log error for monitoring
5. Notify user if persistent issue
```

## Testing Strategy

### Unit Testing

**Framework**: Flutter's built-in test package with mockito for mocking

**Test Coverage Areas**:
1. **Model Serialization**: Test toJson/fromJson for all models
2. **Repository Methods**: Test CRUD operations with mocked Firestore
3. **Provider State Management**: Test state updates and notifications
4. **Error Handling**: Test retry logic and error recovery
5. **Data Validation**: Test input validation and edge cases

**Example Unit Tests**:
- UserData.fromFirestore correctly parses all fields
- UserRepository.updateInventory calls Firestore with correct data
- UserDataProvider notifies listeners when data changes
- RetryStrategy retries exactly 3 times on network error
- purchaseItem rolls back on insufficient funds

### Property-Based Testing

**Framework**: dart_check (Dart's property-based testing library)

**Configuration**: Each property test should run a minimum of 100 iterations

**Test Tagging**: Each property-based test must include a comment with the format:
`// Feature: user-database-system, Property {number}: {property_text}`

**Property Test Coverage**:

1. **Property 1: User document creation**
   - Generate random user IDs
   - Verify document exists after authentication
   - Check document has correct structure

2. **Property 2: Data persistence round-trip**
   - Generate random UserData
   - Save to Firestore
   - Load from Firestore
   - Verify equality

3. **Property 3: Arc status transitions**
   - Generate random arc IDs
   - Start arc → verify "inProgress"
   - Complete arc → verify "completed"

4. **Property 4: Evidence collection accumulation**
   - Generate random evidence IDs
   - Add to arc
   - Verify list contains ID and size increased

5. **Property 5: Arc completion increments counter**
   - Generate random initial counter value
   - Complete arc
   - Verify counter increased by 1

6. **Property 6: Purchase transaction atomicity**
   - Generate random purchases
   - Execute transaction
   - Verify both operations succeeded or both failed

7. **Property 7: Coin balance monotonicity**
   - Generate random sequence of operations
   - Execute all operations
   - Verify final balance matches calculation

8. **Property 8: Settings update persistence**
   - Generate random settings values
   - Update settings
   - Read back settings
   - Verify values match

9. **Property 9: Stats accumulation**
   - Generate random stat updates
   - Apply updates
   - Verify stats never decrease

10. **Property 10: Retry on network failure**
    - Simulate network failures
    - Verify exactly 3 retry attempts

11. **Property 11: Conflict resolution by timestamp**
    - Generate conflicting data with timestamps
    - Trigger conflict resolution
    - Verify most recent data wins

12. **Property 12: Real-time listener reactivity**
    - Generate random data changes
    - Update Firestore
    - Verify listener receives update

13. **Property 13: Listener cleanup on logout**
    - Start listeners
    - Logout
    - Verify no listeners active

14. **Property 14: Evidence preservation on arc restart**
    - Collect random evidences
    - Restart arc
    - Verify evidences still present

### Integration Testing

**Test Scenarios**:
1. Complete user flow: signup → play → purchase → logout → login → verify data
2. Multi-device simulation: Update on device A → verify on device B
3. Offline mode: Make changes offline → go online → verify sync
4. Concurrent updates: Multiple updates to same document → verify consistency

### Mock Strategy

**Mocked Components**:
- FirebaseFirestore: Mock all Firestore operations
- FirebaseAuth: Mock authentication state
- Network connectivity: Mock online/offline states

**Real Components**:
- All models and their serialization
- Provider state management logic
- Retry and error handling logic

## Implementation Notes

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Users can only read/write their own data
      allow read, write: if request.auth != null && request.auth.uid == userId;
      
      // Validate data structure on write
      allow write: if request.resource.data.keys().hasAll(['userId', 'arcProgress', 'inventory', 'settings', 'stats', 'lastUpdated']);
    }
  }
}
```

### Performance Considerations

1. **Batch Writes**: Group multiple updates into batch operations when possible
2. **Selective Listening**: Only listen to specific fields that need real-time updates
3. **Caching**: Use Firestore's built-in caching to reduce reads
4. **Pagination**: Implement pagination for large collections (future: leaderboards)
5. **Indexes**: Create composite indexes for complex queries (future: filtering arcs)

### Migration Strategy

For existing users without the new database structure:
1. Detect missing fields on first load
2. Initialize with default values
3. Merge with any existing local data
4. Save complete structure to Firestore
5. Log migration for analytics

### Monitoring and Analytics

Track the following metrics:
- Average write latency
- Retry rate and success rate
- Listener disconnection frequency
- Data conflict rate
- User data size growth

## Future Enhancements

1. **Offline Queue**: Persistent queue for operations when offline
2. **Data Compression**: Compress large data structures before storage
3. **Leaderboards**: Global and friend leaderboards using Firestore queries
4. **Cloud Functions**: Server-side validation and business logic
5. **Data Export**: Allow users to export their data
6. **Multi-platform Sync**: Ensure seamless sync across mobile, web, and desktop
