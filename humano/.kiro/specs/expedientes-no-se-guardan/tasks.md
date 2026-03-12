# Implementation Plan

- [x] 1. Add provider reference support to BaseArcGame


  - Add `_fragmentsProvider` field to store direct reference
  - Implement `setFragmentsProvider()` method to receive provider from screen
  - Implement `saveFragment()` method that uses direct provider reference
  - Implement `_normalizeArcId()` helper for ID normalization
  - Add error handling with detailed logging
  - _Requirements: 3.1, 3.2, 3.3, 5.1_

- [ ]* 1.1 Write property test for provider reference independence
  - **Property 3: BuildContext Independence**
  - **Validates: Requirements 3.1**

- [ ]* 1.2 Write property test for arc ID normalization
  - **Property 2: Arc ID normalization consistency**
  - **Validates: Requirements 5.1, 5.5**

- [ ]* 1.3 Write property test for idempotent normalization
  - **Property 10: Idempotent normalization**
  - **Validates: Requirements 5.5**

- [ ]* 1.4 Write unit tests for arc ID normalization examples
  - Test 'gluttony' → 'arc_1_gula'
  - Test 'greed' → 'arc_2_greed'
  - Test 'envy' → 'arc_3_envy'
  - Test 'arc_1_gula' → 'arc_1_gula' (idempotent)
  - _Requirements: 5.2, 5.3, 5.4, 5.5_

- [ ]* 1.5 Write property test for error handling
  - **Property 4: Error handling without crashes**
  - **Validates: Requirements 1.4, 3.4**



- [ ] 2. Update ArcGameScreen to pass provider reference
  - Get FragmentsProvider reference in initState using Provider.of
  - Call game.setFragmentsProvider() with the reference
  - Add logging to confirm provider was set
  - Ensure this happens before game starts
  - _Requirements: 3.2_

- [ ]* 2.1 Write unit test for provider initialization
  - Test that setting provider makes it available


  - Test that provider reference is not null after setting
  - _Requirements: 3.2_

- [ ] 3. Update GluttonyArcGame to use new save method
  - Replace PuzzleIntegrationHelper.collectFragment() call with saveFragment()
  - Remove buildContext dependency from fragment collection
  - Update arcId parameter to use 'gluttony' (will be normalized)
  - Test fragment collection in-game
  - _Requirements: 1.1, 3.1_

- [ ]* 3.1 Write property test for fragment persistence
  - **Property 1: Fragment persistence after collection**
  - **Validates: Requirements 1.1, 1.3**



- [ ]* 3.2 Write property test for user ID validation
  - **Property 8: User ID validation before save**
  - **Validates: Requirements 4.4**



- [ ] 4. Update GreedArcGame to use new save method
  - Replace PuzzleIntegrationHelper.collectFragment() call with saveFragment()
  - Remove buildContext dependency from fragment collection
  - Update arcId parameter to use 'greed' (will be normalized)
  - Test fragment collection in-game


  - _Requirements: 1.1, 3.1_

- [ ] 5. Update EnvyArcGame to use new save method
  - Replace PuzzleIntegrationHelper.collectFragment() call with saveFragment()
  - Remove buildContext dependency from fragment collection
  - Update arcId parameter to use 'envy' (will be normalized)
  - Test fragment collection in-game
  - _Requirements: 1.1, 3.1_

- [ ] 6. Verify fragments appear in ARCHIVOS screen
  - Collect fragments in each arc
  - Open ARCHIVOS screen
  - Verify fragments show as unlocked
  - Verify fragment content is displayed
  - Verify clicking fragment opens expediente
  - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [x]* 6.1 Write property test for unlock state consistency


  - **Property 5: Fragment unlock state consistency**
  - **Validates: Requirements 2.1**

- [ ]* 6.2 Write property test for fragment content availability
  - **Property 6: Fragment content availability**
  - **Validates: Requirements 2.3**

- [ ]* 6.3 Write property test for state synchronization
  - **Property 9: Local state synchronization**
  - **Validates: Requirements 2.5**



- [ ] 7. Test provider reference persistence across game resets
  - Start game and collect fragment
  - Trigger game reset (death or restart)
  - Collect another fragment
  - Verify both fragments are saved
  - Verify provider reference is still valid
  - _Requirements: 3.5_

- [ ]* 7.1 Write property test for provider persistence across resets
  - **Property 7: Provider reference persistence across resets**
  - **Validates: Requirements 3.5**



- [ ] 8. Add error handling validation
  - Test with null provider (before setFragmentsProvider called)
  - Test with invalid fragment numbers (0, 6, -1)
  - Test with invalid arc IDs


  - Verify game doesn't crash in any case
  - Verify errors are logged appropriately
  - _Requirements: 1.4, 3.4, 4.1, 4.2, 4.3_

- [ ]* 8.1 Write unit tests for error cases
  - Test null provider is handled gracefully



  - Test invalid fragment number is rejected
  - Test no authenticated user is handled
  - _Requirements: 1.5, 3.4_

- [ ] 9. Deprecate PuzzleIntegrationHelper.collectFragment
  - Add @deprecated annotation to method
  - Add deprecation message pointing to new method
  - Update documentation
  - Keep method for backwards compatibility
  - _Requirements: 3.1_

- [ ] 10. Checkpoint - Verify all fragments save correctly
  - Ensure all tests pass, ask the user if questions arise.
  - Test complete flow: collect → save → appear in ARCHIVOS
  - Test across all three arcs
  - Test with game resets
  - Test error scenarios
  - _Requirements: All_

- [ ] 11. Update documentation
  - Document new saveFragment() method
  - Document setFragmentsProvider() usage
  - Add migration guide for other arcs
  - Update architecture diagrams
  - _Requirements: All_
