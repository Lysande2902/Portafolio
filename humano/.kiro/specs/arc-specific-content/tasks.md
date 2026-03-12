# Implementation Plan

- [x] 1. Create ArcContent data models


  - Create `lib/data/models/arc_content.dart` with all content model classes
  - Define `ArcContent`, `BriefingContent`, `GameOverContent`, `VictoryContent`, `StatConfig` classes
  - Ensure all fields are properly typed and documented
  - _Requirements: 5.1, 5.2, 5.3_



- [ ] 2. Extend ArcDataProvider with content data
  - [ ] 2.1 Add content map to ArcDataProvider


    - Add static `Map<String, ArcContent>` to store all arc content
    - Implement `getArcContent(String arcId)` method


    - Implement fallback method `_getDefaultContent(String arcId)` for missing content
    - _Requirements: 5.1, 5.2_



  - [ ] 2.2 Add Arco 1 (Gula) content
    - Define complete `ArcContent` for Gula with briefing, game over, and victory content
    - Include existing Gula-specific messages and statistics
    - _Requirements: 1.5, 2.4, 3.4_

  - [ ] 2.3 Add Arco 2 (Avaricia) content
    - Define complete `ArcContent` for Avaricia with all specific content


    - Include briefing with resource stealing mechanic explanation
    - Include game over messages about greed
    - Include victory cinematic lines about Valeria and doxing
    - Configure statistics: stolenItems, cashRegistersLooted, stolenSanity


    - _Requirements: 1.1, 1.2, 1.3, 1.4, 2.1, 2.2, 3.1, 3.2, 3.3, 4.1, 4.2, 4.3, 4.4_

- [ ] 3. Update Briefing Screen to use ArcContent
  - [ ] 3.1 Modify _ArcBriefingScreen to receive and use ArcContent
    - Get `ArcContent` from `ArcDataProvider` using arc.id


    - Replace hardcoded "MANUAL DE MISIÓN" header with arc-specific title
    - Display arc title and subtitle from content
    - _Requirements: 1.1, 1.2_

  - [ ] 3.2 Display arc-specific objective and mechanics
    - Show `briefing.objective` instead of generic "Recolecta 5 evidencias"


    - Add mechanic section with `briefing.mechanicTitle` and `briefing.mechanicDescription`
    - Display `briefing.controls` information
    - Add tip section with `briefing.tip`
    - _Requirements: 1.3, 1.4, 1.5_



  - [ ] 3.3 Style mechanic and tip sections
    - Create `_buildMechanicSection` widget for mechanic display
    - Create `_buildTipSection` widget for tip display
    - Use appropriate colors and styling (gold for Avaricia, etc.)
    - Ensure responsive layout for small screens


    - _Requirements: 1.3, 1.4_

- [ ] 4. Update Game Over Screen to use arc-specific content
  - [x] 4.1 Modify GameOverScreen to receive arcId parameter


    - Add `arcId` parameter to GameOverScreen constructor
    - Update all calls to GameOverScreen to pass arcId
    - Get `ArcContent` from `ArcDataProvider` using arcId
    - _Requirements: 2.1, 2.3_


  - [ ] 4.2 Display arc-specific game over messages
    - Show arc title from content (not hardcoded)
    - Display thematic messages from `gameOver.messages` list
    - Show `gameOver.flavorText` at the bottom
    - Remove any Gula-specific messages from Avaricia game over
    - _Requirements: 2.1, 2.2, 2.4_

- [ ] 5. Update Victory Cinematic to use arc-specific content
  - [ ] 5.1 Modify ArcVictoryCinematic to receive arcId and gameStats
    - Add `arcId` parameter to constructor
    - Add `gameStats` Map parameter for dynamic statistics
    - Get `ArcContent` from `ArcDataProvider` using arcId
    - _Requirements: 3.4, 4.5_

  - [ ] 5.2 Display arc-specific cinematic lines
    - Show cinematic lines from `victory.cinematicLines` list
    - Maintain existing animation timing and effects
    - Ensure proper formatting for censored text (████)
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

  - [x] 5.3 Display configured statistics

    - Iterate through `victory.stats` configuration
    - Extract values from `gameStats` Map using `stat.key`
    - Format values using `stat.formatter` function
    - Display with `stat.label` as the label
    - Only show statistics that exist in gameStats
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 6. Update GreedArcGame to track and pass statistics
  - [x] 6.1 Track cash registers looted


    - Add `cashRegistersLooted` counter to GreedArcGame
    - Increment counter when player loots a cash register
    - _Requirements: 3.2_

  - [x] 6.2 Pass statistics to victory screen


    - Create `gameStats` Map with all relevant statistics
    - Include: evidenceCollected, timeElapsed, sanityRemaining, stolenItems, cashRegistersLooted, stolenSanity
    - Pass gameStats to ArcVictoryCinematic on victory
    - _Requirements: 3.1, 3.2, 3.3_

- [ ] 7. Update BaseArcGame to support arcId in screens
  - [x] 7.1 Pass arcId to GameOverScreen

    - Modify `onGameOver()` method to pass arcId
    - Ensure all arc games have access to their arcId
    - _Requirements: 2.3_

  - [x] 7.2 Pass arcId and gameStats to VictoryCinematic

    - Modify `onVictory()` method to pass arcId and gameStats
    - Create method to collect gameStats from current game state
    - _Requirements: 3.4, 4.5_

- [x] 8. Add content for remaining arcs (Arcos 3-7)


  - Add placeholder or basic content for Arcos 3, 4, 5, 6, 7
  - Ensure each arc has at least default content to prevent errors
  - Can be expanded later with full content
  - _Requirements: 5.2_

- [x] 9. Verify Hyena enemy sprite display


  - Check that `AnimatedHyenaEnemySprite` is properly attached to `HyenaEnemy`
  - Verify LPC sprite animations are loading correctly
  - Ensure sprite is visible and not showing as rectangle
  - Debug any rendering issues with the sprite component
  - _Requirements: (Related to user's bug report about enemy appearing as rectangle)_

- [x] 10. Fix evidence positioning in Arco 2



  - Review evidence positions in `greed_arc_game.dart`
  - Ensure evidence items are not spawned inside obstacles
  - Test that all evidence items are accessible to the player
  - Adjust positions if needed based on obstacle layout
  - _Requirements: (Related to user's bug report about evidence in unreachable areas)_
