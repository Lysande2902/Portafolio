# Implementation Plan

- [x] 1. Create GameStateNotifier class


  - Create new file `lib/game/core/state/game_state_notifier.dart`
  - Implement ChangeNotifier with game state properties
  - Add methods to update state with change detection
  - _Requirements: 4.2_




- [ ] 2. Integrate GameStateNotifier into BaseArcGame
  - [x] 2.1 Add stateNotifier field to BaseArcGame


    - Add `final GameStateNotifier stateNotifier = GameStateNotifier()` to BaseArcGame
    - _Requirements: 4.1, 4.2_
  
  - [ ] 2.2 Update game state in update() method
    - Call stateNotifier.updateEvidence() when evidence changes
    - Call stateNotifier.updateSanity() when sanity changes
    - Call stateNotifier.updateGameOver() when game over state changes
    - Call stateNotifier.updateVictory() when victory state changes

    - _Requirements: 4.2_
  


  - [ ]* 2.3 Write property test for state notification
    - **Property 8: Minimal rebuild frequency**
    - **Validates: Requirements 4.2**


- [ ] 3. Refactor ArcGameScreen to use reactive pattern
  - [ ] 3.1 Remove Future.doWhile polling loop
    - Delete the Future.doWhile loop in initState()
    - This is the main cause of the freeze bug
    - _Requirements: 1.1, 4.1_
  

  - [ ] 3.2 Add listener to GameStateNotifier
    - Add game.stateNotifier.addListener(_onGameStateChanged) in initState()
    - Implement _onGameStateChanged() method that calls setState()


    - Remove listener in dispose()
    - _Requirements: 4.2_
  


  - [ ]* 3.3 Write property test for Flutter-Flame separation
    - **Property 7: Flutter-Flame separation**
    - **Validates: Requirements 4.1**

- [ ] 4. Add error handling to game loop
  - [ ] 4.1 Wrap update() in try-catch
    - Add try-catch block in BaseArcGame.update()
    - Call ErrorHandler.handleGameError() on exceptions
    - _Requirements: 1.4, 3.1_

  
  - [ ] 4.2 Implement component failure detection
    - Add _removeFailedComponents() method
    - Test each component's validity in update loop


    - Remove components that throw exceptions
    - _Requirements: 3.2_
  

  - [ ]* 4.3 Write property test for error recovery
    - **Property 3: Error recovery**
    - **Validates: Requirements 1.4, 3.1**
  

  - [ ]* 4.4 Write property test for component failure isolation
    - **Property 4: Component failure isolation**
    - **Validates: Requirements 3.2**

- [x] 5. Implement frame time monitoring


  - [ ] 5.1 Add frame time tracking to BaseArcGame
    - Add _lastFrameTime and _frameTimeHistory fields
    - Track frame times in update() method


    - _Requirements: 1.1, 1.3_
  

  - [ ] 5.2 Add freeze detection
    - Detect when frame time exceeds 100ms
    - Log warning with game state information
    - _Requirements: 2.1, 3.5_
  
  - [x]* 5.3 Write property test for game loop continuity


    - **Property 1: Game loop continuity**

    - **Validates: Requirements 1.1**


- [x] 6. Implement adaptive performance system

  - [ ] 6.1 Add performance monitor
    - Create PerformanceMonitor class
    - Track average frame time over last 60 frames

    - _Requirements: 3.3_

  
  - [ ] 6.2 Add dynamic update frequency adjustment
    - Reduce update frequency when frame time is high
    - Restore normal frequency when performance improves
    - _Requirements: 3.3_

  
  - [ ]* 6.3 Write property test for adaptive performance
    - **Property 5: Adaptive performance**
    - **Validates: Requirements 3.3**


- [ ] 7. Add input responsiveness monitoring
  - [ ] 7.1 Track input-to-response time
    - Add timestamp to input events


    - Measure time until game state changes
    - _Requirements: 1.2, 1.5_
  
  - [ ]* 7.2 Write property test for input responsiveness
    - **Property 2: Input responsiveness**
    - **Validates: Requirements 1.2, 1.5**

- [ ] 8. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 9. Test freeze fix on all arcs
  - [ ] 9.1 Test Gluttony arc (arc_1_gula)
    - Launch arc and play for 2 minutes
    - Verify no freezing occurs
    - Verify smooth gameplay
    - _Requirements: 1.1_
  
  - [ ] 9.2 Test Greed arc (arc_2_greed)
    - Launch arc and play for 2 minutes
    - Verify no freezing occurs
    - Verify smooth gameplay
    - _Requirements: 1.1_
  
  - [ ] 9.3 Test Envy arc (arc_3_envy)
    - Launch arc and play for 2 minutes
    - Verify no freezing occurs
    - Verify smooth gameplay
    - _Requirements: 1.1_
  
  - [ ] 9.4 Test remaining arcs
    - Test Lust, Pride, Sloth, and Wrath arcs
    - Verify no freezing in any arc
    - _Requirements: 1.1_

- [ ] 10. Final checkpoint - Verify all arcs work correctly
  - Ensure all tests pass, ask the user if questions arise.
