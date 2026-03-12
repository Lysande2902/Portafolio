# Design Document

## Overview

This design addresses the "setState() or markNeedsBuild() called during build" error that causes game attachment issues in ArcGameScreen. The root cause is that game initialization triggers state changes that attempt to update the widget during the build phase, violating Flutter's widget lifecycle rules.

The solution involves deferring all state updates until after the initial build completes using post-frame callbacks and ensuring that game initialization doesn't trigger any widget rebuilds.

## Architecture

### Current Flow (Problematic)
```
1. ArcGameScreen.initState() → Creates game instance
2. ArcGameScreen.build() → Creates GameWidget
3. GameWidget attaches game
4. Game.onLoad() → Initializes game
5. Game initialization → Triggers state changes
6. State changes → Call setState() during build ❌
7. Flutter throws error → Game attachment fails
```

### New Flow (Fixed)
```
1. ArcGameScreen.initState() → Creates game instance
2. ArcGameScreen.didChangeDependencies() → Setup providers (no setState)
3. ArcGameScreen.build() → Creates GameWidget
4. GameWidget attaches game
5. Game.onLoad() → Initializes game
6. Post-frame callback → Schedule state updates for next frame ✅
7. Next frame → State updates applied safely
```

## Components and Interfaces

### 1. ArcGameScreen Modifications

**Purpose**: Ensure no setState() calls during build phase

**Key Changes**:
- Remove all direct setState() calls that could be triggered during initialization
- Use `WidgetsBinding.instance.addPostFrameCallback()` for deferred updates
- Ensure `didChangeDependencies()` doesn't trigger rebuilds

### 2. BaseArcGame Modifications

**Purpose**: Prevent game initialization from triggering widget updates

**Key Changes**:
- Add flag to track if initial build is complete
- Queue state updates during initialization
- Flush queued updates after first frame

### 3. GameStateNotifier Enhancement

**Purpose**: Support deferred state updates

**Key Changes**:
- Add method to batch multiple state updates
- Add method to defer updates until safe
- Maintain update queue for post-frame application

## Data Models

### StateUpdateQueue
```dart
class StateUpdateQueue {
  final List<VoidCallback> _updates = [];
  bool _isProcessing = false;
  
  void enqueue(VoidCallback update) {
    _updates.add(update);
  }
  
  void flush() {
    if (_isProcessing) return;
    _isProcessing = true;
    
    for (final update in _updates) {
      update();
    }
    
    _updates.clear();
    _isProcessing = false;
  }
  
  void clear() {
    _updates.clear();
  }
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: No setState during build
*For any* widget build cycle, no setState() calls should occur during the build phase itself
**Validates: Requirements 1.1**

### Property 2: Deferred updates are applied
*For any* state update queued during initialization, that update should be applied after the build phase completes
**Validates: Requirements 1.2**

### Property 3: Game attachment succeeds
*For any* game initialization, the GameWidget should successfully attach the game instance without errors
**Validates: Requirements 1.3**

### Property 4: Initialization completes before updates
*For any* game instance, all initialization logic should complete before any state updates are sent to the widget
**Validates: Requirements 2.1**

### Property 5: Post-frame callbacks execute
*For any* post-frame callback scheduled, it should execute exactly once after the current frame completes
**Validates: Requirements 1.2**

### Property 6: No console errors on load
*For any* game arc navigation, the console should show no "setState during build" or "Game attachment error" messages
**Validates: Requirements 3.1, 3.2, 3.3**

## Error Handling

### Build Phase Violations
- **Detection**: Catch setState() calls during build using Flutter's debug assertions
- **Recovery**: Queue the update for post-frame execution
- **Logging**: Log warning with stack trace for debugging

### Game Attachment Failures
- **Detection**: Monitor onAttach() and onDetach() lifecycle events
- **Recovery**: Retry attachment after clearing widget state
- **Logging**: Log detailed attachment state for debugging

### Post-Frame Callback Failures
- **Detection**: Wrap callbacks in try-catch blocks
- **Recovery**: Log error and continue (don't block game)
- **Logging**: Log callback errors with context

## Testing Strategy

### Unit Tests
- Test that StateUpdateQueue correctly queues and flushes updates
- Test that post-frame callbacks are scheduled correctly
- Test that game initialization doesn't trigger immediate state updates

### Property-Based Tests
- **Property 1 Test**: Generate random game initialization sequences, verify no setState during build
- **Property 2 Test**: Generate random state updates during init, verify all are applied post-frame
- **Property 3 Test**: Generate random game configurations, verify attachment always succeeds
- **Property 4 Test**: Generate random initialization orders, verify init completes before updates
- **Property 5 Test**: Generate random callback schedules, verify each executes exactly once
- **Property 6 Test**: Generate random arc navigations, verify no console errors

### Integration Tests
- Test full game loading flow from navigation to playable state
- Test game reset flow (retry after game over)
- Test rapid navigation (back and forth between arcs)

### Manual Testing
- Load each arc and verify no console errors
- Play through a full arc and verify smooth experience
- Trigger game over and retry, verify clean reset
- Navigate between multiple arcs rapidly

## Implementation Notes

### Critical Sections
1. **ArcGameScreen.initState()**: Must not trigger any setState
2. **ArcGameScreen.didChangeDependencies()**: Must not trigger any setState
3. **Game.onLoad()**: Must not trigger widget updates directly
4. **Game initialization**: Must queue all state updates

### Performance Considerations
- Post-frame callbacks add minimal overhead (< 1ms)
- State update queue is lightweight (simple list)
- No impact on steady-state game performance

### Backwards Compatibility
- All existing game logic remains unchanged
- Only initialization flow is modified
- No breaking changes to game API

## Migration Path

1. Add StateUpdateQueue to BaseArcGame
2. Modify GameStateNotifier to support deferred updates
3. Update ArcGameScreen to use post-frame callbacks
4. Test each arc individually
5. Deploy and monitor for errors
