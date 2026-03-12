# Implementation Plan

- [x] 1. Add multiplayer button to MenuScreen


  - Modify the `_handleMenuSelection` method to handle case 3 (MULTIPLAYER) by navigating to MultiplayerLobbyScreen
  - Add the multiplayer button below the PLAY button in the Center widget using `_buildSecondaryButton`
  - Import MultiplayerLobbyScreen if not already imported
  - _Requirements: 1.1, 1.2, 1.4_



- [ ] 2. Remove multiplayer button from ArcSelectionScreen
  - Remove the Padding widget containing the "PROTOCOLO MULTIJUGADOR [BETA]" button


  - This button is located after the Expanded widget containing the PageView.builder
  - _Requirements: 1.3, 1.5_

- [x] 3. Write unit tests for button placement



  - Test that MenuScreen contains the multiplayer button widget
  - Test that ArcSelectionScreen does not contain the multiplayer button widget
  - Test that clicking the multiplayer button navigates to MultiplayerLobbyScreen
  - _Requirements: 1.1, 1.2, 1.3_

- [ ] 4. Checkpoint - Verify implementation
  - Ensure all tests pass, ask the user if questions arise.
