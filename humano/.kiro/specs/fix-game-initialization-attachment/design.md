# Design Document

## Overview

El error de "Game attachment" persiste porque el GameWidget se está reconstruyendo DURANTE la fase de inicialización del juego, antes de que el widget tree esté completamente estable. La solución requiere un enfoque de "inicialización diferida" donde:

1. El widget se construye completamente primero
2. Solo DESPUÉS de que el primer frame se renderiza, iniciamos la inicialización del juego
3. Durante la inicialización, todos los updates de estado se difieren
4. Una vez completa la inicialización, se habilitan los updates normales

## Architecture

### Current Architecture (Problematic)

```
initState()
  └── Create game instance
  
didChangeDependencies()
  ├── Setup providers
  ├── Load inventory (may trigger updates)
  └── Schedule post-frame callback
  
build()
  ├── GameWidget created
  └── Game starts initializing (PROBLEM: widget tree not stable)
  
Game.onLoad()
  ├── Load resources
  ├── Setup components
  └── Notify state changes (PROBLEM: causes rebuild during initialization)
```

### New Architecture (Solution)

```
initState()
  ├── Create game instance (NO initialization)
  └── Create STATIC GlobalKey
  
didChangeDependencies()
  ├── Setup providers (NO listeners)
  ├── Load inventory (NO state updates)
  └── Mark providers as ready
  
build()
  ├── GameWidget created with STATIC key
  ├── Return widget tree
  └── Schedule post-frame callback (FIRST TIME ONLY)
  
Post-Frame Callback (after first build)
  ├── Enable deferred updates mode
  ├── Start game initialization
  ├── Wait for initialization to complete
  ├── Flush deferred updates
  └── Mark initialization complete
  
Game.onLoad()
  ├── Load resources
  ├── Setup components
  └── Notify state changes (DEFERRED until initialization complete)
```

## Components and Interfaces

### 1. Static GlobalKey Management

El problema con el GlobalKey actual es que se crea como una variable de instancia, lo que significa que se recrea cada vez que el State se reconstruye. Necesitamos un GlobalKey verdaderamente estático que persista entre rebuilds.

```dart
class _ArcGameScreenState extends State<ArcGameScreen> {
  // Static map to store keys per arc
  static final Map<String, GlobalKey> _gameWidgetKeys = {};
  
  late final GlobalKey _gameWidgetKey;
  late final dynamic game;
  bool _providersSetupDone = false;
  bool _initializationStarted = false;
  bool _initializationComplete = false;
  
  @override
  void initState() {
    super.initState();
    
    // Get or create a static key for this arc
    _gameWidgetKey = _gameWidgetKeys.putIfAbsent(
      widget.arcId,
      () => GlobalKey(debugLabel: 'GameWidget_${widget.arcId}'),
    );
    
    // Create game instance (NO initialization yet)
    game = _createGameForArc(widget.arcId);
    
    debugPrint('🎮 [INIT] Game instance created for ${widget.arcId}');
    debugPrint('🔑 [INIT] Using GlobalKey: ${_gameWidgetKey.hashCode}');
  }
  
  @override
  void dispose() {
    // Clean up the static key when screen is disposed
    _gameWidgetKeys.remove(widget.arcId);
    super.dispose();
  }
}
```

### 2. Deferred Initialization Pattern

La inicialización del juego debe ocurrir DESPUÉS de que el primer frame se renderiza, usando un post-frame callback que solo se ejecuta una vez.

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (_providersSetupDone) return;
  
  // Setup providers WITHOUT triggering any updates
  _setupProvidersQuietly();
  _providersSetupDone = true;
  
  debugPrint('✅ [SETUP] Providers configured (no updates triggered)');
}

@override
Widget build(BuildContext context) {
  // Schedule initialization AFTER first build (only once)
  if (!_initializationStarted) {
    _initializationStarted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeGameDeferred();
    });
  }
  
  return Scaffold(
    body: Stack(
      children: [
        GameWidget(
          key: _gameWidgetKey, // STATIC key
          game: game,
        ),
        // ... rest of UI
      ],
    ),
  );
}

Future<void> _initializeGameDeferred() async {
  debugPrint('📍 [INIT] Starting deferred initialization...');
  debugPrint('   Widget tree is now stable');
  
  try {
    // Enable deferred updates mode
    game.stateNotifier.enableDeferredUpdates();
    debugPrint('🔒 [INIT] Deferred updates enabled');
    
    // Set build context
    game.buildContext = context;
    
    // Load inventory (this may trigger game state changes)
    _loadInventory();
    debugPrint('✅ [INIT] Inventory loaded');
    
    // Wait a frame to ensure everything is settled
    await Future.delayed(Duration.zero);
    
    // Flush all deferred updates
    game.stateNotifier.flushDeferredUpdates();
    debugPrint('📤 [INIT] Deferred updates flushed');
    
    // Mark initialization complete
    _initializationComplete = true;
    debugPrint('✅ [INIT] Initialization complete - game ready');
    
  } catch (e, stackTrace) {
    debugPrint('❌ [INIT] Error during initialization: $e');
    debugPrint('Stack trace: $stackTrace');
  }
}
```

### 3. Quiet Provider Setup

Los providers deben configurarse sin causar ninguna notificación o rebuild.

```dart
void _setupProvidersQuietly() {
  // Get providers WITHOUT listening
  final fragmentsProvider = Provider.of<FragmentsProvider>(
    context, 
    listen: false,
  );
  
  // Set providers on game WITHOUT triggering any callbacks
  game.setFragmentsProvider(fragmentsProvider);
  
  debugPrint('✅ [SETUP] FragmentsProvider set (quiet mode)');
}
```

### 4. Enhanced GameStateNotifier

El GameStateNotifier ya tiene el mecanismo de deferred updates, pero necesitamos asegurarnos de que se use correctamente.

```dart
class GameStateNotifier {
  bool _deferUpdates = false;
  final List<VoidCallback> _deferredUpdates = [];
  
  /// Enable deferred updates mode
  void enableDeferredUpdates() {
    _deferUpdates = true;
    _deferredUpdates.clear();
    debugPrint('🔒 [NOTIFIER] Deferred updates enabled');
  }
  
  /// Flush all deferred updates
  void flushDeferredUpdates() {
    debugPrint('📤 [NOTIFIER] Flushing ${_deferredUpdates.length} updates');
    
    _deferUpdates = false;
    
    for (final update in _deferredUpdates) {
      try {
        update();
      } catch (e) {
        debugPrint('❌ [NOTIFIER] Error flushing update: $e');
      }
    }
    
    _deferredUpdates.clear();
    debugPrint('✅ [NOTIFIER] All updates flushed');
  }
  
  /// Update evidence (deferred if in deferred mode)
  void updateEvidence(int count) {
    if (_deferUpdates) {
      _deferredUpdates.add(() {
        if (evidence.value != count) {
          evidence.value = count;
        }
      });
    } else {
      if (evidence.value != count) {
        evidence.value = count;
      }
    }
  }
  
  // Similar for all other update methods...
}
```

### 5. BaseArcGame Integration

El BaseArcGame debe respetar el modo de deferred updates.

```dart
abstract class BaseArcGame extends FlameGame {
  final GameStateNotifier stateNotifier = GameStateNotifier();
  
  @override
  Future<void> onLoad() async {
    debugPrint('🎮 [GAME] onLoad() started');
    
    // Load resources
    await super.onLoad();
    
    // Setup game components
    await setupGame();
    
    // Update state notifiers (will be deferred if in deferred mode)
    _updateStateNotifiers();
    
    debugPrint('✅ [GAME] onLoad() completed');
  }
  
  void _updateStateNotifiers() {
    stateNotifier.updateEvidence(evidenceCollected);
    stateNotifier.updateSanity(sanitySystem?.currentSanity ?? 1.0);
    stateNotifier.updateGameOver(isGameOver);
    stateNotifier.updateVictory(isVictory);
    // ... other updates
  }
}
```

## Data Models

### InitializationState

```dart
enum InitializationState {
  notStarted,
  providersSetup,
  deferredMode,
  gameLoading,
  flushingUpdates,
  complete,
  error,
}
```

### GameWidgetKeyManager

```dart
class GameWidgetKeyManager {
  static final Map<String, GlobalKey> _keys = {};
  
  static GlobalKey getKeyForArc(String arcId) {
    return _keys.putIfAbsent(
      arcId,
      () => GlobalKey(debugLabel: 'GameWidget_$arcId'),
    );
  }
  
  static void removeKeyForArc(String arcId) {
    _keys.remove(arcId);
  }
  
  static void clearAll() {
    _keys.clear();
  }
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*


### Property 1: Build Before Initialize

*For any* game screen initialization sequence, the widget build phase should complete before game initialization starts.

**Validates: Requirements 1.1, 2.3**

### Property 2: Single Attachment Invariant

*For any* game instance, the attachment count to GameWidget should never exceed 1 throughout its lifecycle.

**Validates: Requirements 1.2**

### Property 3: No Rebuilds During Provider Setup

*For any* provider configuration sequence, no widget rebuilds should occur between provider setup start and completion.

**Validates: Requirements 1.3, 2.5**

### Property 4: No Rebuilds During Resource Loading

*For any* game resource loading sequence, the GameWidget should not rebuild while resources are being loaded.

**Validates: Requirements 1.4**

### Property 5: GlobalKey Stability

*For any* sequence of widget rebuilds, the GlobalKey instance (identity) for the GameWidget should remain constant.

**Validates: Requirements 3.2, 3.3**

### Property 6: Deferred Updates During Initialization

*For any* state update that occurs during game initialization, the update should be queued in the deferred updates list rather than applied immediately.

**Validates: Requirements 4.1, 4.2**

### Property 7: Update Flush Completeness

*For any* deferred updates queue, when flushDeferredUpdates() is called, all queued updates should be applied and the queue should be empty.

**Validates: Requirements 4.3**

### Property 8: setState Only for Local State

*For any* setState() call in ArcGameScreen, the state being updated should be local UI state (throwMode, currentHint, etc.), not game state (evidence, sanity, etc.).

**Validates: Requirements 4.4, 4.5**

### Property 9: Initialization Phase Ordering

*For any* game screen initialization, the phases should occur in this exact order: initState → didChangeDependencies → build → post-frame callback → game initialization.

**Validates: Requirements 2.1, 2.2, 2.3, 2.4**

### Property 10: GlobalKey Uniqueness

*For any* set of simultaneously open game screens, each screen should have a unique GlobalKey instance.

**Validates: Requirements 3.5**

## Error Handling

### Attachment Errors

- **Prevention**: Use static GlobalKey map and deferred initialization
- **Detection**: Log all attachment/detachment events with timestamps
- **Recovery**: If attachment error occurs, log full state and prevent further operations

### Initialization Timing Errors

- **Prevention**: Use post-frame callbacks and deferred updates
- **Detection**: Log timestamps for each initialization phase
- **Recovery**: If timing error occurs, reset initialization state and retry

### Deferred Update Errors

- **Prevention**: Wrap each deferred update in try-catch
- **Detection**: Log errors during flush operation
- **Recovery**: Continue flushing remaining updates even if one fails

### GlobalKey Cleanup Errors

- **Prevention**: Always remove key from static map in dispose()
- **Detection**: Log key removal operations
- **Recovery**: If cleanup fails, log warning but don't block disposal

## Testing Strategy

### Unit Tests

1. **GameStateNotifier Deferred Updates**
   - Test that enableDeferredUpdates() prevents immediate updates
   - Test that updates are queued correctly
   - Test that flushDeferredUpdates() applies all queued updates
   - Test that flush is idempotent (can be called multiple times)

2. **GameWidgetKeyManager**
   - Test that getKeyForArc() returns same key for same arc
   - Test that different arcs get different keys
   - Test that removeKeyForArc() cleans up correctly
   - Test that clearAll() removes all keys

### Integration Tests

1. **Initialization Sequence**
   - Test that initState → didChangeDependencies → build → post-frame occurs in order
   - Test that game initialization starts only after post-frame callback
   - Test that no rebuilds occur during initialization
   - Test that deferred updates are flushed after initialization

2. **GlobalKey Stability**
   - Test that GlobalKey remains same across multiple rebuilds
   - Test that GameWidget is recognized as same instance
   - Test that key is cleaned up on dispose

3. **Provider Setup**
   - Test that provider setup doesn't trigger rebuilds
   - Test that provider setup doesn't trigger game initialization
   - Test that providers are available when game initializes

### Property-Based Tests

Property-based testing will use the `test` package with custom generators.

1. **Property 1: Build Before Initialize**
   - Generate random initialization sequences
   - Verify build always completes before game initialization

2. **Property 2: Single Attachment**
   - Generate random sequences of screen opens/closes
   - Verify attachment count never exceeds 1

3. **Property 5: GlobalKey Stability**
   - Generate random sequences of rebuilds
   - Verify GlobalKey identity remains constant

4. **Property 6: Deferred Updates**
   - Generate random state updates during initialization
   - Verify all are deferred until flush

### Testing Framework

- **Unit Tests**: Dart `test` package
- **Widget Tests**: Flutter `flutter_test` package  
- **Property Tests**: Custom generators with `test` package
- **Integration Tests**: Flutter integration test framework

### Test Execution

- All tests should run in CI/CD pipeline
- Property tests should run at least 100 iterations
- Integration tests should cover all 7 arcs
- Performance tests should verify no memory leaks from static keys

