# Implementation Plan - Arco 6: Pereza

- [x] 1. Create Sloth arc directory structure and base game class


  - Create `lib/game/arcs/sloth/` directory
  - Create `sloth_arc_game.dart` extending BaseArcGame
  - Configure arc constants (arcId, totalEvidence, coinsReward)
  - Implement setupScene(), setupPlayer(), setupEnemy(), setupCollectibles() methods
  - _Requirements: 1.1, 8.1_



- [ ] 2. Implement SlowPlayerComponent with reduced speed
  - Create `lib/game/arcs/sloth/components/slow_player_component.dart`
  - Extend PlayerComponent from gluttony arc
  - Override speed property to 90.0 (60% of normal 150.0)


  - Override animationSpeed property to 0.7 (70% of normal)
  - _Requirements: 1.2, 7.1, 7.2, 7.3, 8.4_

- [ ] 3. Implement SlothEnemyComponent with very slow movement
  - Create `lib/game/arcs/sloth/components/sloth_enemy_component.dart`
  - Extend EnemyComponent from gluttony arc
  - Override patrolSpeed to 50.0 (40% of normal 100.0)
  - Override chaseSpeed to 80.0 (50% of normal 120.0)


  - Override detectionRadius to 250.0
  - Override waypointWaitTime to 3.0 seconds
  - Override chaseLostTimeout to 8.0 seconds
  - _Requirements: 1.3, 1.4, 2.1, 2.2, 2.4, 2.5, 8.3_

- [ ] 4. Create SlothScene with blue-gray color palette
  - Create `lib/game/arcs/sloth/sloth_scene.dart`
  - Define blue-gray color constants (backgroundColor, wallColor, obstacleColor, floorColor, accentColor)
  - Reuse scene generation logic from GluttonyScene
  - Apply new color palette to all scene elements
  - Position 5 evidence spawn points
  - Position enemy waypoints for patrol
  - _Requirements: 4.1, 8.2_

- [ ] 5. Configure modified sanity system parameters
  - Modify sanity drain rate near enemy to 0.02 (from 0.05)
  - Modify sanity drain rate on contact to 0.03 (from 0.05)
  - Keep regeneration rate at 0.005
  - _Requirements: 2.3, 6.2, 6.3, 6.5_

- [x] 6. Implement visual effects for sloth atmosphere


  - Modify VignetteOverlay to use 60% base opacity with blue-gray tint
  - Increase vignette to 80% opacity when sanity below 30%
  - Modify FogParticleComponent to spawn at 1 particle per 2 seconds
  - Apply blue-gray color to fog particles
  - Reduce fog particle movement speed to 50%
  - _Requirements: 4.2, 4.3, 4.4, 4.5_

- [ ] 7. Add sloth evidence data
  - Create evidence data for 5 sloth-themed evidence items
  - Add evidence titles and descriptions related to procrastination
  - Register evidence in EvidenceProvider
  - _Requirements: 3.1, 3.2_

- [ ] 8. Implement evidence collection system
  - Spawn 5 EvidenceComponent instances in SlothScene
  - Implement collection detection within 50 pixels
  - Display collection prompt when player is near
  - Increment evidence counter on collection
  - Play collection sound at 80% speed
  - Unlock exit door when all 5 collected
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ] 9. Implement exit door and victory condition
  - Reuse ExitDoorComponent from base system
  - Activate door when all 5 evidence collected
  - Display exit prompt within 60 pixels
  - Trigger victory screen on interaction
  - Save arc completion status
  - Award 100 coins


  - Unlock next arc in progression
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [ ] 10. Configure game over conditions
  - Trigger game over when sanity reaches 0%
  - Trigger game over when enemy catches player
  - Display GameOverScreen with retry and exit options




  - _Requirements: 6.4_

- [ ] 11. Integrate with arc selection system
  - Add Arco 6 entry to arc data provider
  - Set title: "Arco 6: Pereza"
  - Set subtitle: "La Procrastinación Infinita"
  - Set difficulty: 2 (Easy-Medium)
  - Set estimated time: "8-10 min"
  - Set required arc: arc_1_gluttony
  - _Requirements: 8.1_

- [ ] 12. Wire up navigation and screen integration
  - Update ArcGameScreen to support sloth arc
  - Pass arcId 'arc_6_sloth' from arc selection
  - Ensure proper navigation back to menu
  - Ensure proper navigation to victory/game over screens
  - _Requirements: 8.5_

- [ ]* 13. Test gameplay balance and feel
  - Verify slow-motion feel is consistent
  - Verify player can complete arc in 8-10 minutes
  - Verify difficulty is appropriate (not too easy/hard)
  - Adjust speed parameters if needed
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [ ]* 14. Test all game systems integration
  - Verify collision detection works correctly
  - Verify sanity system drains and regenerates properly
  - Verify enemy AI patrols and chases correctly
  - Verify evidence collection works
  - Verify exit door unlocks and triggers victory
  - Verify game over triggers correctly
  - Verify progress saves to ArcProgressProvider
  - Verify evidence unlocks in EvidenceProvider
  - _Requirements: 2.1, 2.2, 2.3, 3.1, 3.2, 3.3, 5.1, 5.2, 5.3, 5.4, 6.2, 6.3, 6.4_
