# Design Document

## Overview

The "Unsupported operation: Game attachment error" occurs **after** successful game initialization and asset loading, indicating that Flame's internal attachment mechanism is detecting a duplicate attachment attempt that our current guard flags cannot prevent. The error appears to be thrown from deep within Flame's widget lifecycle, suggesting the issue is with how Flame tracks attachment state internally, not just with our external guards.

Based on the logs and previous attempts, the problem is:
1. Game is created once ✅
2. GameWidget is created once ✅  
3. Game loads successfully ✅
4. **Then** the attachment error occurs ❌

This timing suggests that something during or after the `onLoad()` phase is triggering a second attachment attempt within Flame's internal state machine.

## Architecture

### Current Implementation Analysis

**What's Working:**
- `_isAttached` flag in `BaseArcGame.attach()` prevents our code from calling `super.attach()` twice
- GlobalKey on GameWidget preserves widget identity
- Game and GameWidget are created exactly once
- Disposal is clean

**What's Not Working:**
- Flame's internal attachment tracking still detects a duplicate attachment
- The error occurs after `onLoad()` completes, during the rendering phase
- Our guard flag prevents the second `super.attach()` call, but Flame still throws the error

### Root Cause Hypothesis

Flame 1.18.0 has internal attachment state tracking that is more strict than previous versions. The error likely occurs because:

1. **Flame's internal state machine**: Flame tracks attachment state internally and throws when it detects inconsistency
2. **Widget lifecycle timing**: The error occurs during the transition from initialization to rendering
3. **Guard flag limitation**: Our `_isAttached` flag prevents the second `super.attach()` call, but Flame's internal state is already inconsistent

### Solution Strategy

Instead of trying to prevent Flame's internal error, we need to ensure Flame never enters the state where it would throw the error. This requires:

1. **Proper detachment before disposal**: Ensure `detach()` is called before the game is removed
2. **Synchronous disposal**: Avoid async delays that might cause timing issues
3. **Clean state reset**: Reset all Flame-related state before creating new instances
4. **Widget preservation**: Use `AutomaticKeepAliveClientMixin` to prevent widget disposal during navigation

## Components and Interfaces

### 1. Enhanced BaseArcGame

```dart
abstract class BaseArcGame extends FlameGame with HasCollisionDetection {
  // Remove the _isAttached flag - it's not helping
  // Instead, rely on Flame's built-in attachment tracking
  
  @override
  void attach(PipelineOwner owner, covariant GameRenderBox gameRenderBox) {
    debugPrint('🔗 [ATTACH] Attaching game: ${this.runtimeType}');
    debugPrint('🔗 [ATTACH] Already attached: ${this.attached}');
    
    // Let Flame handle attachment - don't override its logic
    super.attach(owner, gameRenderBox);
  }
  
  @override
  void detach() {
    debugPrint('🔓 [DETACH] Detaching game: ${this.runtimeType}');
    debugPrint('🔓 [DETACH] Was attached: ${this.attached}');
    super.detach();
  }
  
  @override
  void onRemove() {
    debugPrint('🗑️ [REMOVE] Removing game: ${this.runtimeType}');
    
    // Ensure we're detached before removal
    if (attached) {
      debugPrint('⚠️ [REMOVE] Game still attached - detaching now');
      detach();
    }
    
    super.onRemove();
  }
}
```

### 2. Simplified ArcGameScreen

```dart
class _ArcGameScreenState extends State<ArcGameScreen> 
    with AutomaticKeepAliveClientMixin {
  
  late final BaseArcGame game;
  late final Widget _gameWidget;
  
  @override
  bool get wantKeepAlive => true; // Prevent disposal during navigation
  
  @override
  void initState() {
    super.initState();
    
    // Create game
    game = _createGame(widget.arcId);
    
    // Create GameWidget with stable key
    _gameWidget = GameWidget(
      key: GlobalKey(debugLabel: 'GameWidget_${widget.arcId}'),
      game: game,
    );
  }
  
  @override
  void dispose() {
    debugPrint('🗑️ [SCREEN] Disposing screen for ${widget.arcId}');
    
    // Pause first
    game.pauseEngine();
    
    // Dispose state notifier
    game.stateNotifier.dispose();
    
    // Let Flame handle detachment through its normal lifecycle
    // Don't manually call detach() - let the widget tree handle it
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    
    return Scaffold(
      body: Stack(
        children: [
          _gameWidget, // Use the stable widget
          // ... UI overlays
        ],
      ),
    );
  }
}
```

### 3. Alternative: GameWidget Wrapper

If the above doesn't work, we can create a wrapper that intercepts Flame's attachment:

```dart
class StableGameWidget extends StatefulWidget {
  final BaseArcGame game;
  
  const StableGameWidget({super.key, required this.game});
  
  @override
  State<StableGameWidget> createState() => _StableGameWidgetState();
}

class _StableGameWidgetState extends State<StableGameWidget> 
    with AutomaticKeepAliveClientMixin {
  
  late final Widget _gameWidget;
  bool _isDisposed = false;
  
  @override
  bool get wantKeepAlive => true;
  
  @override
  void initState() {
    super.initState();
    
    _gameWidget = GameWidget(
      key: GlobalKey(debugLabel: 'InnerGameWidget'),
      game: widget.game,
    );
  }
  
  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    if (_isDisposed) {
      return const SizedBox.shrink();
    }
    
    return _gameWidget;
  }
}
```

## Data Models

### Attachment State Tracking

```dart
class AttachmentDebugInfo {
  final String gameType;
  final int gameHashCode;
  final int widgetHashCode;
  final DateTime timestamp;
  final bool wasAttached;
  final StackTrace stackTrace;
  
  AttachmentDebugInfo({
    required this.gameType,
    required this.gameHashCode,
    required this.widgetHashCode,
    required this.timestamp,
    required this.wasAttached,
    required this.stackTrace,
  });
  
  @override
  String toString() {
    return '''
AttachmentDebugInfo:
  Game: $gameType ($gameHashCode)
  Widget: $widgetHashCode
  Time: $timestamp
  Was Attached: $wasAttached
  Stack: ${stackTrace.toString().split('\n').take(5).join('\n')}
''';
  }
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Single Attachment Per Game Instance
*For any* game instance, the `attach()` method should be called at most once during the instance's lifetime, and `attached` should be true after attachment and false after detachment.
**Validates: Requirements 1.1, 3.3**

### Property 2: Successful Initialization Without Errors
*For any* arc game type, initialization and asset loading should complete without throwing attachment-related exceptions.
**Validates: Requirements 1.2**

### Property 3: Stable Attachment During Runtime
*For any* running game, the `attached` property should remain true throughout the game's active lifecycle until disposal begins.
**Validates: Requirements 1.3**

### Property 4: Clean Detachment on Disposal
*For any* game instance being disposed, `detach()` should be called before `onRemove()`, and `attached` should be false after disposal completes.
**Validates: Requirements 1.4**

### Property 5: Fresh Instance on Re-entry
*For any* arc, navigating away and back should create a new game instance with a different hashCode and clean attachment state.
**Validates: Requirements 1.5**

### Property 6: Widget Identity Preservation
*For any* GameWidget with a GlobalKey, the widget's identity (key hashCode) should remain constant across all build cycles until disposal.
**Validates: Requirements 3.5**

### Property 7: No Recreation on Rebuild
*For any* widget tree rebuild triggered by setState or Provider updates, the game instance hashCode and GameWidget hashCode should remain unchanged.
**Validates: Requirements 3.2**

### Property 8: Proper State Reset on Disposal
*For any* game instance after disposal, all attachment-related flags and state should be reset to their initial values.
**Validates: Requirements 3.4**

## Error Handling

### Attachment Error Detection

```dart
class AttachmentErrorHandler {
  static void wrapGameCreation(VoidCallback creation) {
    try {
      creation();
    } catch (e, stackTrace) {
      if (e.toString().contains('attachment')) {
        debugPrint('❌ [ATTACHMENT ERROR] $e');
        debugPrint('📋 [STACK] $stackTrace');
        
        // Log diagnostic information
        _logDiagnostics();
        
        // Rethrow to let Flutter handle it
        rethrow;
      }
      rethrow;
    }
  }
  
  static void _logDiagnostics() {
    debugPrint('═══════════════════════════════════');
    debugPrint('🔍 [DIAGNOSTICS] Attachment Error Occurred');
    debugPrint('   Flame Version: 1.18.0');
    debugPrint('   Flutter Version: ${Platform.version}');
    debugPrint('═══════════════════════════════════');
  }
}
```

### Graceful Degradation

If attachment errors persist:
1. Log full diagnostic information
2. Attempt to detach and reattach
3. If that fails, recreate the game instance
4. If that fails, show error UI and allow retry

## Testing Strategy

### Unit Tests

1. **Test Game Creation**: Verify game instances are created with correct initial state
2. **Test Attachment Flags**: Verify `attached` property reflects actual state
3. **Test Disposal**: Verify all cleanup methods are called in correct order

### Property-Based Tests

We will use the `test` package with custom property testing utilities for Dart/Flutter.

**Property Test 1: Single Attachment Invariant**
- Generate random arc types
- Create game instance
- Attach to widget
- Verify `attached == true`
- Attempt second attachment
- Verify no error or error is caught gracefully
- **Validates: Property 1**

**Property Test 2: Initialization Success**
- Generate random arc types
- Create and initialize game
- Verify no exceptions thrown
- Verify game is in ready state
- **Validates: Property 2**

**Property Test 3: Rebuild Stability**
- Create game and widget
- Trigger multiple rebuilds
- Verify game hashCode unchanged
- Verify widget hashCode unchanged
- **Validates: Property 7**

**Property Test 4: Disposal Cleanup**
- Create game instance
- Attach to widget
- Dispose
- Verify `attached == false`
- Verify state is reset
- **Validates: Property 4, Property 8**

### Integration Tests

1. **Full Navigation Flow**: Navigate to arc → play → exit → re-enter
2. **Multiple Arcs**: Test all 7 arcs in sequence
3. **Stress Test**: Rapidly navigate between arcs
4. **Long Session**: Play for extended period, verify stability

### Manual Testing

1. Enable debug logging
2. Navigate to each arc
3. Check logs for:
   - Single "ATTACH" message per game
   - No "attachment error" messages
   - Clean "DETACH" on exit
4. Verify game plays normally
5. Test navigation patterns:
   - Arc → Menu → Same Arc
   - Arc → Menu → Different Arc
   - Arc → Back → Arc (rapid)

## Implementation Plan

### Phase 1: Diagnostic Enhancement
1. Add comprehensive logging to attachment lifecycle
2. Capture full error messages and stack traces
3. Log Flame's internal `attached` property state

### Phase 2: Simplification
1. Remove custom `_isAttached` flag (rely on Flame's built-in tracking)
2. Simplify disposal logic (remove async delays)
3. Add `AutomaticKeepAliveClientMixin` to prevent premature disposal

### Phase 3: Alternative Approaches (if needed)
1. Implement `StableGameWidget` wrapper
2. Try different GameWidget key strategies
3. Investigate Flame version upgrade/downgrade

### Phase 4: Testing & Validation
1. Run property-based tests
2. Perform integration testing
3. Stress test with rapid navigation
4. Verify across all 7 arcs

## Performance Considerations

- `AutomaticKeepAliveClientMixin` keeps widgets in memory longer, but prevents disposal/recreation overhead
- Simplified disposal logic reduces async timing issues
- Comprehensive logging only in debug mode (no production impact)

## Security Considerations

None - this is an internal game engine integration issue with no security implications.

## Deployment Considerations

- Changes are backwards compatible
- No database migrations needed
- Can be deployed incrementally (test one arc at a time)
- Rollback is simple (revert code changes)
