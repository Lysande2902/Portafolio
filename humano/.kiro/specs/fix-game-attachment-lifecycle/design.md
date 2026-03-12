# Design Document

## Overview

El error "Game attachment error" ocurre porque Flutter reconstruye el widget tree cuando se llama `setState()`, y aunque el `GameWidget` está cacheado con un `ObjectKey`, Flame internamente detecta que la instancia del juego ya está adjunta a otro widget (el widget anterior antes del rebuild).

La solución consiste en usar un patrón de "widget estable" donde el `GameWidget` nunca se reconstruye, y toda la UI reactiva se maneja mediante overlays separados que se actualizan independientemente del `GameWidget`.

## Architecture

### Current Architecture (Problematic)

```
ArcGameScreen (StatefulWidget)
├── setState() called on game state changes
├── Widget tree rebuilds
├── GameWidget attempts to re-attach game instance
└── ERROR: Game already attached
```

### New Architecture (Solution)

```
ArcGameScreen (StatefulWidget)
├── GameWidget (never rebuilds, stable key)
│   └── Game Instance (attached once)
└── Separate UI Overlays (rebuild independently)
    ├── GameHUD (ValueListenableBuilder)
    ├── VictoryScreen (ValueListenableBuilder)
    ├── GameOverScreen (ValueListenableBuilder)
    └── PauseMenu (ValueListenableBuilder)
```

## Components and Interfaces

### 1. GameStateNotifier Enhancement

El `GameStateNotifier` existente se mejorará para usar `ValueNotifier` en lugar de `ChangeNotifier`, permitiendo que widgets específicos escuchen cambios sin reconstruir todo el árbol.

```dart
class GameStateNotifier {
  // Individual ValueNotifiers for each state property
  final ValueNotifier<int> evidence = ValueNotifier<int>(0);
  final ValueNotifier<double> sanity = ValueNotifier<double>(1.0);
  final ValueNotifier<bool> gameOver = ValueNotifier<bool>(false);
  final ValueNotifier<bool> victory = ValueNotifier<bool>(false);
  final ValueNotifier<bool> paused = ValueNotifier<bool>(false);
  
  // Item states
  final ValueNotifier<bool> modoIncognito = ValueNotifier<bool>(false);
  final ValueNotifier<bool> firewall = ValueNotifier<bool>(false);
  final ValueNotifier<bool> vpn = ValueNotifier<bool>(false);
  final ValueNotifier<bool> altAccount = ValueNotifier<bool>(false);
  
  // Arc-specific states (nullable for arcs that don't use them)
  final ValueNotifier<double?> noiseLevel = ValueNotifier<double?>(null);
  final ValueNotifier<int?> foodInventory = ValueNotifier<int?>(null);
  final ValueNotifier<int?> coinInventory = ValueNotifier<int?>(null);
  final ValueNotifier<int?> cameraInventory = ValueNotifier<int?>(null);
  
  void updateEvidence(int value) {
    if (evidence.value != value) {
      evidence.value = value;
    }
  }
  
  void updateSanity(double value) {
    if (sanity.value != value) {
      sanity.value = value;
    }
  }
  
  // ... similar methods for other properties
  
  void dispose() {
    evidence.dispose();
    sanity.dispose();
    gameOver.dispose();
    victory.dispose();
    paused.dispose();
    modoIncognito.dispose();
    firewall.dispose();
    vpn.dispose();
    altAccount.dispose();
    noiseLevel.dispose();
    foodInventory.dispose();
    coinInventory.dispose();
    cameraInventory.dispose();
  }
}
```

### 2. ArcGameScreen Refactoring

El `ArcGameScreen` se refactorizará para:
- Crear el `GameWidget` una sola vez en `initState()`
- Nunca llamar `setState()` para cambios de estado del juego
- Usar `ValueListenableBuilder` para UI reactiva
- Mantener `setState()` solo para estados locales del screen (throw mode, hints)

```dart
class _ArcGameScreenState extends State<ArcGameScreen> {
  late final dynamic game;
  late final Widget _gameWidget;
  bool _providersSetupDone = false;
  
  // Local UI state (not game state)
  bool _throwMode = false;
  String? _throwMessage;
  ArcHint? _currentHint;
  
  @override
  void initState() {
    super.initState();
    
    // Create game instance
    game = _createGameForArc(widget.arcId);
    game.buildContext = context;
    
    // Create GameWidget ONCE with stable key
    _gameWidget = GameWidget(
      key: GlobalKey(), // Use GlobalKey for absolute stability
      game: game,
    );
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_providersSetupDone) return;
    
    // Setup providers once
    _setupProviders();
    _providersSetupDone = true;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // GameWidget - NEVER rebuilds
          _gameWidget,
          
          // UI Overlays - rebuild independently using ValueListenableBuilder
          _buildGameHUD(),
          _buildVictoryScreen(),
          _buildGameOverScreen(),
          _buildPauseMenu(),
          
          // Local UI state (throw mode, hints) - can use setState
          if (_throwMode) _buildThrowModeUI(),
          if (_currentHint != null) _buildHintUI(),
        ],
      ),
    );
  }
  
  Widget _buildGameHUD() {
    return ValueListenableBuilder<double>(
      valueListenable: game.stateNotifier.sanity,
      builder: (context, sanity, child) {
        return ValueListenableBuilder<int>(
          valueListenable: game.stateNotifier.evidence,
          builder: (context, evidence, child) {
            return GameHUD(
              sanity: sanity,
              evidenceCollected: evidence,
              // ... other properties
            );
          },
        );
      },
    );
  }
  
  Widget _buildVictoryScreen() {
    return ValueListenableBuilder<bool>(
      valueListenable: game.stateNotifier.victory,
      builder: (context, isVictory, child) {
        if (!isVictory) return const SizedBox.shrink();
        
        return VictoryScreen(
          // ... properties
        );
      },
    );
  }
  
  // Similar for game over and pause menu
}
```

### 3. BaseArcGame Updates

El `BaseArcGame` se actualizará para:
- Usar el nuevo `GameStateNotifier` con `ValueNotifier`
- Actualizar los notifiers en lugar de notificar listeners globales
- Eliminar la necesidad de `forceNotify()`

```dart
abstract class BaseArcGame extends FlameGame with HasCollisionDetection {
  final GameStateNotifier stateNotifier = GameStateNotifier();
  
  @override
  void update(double dt) {
    super.update(dt);
    
    if (!isPaused && !isGameOver && !isVictory) {
      elapsedTime += dt;
      updateItemTimers(dt);
      updateGame(dt);
      
      // Update state notifiers (no listeners to notify)
      _updateStateNotifiers();
    }
    
    // ... rest of update logic
  }
  
  void _updateStateNotifiers() {
    stateNotifier.updateEvidence(evidenceCollected);
    stateNotifier.updateGameOver(isGameOver);
    stateNotifier.updateVictory(isVictory);
    stateNotifier.updateSanity(sanitySystem?.currentSanity ?? 1.0);
    // ... other updates
    
    // Call subclass-specific updates
    updateStateNotifierExtended();
  }
  
  @override
  void onRemove() {
    stateNotifier.dispose();
    super.onRemove();
  }
}
```

## Data Models

### GameStateNotifier

```dart
class GameStateNotifier {
  // Core game state
  final ValueNotifier<int> evidence;
  final ValueNotifier<double> sanity;
  final ValueNotifier<bool> gameOver;
  final ValueNotifier<bool> victory;
  final ValueNotifier<bool> paused;
  
  // Item states
  final ValueNotifier<bool> modoIncognito;
  final ValueNotifier<bool> firewall;
  final ValueNotifier<bool> vpn;
  final ValueNotifier<bool> altAccount;
  
  // Arc-specific states
  final ValueNotifier<double?> noiseLevel;
  final ValueNotifier<int?> foodInventory;
  final ValueNotifier<int?> coinInventory;
  final ValueNotifier<int?> cameraInventory;
  
  // Methods to update values
  void updateEvidence(int value);
  void updateSanity(double value);
  void updateGameOver(bool value);
  void updateVictory(bool value);
  // ... etc
  
  void dispose();
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Single Attachment Invariant

*For any* game instance and any sequence of UI state changes, the game instance should be attached to exactly one GameWidget at all times during its lifecycle.

**Validates: Requirements 1.1, 1.2**

### Property 2: UI Update Independence

*For any* game state change (evidence collected, sanity changed, etc.), updating the UI overlays should not trigger a re-attachment of the game instance.

**Validates: Requirements 1.3, 2.3**

### Property 3: GameWidget Stability

*For any* sequence of setState() calls in ArcGameScreen, the GameWidget instance should remain the same object (same identity) throughout the screen's lifecycle.

**Validates: Requirements 2.2**

### Property 4: State Synchronization

*For any* game state property (evidence, sanity, victory, etc.), when the game updates that property, the corresponding ValueNotifier should reflect the new value within one frame.

**Validates: Requirements 1.3, 2.3**

### Property 5: Proper Cleanup

*For any* game instance, when the ArcGameScreen is disposed, all ValueNotifiers in the GameStateNotifier should be properly disposed without causing memory leaks.

**Validates: Requirements 2.4**

## Error Handling

### Game Attachment Errors

- **Prevention**: Use GlobalKey for GameWidget to ensure absolute identity stability
- **Detection**: Log onAttach() and onDetach() calls in BaseArcGame
- **Recovery**: If attachment error occurs, log detailed state and prevent further operations

### ValueNotifier Disposal

- **Prevention**: Dispose all ValueNotifiers in GameStateNotifier.dispose()
- **Detection**: Call dispose() in BaseArcGame.onRemove()
- **Recovery**: Ensure dispose() is idempotent (can be called multiple times safely)

### State Synchronization Issues

- **Prevention**: Update ValueNotifiers only when values actually change
- **Detection**: Log when ValueNotifier updates occur
- **Recovery**: If synchronization fails, force a full state update

## Testing Strategy

### Unit Tests

1. **GameStateNotifier Tests**
   - Test that updateEvidence() only notifies when value changes
   - Test that dispose() properly cleans up all ValueNotifiers
   - Test that multiple updates in quick succession work correctly

2. **BaseArcGame Tests**
   - Test that _updateStateNotifiers() updates all relevant notifiers
   - Test that game state changes trigger notifier updates
   - Test that onRemove() properly disposes the state notifier

### Integration Tests

1. **ArcGameScreen Widget Tests**
   - Test that GameWidget is created once and never rebuilt
   - Test that UI overlays update when game state changes
   - Test that setState() for local UI state doesn't affect GameWidget
   - Test that screen disposal properly cleans up resources

2. **Full Game Flow Tests**
   - Test complete game session from start to victory
   - Test complete game session from start to game over
   - Test pause/resume cycle
   - Test retry after game over

### Property-Based Tests

Property-based testing will use the `test` package with custom generators for game states.

1. **Property 1: Single Attachment**
   - Generate random sequences of UI updates
   - Verify game instance attachment count never exceeds 1

2. **Property 2: UI Update Independence**
   - Generate random game state changes
   - Verify no attachment errors occur during UI updates

3. **Property 3: GameWidget Stability**
   - Generate random setState() calls
   - Verify GameWidget identity remains constant

### Testing Framework

- **Unit Tests**: Dart `test` package
- **Widget Tests**: Flutter `flutter_test` package
- **Property Tests**: Custom generators with `test` package
- **Integration Tests**: Flutter integration test framework

### Test Execution

- All tests should run in CI/CD pipeline
- Property tests should run at least 100 iterations
- Integration tests should cover all 7 arcs
- Performance tests should verify no memory leaks
