# Implementation Plan

- [x] 1. Add stable GameWidget field to ArcGameScreen state


  - Add `late final Widget _stableGameWidget` field to `_ArcGameScreenState` class
  - This field will store the GameWidget instance created once in initState
  - _Requirements: 1.1, 1.2_



- [ ] 2. Create GameWidget in initState
  - Modify `initState()` method to create the GameWidget instance
  - Store the created GameWidget in `_stableGameWidget` field


  - Ensure this happens after the game instance is created
  - _Requirements: 1.1, 2.1_




- [ ] 3. Update build method to use stable widget
  - Replace `GameWidget(game: game)` with `_stableGameWidget` in the build method
  - Ensure the same widget instance is returned on every build cycle
  - _Requirements: 1.2, 1.3, 1.4_

- [ ] 4. Verify the fix works
  - Run the application and navigate to a game arc
  - Trigger multiple UI updates (collect evidence, use items, pause/resume)
  - Check logs to confirm no "Game attachment error" appears
  - Verify game functionality remains intact
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4_
