# Design Document: Fix Flame Double Attachment

## Overview

El problema fundamental es que Flame está intentando adjuntar una instancia de juego que ya está adjuntada a un GameWidget. Esto ocurre porque Flutter está reconstruyendo el widget tree y creando nuevas instancias de GameWidget con la misma instancia de juego.

La solución consiste en garantizar que:
1. La instancia del juego se crea exactamente una vez en `initState()`
2. El GameWidget se crea exactamente una vez y se almacena como variable de instancia
3. El método `build()` siempre retorna la misma instancia de GameWidget
4. No se intenta desadjuntar el juego en `deactivate()` o `dispose()`

## Architecture

### Current Problem

```
Usuario navega → ArcGameScreen creado → initState() crea game
                                      → initState() crea GameWidget(game)
                                      → build() retorna GameWidget
                                      
Flutter rebuild → build() llamado de nuevo
                → Si creamos nuevo GameWidget(game) → ERROR: game ya adjuntado
```

### Solution Architecture

```
Usuario navega → ArcGameScreen creado → initState() crea game ONCE
                                      → initState() crea _gameWidget ONCE
                                      → build() retorna _gameWidget (misma instancia)
                                      
Flutter rebuild → build() llamado de nuevo
                → build() retorna _gameWidget (misma instancia) → OK
```

## Components and Interfaces

### ArcGameScreen State Management

```dart
class _ArcGameScreenState extends State<ArcGameScreen> {
  // Game instance - created ONCE in initState
  late final BaseArcGame _game;
  
  // GameWidget instance - created ONCE in initState
  late final Widget _gameWidget;
  
  // Flag to ensure providers are setup only once
  bool _providersSetupDone = false;
  
  @override
  void initState() {
    super.initState();
    
    // Create game instance ONCE
    _game = _createGameForArc(widget.arcId);
    
    // Create GameWidget ONCE - store as instance variable
    _gameWidget = GameWidget(game: _game);
  }
  
  @override
  Widget build(BuildContext context) {
    // Always return the SAME GameWidget instance
    return Scaffold(
      body: Stack(
        children: [
          _gameWidget, // Same instance every time
          // ... other UI elements
        ],
      ),
    );
  }
  
  // NO deactivate() override
  // NO dispose() override that touches the game
}
```

### Game Instance Creation

```dart
BaseArcGame _createGameForArc(String arcId) {
  switch (arcId) {
    case 'arc_1_gula':
      return GluttonyArcGame();
    case 'arc_2_greed':
      return GreedArcGame();
    // ... other arcs
    default:
      return GluttonyArcGame();
  }
}
```

## Data Models

### Game Lifecycle States

```dart
enum GameLifecycleState {
  created,      // Game instance created
  attached,     // Game attached to GameWidget
  active,       // Game running
  paused,       // Game paused
  detached,     // Game detached from GameWidget
  disposed,     // Game disposed
}
```

### Attachment Tracking

```dart
class GameAttachmentTracker {
  bool _isAttached = false;
  int _attachmentCount = 0;
  
  void onAttach() {
    if (_isAttached) {
      throw StateError('Game already attached!');
    }
    _isAttached = true;
    _attachmentCount++;
  }
  
  void onDetach() {
    _isAttached = false;
  }
  
  bool get isAttached => _isAttached;
  int get attachmentCount => _attachmentCount;
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Widget rebuild preserves game instance

*For any* ArcGameScreen widget, when build() is called multiple times, the game instance should remain the same object (same identity).

**Validates: Requirements 1.2**

### Property 2: Widget rebuild preserves GameWidget instance

*For any* ArcGameScreen widget, when build() is called multiple times, the GameWidget instance should remain the same object (same identity).

**Validates: Requirements 2.2**

### Property 3: Deactivation preserves game state

*For any* ArcGameScreen widget with active game state, when the widget is temporarily deactivated, the game's state (evidence count, sanity, position) should remain unchanged.

**Validates: Requirements 2.4**

### Property 4: Reactivation preserves game instance

*For any* ArcGameScreen widget that has been deactivated, when it is reactivated, the game instance should be the same object (same identity).

**Validates: Requirements 2.5**

### Property 5: Single attachment invariant

*For any* game instance, the attachment count should never exceed 1 during its lifetime.

**Validates: Requirements 1.5**

## Error Handling

### Attachment Error Detection

```dart
class SafeGameWidget extends StatefulWidget {
  final BaseArcGame game;
  
  const SafeGameWidget({required this.game, super.key});
  
  @override
  State<SafeGameWidget> createState() => _SafeGameWidgetState();
}

class _SafeGameWidgetState extends State<SafeGameWidget> {
  @override
  Widget build(BuildContext context) {
    try {
      return GameWidget(game: widget.game);
    } catch (e) {
      if (e.toString().contains('already attached')) {
        // Log detailed error information
        debugPrint('❌ ATTACHMENT ERROR: Game already attached');
        debugPrint('Game type: ${widget.game.runtimeType}');
        debugPrint('Game hashCode: ${widget.game.hashCode}');
        
        // Show error UI instead of crashing
        return Center(
          child: Text('Error: Game attachment failed'),
        );
      }
      rethrow;
    }
  }
}
```

### Lifecycle Error Recovery

```dart
void _handleLifecycleError(Object error, StackTrace stackTrace) {
  debugPrint('❌ Lifecycle error: $error');
  debugPrint('Stack trace: $stackTrace');
  
  // Attempt recovery by resetting game state
  try {
    _game.resetGame();
  } catch (e) {
    debugPrint('❌ Recovery failed: $e');
    // Navigate back to safety
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
```

## Testing Strategy

### Unit Tests

Unit tests will verify specific lifecycle scenarios:

1. **Single initialization test**: Verify that initState() creates exactly one game instance
2. **Disposal test**: Verify that dispose() is called when widget is destroyed
3. **Provider setup test**: Verify that providers are setup exactly once

### Property-Based Tests

Property-based tests will verify universal behaviors across many scenarios:

1. **Widget rebuild property**: Generate random sequences of build() calls and verify game instance remains the same
2. **GameWidget stability property**: Generate random sequences of build() calls and verify GameWidget instance remains the same
3. **Deactivation property**: Generate random game states, deactivate widget, verify state unchanged
4. **Reactivation property**: Generate random deactivation/reactivation sequences, verify game instance unchanged
5. **Attachment invariant property**: Generate random widget lifecycle sequences, verify attachment count never exceeds 1

### Testing Framework

We will use the following testing frameworks:
- **flutter_test**: For widget testing and lifecycle testing
- **test**: For unit testing
- **mockito**: For mocking providers and dependencies

### Property-Based Testing Configuration

- Each property test will run a minimum of 100 iterations
- Tests will use random seeds for reproducibility
- Failed tests will report the exact input that caused the failure

## Implementation Notes

### Key Principles

1. **Single Responsibility**: The game instance is created once and owned by the State object
2. **Immutability**: Once created, the game and GameWidget instances never change
3. **No Manual Lifecycle Management**: We don't override deactivate() or dispose() to manipulate the game
4. **Let Flame Handle It**: Flame's internal lifecycle management handles attachment/detachment

### What NOT to Do

❌ Don't create new GameWidget in build()
❌ Don't try to detach game in deactivate()
❌ Don't try to dispose game manually
❌ Don't use keys on GameWidget (causes Flutter to think it's a new widget)
❌ Don't call game.attach() or game.detach() manually

### What TO Do

✅ Create game once in initState()
✅ Create GameWidget once in initState()
✅ Store both as late final instance variables
✅ Return same GameWidget instance in build()
✅ Let Flame handle its own lifecycle

## Migration Path

### Step 1: Remove Problematic Code

Remove all manual lifecycle management:
- Remove `deactivate()` override
- Remove `dispose()` override that touches the game
- Remove any manual `attach()`/`detach()` calls

### Step 2: Implement Single Instance Pattern

```dart
class _ArcGameScreenState extends State<ArcGameScreen> {
  late final BaseArcGame _game;
  late final Widget _gameWidget;
  
  @override
  void initState() {
    super.initState();
    _game = _createGameForArc(widget.arcId);
    _gameWidget = GameWidget(game: _game);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _gameWidget, // Always the same instance
          // ... UI
        ],
      ),
    );
  }
}
```

### Step 3: Verify

- Run the app
- Navigate to game screen
- Verify no attachment errors
- Hot reload several times
- Verify no attachment errors
- Navigate away and back
- Verify no attachment errors

## Performance Considerations

### Memory

- Single game instance per screen: ~10-50MB depending on arc
- GameWidget overhead: negligible
- Total memory impact: minimal

### CPU

- No performance impact from this change
- Actually improves performance by avoiding unnecessary widget recreation

### Battery

- No impact on battery life

## Future Enhancements

1. **Attachment Monitoring**: Add development-mode monitoring to detect attachment issues early
2. **Lifecycle Visualization**: Add debug UI to visualize game lifecycle states
3. **Automatic Recovery**: Implement automatic recovery from attachment errors
4. **Testing Tools**: Create testing utilities to simulate complex lifecycle scenarios
