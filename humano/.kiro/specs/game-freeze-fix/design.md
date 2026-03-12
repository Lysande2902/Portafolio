# Design Document

## Overview

El juego se congela debido a un `Future.doWhile` loop infinito en `ArcGameScreen` que llama a `setState()` cada 100ms. Este patrón causa:

1. **Rebuilds excesivos**: El widget tree completo se reconstruye 10 veces por segundo
2. **Interferencia con Flame**: Los rebuilds de Flutter bloquean el game loop de Flame
3. **Consumo de recursos**: CPU y memoria se saturan con rebuilds innecesarios
4. **Deadlock**: El game loop y el UI loop compiten por recursos, causando congelamiento

La solución es eliminar el polling loop y usar un patrón reactivo basado en `ValueNotifier` o `ChangeNotifier` que solo actualice la UI cuando el estado del juego realmente cambia.

## Architecture

### Current Architecture (Problematic)

```
ArcGameScreen (Flutter)
  ├─ Future.doWhile loop (100ms)
  │   └─ setState() → Full widget rebuild
  │       └─ Blocks Flame game loop
  └─ GameWidget (Flame)
      └─ Game.update(dt) → Blocked by rebuilds
```

### New Architecture (Solution)

```
ArcGameScreen (Flutter)
  ├─ ValueListenable listeners
  │   └─ Selective rebuilds only when needed
  └─ GameWidget (Flame)
      ├─ Game.update(dt) → Runs freely
      └─ GameStateNotifier → Notifies UI changes
```

## Components and Interfaces

### 1. GameStateNotifier

Clase que encapsula el estado del juego y notifica cambios a la UI:

```dart
class GameStateNotifier extends ChangeNotifier {
  int _evidenceCollected = 0;
  double _sanity = 1.0;
  bool _isGameOver = false;
  bool _isVictory = false;
  Map<String, int> _availableItems = {};
  
  // Getters
  int get evidenceCollected => _evidenceCollected;
  double get sanity => _sanity;
  bool get isGameOver => _isGameOver;
  bool get isVictory => _isVictory;
  Map<String, int> get availableItems => _availableItems;
  
  // Setters that notify listeners
  void updateEvidence(int count) {
    if (_evidenceCollected != count) {
      _evidenceCollected = count;
      notifyListeners();
    }
  }
  
  void updateSanity(double value) {
    if ((_sanity - value).abs() > 0.01) { // Only notify if significant change
      _sanity = value;
      notifyListeners();
    }
  }
  
  void updateGameOver(bool value) {
    if (_isGameOver != value) {
      _isGameOver = value;
      notifyListeners();
    }
  }
  
  void updateVictory(bool value) {
    if (_isVictory != value) {
      _isVictory = value;
      notifyListeners();
    }
  }
  
  void updateItems(Map<String, int> items) {
    _availableItems = Map.from(items);
    notifyListeners();
  }
}
```

### 2. BaseArcGame Integration

Agregar el notifier al juego base:

```dart
abstract class BaseArcGame extends FlameGame with HasCollisionDetection {
  // Add state notifier
  final GameStateNotifier stateNotifier = GameStateNotifier();
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isPaused && !isGameOver && !isVictory) {
      elapsedTime += dt;
      updateItemTimers(dt);
      updateGame(dt);
      
      // Update notifier (only when values change)
      stateNotifier.updateEvidence(evidenceCollected);
      stateNotifier.updateSanity(sanitySystem.currentSanity);
      stateNotifier.updateGameOver(isGameOver);
      stateNotifier.updateVictory(isVictory);
    }
  }
}
```

### 3. ArcGameScreen Refactor

Eliminar el polling loop y usar listeners:

```dart
class _ArcGameScreenState extends State<ArcGameScreen> {
  late final dynamic game;
  Map<String, int> availableItems = {};
  bool showPauseMenu = false;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize game
    switch (widget.arcId) {
      case 'arc_1_gula':
        game = GluttonyArcGame();
        break;
      // ... other arcs
    }
    
    // Load inventory
    _loadInventory();
    
    // Listen to game state changes (REACTIVE, not polling)
    game.stateNotifier.addListener(_onGameStateChanged);
  }
  
  void _onGameStateChanged() {
    if (mounted) {
      setState(() {
        // Only rebuild when game state actually changes
      });
    }
  }
  
  @override
  void dispose() {
    game.stateNotifier.removeListener(_onGameStateChanged);
    super.dispose();
  }
  
  // Remove the Future.doWhile loop completely
}
```

## Data Models

### GameState

```dart
class GameState {
  final int evidenceCollected;
  final double sanity;
  final bool isGameOver;
  final bool isVictory;
  final Map<String, int> availableItems;
  final bool modoIncognitoActive;
  final bool firewallActive;
  final bool vpnActive;
  final bool altAccountActive;
  
  GameState({
    required this.evidenceCollected,
    required this.sanity,
    required this.isGameOver,
    required this.isVictory,
    required this.availableItems,
    required this.modoIncognitoActive,
    required this.firewallActive,
    required this.vpnActive,
    required this.altAccountActive,
  });
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

Property 1: Game loop continuity
*For any* game session, the time between consecutive frame updates should never exceed 100ms, ensuring the game never freezes
**Validates: Requirements 1.1**

Property 2: Input responsiveness
*For any* sequence of player inputs, each input should result in a corresponding game state change within 100ms
**Validates: Requirements 1.2, 1.5**

Property 3: Error recovery
*For any* non-critical error that occurs in the game loop, the system should log the error and continue executing without stopping
**Validates: Requirements 1.4, 3.1**

Property 4: Component failure isolation
*For any* component that fails during execution, the system should remove that component and continue running without affecting other components
**Validates: Requirements 3.2**

Property 5: Adaptive performance
*For any* game session where the frame time exceeds a threshold, the system should automatically reduce update frequency to maintain responsiveness
**Validates: Requirements 3.3**

Property 6: Freeze detection and recovery
*For any* component that stops responding for more than 2 seconds, the system should detect it and attempt to restart that component
**Validates: Requirements 3.5**

Property 7: Flutter-Flame separation
*For any* setState call in Flutter, the Flame game loop frame time should not increase by more than 10ms
**Validates: Requirements 4.1**

Property 8: Minimal rebuild frequency
*For any* 1-second time window during gameplay, the number of widget rebuilds should not exceed the number of actual game state changes plus 1
**Validates: Requirements 4.2**

Property 9: Asynchronous UI updates
*For any* setState call, it should execute asynchronously (in a microtask or future) and not block the current execution frame
**Validates: Requirements 4.3**

Property 10: Overlay rendering performance
*For any* overlay widget creation, the frame time during creation should not exceed 50ms
**Validates: Requirements 4.5**

## Error Handling

### Error Categories

1. **Critical Errors**: Errors that require game restart
   - Game initialization failure
   - Asset loading failure
   - Memory allocation failure

2. **Non-Critical Errors**: Errors that can be recovered
   - Component update failure
   - Animation glitch
   - Sound playback failure

3. **Performance Issues**: Not errors but degraded performance
   - Low FPS (< 30)
   - High frame time (> 33ms)
   - Memory pressure

### Error Handling Strategy

```dart
class ErrorHandler {
  static void handleGameError(dynamic error, StackTrace stackTrace) {
    // Log error
    print('❌ [ERROR] $error');
    print('📋 [STACK] $stackTrace');
    
    // Categorize error
    if (isCritical(error)) {
      // Show error dialog and exit
      _showCriticalError(error);
    } else {
      // Log and continue
      _logNonCriticalError(error);
    }
  }
  
  static bool isCritical(dynamic error) {
    // Check if error is critical
    return error is InitializationError ||
           error is AssetLoadError ||
           error is OutOfMemoryError;
  }
}
```

### Component Failure Handling

```dart
@override
void update(double dt) {
  try {
    super.update(dt);
    
    if (!isPaused && !isGameOver && !isVictory) {
      elapsedTime += dt;
      updateItemTimers(dt);
      updateGame(dt);
      
      // Update notifier
      _updateStateNotifier();
    }
  } catch (e, stackTrace) {
    ErrorHandler.handleGameError(e, stackTrace);
    
    // Try to continue without the failed component
    _removeFailedComponents();
  }
}

void _removeFailedComponents() {
  // Remove components that are in error state
  world.children.removeWhere((component) {
    try {
      // Test if component is still valid
      component.position;
      return false;
    } catch (e) {
      print('🗑️ Removing failed component: ${component.runtimeType}');
      return true;
    }
  });
}
```

## Testing Strategy

### Unit Testing

Unit tests will cover:

1. **GameStateNotifier**: Test that notifyListeners is called only when values change
2. **Error handling**: Test that errors are caught and logged correctly
3. **Component removal**: Test that failed components are removed without affecting others
4. **State updates**: Test that game state updates correctly reflect in the notifier

### Property-Based Testing

Property-based tests will use the `test` package with custom generators to verify:

1. **Frame time consistency**: Generate random game sessions and verify frame times stay below threshold
2. **Input responsiveness**: Generate random input sequences and verify response times
3. **Error recovery**: Inject random errors and verify the game continues
4. **Rebuild frequency**: Monitor rebuilds during random gameplay and verify they match state changes

### Integration Testing

Integration tests will verify:

1. **Full game session**: Play through a complete arc without freezing
2. **UI interaction**: Test all UI interactions don't cause freezes
3. **Memory stability**: Monitor memory usage over extended gameplay
4. **Performance**: Verify FPS stays above 30 during normal gameplay

### Testing Framework

We will use Dart's built-in `test` package for property-based testing since Dart doesn't have a dedicated PBT library like QuickCheck. We'll create custom generators for game states and inputs.

```dart
// Example property test structure
void main() {
  group('Game Loop Properties', () {
    test('Property 1: Frame time never exceeds 100ms', () {
      // Generate random game session
      final game = createTestGame();
      final frameTimes = <double>[];
      
      // Run for 10 seconds
      for (int i = 0; i < 600; i++) {
        final start = DateTime.now();
        game.update(1/60); // 60 FPS
        final end = DateTime.now();
        
        final frameTime = end.difference(start).inMilliseconds;
        frameTimes.add(frameTime.toDouble());
      }
      
      // Verify all frame times < 100ms
      expect(frameTimes.every((t) => t < 100), isTrue);
    });
  });
}
```

