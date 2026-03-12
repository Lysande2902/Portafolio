# Implementation Plan - Sistema de Arcos/Episodios

- [x] 1. Create data models and providers



  - Create Arc model class with all properties (id, number, title, subtitle, description, thumbnailPath, isUnlockedByDefault, unlockRequirements)
  - Create ArcProgress model class with status enum and progress tracking
  - Create ArcDataProvider with static list of 7 arcs matching the game design document




  - _Requirements: 1.1, 1.2, 1.3_

- [ ] 2. Implement state management with Firebase integration
- [ ] 2.1 Create ArcProgressProvider with ChangeNotifier
  - Implement loadProgress method to fetch from Firestore
  - Implement updateProgress method to save to Firestore

  - Implement getProgress method to retrieve arc progress
  - Implement isArcUnlocked method to check unlock requirements
  - Add local caching with SharedPreferences for offline support
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_





- [ ] 2.2 Setup Firestore structure for arc progress
  - Create Firestore collection structure: users/{userId}/arcProgress/{arcId}
  - Implement data serialization/deserialization methods
  - Add error handling for network failures
  - _Requirements: 3.5_


- [ ] 3. Build ArcCard widget
- [ ] 3.1 Create ArcCard stateless widget
  - Design card layout with thumbnail, title, subtitle, and progress indicator
  - Implement locked state visual (lock icon, desaturated colors)
  - Implement in-progress state visual (progress bar with percentage)
  - Implement completed state visual (checkmark indicator)
  - Add tap gesture handling with selection feedback
  - _Requirements: 1.2, 1.3, 1.4, 2.2_

- [ ] 3.2 Style ArcCard with game aesthetic
  - Apply Courier Prime font with appropriate sizes and letter spacing





  - Use black background with opacity and red accent colors
  - Add border styling for selected/unselected states
  - Implement hover effects for better UX
  - _Requirements: 4.1, 4.3_

- [x]* 3.3 Add animations to ArcCard

  - Implement entrance animation (fade in + slide from bottom)
  - Add selection animation (scale up on tap)
  - Add lock shake animation when tapping locked arc
  - Stagger card entrance animations for visual appeal
  - _Requirements: 4.1_


- [ ] 4. Create ArcSelectionScreen
- [ ] 4.1 Build screen structure and layout
  - Create StatefulWidget for ArcSelectionScreen
  - Setup video background layer with lobby video
  - Add dark overlay (0.3 opacity) over video

  - Implement SafeArea with LayoutBuilder for responsive design

  - Create scrollable list of ArcCards using ListView.builder
  - _Requirements: 1.1, 4.2_

- [ ] 4.2 Add VHS effects and atmospheric elements
  - Integrate VHSEffectPainter for glitch effects
  - Add REC indicator in bottom-right corner with pulsing animation

  - Implement back button in top-left corner
  - Add ambient audio playback on screen load
  - _Requirements: 4.1, 4.2, 4.4, 4.5_

- [ ] 4.3 Implement navigation logic
  - Connect back button to navigate to MenuScreen
  - Implement arc selection tap handler
  - Add locked arc dialog showing unlock requirements




  - Create navigation to ArcGameplayScreen placeholder
  - Handle navigation errors with try-catch
  - _Requirements: 2.1, 2.2, 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 5. Integrate with Firebase and handle data loading

- [x] 5.1 Connect ArcProgressProvider to screen



  - Use Provider.of or Consumer to access ArcProgressProvider
  - Load user progress on screen initialization
  - Display loading indicator while fetching data
  - Handle loading errors with retry mechanism
  - _Requirements: 2.3, 2.4, 3.5_





- [ ] 5.2 Implement offline mode support
  - Check network connectivity on load
  - Display cached data when offline
  - Show offline indicator in UI
  - Sync data when connection is restored
  - _Requirements: 3.5_

- [ ] 6. Add assets and prepare arc data
- [ ] 6.1 Create placeholder thumbnails for arcs
  - Create or source thumbnail images for all 7 arcs
  - Add images to assets/images/arcs/ folder
  - Update pubspec.yaml to include arc images
  - Verify images load correctly in ArcCards
  - _Requirements: 1.2, 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ] 6.2 Populate ArcDataProvider with complete arc information
  - Add all 7 arcs with correct titles, subtitles, and descriptions from GDD
  - Set unlock requirements (Arco 1 unlocked by default, others require previous)
  - Verify arc data matches game design document





  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ] 7. Connect to MenuScreen
- [ ] 7.1 Update MenuScreen PLAY button handler
  - Modify _handleMenuSelection to navigate to ArcSelectionScreen
  - Add page transition animation

  - Ensure proper disposal of MenuScreen resources
  - Test navigation flow from menu to arc selection and back
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 8. Create placeholder ArcGameplayScreen
- [ ] 8.1 Build minimal gameplay screen for testing
  - Create simple StatefulWidget with black background
  - Display arc title and "Gameplay Coming Soon" message
  - Add back button to return to ArcSelectionScreen
  - Test navigation from arc selection to gameplay
  - _Requirements: 2.1, 2.3, 2.4_

- [ ]* 9. Add error handling and edge cases
  - Implement error dialogs for network failures
  - Add retry logic for failed Firestore operations
  - Handle missing arc data gracefully
  - Test with airplane mode enabled
  - Verify behavior when Firebase is unreachable
  - _Requirements: 2.4, 5.4_

- [ ]* 10. Performance optimization
  - Implement lazy loading for arc thumbnails
  - Optimize video background loading
  - Add image caching with CachedNetworkImage
  - Profile widget rebuilds and optimize with Consumer
  - Test on lower-end devices
  - _Requirements: 1.1, 2.3_

- [ ] 11. Final integration testing
- [ ] 11.1 Test complete user flow
  - Test navigation: Menu → Arc Selection → Gameplay → Back
  - Verify progress saves correctly to Firebase
  - Test locked arc behavior and unlock requirements
  - Verify UI updates when progress changes
  - Test with multiple user accounts
  - _Requirements: All requirements_

- [ ] 11.2 Verify visual consistency
  - Check that aesthetic matches other screens (intro, menu)
  - Verify fonts, colors, and spacing are consistent
  - Test on different screen sizes
  - Ensure animations are smooth
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_
