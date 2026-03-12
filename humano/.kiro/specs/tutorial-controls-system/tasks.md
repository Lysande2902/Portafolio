# Implementation Plan

- [x] 1. Create TutorialStateManager for persistence


  - Create `lib/game/core/tutorial/tutorial_state_manager.dart`
  - Implement SharedPreferences integration for tutorial completion tracking
  - Add methods: `hasCompletedFirstTimeTutorial()`, `completeFirstTimeTutorial()`, `hasCompletedArcTutorial()`, `completeArcTutorial()`
  - Add error handling for storage failures with fallback to showing tutorials
  - Add timestamp recording for completion events
  - _Requirements: 1.3, 3.3, 3.4, 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 1.1 Write property test for tutorial persistence


  - **Property 3: Tutorial completion persists across sessions**
  - **Validates: Requirements 1.3, 3.4**


- [ ] 1.2 Write property test for skip persistence
  - **Property 4: Skip has same effect as completion**
  - **Validates: Requirements 1.4, 3.3**


- [ ] 1.3 Write property test for arc-specific persistence
  - **Property 7: Arc tutorial completion persists per arc**

  - **Validates: Requirements 2.5**

- [x] 1.4 Write property test for saved state structure

  - **Property 16: Saved state has correct structure**
  - **Validates: Requirements 5.2**


- [ ] 1.5 Write property test for state loading
  - **Property 17: Persisted state loads correctly**
  - **Validates: Requirements 5.3**

- [ ] 1.6 Write unit tests for storage error handling
  - Test storage read failures default to showing tutorials
  - Test storage write failures don't crash
  - _Requirements: 5.4, 5.5_

- [x] 2. Enhance FirstTimeTutorialOverlay



  - Update `lib/game/ui/first_time_tutorial_overlay.dart`
  - Integrate with TutorialStateManager for persistence
  - Add fade in/out animations (300ms duration)
  - Ensure all 5 steps are present with correct content
  - Add proper game pause integration
  - Improve accessibility (larger touch targets, better contrast)
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 4.1, 4.2, 4.3, 4.5, 6.4, 6.5_

- [x] 2.1 Write property test for tutorial structure


  - **Property 2: Tutorial structure is always complete**
  - **Validates: Requirements 1.2**


- [ ] 2.2 Write property test for tap advancement
  - **Property 5: Tap advances tutorial steps**

  - **Validates: Requirements 1.5**

- [x] 2.3 Write property test for skip button presence

  - **Property 8: All tutorials have skip button**
  - **Validates: Requirements 3.1**


- [ ] 2.4 Write property test for skip functionality
  - **Property 9: Skip immediately closes tutorial**
  - **Validates: Requirements 3.2**


- [ ] 2.5 Write property test for overlay opacity
  - **Property 10: Tutorial overlay has correct opacity**

  - **Validates: Requirements 4.1**

- [x] 2.6 Write property test for text accessibility

  - **Property 11: Tutorial text meets accessibility standards**
  - **Validates: Requirements 4.2**

- [ ] 2.7 Write property test for progress indicator
  - **Property 12: Progress indicator is accurate**
  - **Validates: Requirements 4.3**

- [ ] 2.8 Write property test for animation durations
  - **Property 14: Animation durations are within bounds**
  - **Validates: Requirements 4.5, 6.4, 6.5**

- [x] 3. Create ArcSpecificTutorialOverlay


  - Create `lib/game/ui/arc_specific_tutorial_overlay.dart` (or enhance existing `tutorial_overlay.dart`)
  - Integrate with TutorialStateManager
  - Add confirmation dialog ("¿Ver Tutorial?")
  - Implement arc-specific content for all three arcs (Gluttony, Greed, Envy)
  - Add manual trigger mode (doesn't affect completion state)
  - Add fade in/out animations
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 7.1, 7.2, 7.3, 7.4, 7.5, 8.2, 8.3, 8.5_

- [x] 3.1 Write property test for arc tutorial display


  - **Property 6: Arc tutorials display on first arc entry**
  - **Validates: Requirements 2.1**

- [x] 3.2 Write property test for arc objectives

  - **Property 23: Arc tutorials display correct objectives**
  - **Validates: Requirements 7.4**

- [x] 3.3 Write property test for terminology consistency

  - **Property 24: Tutorial terminology matches UI**
  - **Validates: Requirements 7.5**

- [x] 3.4 Write property test for manual tutorial content

  - **Property 25: Manual tutorial shows correct arc content**
  - **Validates: Requirements 8.2**

- [x] 3.5 Write property test for manual tutorial state

  - **Property 26: Manual tutorial doesn't affect completion state**
  - **Validates: Requirements 8.3, 8.5**

- [x] 3.6 Write unit tests for arc-specific content

  - Test Gluttony arc content includes hiding and devourer mechanic
  - Test Greed arc content includes sanity theft and cash registers
  - Test Envy arc content explicitly states NO hiding
  - _Requirements: 2.2, 2.3, 2.4, 7.1, 7.2, 7.3_

- [x] 4. Integrate tutorials into ArcGameScreen


  - Update `lib/screens/arc_game_screen.dart`
  - Add tutorial state management (_showFirstTimeTutorial, _showArcTutorial, _tutorialCheckComplete)
  - Implement _checkTutorials() to check both first-time and arc-specific tutorials
  - Implement _completeFirstTimeTutorial() and _completeArcTutorial()
  - Add tutorial overlays to widget tree with proper z-index
  - Ensure game pauses when tutorials are shown
  - Ensure game resumes smoothly after tutorials
  - _Requirements: 1.1, 2.1, 6.1, 6.2, 6.3_

- [x] 4.1 Write property test for first-time tutorial display

  - **Property 1: First-time tutorial displays on fresh install**
  - **Validates: Requirements 1.1**

- [x] 4.2 Write property test for game pause during tutorial

  - **Property 20: Active tutorial pauses game logic**
  - **Validates: Requirements 6.1**

- [x] 4.3 Write property test for game resume after tutorial

  - **Property 21: Tutorial completion resumes game smoothly**
  - **Validates: Requirements 6.2**

- [x] 4.4 Write property test for input blocking

  - **Property 22: Tutorial blocks game input**
  - **Validates: Requirements 6.3**

- [x] 4.5 Write integration test for full tutorial flow

  - Test complete flow from fresh install through first-time tutorial to arc tutorial
  - Verify game state transitions correctly
  - _Requirements: 1.1, 2.1, 6.1, 6.2, 6.3_

- [x] 5. Add tutorial option to PauseMenu


  - Update `lib/game/ui/pause_menu.dart`
  - Add "Ver Tutorial" button
  - Add onShowTutorial callback parameter
  - Wire up callback to show arc-specific tutorial
  - _Requirements: 3.5, 8.1, 8.2, 8.4_

- [x] 5.1 Write property test for manual tutorial return

  - **Property 27: Manual tutorial returns to pause menu**
  - **Validates: Requirements 8.4**

- [x] 5.2 Write unit test for pause menu tutorial option

  - Test "Ver Tutorial" button is present
  - Test button triggers tutorial correctly
  - _Requirements: 3.5, 8.1_

- [x] 6. Checkpoint - Ensure all tests pass


  - Ensure all tests pass, ask the user if questions arise.

- [x] 7. Add tutorial content positioning logic

  - Create `lib/game/core/tutorial/tutorial_layout_helper.dart`
  - Implement logic to position tutorial content to avoid covering highlighted UI elements
  - Add alignment calculations based on screen size and highlighted element position
  - _Requirements: 4.4_

- [x] 7.1 Write property test for content positioning

  - **Property 13: Tutorial content doesn't overlap highlighted elements**
  - **Validates: Requirements 4.4**

- [x] 8. Implement tutorial completion timing

  - Add immediate save functionality to TutorialStateManager
  - Ensure completion saves within 100ms
  - Add performance logging for save operations
  - _Requirements: 5.1_

- [x] 8.1 Write property test for save timing

  - **Property 15: Tutorial completion saves immediately**
  - **Validates: Requirements 5.1**

- [x] 9. Add error handling and logging

  - Add comprehensive error handling for all storage operations
  - Add debug logging for tutorial state changes
  - Add warning logs for storage failures
  - Implement graceful fallbacks for all error scenarios
  - _Requirements: 5.4, 5.5_

- [x] 9.1 Write property test for storage failure handling

  - **Property 18: Storage failure defaults to showing tutorials**
  - **Validates: Requirements 5.4**

- [x] 9.2 Write property test for write failure handling

  - **Property 19: Write failures don't crash the game**
  - **Validates: Requirements 5.5**

- [x] 10. Final Checkpoint - Ensure all tests pass

  - Ensure all tests pass, ask the user if questions arise.

- [x] 11. Manual testing and polish


  - Test on different screen sizes
  - Test on different device orientations
  - Verify animations are smooth
  - Verify text is readable
  - Test all three arcs
  - Test skip functionality
  - Test manual tutorial trigger
  - Verify persistence across app restarts
  - _Requirements: All_
