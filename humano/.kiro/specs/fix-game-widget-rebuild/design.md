# Design Document

## Overview

This design solves the "Game attachment error" by ensuring that the GameWidget is created exactly once during the StatefulWidget's initialization and reused across all subsequent build cycles. The solution leverages Flutter's StatefulWidget lifecycle to create a stable widget instance that never changes.

## Architecture

The fix involves modifying the `_ArcGameScreenState` class to:

1. Store a stable `Widget` reference to the GameWidget created in `initState()`
2. Return this same widget instance in every `build()` call
3. Ensure the game instance is also created once and never recreated

### Current Problem

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    body: Stack(
      children: [
        GameWidget(game: game), // ❌ NEW widget created on every build!
        // ...
      ],
    ),
  );
}
```

Every time `build()` is called (which happens frequently in Flutter), a **new** `GameWidget` is created. Flame detects this as an attempt to attach the same game instance to multiple widgets, causing the error.

### Solution

```dart
class _ArcGameScreenState extends State<ArcGameScreen> {
  late final dynamic game;
  late final Widget _stableGameWidget; // ✅ Created once, never changes
  
  @override
  void initState() {
    super.initState();
    
    // Create game instance once
    game = _createGameInstance();
    
    // Create GameWidget once and store it
    _stableGameWidget = GameWidget(game: game);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _stableGameWidget, // ✅ Same widget instance every time
          // ...
        ],
      ),
    );
  }
}
```

## Components and Interfaces

### Modified Component: `_ArcGameScreenState`

**New Fields:**
- `_stableGameWidget`: A `late final Widget` that holds the GameWidget instance created in `initState()`

**Modified Methods:**
- `initState()`: Now creates both the game instance AND the GameWidget, storing the latter in `_stableGameWidget`
- `build()`: Now returns `_stableGameWidget` instead of creating a new `GameWidget(game: game)`

## Data Models

No data model changes required. The existing game instance types remain unchanged.

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Single GameWidget Creation

*For any* ArcGameScreen widget lifecycle, the GameWidget SHALL be instantiated exactly once during initState and never recreated during subsequent build calls.

**Validates: Requirements 1.1, 1.2, 1.3**

### Property 2: Stable Widget Reference

*For any* sequence of build() calls on the same ArcGameScreen instance, the returned GameWidget reference SHALL be identical (same object instance) across all calls.

**Validates: Requirements 1.2, 1.4**

### Property 3: Game Instance Stability

*For any* ArcGameScreen widget lifecycle, the game instance SHALL be created exactly once in initState and SHALL maintain the same reference throughout the widget's lifetime.

**Validates: Requirements 2.1, 2.2, 2.3, 2.4**

## Error Handling

### Attachment Error Prevention

The design eliminates the attachment error by ensuring:
1. Only one GameWidget instance exists per ArcGameScreen
2. The GameWidget is created before any build cycles
3. The same widget instance is reused, preventing re-attachment

### Lifecycle Safety

- The `late final` modifier ensures the widget is initialized before use
- The widget is created in `initState()`, which runs exactly once
- No disposal logic is needed for the GameWidget itself (Flame handles this internally)

## Testing Strategy

### Unit Tests

1. **Test GameWidget Creation Count**
   - Verify that `initState()` creates exactly one GameWidget
   - Verify that multiple `build()` calls don't create new GameWidgets

2. **Test Widget Reference Stability**
   - Call `build()` multiple times
   - Verify the returned GameWidget reference is identical each time

3. **Test Game Instance Stability**
   - Verify game instance is created once in `initState()`
   - Verify game instance reference doesn't change across rebuilds

### Integration Tests

1. **Test Full Widget Lifecycle**
   - Create ArcGameScreen
   - Trigger multiple rebuilds (via setState)
   - Verify no attachment errors occur
   - Verify game state is preserved

2. **Test with Real Game Instances**
   - Test with GluttonyArcGame
   - Test with GreedArcGame
   - Test with other arc game types
   - Verify all work without attachment errors

### Manual Testing

1. Run the game and navigate to an arc
2. Trigger UI updates (collect evidence, use items, etc.)
3. Verify no "Game attachment error" appears in logs
4. Verify game continues to function correctly

### Property-Based Testing

We will use the `test` package (Dart's built-in testing framework) for property-based testing. While Dart doesn't have a dedicated PBT library like QuickCheck, we can simulate property testing by running tests with multiple iterations and varied inputs.

Each property-based test will:
- Run a minimum of 100 iterations
- Use varied game types and widget states
- Verify the correctness properties hold across all iterations
- Be tagged with comments linking to design properties
