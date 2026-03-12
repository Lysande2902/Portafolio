# Implementation Plan

- [x] 1. Add ObjectKey field to ArcGameScreen


  - Add `late final Key _gameWidgetKey;` field to `_ArcGameScreenState`
  - Initialize the key in `initState()` using `ObjectKey(game)`
  - Ensure key is created after game instance is created
  - _Requirements: 2.1, 2.4_



- [ ] 2. Apply key to GameWidget
  - Pass `_gameWidgetKey` to the `GameWidget` constructor

  - Verify key is applied in the correct location in the widget tree
  - _Requirements: 1.2, 1.3, 2.2_

- [x] 3. Add debug logging for key creation


  - Log when the key is created with game hashCode
  - Log the key's hashCode for verification
  - _Requirements: 3.4_

- [x] 4. Test the fix



  - Run the app and enter an arc
  - Verify no attachment errors occur
  - Trigger UI rebuilds (pause, use items) and verify stability
  - Test all 7 arcs to ensure consistency
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 5. Verify disposal behavior
  - Ensure game disposal still works correctly
  - Verify no memory leaks or hanging references
  - Check that key doesn't interfere with cleanup
  - _Requirements: 1.5_
