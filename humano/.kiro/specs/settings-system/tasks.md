# Implementation Plan - Sistema de Configuración

- [x] 1. Create settings data models


  - Create GameSettings model class with audio and visual properties
  - Create UserStats model class for profile information
  - Add serialization/deserialization methods (toJson/fromJson)
  - Add default values factory method
  - _Requirements: 1.4, 2.4, 6.5_





- [ ] 2. Implement SettingsProvider with persistence
- [ ] 2.1 Create SettingsProvider with ChangeNotifier
  - Implement loadSettings method to fetch from SharedPreferences
  - Implement saveSettings method with debouncing (500ms)
  - Implement volume setter methods (music, sfx, ambient)

  - Implement visual effect toggle methods
  - Implement resetToDefaults method
  - _Requirements: 1.2, 1.4, 2.2, 2.4, 6.3, 6.4, 6.5_





- [ ] 2.2 Add audio preview functionality
  - Create method to play preview sound when volume changes
  - Implement debouncing for preview (max once per 200ms)
  - Dispose audio players properly
  - _Requirements: 1.3_



- [ ] 3. Build custom setting widgets
- [ ] 3.1 Create VolumeSlider widget
  - Design slider with value display (percentage)
  - Add drag interaction with smooth animation


  - Display current volume value
  - Apply game aesthetic (Courier Prime font, red accent)
  - _Requirements: 1.1, 1.2_

- [x] 3.2 Create ToggleSwitch widget



  - Design custom switch with VHS aesthetic
  - Add flip animation (200ms duration)
  - Show ON/OFF state clearly
  - Apply game styling
  - _Requirements: 2.1, 2.2_

- [ ] 3.3 Create ProfileInfoCard widget
  - Display user email/username

  - Display total play time
  - Display arcs completed count
  - Add logout button
  - Style with game aesthetic
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_


- [ ] 4. Create SettingsScreen
- [ ] 4.1 Build screen structure and layout
  - Create StatefulWidget for SettingsScreen
  - Setup video background layer with lobby video
  - Add dark overlay (0.3 opacity) over video
  - Implement SafeArea with ScrollView for content

  - Add back button in top-left corner
  - Add REC indicator in bottom-right corner
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 5.1_

- [ ] 4.2 Implement Profile section
  - Add section header "PERFIL"

  - Integrate ProfileInfoCard widget
  - Connect to AuthProvider for user data
  - Implement logout functionality with confirmation
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_


- [x] 4.3 Implement Audio section

  - Add section header "AUDIO"
  - Add three VolumeSlider widgets (music, sfx, ambient)
  - Connect sliders to SettingsProvider
  - Implement audio preview on slider change

  - _Requirements: 1.1, 1.2, 1.3_

- [ ] 4.4 Implement Visual section
  - Add section header "VISUAL"
  - Add three ToggleSwitch widgets (VHS, glitch, screen shake)

  - Connect toggles to SettingsProvider
  - Apply visual changes immediately
  - _Requirements: 2.1, 2.2, 2.3_

- [ ] 4.5 Implement Reset section
  - Add "RESTABLECER VALORES POR DEFECTO" button at bottom
  - Implement confirmation dialog

  - Connect to resetToDefaults method

  - Show success message after reset
  - _Requirements: 2.5, 6.1, 6.2, 6.3, 6.4_

- [ ] 5. Integrate with existing systems
- [ ] 5.1 Register SettingsProvider in main.dart
  - Add SettingsProvider to MultiProvider
  - Initialize settings on app start
  - _Requirements: 1.5_

- [ ] 5.2 Connect audio players to settings
  - Update MenuScreen to use settings volumes
  - Update IntroScreen to use settings volumes
  - Update ArcSelectionScreen to use settings volumes
  - _Requirements: 1.2, 1.5_

- [x] 5.3 Connect visual effects to settings


  - Update VHS effects based on settings

  - Update glitch effects based on settings
  - Make effects conditional on settings
  - _Requirements: 2.2, 2.3_

- [ ] 6. Connect to MenuScreen
- [ ] 6.1 Update MenuScreen SETTINGS button handler
  - Modify _handleMenuSelection to navigate to SettingsScreen

  - Add page transition animation
  - Ensure proper disposal of resources
  - Test navigation flow from menu to settings and back
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x]* 7. Add user statistics tracking

  - Create method to track play time
  - Create method to update arcs completed
  - Save stats to Firestore
  - Load stats on settings screen
  - _Requirements: 3.2, 3.3, 3.4_

- [ ]* 8. Add advanced features
  - Implement haptic feedback on slider drag
  - Add sound effect on toggle switch
  - Add confirmation sound on save
  - Implement smooth scroll to section
  - _Requirements: 1.3, 2.2_

- [ ] 9. Final integration testing
- [ ] 9.1 Test complete settings flow
  - Test navigation: Menu → Settings → Back
  - Verify volume changes persist after app restart
  - Test visual effect toggles work correctly
  - Verify logout functionality
  - Test reset to defaults
  - _Requirements: All requirements_

- [ ] 9.2 Test audio integration
  - Verify music volume affects all music players
  - Verify SFX volume affects sound effects
  - Verify ambient volume affects ambient sounds
  - Test audio preview functionality
  - _Requirements: 1.1, 1.2, 1.3, 1.5_

- [ ] 9.3 Verify visual consistency
  - Check that aesthetic matches other screens
  - Verify fonts, colors, and spacing are consistent
  - Test on different screen sizes
  - Ensure animations are smooth
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_
