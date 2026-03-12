# Implementation Plan

- [x] 1. Adjust Envy Arc enemy balance


  - Modify `lib/game/arcs/envy/components/chameleon_enemy.dart`
  - Change `increasePhase()` to increment speed by 10 instead of 20
  - Add grace period timer (1 second after unhiding)
  - Update chase detection logic to respect grace period
  - Test that speeds progress as: 80/110 → 90/120 → 100/130
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.3_

- [x] 2. Create DisclaimerPreferenceManager


  - Create `lib/core/preferences/disclaimer_preference_manager.dart`
  - Implement SharedPreferences integration
  - Add methods: `hasSkippedDemoEnding()`, `setDemoEndingSkipped()`, `resetPreference()`
  - Add error handling with safe fallbacks
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [x] 3. Create improved disclaimer screen


  - Create `lib/screens/improved_demo_ending_disclaimer_screen.dart`
  - Implement calm, neutral design with proper spacing
  - Add warning icon and clear title
  - List specific content warnings (self-harm, mental health, disturbing content)
  - Add context about demo vs full game
  - Include supportive message and resources
  - Use font size 18px+ for readability
  - _Requirements: 4.1, 4.2, 4.3, 5.1, 5.2, 5.3, 5.4, 5.5, 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 4. Add disclaimer buttons and navigation

  - Add "Continuar" button that proceeds to demo ending
  - Add "Saltar" button that navigates to archive
  - Implement smooth fade in/out animations (300ms)
  - Wire up DisclaimerPreferenceManager to save choices
  - Ensure progress is saved regardless of choice
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 5. Integrate disclaimer into game flow

  - Update `lib/screens/arc_game_screen.dart` victory flow
  - Check disclaimer preference before showing ending
  - Navigate to improved disclaimer screen after Envy arc
  - Handle both "continue" and "skip" flows
  - _Requirements: 4.1, 4.4, 4.5_

- [x] 6. Test balance changes

  - Play through Envy arc multiple times
  - Verify enemy speeds at each phase
  - Confirm grace period works after unhiding
  - Validate game is winnable with reasonable skill
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.3_

- [x] 7. Test disclaimer functionality

  - Verify disclaimer shows before demo ending
  - Test "Continuar" navigation flow
  - Test "Saltar" navigation flow
  - Verify preference persistence across sessions
  - Test preference reset functionality
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 6.1, 6.2, 6.3, 8.1, 8.2_

- [x] 8. Final polish and validation


  - Verify all text is readable and clear
  - Check animations are smooth
  - Ensure emotional tone is appropriate
  - Validate accessibility standards
  - Get user feedback on both changes
  - _Requirements: All_
