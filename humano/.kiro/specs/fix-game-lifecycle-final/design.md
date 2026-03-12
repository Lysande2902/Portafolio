# Design Document

## Overview

El problema del "Game attachment error" persiste porque hay una desconexión fundamental entre el ciclo de vida de Flutter (Widget) y el ciclo de vida de Flame (Game). La solución requiere una sincronización estricta entre ambos ciclos de vida, asegurando que:

1. El juego se crea ANTES del GameWidget
2. Los componentes se agregan DESPUÉS de que el juego esté montado
3. Las actualizaciones de estado se difieren hasta después del primer frame
4. El reset limpia completamente el estado antes de reinicializar

## Architecture

```
Flutter Widget Lifecycle          Flame Game Lifecycle
─────────────────────────         ────────────────────
initState()                       
  ├─> Create game instance        
  └─> Create GameWidget           
                                  
didChangeDependencies()           
  └─> Setup providers             
                                  
build()                           
  └─> Return GameWidget           ├─> onLoad()
                                  │   └─> (defer component setup)
                                  │
                                  ├─> onAttach()
                                  │   └─> (game attached to widget)
                                  │
                                  └─> onMount()
                                      └─> NOW safe to add components
                                  
Post-frame callback               
  └─> Flush deferred updates      ├─> setupScene()
                                  ├─> setupPlayer()
                                  ├─> setupEnemy()
                                  └─> setupCollectibles()
```

## Components and Interfaces

### 1. GameLifecycleManager

**Purpose**: Coordinar el ciclo de vida entre Flutter y Flame

```dart
class GameLifecycleManager {
  bool _isAttached = false;
  bool _isMounted = false;
  bool _isInitialized = false;
  final List<VoidCallback> _deferredActions = [];
  
  void markAttached() {
    _isAttached = true;
    _tryFlushDeferred();
  }
  
  void markMounted() {
    _isMounted = true;
    _tryFlushDeferred();
  }
  
  void markInitialized() {
    _isInitialized = true;
  }
  
  bool get canAddComponents => _isAttached && _isMounted;
  
  void deferAction(VoidCallback action) {
    if (canAddComponents) {
      action();
    } else {
      _deferredActions.add(action);
    }
  }
  
  void _tryFlushDeferred() {
    if (canAddComponents && _deferredActions.isNotEmpty) {
      for (final action in _deferredActions) {
        action();
      }
      _deferredActions.clear();
    }
  }
  
  void reset() {
    _isAttached = false;
    _isMounted = false;
    _isInitialized = false;
    _deferredActions.clear();
  }
}
```

### 2. BaseArcGame Modifications

**Changes**:
- Add `GameLifecycleManager`
- Override `onAttach()` to mark attachment
- Override `onMount()` to mark mounting and trigger deferred setup
- Modify `setupScene/Player/Enemy/Collectibles` to use deferred actions
- Ensure `resetGame()` properly resets lifecycle state

### 3. ArcGameScreen Modifications

**Changes**:
- Keep game instance creation in `initState()`
- Keep GameWidget caching
- Ensure no setState() calls during initialization
- Use post-frame callback to verify initialization complete

## Data Models

No new data models required. Existing models remain unchanged.

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Lifecycle ordering

*For any* game initialization, the lifecycle events should occur in strict order: create → attach → mount → add components
**Validates: Requirements 1.1, 1.2, 1.3, 2.1**

### Property 2: Component addition safety

*For any* component addition during initialization, it should only occur after the game is both attached and mounted
**Validates: Requirements 1.2, 1.3**

### Property 3: State update deferral

*For any* state update during initialization, it should be queued and applied only after the first frame completes
**Validates: Requirements 1.5, 2.2**

### Property 4: Reset completeness

*For any* game reset, all components should be removed and lifecycle state should be cleared before reinitialization
**Validates: Requirements 1.4, 2.4**

### Property 5: Cross-arc consistency

*For any* arc (Gula, Avaricia, Envidia), the initialization pattern should be identical
**Validates: Requirements 3.1**

## Error Handling

### Lifecycle Violations

- **Detection**: Log all lifecycle events with timestamps
- **Prevention**: Use `canAddComponents` check before any component addition
- **Recovery**: Queue actions for later execution if lifecycle not ready

### Component Addition Errors

- **Detection**: Catch exceptions during component addition
- **Prevention**: Use `deferAction()` for all component additions during init
- **Recovery**: Retry failed additions after mount completes

### State Update Errors

- **Detection**: Catch setState during build errors
- **Prevention**: Use post-frame callbacks for all initial state updates
- **Recovery**: Queue updates for next frame

## Testing Strategy

### Unit Tests

1. **GameLifecycleManager Tests**
   - Test state transitions (not attached → attached → mounted)
   - Test deferred action queueing and flushing
   - Test reset behavior

2. **BaseArcGame Tests**
   - Test lifecycle event ordering
   - Test component addition deferral
   - Test reset cleanup

### Integration Tests

1. **Arc Loading Test**
   - Load each arc (Gula, Avaricia, Envidia)
   - Verify no attachment errors in logs
   - Verify game is playable

2. **Reset Test**
   - Start game → collect evidence → die → retry
   - Verify clean reset without errors
   - Verify game state is properly restored

3. **Rapid Navigation Test**
   - Open arc → close → open again quickly
   - Verify no double initialization
   - Verify proper cleanup

### Manual Testing

1. Open each arc and verify:
   - No console errors
   - Map loads correctly
   - Player can move
   - Evidence can be collected

2. Test game over flow:
   - Die intentionally
   - Click retry
   - Verify game resets properly

3. Test victory flow:
   - Complete arc
   - Verify victory screen shows
   - Verify progress saves

## Implementation Notes

- All component additions during initialization MUST use `deferAction()`
- All state updates during initialization MUST be queued
- Lifecycle events MUST be logged for debugging
- Reset MUST clear lifecycle state before reinitializing
