# Implementation Plan

- [x] 1. Add comprehensive diagnostic logging to attachment lifecycle


  - Add detailed logging to `BaseArcGame.attach()` method
  - Add detailed logging to `BaseArcGame.detach()` method
  - Add detailed logging to `BaseArcGame.onRemove()` method
  - Log Flame's built-in `attached` property state at each transition
  - Add stack trace capture for attachment events
  - _Requirements: 2.1, 2.2, 2.3, 2.4_



- [ ] 2. Simplify BaseArcGame attachment handling
  - Remove custom `_isAttached` flag from `BaseArcGame`
  - Rely on Flame's built-in `attached` property instead
  - Update `attach()` override to only add logging, not prevent attachment
  - Update `detach()` override to only add logging


  - Ensure `onRemove()` checks `attached` property before calling `detach()`
  - _Requirements: 3.1, 3.3, 3.4_

- [x] 3. Add AutomaticKeepAliveClientMixin to ArcGameScreen


  - Add `AutomaticKeepAliveClientMixin` to `_ArcGameScreenState`
  - Override `wantKeepAlive` to return `true`
  - Call `super.build(context)` at start of `build()` method
  - _Requirements: 1.1, 3.2_




- [ ] 4. Simplify disposal logic in ArcGameScreen
  - Remove async `Future.delayed()` calls from `dispose()` method
  - Make disposal synchronous: pause → dispose notifier → call super.dispose()
  - Remove manual `game.onRemove()` call (let Flame handle it)
  - Remove manual `detach()` call (let widget tree handle it)
  - _Requirements: 1.4, 3.4_

- [ ] 5. Test single arc (Gluttony) with new implementation
  - Run the app and navigate to Gluttony arc
  - Check logs for single ATTACH message
  - Verify no "attachment error" appears
  - Play through the arc normally
  - Exit and check for clean DETACH message
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [ ] 6. Test navigation patterns
  - Test: Arc → Menu → Same Arc (verify fresh instance)
  - Test: Arc → Menu → Different Arc
  - Test: Rapid back/forward navigation
  - Verify each pattern shows clean attach/detach cycle
  - _Requirements: 1.5, 3.5_

- [ ] 7. Test all 7 arcs
  - Test Gluttony arc
  - Test Greed arc
  - Test Envy arc
  - Test Lust arc
  - Test Pride arc
  - Test Sloth arc
  - Test Wrath arc
  - Verify no attachment errors in any arc
  - _Requirements: 1.1, 1.2, 1.3_

- [ ] 8. If errors persist: Implement StableGameWidget wrapper
  - Create `StableGameWidget` class extending `StatefulWidget`
  - Add `AutomaticKeepAliveClientMixin` to state class
  - Create inner `GameWidget` in `initState()`
  - Store as `late final Widget _gameWidget`
  - Return stored widget in `build()`


  - Update `ArcGameScreen` to use `StableGameWidget` instead of `GameWidget`
  - _Requirements: 3.2, 3.5_

- [ ] 9. If errors still persist: Investigate Flame version
  - Check Flame changelog for attachment-related changes in 1.18.0
  - Test with Flame 1.17.0 to see if error disappears
  - Test with Flame 1.19.0 (if available) to see if error is fixed

  - Document findings and recommend version strategy
  - _Requirements: 1.2_

- [ ] 10. Write property test for single attachment invariant
  - **Property 1: Single Attachment Per Game Instance**
  - **Validates: Requirements 1.1, 3.3**
  - Create test that generates random arc types

  - Create game instance and attach to widget
  - Verify `attached == true` after attachment
  - Verify `attached == false` after detachment
  - Test across all arc types

- [ ] 11. Write property test for initialization success
  - **Property 2: Successful Initialization Without Errors**

  - **Validates: Requirements 1.2**
  - Generate random arc types
  - Create and initialize game for each type
  - Verify no exceptions thrown during initialization
  - Verify game reaches ready state

- [ ] 12. Write property test for rebuild stability
  - **Property 7: No Recreation on Rebuild**



  - **Validates: Requirements 3.2**
  - Create game and widget
  - Capture initial hashCodes
  - Trigger multiple rebuilds via setState
  - Verify hashCodes remain unchanged

- [ ] 13. Write property test for disposal cleanup
  - **Property 4: Clean Detachment on Disposal**
  - **Property 8: Proper State Reset on Disposal**
  - **Validates: Requirements 1.4, 3.4**
  - Create game instance and attach
  - Dispose game
  - Verify `attached == false`
  - Verify state is reset to initial values

- [ ] 14. Final verification and cleanup
  - Remove all debug logging added for diagnostics (or wrap in kDebugMode)
  - Verify all 7 arcs work without errors
  - Test complete gameplay flow: start → play → victory/game over → exit
  - Document any remaining issues or workarounds needed
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_
