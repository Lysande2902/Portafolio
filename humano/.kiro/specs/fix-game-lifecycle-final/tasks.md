# Implementation Plan

- [ ] 1. Create GameLifecycleManager class
  - Create new file `lib/game/core/lifecycle/game_lifecycle_manager.dart`
  - Implement state tracking (attached, mounted, initialized)
  - Implement deferred action queue
  - Implement flush mechanism
  - Add reset functionality
  - _Requirements: 1.1, 1.2, 1.3, 2.1_

- [ ] 2. Integrate GameLifecycleManager into BaseArcGame
  - Add GameLifecycleManager instance to BaseArcGame
  - Override onAttach() to call markAttached()
  - Override onMount() to call markMounted()
  - Modify setupScene() to use deferAction()
  - Modify setupPlayer() to use deferAction()
  - Modify setupEnemy() to use deferAction()
  - Modify setupCollectibles() to use deferAction()
  - Update resetGame() to reset lifecycle manager
  - Add lifecycle logging for debugging
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.4_

- [ ] 3. Update GluttonyArcGame to use lifecycle manager
  - Ensure all component additions use safeAdd() or deferAction()
  - Verify setupScene() defers component additions
  - Verify setupPlayer() defers component additions
  - Verify setupEnemy() defers component additions
  - Verify setupCollectibles() defers component additions
  - Test reset functionality
  - _Requirements: 1.2, 1.3, 1.4, 3.1_

- [ ] 4. Update GreedArcGame to use lifecycle manager
  - Apply same changes as GluttonyArcGame
  - Ensure consistency with other arcs
  - Test reset functionality
  - _Requirements: 1.2, 1.3, 1.4, 3.1_

- [ ] 5. Update EnvyArcGame to use lifecycle manager
  - Apply same changes as GluttonyArcGame
  - Ensure consistency with other arcs
  - Test reset functionality
  - _Requirements: 1.2, 1.3, 1.4, 3.1_

- [ ] 6. Verify ArcGameScreen initialization
  - Confirm game instance created in initState()
  - Confirm GameWidget cached properly
  - Confirm no setState() during build
  - Add post-frame callback to verify initialization
  - Add lifecycle state logging
  - _Requirements: 1.1, 1.5, 2.2_

- [ ] 7. Test complete lifecycle for all arcs
  - Test Gula arc: load → play → collect evidence → reset
  - Test Avaricia arc: load → play → collect evidence → reset
  - Test Envidia arc: load → play → collect evidence → reset
  - Verify no "Game attachment error" in logs
  - Verify lifecycle events occur in correct order
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 3.1, 3.2, 3.3_

- [ ] 8. Test edge cases
  - Rapid arc switching (open → close → open quickly)
  - Multiple resets in succession
  - Victory → retry → victory again
  - Game over → retry → game over again
  - Verify no memory leaks or dangling references
  - _Requirements: 1.4, 2.4, 3.3, 3.5_

- [ ] 9. Final verification
  - Run all three arcs from start to finish
  - Collect all evidence in each arc
  - Verify victory screens work
  - Verify progress saves correctly
  - Verify no console errors throughout
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_
