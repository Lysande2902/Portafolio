# Implementation Plan - Arco 1: Gula

## Overview

Este plan de implementación desglosa el desarrollo del Arco 1: Gula en tareas incrementales y manejables. Cada tarea construye sobre las anteriores, asegurando progreso continuo hacia un nivel jugable funcional.

**Duración estimada:** 6-7 días de desarrollo
**Prioridad:** Alta (primer nivel jugable del juego)

---

## Tasks

- [x] 1. Setup project structure and base classes



  - Create directory structure for game module (`lib/game/`)
  - Create base classes: `BaseArcGame`, `GameComponent`
  - Setup Flame Engine dependencies in `pubspec.yaml`
  - Create `ArcGameScreen` Flutter wrapper widget





  - _Requirements: 10.5_

- [ ] 2. Implement player movement and controls
- [ ] 2.1 Create PlayerComponent with basic rendering
  - Implement `PlayerComponent` class extending Flame's `PositionComponent`


  - Add rectangular hitbox (40x60 pixels, blue color)
  - Add position and velocity properties
  - Render player as colored rectangle
  - _Requirements: 1.1, 1.2, 1.3_



- [ ] 2.2 Implement movement input handling
  - Create `InputController` class for processing input





  - Implement virtual joystick for mobile (using `flame_joystick` package)
  - Implement WASD keyboard controls for desktop testing
  - Connect input to player velocity (150 px/s)
  - _Requirements: 1.1, 1.4_



- [ ] 2.3 Add camera following behavior
  - Configure Flame camera to follow player




  - Implement smooth camera interpolation (0.2s lerp)
  - Set camera bounds to scene size (3000x1000)
  - _Requirements: 1.4_

- [x] 3. Implement collision system

- [ ] 3.1 Setup collision detection infrastructure
  - Add `HasCollisionDetection` mixin to game class
  - Create collision layer enum
  - Add `RectangleHitbox` to PlayerComponent
  - _Requirements: 2.1, 2.2_


- [ ] 3.2 Create obstacle components and collision response
  - Create `ObstacleComponent` class with hitbox
  - Implement collision callback in PlayerComponent



  - Add collision response (stop movement in collision direction)
  - Test player-obstacle collisions
  - _Requirements: 1.5, 2.2, 2.5_

- [ ] 4. Generate procedural scene
- [x] 4.1 Create SceneComponent class

  - Implement `GluttonyScene` class
  - Define color palette (reds, oranges, browns)
  - Create background rectangle (3000x1000, dark red)
  - _Requirements: 9.1, 9.2, 9.4_

- [x] 4.2 Generate obstacles and decorations

  - Create helper methods: `createObstacle()`, `createDecoration()`
  - Generate walls (top, bottom, side barriers)
  - Generate food court elements (tables, counters) as colored rectangles
  - Position obstacles to create pathways
  - _Requirements: 9.3_


- [ ] 4.3 Integrate scene with game
  - Add scene to game world in `onLoad()`
  - Verify all obstacles have collision hitboxes




  - Test player navigation through scene
  - _Requirements: 9.5_

- [ ] 5. Implement enemy AI (Mateo)
- [ ] 5.1 Create EnemyComponent with basic rendering
  - Implement `EnemyComponent` class

  - Add rectangular hitbox (50x70 pixels, red color)
  - Add direction indicator (small triangle)
  - Position enemy in scene
  - _Requirements: 3.1_


- [ ] 5.2 Implement patrol behavior
  - Define 3 waypoints in scene




  - Implement waypoint navigation logic
  - Add waiting behavior at waypoints (2s pause)
  - Cycle through waypoints continuously
  - _Requirements: 3.1, 3.2_

- [x] 5.3 Implement player detection and chase

  - Add detection radius check (200 pixels)
  - Implement chase behavior (move toward player at 120 px/s)
  - Add state machine (patrol/chase/waiting/returning)
  - Respect hiding status (don't detect hidden player)
  - _Requirements: 3.3, 3.4, 3.6_


- [ ] 5.4 Implement game over on collision
  - Add collision detection between enemy and player



  - Trigger game over state when collision occurs
  - _Requirements: 3.5_

- [ ] 6. Implement sanity system
- [ ] 6.1 Create SanitySystem class
  - Implement `SanitySystem` with current sanity property (0.0-1.0)

  - Add drain logic (5% per second near enemy)
  - Add regeneration logic (10% per second when hiding)
  - Add clamping to valid range
  - _Requirements: 4.1, 4.2, 4.3_

- [x] 6.2 Add visual static effect

  - Create static overlay widget
  - Calculate intensity based on sanity level
  - Update overlay in real-time
  - _Requirements: 4.4_




- [ ] 6.3 Implement game over on zero sanity
  - Check sanity level each frame
  - Trigger game over when sanity reaches 0
  - _Requirements: 4.5_

- [x] 7. Implement hiding mechanic

- [ ] 7.1 Create HidingSpotComponent
  - Implement `HidingSpotComponent` class
  - Render as dark gray rectangle with dashed border
  - Add area detection hitbox
  - Place 5 hiding spots in scene

  - _Requirements: 6.1_

- [ ] 7.2 Implement hide/unhide functionality
  - Detect when player enters hiding spot area
  - Show "Hide" button in UI when near hiding spot
  - Implement hide action (set player opacity to 50%, mark as hidden)
  - Implement unhide on movement

  - _Requirements: 6.2, 6.3, 6.5_

- [ ] 7.3 Integrate hiding with enemy AI
  - Modify enemy detection to check player hidden status
  - Enemy should not detect hidden player


  - _Requirements: 6.4_


- [ ] 8. Implement evidence collection
- [ ] 8.1 Create EvidenceComponent
  - Implement `EvidenceComponent` class
  - Render as yellow/gold square (30x30 pixels)
  - Add pulsing glow animation
  - Place 3 evidence items in scene

  - _Requirements: 5.1_

- [ ] 8.2 Implement collection mechanic
  - Detect when player is near evidence (50 pixel range)
  - Show visual indicator when in range
  - Collect evidence on action button press
  - Remove evidence from scene when collected

  - _Requirements: 5.2, 5.3_




- [ ] 8.3 Integrate with EvidenceProvider
  - Define 3 evidence data objects for Arco 1
  - Call `EvidenceProvider.unlockEvidence()` on collection
  - Show notification popup with evidence preview (2s duration)
  - Update evidence counter in UI
  - _Requirements: 5.4, 5.5, 10.2_


- [ ] 9. Implement victory condition
- [ ] 9.1 Create ExitDoorComponent
  - Implement `ExitDoorComponent` class

  - Render as green rectangle (60x100 pixels) with bright outline
  - Add pulsing glow effect
  - Position at far end of scene
  - _Requirements: 7.1_

- [x] 9.2 Implement victory trigger

  - Detect when player reaches exit door
  - Check victory condition (player at door)
  - Trigger victory sequence
  - _Requirements: 7.2, 7.3, 7.4_


- [ ] 9.3 Create victory screen
  - Implement `VictoryScreen` widget
  - Display "Arco Completado" title
  - Show statistics: evidence collected, time taken, coins earned
  - Add "Continue" button




  - Add slide-up animation
  - _Requirements: 7.5_

- [x] 9.4 Integrate with progress system

  - Call `ArcProgressProvider.completeArc()` on victory
  - Award 100 coins via `StoreProvider`
  - Save completion status locally
  - Navigate back to Arc Selection screen on continue
  - _Requirements: 10.1, 10.3, 10.4_


- [ ] 10. Implement game over and retry
- [ ] 10.1 Create GameOverScreen widget
  - Implement `GameOverScreen` widget
  - Display dark overlay (80% opacity)
  - Show message from Mateo: "¿Valió la pena el meme?"

  - Add "Retry" and "Exit to Menu" buttons
  - Add fade-in animation
  - _Requirements: 8.1, 8.2_

- [ ] 10.2 Implement retry functionality
  - Reset all game state on retry
  - Respawn player at start position
  - Reset enemy to patrol
  - Restore all evidence items
  - Reset sanity to 100%
  - _Requirements: 8.4_

- [ ] 10.3 Implement exit to menu
  - Navigate back to main menu on exit button press
  - Clean up game resources
  - _Requirements: 8.5_

- [ ] 11. Implement game HUD
- [ ] 11.1 Create sanity bar widget
  - Implement `SanityBar` widget
  - Display as progress bar (top-left)
  - Color code: green (100-70%), yellow (70-30%), red (30-0%)
  - Update in real-time
  - _Requirements: 4.4_

- [ ] 11.2 Create evidence counter widget
  - Display evidence count as "📄 X/3" (top-right)
  - Add glow effect when evidence collected
  - _Requirements: 5.5_

- [ ] 11.3 Create action button
  - Implement context-sensitive action button (bottom-right)
  - Show "Hide" text when near hiding spot
  - Show "Collect" text when near evidence
  - Circular button with icon
  - _Requirements: 6.2, 5.3_

- [ ] 11.4 Create pause button
  - Add pause button (top-center, hamburger icon)
  - Implement pause overlay with resume/exit options
  - Pause game logic when active
  - _Requirements: 10.5_

- [ ] 11.5 Assemble complete HUD
  - Create `GameHUD` widget combining all UI elements
  - Add as overlay to Flame game
  - Ensure proper z-ordering
  - Test on mobile and desktop
  - _Requirements: 10.5_

- [ ] 12. Integration and polish
- [ ] 12.1 Integrate with settings
  - Load volume settings from `SettingsProvider` on game start
  - Apply control preferences (virtual joystick visibility)
  - _Requirements: 10.5_

- [ ] 12.2 Add error handling
  - Wrap provider calls in try-catch blocks
  - Show error notifications on save failures
  - Implement graceful degradation
  - _Requirements: Design - Error Handling_

- [ ] 12.3 Performance optimization
  - Profile game performance
  - Ensure 60 FPS on target devices
  - Optimize collision checks if needed
  - Reduce overdraw where possible
  - _Requirements: 9.5_

- [ ] 12.4 Final testing and bug fixes
  - Complete manual testing checklist from design doc
  - Fix any discovered bugs
  - Test on multiple devices (Android, iOS if available)
  - Verify all requirements are met
  - _Requirements: All_

---

## Notes

- Tasks are designed to be completed sequentially for best results
- Each task builds on previous tasks
- Testing should be done after each major task
- Focus on functionality first, polish later
- Estimated time: 1-2 days per major section (2-5)
