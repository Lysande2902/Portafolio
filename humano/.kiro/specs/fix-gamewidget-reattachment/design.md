# Design Document

## Overview

The attachment error occurs because Flutter's widget rebuild mechanism causes the `GameWidget` to be reconstructed while still referencing the same game instance. Flame's architecture prevents a single game instance from being attached to multiple widgets simultaneously, even if those widgets are the same logical widget being rebuilt.

The solution is to use Flutter's `key` system to maintain widget identity across rebuilds, preventing Flame from attempting reattachment of the same game instance.

## Architecture

### Current Flow (Problematic)
```
1. initState() → Create game instance (hashCode: 115067360)
2. build() → Create GameWidget(game: 115067360)
3. GameWidget attaches game to render tree
4. ValueListenableBuilder rebuilds
5. build() called again → Create NEW GameWidget(game: 115067360)
6. NEW GameWidget tries to attach SAME game → ERROR
```

### Fixed Flow
```
1. initState() → Create game instance (hashCode: 115067360)
2. initState() → Create ObjectKey(game) for stable identity
3. build() → Create GameWidget(key: ObjectKey(game), game: 115067360)
4. GameWidget attaches game to render tree
5. ValueListenableBuilder rebuilds
6. build() called again → Flutter sees SAME key → Reuses existing GameWidget
7. No reattachment attempted → No error
```

## Components and Interfaces

### 1. ArcGameScreen Widget
**Responsibility:** Manage game lifecycle and provide stable GameWidget identity

**Changes:**
- Add `_gameWidgetKey` field to store the key
- Create key in `initState()` using `ObjectKey(game)`
- Pass key to `GameWidget` in `build()`

### 2. GameWidget Key Strategy
**Responsibility:** Ensure Flutter recognizes widget identity across rebuilds

**Implementation:**
- Use `ObjectKey(game)` which uses the game instance's identity
- Key is created once in `initState()` and never changes
- Flutter's reconciliation algorithm uses the key to match widgets across builds

## Data Models

### Widget Key
```dart
late final Key _gameWidgetKey;

// In initState:
_gameWidgetKey = ObjectKey(game);
```

### GameWidget with Key
```dart
GameWidget(
  key: _gameWidgetKey,
  game: game,
)
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Single Attachment Per Game Instance
*For any* game instance created in initState, the GameWidget SHALL attach that instance exactly once during the widget's lifetime, regardless of how many times build() is called.

**Validates: Requirements 1.1, 1.2**

### Property 2: Key Stability
*For any* game instance, the ObjectKey created for that instance SHALL remain constant throughout the widget's lifetime and SHALL be unique to that instance.

**Validates: Requirements 2.1, 2.2, 2.4**

### Property 3: Widget Identity Preservation
*For any* widget rebuild triggered by parent or ValueListenableBuilder changes, Flutter's reconciliation algorithm SHALL recognize the GameWidget as the same widget when it has the same key, preventing reconstruction.

**Validates: Requirements 1.3, 1.4, 2.2**

## Error Handling

### Attachment Error Prevention
- **Strategy:** Use ObjectKey to prevent widget reconstruction
- **Fallback:** If error still occurs, log detailed information about game instance and key
- **Recovery:** Not applicable - prevention is the only strategy

### Disposal Safety
- **Strategy:** Maintain existing disposal logic
- **Verification:** Ensure key doesn't interfere with proper cleanup
- **Logging:** Keep existing disposal logs for debugging

## Testing Strategy

### Unit Tests
- Test that ObjectKey is created in initState
- Test that the same key is used across multiple build() calls
- Test that different game instances get different keys

### Integration Tests
- Test that entering an arc doesn't produce attachment errors
- Test that ValueListenableBuilder rebuilds don't cause errors
- Test that the game runs correctly with the key in place

### Manual Testing
- Enter each of the 7 arcs and verify no attachment errors
- Trigger UI rebuilds (pause menu, item usage) and verify stability
- Monitor logs for any attachment-related warnings

## Implementation Notes

### Why ObjectKey?
- `ObjectKey` uses Dart's object identity (same as hashCode)
- Perfect for our use case: one key per game instance
- Automatically unique without manual key generation
- Lightweight and efficient

### Why Not ValueKey?
- `ValueKey` requires a primitive value (String, int, etc.)
- Would need to manually generate unique values
- More error-prone and less semantic

### Why Not GlobalKey?
- `GlobalKey` is heavier and meant for accessing widget state
- Overkill for our use case
- Can cause memory leaks if not managed carefully

### Alternative Considered: Const GameWidget
- Considered making GameWidget const to prevent rebuilds
- Not possible because game instance is not const
- Key-based approach is more idiomatic and flexible
