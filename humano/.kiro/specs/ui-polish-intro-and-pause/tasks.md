# Implementation Plan

- [x] 1. Remove continue button from arc intro screen


  - Remove the `Positioned` widget containing "TOCA PARA CONTINUAR" button from the Stack in `lib/screens/arc_intro_screen.dart`
  - Verify auto-continue timer still functions correctly
  - Ensure skip button remains visible and functional
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 2. Redesign tutorial button in pause menu


  - Replace `OutlinedButton` with `TextButton` for tutorial option in `lib/game/ui/pause_menu.dart`
  - Apply subtle styling: no border, no background, muted grey color, smaller font
  - Reduce padding to minimize visual footprint
  - Maintain proper spacing between menu items
  - Ensure callback functionality remains intact
  - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 3. Verify UI changes



  - Test arc intro screen displays correctly without continue button
  - Test auto-continue triggers after 2 seconds
  - Test skip button works on arc intro screen
  - Test pause menu displays with subtle tutorial button
  - Test all pause menu buttons remain functional
  - Verify visual hierarchy is improved
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 2.3, 2.4, 2.5_
