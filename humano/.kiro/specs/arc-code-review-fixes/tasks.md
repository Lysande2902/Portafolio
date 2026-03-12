# Implementation Plan - Arc Code Review and Fixes

- [ ] 1. Analyze and document current issues in all 3 arcs


  - Review Arco 1 (Gula) code for bugs, memory leaks, and performance issues
  - Review Arco 2 (Avaricia) code for bugs, memory leaks, and performance issues
  - Review Arco 3 (Envidia) code for bugs, memory leaks, and performance issues
  - Document all identified issues with severity levels
  - _Requirements: 1.1-1.5, 2.1-2.5, 3.1-3.5, 6.1-6.5, 7.1-7.5_

- [ ] 2. Fix Arco 1 (Gula) core issues
- [ ] 2.1 Fix food inventory synchronization
  - Ensure food collection updates UI immediately
  - Verify Firebase persistence within 2 seconds
  - Add proper error handling for collection failures
  - Test with rapid collection attempts
  - _Requirements: 1.1, 4.1, 5.1_

- [ ]* 2.2 Write property test for food inventory synchronization
  - **Property 1: Inventory UI Synchronization**
  - **Validates: Requirements 1.1, 4.1, 5.1**

- [ ] 2.3 Fix food inventory capacity enforcement
  - Prevent collection when inventory is full (2 items)
  - Display clear feedback message when full
  - Test boundary conditions (exactly at capacity)
  - _Requirements: 1.3_

- [ ]* 2.4 Write property test for inventory capacity
  - **Property 2: Inventory Capacity Enforcement**
  - **Validates: Requirements 1.3**

- [ ] 2.5 Fix food consumption and effects
  - Ensure consuming food decrements inventory atomically
  - Verify distraction effects apply correctly
  - Test with different food types (apple vs salad)
  - _Requirements: 1.2, 2.3_

- [ ]* 2.6 Write property test for atomic operations
  - **Property 3: Atomic State Updates**
  - **Validates: Requirements 1.2, 2.3, 5.4**

- [ ] 2.7 Fix food throw mechanic
  - Validate throw range (max 150 pixels)
  - Ensure cooldown works correctly (3 seconds)
  - Fix distraction point creation and enemy detection
  - Test edge cases (throwing at max range, during cooldown)
  - _Requirements: 1.2, 7.5_

- [ ] 2.8 Fix Arco 1 memory management
  - Properly dispose DiscomfortEffectsManager in resetGame()
  - Clear all component references
  - Dispose listeners and subscriptions
  - Test for memory leaks with repeated resets
  - _Requirements: 6.2, 6.4_

- [ ]* 2.9 Write property test for resource cleanup
  - **Property 7: Resource Cleanup on Navigation**
  - **Validates: Requirements 6.2, 6.4**

- [ ] 2.10 Fix Arco 1 state persistence
  - Ensure all game state saves to Firebase on completion
  - Verify state restoration on re-entry
  - Test with various completion states (different evidence counts)
  - _Requirements: 1.4, 1.5, 5.1_

- [ ]* 2.11 Write property test for state round-trip
  - **Property 4: State Persistence Round-Trip**
  - **Validates: Requirements 1.4, 1.5**

- [ ] 3. Fix Arco 2 (Avaricia) core issues
- [ ] 3.1 Fix coin inventory synchronization
  - Ensure coin collection updates UI immediately
  - Verify Firebase persistence within 2 seconds
  - Add proper error handling for collection failures
  - Test with rapid collection attempts
  - _Requirements: 2.1, 4.1, 5.1_

- [ ]* 3.2 Write property test for coin inventory synchronization
  - **Property 1: Inventory UI Synchronization**
  - **Validates: Requirements 2.1, 4.1, 5.1**

- [ ] 3.3 Fix coin inventory capacity enforcement
  - Prevent collection when inventory is full (2 coins)
  - Display clear feedback message when full
  - Test boundary conditions
  - _Requirements: 2.2_

- [ ]* 3.4 Write property test for coin capacity
  - **Property 2: Inventory Capacity Enforcement**
  - **Validates: Requirements 2.2**

- [ ] 3.5 Fix coin throw mechanic
  - Validate throw range (max 150 pixels)
  - Ensure cooldown works correctly (3 seconds)
  - Fix distraction point creation and enemy detection
  - Test with different coin types (gold vs silver)
  - _Requirements: 2.3, 7.5_

- [ ]* 3.6 Write property test for coin atomic operations
  - **Property 3: Atomic State Updates**
  - **Validates: Requirements 2.3, 5.4**

- [ ] 3.7 Fix cash register recovery mechanic
  - Ensure sanity recovery works correctly
  - Verify stolen sanity tracking
  - Test recovery with various stolen amounts
  - Balance recovery amounts for fair gameplay
  - _Requirements: 2.1, 2.3_

- [ ] 3.8 Fix enemy steal mechanic
  - Ensure evidence stealing updates state atomically
  - Verify sanity stealing works correctly
  - Test flash effect triggers properly
  - Ensure evidence respawns correctly
  - _Requirements: 2.3, 5.4_

- [ ] 3.9 Fix Arco 2 memory management
  - Properly dispose background music player
  - Clear all component references in resetGame()
  - Dispose listeners and subscriptions
  - Test for memory leaks
  - _Requirements: 6.2, 6.4_

- [ ]* 3.10 Write property test for Arco 2 resource cleanup
  - **Property 7: Resource Cleanup on Navigation**
  - **Validates: Requirements 6.2, 6.4**

- [ ] 3.11 Fix Arco 2 state persistence
  - Ensure all game state saves to Firebase on completion
  - Verify coin inventory restoration on re-entry
  - Test with various completion states
  - _Requirements: 2.4, 2.5, 5.1_

- [ ]* 3.12 Write property test for Arco 2 state round-trip
  - **Property 4: State Persistence Round-Trip**
  - **Validates: Requirements 2.4, 2.5**

- [ ] 4. Fix Arco 3 (Envidia) core issues
- [ ] 4.1 Fix camera/photograph inventory synchronization
  - Ensure camera collection updates UI immediately
  - Verify Firebase persistence within 2 seconds
  - Add proper error handling for collection failures
  - Test with rapid collection attempts
  - _Requirements: 3.1, 4.1, 5.1_

- [ ]* 4.2 Write property test for camera inventory synchronization
  - **Property 1: Inventory UI Synchronization**
  - **Validates: Requirements 3.1, 4.1, 5.1**

- [ ] 4.3 Fix camera inventory capacity enforcement
  - Prevent collection when inventory is full (3 photos)
  - Display clear feedback message when full
  - Test boundary conditions
  - _Requirements: 3.2_

- [ ]* 4.4 Write property test for camera capacity
  - **Property 2: Inventory Capacity Enforcement**
  - **Validates: Requirements 3.2**

- [ ] 4.5 Fix photograph placement mechanic
  - Validate placement range (max 100 pixels)
  - Ensure cooldown works correctly (2 seconds)
  - Fix photograph component creation and enemy detection
  - Test photograph pose capture accuracy
  - _Requirements: 3.1, 3.3, 7.5_

- [ ]* 4.6 Write property test for photograph atomic operations
  - **Property 3: Atomic State Updates**
  - **Validates: Requirements 3.1, 5.4**

- [ ] 4.7 Fix enemy phase transitions
  - Ensure phase updates smoothly based on evidence count
  - Verify speed and behavior changes per phase
  - Test dash mechanic timing and cooldown
  - Fix breakout mechanic and statistics tracking
  - _Requirements: 3.1, 4.1_

- [ ] 4.8 Optimize screen shake effects
  - Reduce shake intensity calculation overhead
  - Ensure shake doesn't cause frame drops
  - Test shake with various enemy distances and phases
  - _Requirements: 4.1, 4.4, 6.1_

- [ ] 4.9 Fix Arco 3 memory management
  - Properly dispose photograph components
  - Clear all component references in resetGame()
  - Dispose listeners and subscriptions
  - Test for memory leaks
  - _Requirements: 6.2, 6.4_

- [ ]* 4.10 Write property test for Arco 3 resource cleanup
  - **Property 7: Resource Cleanup on Navigation**
  - **Validates: Requirements 6.2, 6.4**

- [ ] 4.11 Fix Arco 3 state persistence
  - Ensure all game state saves to Firebase on completion
  - Verify photograph data restoration on re-entry
  - Test with various completion states
  - _Requirements: 3.4, 3.5, 5.1_

- [ ]* 4.12 Write property test for Arco 3 state round-trip
  - **Property 4: State Persistence Round-Trip**
  - **Validates: Requirements 3.4, 3.5**

- [ ] 5. Fix cross-arc UI reactivity issues
- [ ] 5.1 Add visual feedback for item collection
  - Create particle effect or floating text component for collection feedback
  - Add immediate visual effect when collecting food items (Arco 1)
  - Add immediate visual effect when collecting coins (Arco 2)
  - Add immediate visual effect when collecting camera/photos (Arco 3)
  - Add immediate visual effect when collecting evidence/fragments (all arcs)
  - Test that effects appear within 50ms of collection
  - _Requirements: 1.1, 2.1, 3.1, 4.6_

- [ ]* 5.2 Write property test for collection visual feedback
  - **Property 16: Collection Visual Feedback**
  - **Validates: Requirements 1.1, 2.1, 3.1, 4.6**

- [ ] 5.3 Optimize provider notifications
  - Ensure providers notify listeners immediately on state change
  - Reduce notification overhead
  - Test with rapid state changes
  - Measure notification latency (target: <50ms)
  - _Requirements: 4.1, 4.3, 4.4_

- [ ]* 5.4 Write property test for provider state consistency
  - **Property 15: Provider State Consistency**
  - **Validates: Requirements 4.3**

- [ ] 5.5 Add immediate visual feedback for all interactions
  - Button presses show immediate visual response
  - Item usage shows immediate effect indication
  - Test feedback timing (target: <50ms)
  - _Requirements: 4.5_

- [ ]* 5.6 Write property test for immediate visual feedback
  - **Property 14: Immediate Visual Feedback**
  - **Validates: Requirements 4.5**

- [ ] 5.7 Fix UI stuttering under rapid state changes
  - Implement debouncing for rapid updates
  - Optimize widget rebuilds
  - Test with stress scenarios (rapid evidence collection, item spam)
  - Measure frame rate (target: maintain 60fps)
  - _Requirements: 4.2, 4.4_

- [ ]* 5.8 Write property test for UI reactivity under load
  - **Property 13: UI Reactivity Under Load**
  - **Validates: Requirements 4.4**

- [ ] 6. Fix Firebase persistence and error handling
- [ ] 6.1 Implement Firebase retry logic with exponential backoff
  - Add retry mechanism to all Firebase operations
  - Implement exponential backoff (1s, 2s, 4s delays)
  - Log retry attempts
  - Show user notification after max retries
  - _Requirements: 5.2, 7.2_

- [ ]* 6.2 Write property test for Firebase retry logic
  - **Property 5: Firebase Retry on Failure**
  - **Validates: Requirements 5.2, 7.2**

- [ ] 6.3 Implement offline queue and synchronization
  - Queue state changes when offline
  - Detect network connectivity changes
  - Sync queued changes when connection restored
  - Test with simulated network disconnection
  - _Requirements: 5.3_

- [ ]* 6.4 Write property test for offline queue sync
  - **Property 6: Offline Queue Synchronization**
  - **Validates: Requirements 5.3**

- [ ] 6.5 Add Firebase operation timing logs
  - Log timestamp for each Firebase write
  - Log confirmation timestamp
  - Calculate and log operation duration
  - Alert if operation exceeds 2 second target
  - _Requirements: 5.1_

- [ ] 6.6 Improve Firebase error messages
  - Replace generic error messages with specific ones
  - Provide actionable guidance to users
  - Log detailed error information for debugging
  - Test all error scenarios
  - _Requirements: 7.1, 7.2_

- [ ]* 6.7 Write property test for error handling without crashes
  - **Property 10: Error Handling Without Crashes**
  - **Validates: Requirements 7.1, 7.2, 7.3, 7.4**

- [ ] 7. Fix memory management across all arcs
- [ ] 7.1 Audit and fix all resetGame() implementations
  - Verify all components are properly disposed
  - Clear all lists and maps
  - Reset all timers and counters
  - Test memory usage before and after reset
  - _Requirements: 6.2, 6.4_

- [ ] 7.2 Implement proper asset caching and disposal
  - Cache frequently used assets (images, sounds)
  - Release unused assets after navigation
  - Monitor cache size
  - Test with repeated arc loading
  - _Requirements: 6.3_

- [ ]* 7.3 Write property test for asset caching
  - **Property 8: Asset Caching Efficiency**
  - **Validates: Requirements 6.3**

- [ ] 7.4 Fix listener and subscription disposal
  - Audit all StreamSubscriptions and listeners
  - Ensure disposal in dispose() methods
  - Use AutoDispose where applicable
  - Test for lingering listeners
  - _Requirements: 6.4_

- [ ] 7.5 Test app lifecycle (background/resume)
  - Verify state restoration after backgrounding
  - Check for memory spikes on resume
  - Test with various background durations
  - Ensure no data loss
  - _Requirements: 6.5_

- [ ]* 7.6 Write property test for lifecycle state restoration
  - **Property 9: Lifecycle State Restoration**
  - **Validates: Requirements 6.5**

- [ ] 8. Add comprehensive error handling
- [ ] 8.1 Add try-catch blocks to all async operations
  - Audit all async functions
  - Add try-catch with proper error handling
  - Log errors with stack traces
  - Show user-friendly error messages
  - _Requirements: 7.1, 8.4_

- [ ]* 8.2 Write property test for async error handling
  - **Property 12: Async Error Handling**
  - **Validates: Requirements 8.4**

- [ ] 8.3 Implement null safety and safe defaults
  - Replace all nullable accesses with null checks
  - Provide safe default values
  - Use null-aware operators (??, ?.)
  - Test with null/invalid data scenarios
  - _Requirements: 7.3_

- [ ] 8.4 Add input validation for all user actions
  - Validate ranges (throw distance, etc.)
  - Validate state preconditions
  - Provide clear feedback for invalid actions
  - Test all validation paths
  - _Requirements: 7.5_

- [ ]* 8.5 Write property test for input validation
  - **Property 11: Input Validation and Feedback**
  - **Validates: Requirements 7.5**

- [ ] 9. Checkpoint - Ensure all tests pass
  - Run all unit tests
  - Run all property-based tests
  - Run all integration tests
  - Fix any failing tests
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 10. Performance testing and optimization
- [ ] 10.1 Measure and optimize UI update latency
  - Instrument code to measure UI update timing
  - Identify slow update paths
  - Optimize to meet <100ms target
  - Re-measure and verify improvement
  - _Requirements: 4.1_

- [ ] 10.2 Measure and optimize Firebase operation timing
  - Instrument code to measure Firebase operation duration
  - Identify slow operations
  - Optimize to meet <2s target
  - Re-measure and verify improvement
  - _Requirements: 5.1_

- [ ] 10.3 Profile memory usage over extended play session
  - Run 1-hour play session
  - Monitor memory usage continuously
  - Identify memory leaks or growth
  - Fix any issues found
  - _Requirements: 6.1_

- [ ] 10.4 Measure and maintain frame rate
  - Monitor frame rate during gameplay
  - Identify frame drops and stuttering
  - Optimize to maintain 60fps
  - Test under various load conditions
  - _Requirements: 4.2, 4.4_

- [ ] 11. Manual testing of all 3 arcs
- [ ] 11.1 Complete manual testing checklist for Arco 1
  - Collect all evidence types
  - Use all consumable items
  - Reach maximum food inventory capacity
  - Complete arc and verify Firebase save
  - Exit and re-enter to verify state restoration
  - Test offline mode and sync
  - Trigger error conditions
  - Play for 30+ minutes
  - Background and resume app
  - _Requirements: 1.1-1.5_

- [ ] 11.2 Complete manual testing checklist for Arco 2
  - Collect all evidence types
  - Use all consumable items
  - Reach maximum coin inventory capacity
  - Test cash register recovery
  - Test enemy steal mechanic
  - Complete arc and verify Firebase save
  - Exit and re-enter to verify state restoration
  - Test offline mode and sync
  - Trigger error conditions
  - Play for 30+ minutes
  - Background and resume app
  - _Requirements: 2.1-2.5_

- [ ] 11.3 Complete manual testing checklist for Arco 3
  - Collect all evidence types
  - Use all consumable items
  - Reach maximum camera inventory capacity
  - Test photograph placement
  - Test enemy phase transitions
  - Complete arc and verify Firebase save
  - Exit and re-enter to verify state restoration
  - Test offline mode and sync
  - Trigger error conditions
  - Play for 30+ minutes
  - Background and resume app
  - _Requirements: 3.1-3.5_

- [ ] 12. Final checkpoint - Verify all success criteria
  - Verify all 15 correctness properties pass
  - Verify all unit tests pass
  - Verify all integration tests pass
  - Verify manual testing completed for all 3 arcs
  - Verify performance metrics meet targets
  - Verify no memory leaks in 1-hour session
  - Verify no crashes or unhandled exceptions
  - Verify Firebase operations <1% failure rate
  - Verify UI remains responsive under all conditions
  - Ensure all tests pass, ask the user if questions arise.

- [ ] 13. Documentation and cleanup
- [ ] 13.1 Document all fixes made
  - Create summary document of all issues fixed
  - Document any breaking changes
  - Update code comments where needed
  - Create migration guide if needed
  - _Requirements: All_

- [ ] 13.2 Clean up debug logs
  - Remove excessive debug prints
  - Keep essential logging
  - Ensure log levels are appropriate
  - Test that logs don't impact performance
  - _Requirements: All_

- [ ] 13.3 Create testing guide
  - Document how to run all tests
  - Document manual testing procedures
  - Document performance testing procedures
  - Create troubleshooting guide
  - _Requirements: All_
