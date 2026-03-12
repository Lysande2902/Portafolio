# Design Document: Remove Error Handler Workaround

## Overview

This design eliminates the global error handler workaround that was masking "Game attachment error" exceptions. The root cause of these errors has already been fixed in `EvidenceComponent` by handling animations manually instead of using `add()` during the update cycle. The error handler is now unnecessary and should be removed to improve code quality and debugging capabilities.

## Architecture

### Current Architecture (With Workaround)

```
Application Start
    ↓
main() initializes ErrorHandler.initGlobalHandlers()
    ↓
ErrorHandler intercepts all Flutter/Flame errors
    ↓
If error contains "game attachment error" → Suppress and log
    ↓
Other errors → Pass through
```

### New Architecture (Clean)

```
Application Start
    ↓
main() starts normally (no error handler)
    ↓
Flutter's default error handling
    ↓
All errors visible in console for debugging
```

## Components and Interfaces

### Components to Remove

1. **lib/game/core/error/error_handler.dart**
   - Entire file to be deleted
   - Contains `ErrorHandler` class with `initGlobalHandlers()` method
   - Intercepts `FlutterError.onError` and `PlatformDispatcher.instance.onError`

2. **References in lib/main.dart**
   - Import statement: `import 'package:humano/game/core/error/error_handler.dart';`
   - Initialization call: `ErrorHandler.initGlobalHandlers();`

3. **References in lib/game/core/base/base_arc_game.dart**
   - Import statement (if exists)

### Components to Keep (Already Fixed)

1. **lib/game/core/components/evidence_component.dart**
   - Already implements manual animation in `update()` method
   - No longer calls `add()` during collection
   - This is the REAL fix for the game attachment error

## Data Models

No data model changes required. This is purely a cleanup task.

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Error visibility preservation
*For any* error that occurs during application execution, the error should be visible in the console output and not suppressed by custom handlers
**Validates: Requirements 1.2**

### Property 2: Evidence collection correctness
*For any* evidence component in any arc, calling `collect()` should complete the collection animation without throwing game attachment errors
**Validates: Requirements 3.1, 3.2, 3.3**

### Property 3: Code cleanliness
*For any* search of "ErrorHandler" or "error_handler" in the codebase, no results should be found after cleanup
**Validates: Requirements 2.1, 2.2, 2.3**

## Error Handling

### Before Removal
- Errors were suppressed silently
- Developers couldn't see real issues
- False sense of stability

### After Removal
- All errors visible in console
- Flutter's default error handling active
- Better debugging experience
- If game attachment errors appear, they indicate real problems that need fixing

## Testing Strategy

### Manual Testing

1. **Remove ErrorHandler**
   - Delete the file
   - Remove all imports and calls
   - Run the application

2. **Test Evidence Collection**
   - Play Arco Gula (Gluttony)
   - Collect all 5 evidence fragments
   - Verify smooth animation
   - Check console for errors

3. **Test Other Arcs**
   - Repeat for Arco Ira (Wrath)
   - Repeat for Arco Pereza (Sloth)
   - Verify no game attachment errors appear

4. **Rapid Collection Test**
   - Collect multiple fragments quickly
   - Verify no errors or crashes

### Expected Behavior

- ✅ Application starts normally
- ✅ Evidence collection works smoothly
- ✅ No "Game attachment error" messages in console
- ✅ All animations play correctly
- ✅ No crashes or freezes

### If Errors Appear

If game attachment errors appear after removal, it means:
1. There's a real problem in the code
2. The error was being hidden by the handler
3. We need to fix the actual issue (like we did with EvidenceComponent)

This is GOOD - we want to see real errors so we can fix them properly.

## Implementation Notes

### Why This Works

The real fix was already implemented in `EvidenceComponent.collect()`:

```dart
void collect() {
  if (isCollected || _isCollecting) return;
  _isCollecting = true;
  isCollected = true;
  
  // Store initial scale for animation
  _initialScale = scale.x;
  
  // Reset collection timer to start animation
  _collectionTimer = 0.0;
  
  // Animation will be handled in update() method
  // This avoids the "Game attachment error" by not calling add() during update cycle
}
```

The animation is handled manually in `update()` instead of using `add(ScaleEffect(...))`, which was causing the error.

### Files to Modify

1. **lib/game/core/error/error_handler.dart** - DELETE
2. **lib/main.dart** - Remove import and initialization
3. **lib/game/core/base/base_arc_game.dart** - Remove import if present
4. **GAME_ATTACHMENT_SOLUCION_SIMPLE.md** - Can be archived or deleted (documentation only)

### Documentation Cleanup

The following documentation files reference the workaround and can be archived:
- `GAME_ATTACHMENT_SOLUCION_SIMPLE.md`
- `.kiro/specs/fix-game-attachment-errors/` (entire spec folder)

These are historical and no longer needed for the current codebase.

## Benefits

1. **Cleaner Code**: No unnecessary error suppression
2. **Better Debugging**: All errors visible during development
3. **Maintainability**: Less code to maintain
4. **Transparency**: No hidden behaviors
5. **Best Practices**: Following Flutter/Flame conventions

## Risk Assessment

**Risk Level**: LOW

- The real fix is already in place
- ErrorHandler was only masking symptoms
- Removing it exposes real issues (which is good)
- Easy to rollback if needed (just restore the file)

## Migration Path

1. Remove ErrorHandler file
2. Remove references in main.dart
3. Test evidence collection in all arcs
4. If errors appear → Fix the actual issue
5. If no errors → Cleanup complete ✅
