# Implementation Plan

- [x] 1. Add StateUpdateQueue to BaseArcGame


  - Create StateUpdateQueue class in base_arc_game.dart
  - Add queue instance to BaseArcGame
  - Add methods to enqueue and flush updates
  - _Requirements: 1.2, 2.1_



- [ ] 2. Enhance GameStateNotifier with deferred updates
  - Add deferUpdates flag to GameStateNotifier
  - Add batchUpdate() method for multiple updates
  - Add flushDeferredUpdates() method


  - Modify all update methods to respect deferUpdates flag
  - _Requirements: 1.2, 2.2_

- [ ] 3. Modify BaseArcGame initialization flow
  - Add _initialBuildComplete flag to BaseArcGame


  - Queue state updates during initialization
  - Add schedulePostFrameUpdate() method
  - Flush queued updates after first frame
  - _Requirements: 1.1, 1.2, 2.1_



- [ ] 4. Update ArcGameScreen to use post-frame callbacks
  - Remove setState() calls from didChangeDependencies()
  - Wrap any initialization-triggered updates in post-frame callbacks
  - Add _buildComplete flag to track build state
  - Schedule deferred updates using WidgetsBinding


  - _Requirements: 1.1, 1.3, 2.1_

- [ ] 5. Add debug logging for lifecycle events
  - Log when build phase starts and ends
  - Log when post-frame callbacks execute
  - Log when state updates are queued vs applied
  - Add timestamps to track timing
  - _Requirements: 2.4_

- [ ] 6. Test game initialization without errors
  - Load each arc (Gluttony, Greed, Envy, Sloth)
  - Verify no "setState during build" errors in console
  - Verify no "Game attachment error" messages
  - Verify game loads and is playable
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [ ] 7. Test game reset flow
  - Trigger game over in an arc
  - Click retry button
  - Verify clean reset without errors
  - Verify game is playable after reset
  - _Requirements: 3.5_

- [ ] 8. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
