# Implementation Plan

- [x] 1. Create data models for puzzle fragments


  - Create `PuzzleFragment` model with shape data, position, rotation, and collection state
  - Create `FragmentShape` model with SVG path and connection points
  - Create `PuzzleEvidence` model with 5 fragments and completion state
  - Create `ConnectionPoint` model with side, type (tab/blank), and match ID
  - _Requirements: 1.1, 1.4, 1.5, 2.1, 2.2_

- [ ]* 1.1 Write property test for fragment persistence
  - **Property 1: Fragment persistence round-trip**
  - **Validates: Requirements 1.1**



- [ ] 2. Implement shape generator for puzzle pieces
  - Create `ShapeGenerator` class with puzzle shape generation logic
  - Implement SVG path generation with bezier curves for tabs and blanks
  - Generate 5 interlocking shapes in 2x3 grid layout
  - Ensure adjacent pieces have complementary connection points (tab matches blank)
  - Add deterministic pseudo-random tab/blank assignment
  - _Requirements: 2.1, 2.2, 2.3, 2.5_

- [ ]* 2.1 Write property test for shape generation
  - **Property 6: Unique shape generation**
  - **Validates: Requirements 2.1**

- [ ]* 2.2 Write property test for connection compatibility
  - **Property 7: Connection point compatibility**
  - **Validates: Requirements 2.2, 2.3**

- [x]* 2.3 Write property test for complete puzzle validity


  - **Property 8: Complete puzzle validity**
  - **Validates: Requirements 2.5**

- [ ] 3. Create puzzle data provider
  - Create `PuzzleDataProvider` class extending ChangeNotifier
  - Implement methods to load evidence definitions from assets/Firestore
  - Implement methods to load player's collected fragments
  - Add `collectFragment()` method to mark fragments as collected
  - Add `completeEvidence()` method to save completion state
  - Add methods to query evidences by arc and check assembly availability
  - _Requirements: 1.1, 1.5, 4.3, 9.1, 9.2, 9.3, 9.4_

- [ ]* 3.1 Write property test for collection state persistence
  - **Property 36: Collection state persistence**
  - **Validates: Requirements 9.3**



- [ ]* 3.2 Write property test for arc association integrity
  - **Property 5: Arc association integrity**
  - **Validates: Requirements 1.5**

- [ ] 4. Define evidence data for three arcs
  - Create evidence definition for Arc 1 (Gula - Mateo's viral video)


  - Create evidence definition for Arc 2 (Avaricia - Valeria's doxxing)
  - Create evidence definition for Arc 3 (Envidia - Lucía's comparison)
  - Define 5 fragments per evidence with narrative snippets
  - Specify image regions for each fragment
  - Set correct positions and rotations for each fragment
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 5. Create fragment shape clipper for custom rendering
  - Create `FragmentShapeClipper` class extending CustomClipper<Path>


  - Implement `getClip()` to parse SVG path and create Flutter Path
  - Implement `shouldReclip()` for performance optimization
  - Test rendering with sample images
  - _Requirements: 1.4, 2.4, 5.4_

- [ ]* 5.1 Write property test for image region slicing
  - **Property 20: Image region slicing**
  - **Validates: Requirements 5.4**

- [ ] 6. Implement draggable fragment component
  - Create `DraggableFragment` StatefulWidget with animation controller
  - Implement drag gesture detection with GestureDetector
  - Add rotation state and tap-to-rotate functionality (90° increments)
  - Implement pickup effects (scale animation, shadow)
  - Implement drag effects (smooth following, momentum)


  - Add visual feedback for hover state
  - _Requirements: 3.1, 3.2, 3.3, 6.1, 6.7_

- [ ]* 6.1 Write property test for rotation increment
  - **Property 11: Rotation increment**
  - **Validates: Requirements 3.3**

- [ ]* 6.2 Write property test for drag responsiveness
  - **Property 10: Drag responsiveness**
  - **Validates: Requirements 3.2**

- [ ] 7. Create puzzle validator
  - Create `PuzzleValidator` class with static validation methods
  - Implement `isCorrectPlacement()` to check position and rotation within tolerance


  - Implement `calculateSnapPosition()` to compute snap target
  - Implement `isPuzzleComplete()` to check if all fragments are correctly placed
  - Add configurable tolerance parameters
  - _Requirements: 3.4, 3.5, 3.6_

- [ ]* 7.1 Write property test for snap on correct placement
  - **Property 12: Snap on correct placement**
  - **Validates: Requirements 3.4**

- [ ]* 7.2 Write property test for completion detection
  - **Property 14: Completion detection**
  - **Validates: Requirements 3.6**

- [ ] 8. Implement difficulty manager
  - Create `DifficultyManager` class to manage challenge mechanics


  - Implement `getSnapTolerance()` with progressive increase after 2+ correct placements
  - Implement `shouldLockFragment()` to check for 3+ errors
  - Implement `getLockDuration()` returning 3 second duration
  - Implement `shouldOfferHint()` based on attempt count
  - Implement `getFalseMagneticStrength()` for proximity-based false attraction
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [ ]* 8.1 Write property test for progressive tolerance increase
  - **Property 32: Progressive tolerance increase**
  - **Validates: Requirements 7.4**

- [ ]* 8.2 Write property test for fragment locking
  - **Property 30: Fragment locking on repeated errors**


  - **Validates: Requirements 7.2**

- [ ] 9. Create particle system
  - Create `Particle` class with position, velocity, color, size, lifetime
  - Create `ParticleSystem` StatefulWidget to render particles
  - Create `ParticleEmitter` class with static methods for different effects
  - Implement `emitTrailParticles()` for drag trail effect
  - Implement `emitSnapParticles()` for successful snap explosion
  - Implement `emitErrorParticles()` for incorrect placement
  - Implement `emitConfettiParticles()` for puzzle completion
  - Add particle update logic with gravity and lifetime
  - _Requirements: 6.2, 6.4, 6.5, 6.6_

- [ ]* 9.1 Write property test for drag particle trail
  - **Property 23: Drag particle trail**
  - **Validates: Requirements 6.2**

- [x] 10. Implement sound and haptic feedback


  - Add sound assets (pickup.mp3, snap.mp3, error.mp3, completion.mp3, proximity.mp3)
  - Create `SoundManager` class using audioplayers package
  - Implement methods to play each sound effect
  - Add haptic feedback using vibration package for error events
  - Integrate sound calls into fragment interactions
  - _Requirements: 6.1, 6.3, 6.4, 6.5, 6.6_

- [ ]* 10.1 Write property test for pickup effects trigger
  - **Property 22: Pickup effects trigger**
  - **Validates: Requirements 6.1**

- [ ]* 10.2 Write property test for snap effects trigger
  - **Property 25: Snap effects trigger**

  - **Validates: Requirements 6.4**

- [ ]* 10.3 Write property test for error effects trigger
  - **Property 26: Error effects trigger**
  - **Validates: Requirements 6.5**

- [ ] 11. Create puzzle assembly screen
  - Create `PuzzleAssemblyScreen` StatefulWidget
  - Initialize puzzle board with scattered fragments at random positions and rotations
  - Implement state management for fragment positions, rotations, and lock states
  - Add time pressure indicator UI (non-blocking)
  - Implement `_onFragmentDragged()` handler
  - Implement `_onFragmentDropped()` handler with validation
  - Implement `_onFragmentTapped()` handler for rotation
  - Track correct placements and error counts per fragment
  - _Requirements: 3.1, 3.2, 3.3, 7.1_

- [ ]* 11.1 Write property test for random initialization
  - **Property 9: Random initialization**
  - **Validates: Requirements 3.1**


- [ ] 12. Implement snap and rejection logic
  - Integrate `PuzzleValidator` into drop handler
  - Implement snap animation with magnetic effect when placement is correct
  - Implement rejection animation (shake + bounce) when placement is incorrect
  - Add proximity detection for glow effect and proximity sound
  - Apply false magnetic attraction for nearby incorrect positions

  - Update difficulty manager tolerance based on correct placements
  - _Requirements: 3.4, 3.5, 6.3, 7.3, 7.4_

- [ ]* 12.1 Write property test for rejection on incorrect placement
  - **Property 13: Rejection on incorrect placement**
  - **Validates: Requirements 3.5**

- [ ]* 12.2 Write property test for proximity feedback
  - **Property 24: Proximity feedback activation**
  - **Validates: Requirements 6.3**

- [ ]* 12.3 Write property test for false magnetic attraction
  - **Property 31: False magnetic attraction**
  - **Validates: Requirements 7.3**

- [ ] 13. Implement fragment locking mechanism
  - Track error count per fragment in assembly screen state
  - Lock fragment for 3 seconds after 3 incorrect placements
  - Display cooldown timer on locked fragments
  - Prevent interaction with locked fragments
  - Reset error count when fragment is correctly placed

  - _Requirements: 7.2_

- [ ] 14. Implement completion detection and animation
  - Check puzzle completion after each successful snap
  - Trigger completion animation sequence when all fragments are correct
  - Play triumphant sound sequence
  - Show confetti particle effect
  - Animate puzzle lines dissolving to reveal seamless image
  - Display evidence title and narrative description
  - Call `PuzzleDataProvider.completeEvidence()` to save state
  - _Requirements: 3.6, 4.1, 4.2, 4.3, 6.6_



- [ ]* 14.1 Write property test for completion effects
  - **Property 27: Completion effects trigger**
  - **Validates: Requirements 6.6**

- [ ]* 14.2 Write property test for seamless final rendering
  - **Property 15: Seamless final rendering**
  - **Validates: Requirements 4.1**

- [ ]* 14.3 Write property test for evidence metadata display
  - **Property 16: Evidence metadata display**
  - **Validates: Requirements 4.2**

- [ ] 15. Implement hint system
  - Add hint button to assembly screen UI
  - Show hint button only when `DifficultyManager.shouldOfferHint()` returns true
  - Implement hint visualization (highlight one correct position)
  - Limit hints to one per puzzle attempt
  - Add subtle animation to guide player attention


  - _Requirements: 7.5_

- [ ]* 15.1 Write property test for hint availability
  - **Property 33: Hint availability**
  - **Validates: Requirements 7.5**

- [ ] 16. Update archive screen for puzzle fragments
  - Modify `ArchiveScreen` to display evidences with fragment collection status
  - Show visual indicators for collected vs missing fragments (✨ vs ☆)
  - Display fragment count (e.g., "3/5 FRAGMENTOS")
  - Group evidences by arc with visual separation
  - Add tap handler to open assembly screen when all fragments collected
  - Show message when tapping incomplete evidence
  - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5_


- [ ]* 16.1 Write property test for archive evidence display
  - **Property 38: Archive evidence display**
  - **Validates: Requirements 10.1**

- [ ]* 16.2 Write property test for incomplete evidence status
  - **Property 39: Incomplete evidence status display**
  - **Validates: Requirements 10.2**

- [ ]* 16.3 Write property test for arc-based organization
  - **Property 42: Arc-based organization**
  - **Validates: Requirements 10.5**

- [ ] 17. Integrate fragment collection into gameplay
  - Update `EvidenceComponent` to use `PuzzleDataProvider.collectFragment()`


  - Modify collection notification to show fragment preview
  - Update HUD to display fragment collection progress
  - Ensure fragment collection triggers across all three arcs
  - Test fragment collection during actual gameplay
  - _Requirements: 1.1, 1.2, 1.3_

- [x]* 17.1 Write property test for collection notification



  - **Property 2: Collection notification triggers**
  - **Validates: Requirements 1.2**

- [ ]* 17.2 Write property test for assembly unlock
  - **Property 3: Assembly unlock on completion**
  - **Validates: Requirements 1.3**

- [ ] 18. Implement completed evidence viewing
  - Add logic to display assembled version by default for completed evidences
  - Show complete image without puzzle lines
  - Display full narrative description
  - Add option to view individual fragments
  - Ensure completed state persists across app restarts
  - _Requirements: 4.1, 4.2, 4.4, 4.5_

- [ ]* 18.1 Write property test for completed state restoration
  - **Property 18: Completed state restoration**
  - **Validates: Requirements 4.4**

- [ ]* 18.2 Write property test for narrative content display
  - **Property 19: Narrative content display**
  - **Validates: Requirements 4.5**

- [ ] 19. Add performance optimizations
  - Cache generated SVG paths in `ShapeGenerator`
  - Implement particle pooling to reuse particle objects
  - Add `RepaintBoundary` widgets around fragments
  - Optimize image loading with appropriate sizes
  - Dispose animation controllers properly
  - Clear particle lists when screen is disposed
  - _Requirements: All (performance)_

- [ ] 20. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [ ]* 21. Write integration tests
  - Test complete flow: collect fragments → open archive → assemble puzzle → view completed evidence
  - Test persistence across app restarts
  - Test multiple arcs with separate fragment collections
  - Test error handling for network failures and corrupted data
