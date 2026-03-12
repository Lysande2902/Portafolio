# Implementation Plan - Arco 7: Ira

- [x] 1. Create Wrath arc directory structure and base game class


  - Create `lib/game/arcs/wrath/` directory
  - Create `wrath_arc_game.dart` extending BaseArcGame
  - Configure arc constants (arcId, totalEvidence, coinsReward = 150)
  - Implement setupScene(), setupPlayer(), setupEnemy(), setupCollectibles() methods
  - _Requirements: 1.1, 8.1_



- [ ] 2. Implement RagingBullEnemy with extreme aggression
  - Create `lib/game/arcs/wrath/components/raging_bull_enemy.dart`
  - Extend EnemyComponent from gluttony arc
  - Set isAlwaysEnraged = true
  - Override patrolSpeed to 200.0 (200% of normal 100.0)
  - Override chaseSpeed to 300.0 (250% of normal 120.0)
  - Override detectionRadius to 400.0
  - Override detectionDelay to 0.0 (instant detection)
  - Override chaseLostTimeout to double.infinity (never gives up)
  - Override waypointWaitTime to 0.0 (no waiting)
  - Override turnSpeed to 10.0 (fast turns)
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 2.1, 2.2, 8.3_

- [ ] 3. Implement charge and search behaviors for enemy
  - Add lastKnownPlayerPosition tracking
  - Implement onLosePlayer() method to start charge
  - Implement chargeBehavior() to move toward last known position for 3 seconds
  - Implement performAreaSearch() for circular search pattern
  - _Requirements: 2.4, 2.5, 9.4, 9.5_

- [ ] 4. Implement ParticleTrailComponent for enemy
  - Create `lib/game/arcs/wrath/components/particle_trail_component.dart`
  - Create Particle class with position, color, lifetime, age
  - Spawn 20 red particles per second behind enemy
  - Update and render particles with fade-out effect
  - Remove dead particles (lifetime 0.5 seconds)


  - Add trail to RagingBullEnemy in onLoad()
  - _Requirements: 4.3, 9.3_

- [ ] 5. Create WrathScene with bright red color palette
  - Create `lib/game/arcs/wrath/wrath_scene.dart`
  - Define bright red color constants (backgroundColor, wallColor, obstacleColor, floorColor, accentColor)
  - Reuse scene generation logic from GluttonyScene
  - Apply new red color palette to all scene elements
  - Position 4 evidence spawn points
  - Position only 3 hiding spots (reduced for difficulty)
  - Position enemy waypoints for patrol
  - _Requirements: 4.1, 8.2_

- [ ] 6. Implement ScreenShakeEffect component
  - Create `lib/game/arcs/wrath/components/screen_shake_effect.dart`
  - Add intensity property (0.0 to 1.0)
  - Calculate shake offset based on intensity and random values
  - Apply shake to camera position
  - Add to WrathArcGame in onLoad()
  - Update intensity in game update() based on enemy proximity (0-200 pixels)
  - Increase intensity when sanity is low
  - _Requirements: 4.2, 4.4_

- [ ] 7. Implement RedFlashEffect component
  - Create `lib/game/arcs/wrath/components/red_flash_effect.dart`
  - Add opacity property and isPulsing flag
  - Implement pulse() method to trigger flash
  - Update opacity to fade in to 30% then fade out
  - Render red rectangle overlay with current opacity
  - Add to WrathArcGame in onLoad()
  - Trigger pulse when enemy starts chasing
  - _Requirements: 4.5_

- [x] 8. Configure aggressive sanity system parameters


  - Modify sanity drain rate near enemy (200 pixels) to 0.08 (from 0.05)
  - Modify sanity drain rate on contact to 0.15 (from 0.05)
  - Increase regeneration rate when hiding to 0.01 (from 0.005)
  - _Requirements: 6.2, 6.3, 6.5_

- [ ] 9. Add wrath evidence data
  - Create evidence data for 4 wrath-themed evidence items
  - Add evidence titles and descriptions related to rage and anger
  - Register evidence in EvidenceProvider
  - _Requirements: 3.1, 3.2_

- [ ] 10. Implement evidence collection with enemy alert
  - Spawn 4 EvidenceComponent instances in WrathScene
  - Implement collection detection within 50 pixels
  - Display collection prompt when player is near
  - Increment evidence counter on collection
  - Alert RagingBullEnemy and move toward collection location
  - Unlock exit door when all 4 collected
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 11. Implement exit door and victory condition
  - Reuse ExitDoorComponent from base system
  - Activate door when all 4 evidence collected
  - Display exit prompt within 60 pixels
  - Trigger victory screen on interaction
  - Save arc completion status
  - Award 150 coins (higher reward for difficulty)
  - Unlock achievement for completing hardest arc
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_



- [ ] 12. Configure game over conditions
  - Trigger game over when sanity reaches 0%
  - Trigger game over when enemy catches player
  - Display GameOverScreen with message "La ira te consumió"
  - Provide retry and exit options
  - _Requirements: 6.4_




- [ ] 13. Integrate with arc selection system
  - Add Arco 7 entry to arc data provider
  - Set title: "Arco 7: Ira"
  - Set subtitle: "El Rage Quit"
  - Set difficulty: 5 (Hardest)
  - Set estimated time: "10-15 min"
  - Set required arc: arc_1_gluttony
  - _Requirements: 8.1_

- [ ] 14. Wire up navigation and screen integration
  - Update ArcGameScreen to support wrath arc
  - Pass arcId 'arc_7_wrath' from arc selection
  - Ensure proper navigation back to menu
  - Ensure proper navigation to victory/game over screens
  - _Requirements: 8.5_

- [ ]* 15. Implement special rage behaviors
  - Add destructible obstacle system
  - Implement obstacle destruction on enemy collision
  - Add angry sound effects every 2 seconds during chase
  - Add destruction particle effects
  - _Requirements: 9.1, 9.2_

- [ ]* 16. Test gameplay balance and difficulty
  - Verify game is challenging but beatable
  - Verify hiding spots provide adequate safety
  - Verify player can complete arc in 10-15 minutes
  - Adjust enemy speed or detection if too hard/easy
  - Test with multiple players for feedback
  - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2_

- [ ]* 17. Test all visual effects and performance
  - Verify screen shake feels good and not nauseating
  - Verify red flash is visible but not annoying
  - Verify particle trail renders correctly
  - Verify performance stays at 60 FPS
  - Optimize particle count if needed
  - Test on mid-range devices
  - _Requirements: 4.2, 4.3, 4.4, 4.5_

- [ ]* 18. Test all game systems integration
  - Verify collision detection works correctly
  - Verify aggressive sanity system drains faster
  - Verify enemy AI is always aggressive
  - Verify evidence collection alerts enemy
  - Verify exit door unlocks and triggers victory
  - Verify game over triggers correctly
  - Verify progress saves to ArcProgressProvider
  - Verify 150 coins are awarded
  - Verify achievement unlocks
  - _Requirements: 2.1, 2.2, 2.3, 3.1, 3.2, 3.5, 5.1, 5.2, 5.3, 5.4, 5.5, 6.2, 6.3, 6.4_
