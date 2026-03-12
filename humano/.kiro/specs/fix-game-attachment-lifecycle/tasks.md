# Implementation Plan

- [x] 1. Refactor GameStateNotifier to use ValueNotifier


  - Replace ChangeNotifier with individual ValueNotifier instances for each state property
  - Add ValueNotifier for evidence, sanity, gameOver, victory, paused
  - Add ValueNotifier for item states (modoIncognito, firewall, vpn, altAccount)
  - Add ValueNotifier for arc-specific states (noiseLevel, foodInventory, coinInventory, cameraInventory)
  - Implement update methods that only notify when values change
  - Implement dispose() method to clean up all ValueNotifiers
  - _Requirements: 2.3_



- [ ] 2. Update BaseArcGame to use new GameStateNotifier
  - Modify _updateStateNotifiers() to update ValueNotifiers instead of calling notifyListeners()
  - Remove forceNotify() mechanism and frame counter
  - Add stateNotifier.dispose() call in onRemove()
  - Update updateStateNotifierExtended() documentation for subclasses


  - _Requirements: 2.3, 2.4_


- [-] 3. Update arc-specific games to use ValueNotifiers

  - [x] 3.1 Update GluttonyArcGame

    - Update updateStateNotifierExtended() to use stateNotifier.foodInventory.value

    - _Requirements: 2.3_


  
  - [x] 3.2 Update GreedArcGame



    - Update updateStateNotifierExtended() to use stateNotifier.coinInventory.value
    - _Requirements: 2.3_
  
  - [x] 3.3 Update EnvyArcGame

    - Update updateStateNotifierExtended() to use stateNotifier.cameraInventory.value
    - _Requirements: 2.3_
  
  - [ ] 3.4 Update SlothArcGame
    - Update updateStateNotifierExtended() to use stateNotifier.noiseLevel.value
    - _Requirements: 2.3_

- [x] 4. Refactor ArcGameScreen to prevent GameWidget rebuilds

  - Replace ObjectKey with GlobalKey for GameWidget
  - Remove _onGameStateChanged() listener and setState() calls for game state
  - Keep setState() only for local UI state (throwMode, hints, throwMessage)
  - Remove stateNotifier.addListener() and removeListener() calls

  - _Requirements: 1.2, 2.2_

- [ ] 5. Implement ValueListenableBuilder for GameHUD
  - Wrap GameHUD with ValueListenableBuilder for sanity

  - Nest ValueListenableBuilder for evidence
  - Nest ValueListenableBuilder for item states
  - Nest ValueListenableBuilder for arc-specific states
  - Remove GameHUD from setState() rebuilds

  - _Requirements: 1.3, 2.3_

- [ ] 6. Implement ValueListenableBuilder for game state screens
  - [x] 6.1 Wrap VictoryScreen with ValueListenableBuilder

    - Listen to stateNotifier.victory
    - Return SizedBox.shrink() when not victory
    - _Requirements: 3.1_
  
  - [ ] 6.2 Wrap GameOverScreen with ValueListenableBuilder
    - Listen to stateNotifier.gameOver



    - Return SizedBox.shrink() when not game over
    - _Requirements: 3.2_
  
  - [ ] 6.3 Wrap PauseMenu with ValueListenableBuilder
    - Listen to stateNotifier.paused
    - Return SizedBox.shrink() when not paused
    - _Requirements: 3.3, 3.4_

- [ ] 7. Update throw/photo button visibility logic
  - Wrap throw button with ValueListenableBuilder for gameOver and victory
  - Ensure button visibility updates without setState()
  - _Requirements: 1.5_

- [ ] 8. Add logging for attachment lifecycle
  - Add detailed logging in BaseArcGame.onAttach()
  - Add detailed logging in BaseArcGame.onDetach()
  - Add logging in ArcGameScreen.initState() for GameWidget creation
  - Add logging in ArcGameScreen.dispose() for cleanup
  - _Requirements: 2.4_

- [ ] 9. Test and verify no attachment errors
  - Run game through complete victory flow
  - Run game through complete game over flow
  - Test pause/resume cycle multiple times
  - Test retry after game over
  - Verify no "Game attachment error" appears in logs
  - Verify GameWidget is created only once per screen
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5_

- [ ] 10. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.
