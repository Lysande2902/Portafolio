# Implementation Plan

- [x] 1. Implement static GlobalKey management


  - Create GameWidgetKeyManager class with static map
  - Add getKeyForArc() method to retrieve or create keys
  - Add removeKeyForArc() method for cleanup
  - Add clearAll() method for testing
  - _Requirements: 3.1, 3.2, 3.5_



- [ ] 2. Update ArcGameScreen to use static GlobalKey
  - Replace instance GlobalKey with call to GameWidgetKeyManager
  - Store the key in _gameWidgetKey variable
  - Remove key from manager in dispose()


  - Add debug logging for key operations
  - _Requirements: 3.1, 3.2, 3.3, 3.4_

- [ ] 3. Implement deferred initialization pattern
  - Add _initializationStarted flag to track if initialization has begun
  - Add _initializationComplete flag to track completion

  - Move game initialization out of didChangeDependencies
  - Schedule post-frame callback in build() (only once)
  - Implement _initializeGameDeferred() method
  - _Requirements: 1.1, 2.3, 2.4_

- [ ] 4. Implement quiet provider setup
  - Create _setupProvidersQuietly() method

  - Get all providers with listen: false
  - Set providers on game without triggering callbacks
  - Remove any setState() calls from provider setup
  - Add debug logging for provider setup
  - _Requirements: 1.3, 2.2, 2.5_

- [ ] 5. Integrate deferred updates into initialization
  - Call stateNotifier.enableDeferredUpdates() at start of initialization


  - Load inventory and configure game
  - Wait for a frame to ensure stability
  - Call stateNotifier.flushDeferredUpdates() at end
  - Mark initialization as complete


  - Add comprehensive debug logging
  - _Requirements: 4.1, 4.2, 4.3_

- [ ] 6. Update _loadInventory to not trigger updates
  - Remove any setState() calls from _loadInventory

  - Ensure all game state changes go through stateNotifier
  - Verify no widget rebuilds occur during inventory load
  - _Requirements: 1.3, 4.4_

- [ ] 7. Verify GameStateNotifier deferred updates implementation
  - Confirm enableDeferredUpdates() sets flag correctly
  - Confirm all update methods check deferred flag


  - Confirm flushDeferredUpdates() applies all queued updates
  - Add error handling for failed updates during flush
  - _Requirements: 4.1, 4.2, 4.3_

- [ ] 8. Add comprehensive initialization logging
  - Log each phase of initialization with timestamps

  - Log GlobalKey operations (get, reuse, remove)
  - Log deferred updates (queue, flush)
  - Log provider setup operations
  - Log game attachment/detachment events
  - _Requirements: 1.5_


- [ ] 9. Test initialization sequence
  - Run game and verify build completes before initialization
  - Verify no "Game attachment error" in logs
  - Verify GlobalKey is reused across rebuilds
  - Verify deferred updates are flushed correctly
  - Test with all 7 arcs


  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 10. Test GlobalKey stability
  - Trigger multiple rebuilds (pause/resume, item usage)
  - Verify GlobalKey identity remains constant
  - Verify GameWidget is not recreated
  - Test with multiple screens open simultaneously
  - _Requirements: 3.2, 3.3, 3.5_

- [ ] 11. Test deferred updates mechanism
  - Trigger state changes during initialization
  - Verify updates are queued, not applied immediately
  - Verify all updates are applied after flush
  - Test error handling during flush
  - _Requirements: 4.1, 4.2, 4.3_

- [ ] 12. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

