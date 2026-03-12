# Implementation Plan - Galería de Evidencias

- [x] 1. Create evidence data models


  - Create Evidence model class with all properties (id, arcId, type, title, description, contentPath, unlockHint)
  - Create EvidenceType enum (screenshot, message, video, audio, document)
  - Add serialization/deserialization methods
  - _Requirements: 1.1, 1.3, 1.4_



- [ ] 2. Create EvidenceDataProvider with static evidence data
  - Create EvidenceDataProvider class
  - Define 49 evidences (7 per arc) with placeholder content
  - Organize evidences by arc and type





  - Add helper methods to get evidences by arc or type
  - _Requirements: 1.1, 1.2, 3.3, 3.4_

- [ ] 3. Implement EvidenceProvider with Firebase integration
- [ ] 3.1 Create EvidenceProvider with ChangeNotifier
  - Implement loadEvidences method to fetch unlock status from Firestore
  - Implement unlockEvidence method to save to Firestore

  - Implement getEvidencesByArc method
  - Implement getEvidencesByType method
  - Implement getCollectionProgress method




  - Add local caching with SharedPreferences
  - _Requirements: 1.2, 3.3, 3.4, 3.5_

- [ ] 3.2 Add filtering and progress logic
  - Implement filter state management
  - Calculate collection progress percentage

  - Count unlocked evidences per arc
  - _Requirements: 3.3, 3.4, 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 4. Build EvidenceCard widget




- [ ] 4.1 Create EvidenceCard stateless widget
  - Design card layout with thumbnail/icon
  - Implement locked state visual (silhouette with lock icon)
  - Implement unlocked state visual (preview visible)
  - Add "NUEVO" badge for recently unlocked
  - Apply game aesthetic styling

  - _Requirements: 1.3, 1.4, 3.1, 3.2_

- [ ] 4.2 Add tap interaction
  - Handle tap on unlocked evidence (open detail view)
  - Handle tap on locked evidence (show hint dialog)



  - Add visual feedback on tap
  - _Requirements: 2.1, 3.2_

- [ ] 5. Create EvidenceDetailView
- [ ] 5.1 Build detail view dialog
  - Create fullscreen/dialog overlay
  - Add close button
  - Display evidence title and description

  - Show arc information
  - Apply VHS aesthetic
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 5.2 Implement content display by type

  - Add image viewer for screenshots
  - Add text display for messages/documents
  - Add video player for videos (placeholder)
  - Add audio player for audio (placeholder)
  - _Requirements: 2.2_


- [ ] 6. Create ArchiveScreen
- [ ] 6.1 Build screen structure and layout
  - Create StatefulWidget for ArchiveScreen
  - Setup video background layer
  - Add dark overlay (0.3 opacity)

  - Implement SafeArea with ScrollView
  - Add back button in top-left corner
  - Add REC indicator in bottom-right corner
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 6.1_


- [x] 6.2 Implement header with progress

  - Add title "ARCHIVO"
  - Display collection progress (e.g., "15/49")
  - Add progress bar visual
  - _Requirements: 1.2, 3.4_


- [ ] 6.3 Implement filter bar
  - Create filter buttons (All, Screenshots, Messages, Videos, Audio)
  - Add selected state styling
  - Connect to filter logic
  - Show count per filter
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 6.4 Implement arc tabs
  - Create horizontal tab bar with 7 arcs
  - Add selected state styling
  - Connect to arc filtering
  - _Requirements: 1.1_

- [ ] 6.5 Implement evidence grid
  - Create GridView with EvidenceCards
  - Make grid responsive (2-4 columns based on screen size)


  - Connect to EvidenceProvider

  - Filter evidences based on selected arc and type
  - _Requirements: 1.1, 1.3, 1.4, 1.5_

- [ ] 7. Integrate with existing systems
- [ ] 7.1 Register EvidenceProvider in main.dart
  - Add EvidenceProvider to MultiProvider
  - Initialize evidences on app start

  - _Requirements: 3.5_

- [ ] 7.2 Connect to MenuScreen
  - Update MenuScreen ARCHIVE button handler
  - Add navigation to ArchiveScreen
  - Test navigation flow

  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ]* 8. Add placeholder evidence content
  - Create placeholder images for screenshots
  - Create placeholder text for messages
  - Add placeholder icons for locked evidences
  - Update EvidenceDataProvider with content paths
  - _Requirements: 1.4, 2.2_

- [ ]* 9. Add unlock animations
  - Implement fade-in animation for newly unlocked evidences
  - Add pulsing glow effect for "NUEVO" badge
  - Add slide-up animation for detail view
  - _Requirements: 2.1, 2.5_

- [ ] 10. Final integration testing
- [ ] 10.1 Test complete archive flow
  - Test navigation: Menu → Archive → Back
  - Verify evidences display correctly
  - Test filters work properly
  - Test arc tabs navigation
  - Verify locked/unlocked states
  - _Requirements: All requirements_

- [ ] 10.2 Test detail view
  - Test opening detail view for unlocked evidences
  - Test hint dialog for locked evidences
  - Verify content displays correctly
  - Test close functionality
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5, 3.2_

- [ ] 10.3 Verify visual consistency
  - Check that aesthetic matches other screens
  - Verify fonts, colors, and spacing are consistent
  - Test on different screen sizes
  - Ensure animations are smooth
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_
