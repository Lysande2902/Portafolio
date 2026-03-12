# Implementation Plan

- [x] 1. Add callback system to BaseArcGame


  - Add `onEvidenceCollectedChanged` callback property to BaseArcGame
  - Add `onGameStateChanged` callback property to BaseArcGame
  - Ensure callbacks are nullable and checked before invocation
  - _Requirements: 2.5_



- [ ] 2. Update evidence collection to trigger callbacks
  - Modify `_checkEvidenceCollection()` in GluttonyArcGame to invoke `onEvidenceCollectedChanged` when evidence is collected
  - Ensure callback is invoked after `evidenceCollected` is incremented


  - Add null check before invoking callback
  - _Requirements: 2.1, 2.2_

- [ ] 3. Fix hide button crash with safe type checking
  - Replace dynamic casting in `_handleHide()` with proper type checking


  - Use `is` operator to verify game type before casting
  - Call existing `toggleHide()` method instead of direct property access
  - Add comprehensive error logging for debugging
  - _Requirements: 1.1, 1.5_



- [ ] 4. Connect evidence callback in ArcGameScreen
  - In `initState()`, set `game.onEvidenceCollectedChanged` callback
  - Callback should call `setState()` to trigger HUD rebuild



  - Add `mounted` check before calling `setState()`
  - _Requirements: 2.4, 2.5_

- [ ] 5. Add visual feedback for hide action
  - Show temporary message when player tries to hide without being near a hiding spot
  - Use existing notification system or create simple overlay
  - Message should disappear after 2 seconds
  - _Requirements: 1.4_

- [ ] 6. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
