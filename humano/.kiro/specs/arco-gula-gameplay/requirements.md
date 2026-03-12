# Requirements Document - Arco 1: Gula

## Introduction

El Arco 1: Gula es el primer nivel jugable de CONDICIÓN: HUMANO. Este arco introduce al jugador a las mecánicas core del juego: movimiento 2D, sigilo, colisiones, sistema de enemigos con IA, y recolección de evidencias. El jugador debe escapar de un food court abandonado mientras es perseguido por Mateo [Cerdo], quien representa el pecado de Gula que el jugador causó al exponerlo en redes sociales.

Este arco establece el tono narrativo y mecánico para los 6 arcos restantes, por lo que debe ser funcional, pulido y servir como base reutilizable para futuros niveles.

## Glossary

- **Game_System**: El sistema principal de juego construido con Flutter y Flame Engine
- **Player_Character**: El avatar controlado por el usuario (P-L-A-Y-E-R)
- **Enemy_AI**: Sistema de inteligencia artificial que controla a Mateo [Cerdo]
- **Evidence_Item**: Coleccionable digital que revela fragmentos de la historia
- **Sanity_Meter**: Sistema de "Cordura Digital" que representa la salud del jugador mediante estática visual
- **Collision_System**: Sistema que detecta intersecciones entre objetos del juego
- **Game_Scene**: Escenario 2D donde ocurre el gameplay (food court abandonado)
- **Obstacle**: Objeto del escenario que bloquea el movimiento o la visión
- **Hiding_Spot**: Área donde el jugador puede ocultarse del enemigo
- **Victory_Condition**: Estado que se alcanza al completar el arco exitosamente
- **Game_Over_State**: Estado que se alcanza cuando el jugador pierde toda su cordura

## Requirements

### Requirement 1: Player Movement and Controls

**User Story:** Como jugador, quiero controlar el movimiento de mi personaje de forma fluida y responsiva, para poder navegar el escenario y escapar del enemigo.

#### Acceptance Criteria

1. WHEN the player touches the virtual joystick on mobile OR presses WASD keys on desktop, THE Game_System SHALL move the Player_Character in the corresponding direction at a speed of 150 pixels per second with tolerance of plus or minus 10 pixels per second.

2. WHEN the Player_Character moves, THE Game_System SHALL play a walking animation that cycles through 4 sprite frames at 8 frames per second.

3. WHEN the Player_Character stops moving, THE Game_System SHALL display the idle animation within 100 milliseconds.

4. WHILE the Player_Character is moving, THE Game_System SHALL update the camera position to keep the Player_Character centered on screen with smooth interpolation over 0.2 seconds.

5. WHEN the Player_Character collides with an Obstacle, THE Game_System SHALL prevent further movement in that direction while allowing movement in perpendicular directions.

### Requirement 2: Collision Detection System

**User Story:** Como jugador, quiero que mi personaje interactúe físicamente con el entorno, para que el mundo del juego se sienta sólido y realista.

#### Acceptance Criteria

1. THE Game_System SHALL detect collisions between the Player_Character and all Obstacles using rectangular bounding boxes with checks performed every frame.

2. WHEN a collision is detected between the Player_Character and an Obstacle, THE Game_System SHALL prevent the Player_Character from overlapping the Obstacle by stopping movement in the collision direction.

3. THE Game_System SHALL detect when the Player_Character enters a Hiding_Spot area using rectangular overlap detection.

4. WHEN the Player_Character enters a Hiding_Spot, THE Game_System SHALL mark the player as hidden within 50 milliseconds.

5. THE Game_System SHALL detect collisions between the Enemy_AI and Obstacles to prevent the enemy from passing through walls.

### Requirement 3: Enemy AI - Mateo [Cerdo]

**User Story:** Como jugador, quiero enfrentar un enemigo inteligente y amenazante, para sentir tensión y desafío durante el gameplay.

#### Acceptance Criteria

1. THE Enemy_AI SHALL patrol between 3 predefined waypoints in the Game_Scene, moving at 100 pixels per second with tolerance of plus or minus 10 pixels per second.

2. WHEN the Enemy_AI reaches a waypoint, THE Enemy_AI SHALL wait for 2 seconds with tolerance of plus or minus 0.5 seconds before moving to the next waypoint.

3. WHEN the Player_Character enters within a 200 pixel radius of the Enemy_AI AND the player is not hidden, THE Enemy_AI SHALL detect the player and change to chase mode within 200 milliseconds.

4. WHILE in chase mode, THE Enemy_AI SHALL move toward the Player_Character at 120 pixels per second with tolerance of plus or minus 10 pixels per second.

5. WHEN the Enemy_AI collides with the Player_Character, THE Game_System SHALL trigger the Game_Over_State within 100 milliseconds.

6. WHEN the Player_Character exits the 200 pixel detection radius OR enters a Hiding_Spot, THE Enemy_AI SHALL return to patrol mode after 3 seconds with tolerance of plus or minus 0.5 seconds.

### Requirement 4: Sanity System (Cordura Digital)

**User Story:** Como jugador, quiero ver un indicador visual de mi "salud" que refleje el peligro, para saber cuándo estoy en riesgo.

#### Acceptance Criteria

1. THE Game_System SHALL initialize the Sanity_Meter at 100 percent when the arco begins.

2. WHILE the Player_Character is within 150 pixels of the Enemy_AI, THE Game_System SHALL decrease the Sanity_Meter by 5 percent per second.

3. WHILE the Player_Character is hidden in a Hiding_Spot, THE Game_System SHALL increase the Sanity_Meter by 10 percent per second up to a maximum of 100 percent.

4. WHEN the Sanity_Meter value changes, THE Game_System SHALL update the visual static overlay effect with intensity proportional to sanity loss within 100 milliseconds.

5. WHEN the Sanity_Meter reaches 0 percent, THE Game_System SHALL trigger the Game_Over_State within 200 milliseconds.

### Requirement 5: Evidence Collection

**User Story:** Como jugador, quiero encontrar y recolectar evidencias digitales, para descubrir la historia detrás del arco y desbloquear contenido.

#### Acceptance Criteria

1. THE Game_System SHALL place 3 Evidence_Items in fixed locations throughout the Game_Scene.

2. WHEN the Player_Character moves within 50 pixels of an Evidence_Item, THE Game_System SHALL display a visual indicator (glowing effect) on the Evidence_Item.

3. WHEN the player taps the action button while within 50 pixels of an Evidence_Item, THE Game_System SHALL collect the Evidence_Item and remove it from the scene within 200 milliseconds.

4. WHEN an Evidence_Item is collected, THE Game_System SHALL display a notification popup for 2 seconds showing the evidence preview.

5. THE Game_System SHALL track the number of Evidence_Items collected and display the count in the UI (format: "X/3").

### Requirement 6: Hiding Mechanic

**User Story:** Como jugador, quiero poder esconderme del enemigo en lugares específicos, para tener una estrategia de supervivencia además de solo correr.

#### Acceptance Criteria

1. THE Game_System SHALL designate 5 Hiding_Spots in the Game_Scene marked with visual cues (darker areas, furniture).

2. WHEN the Player_Character enters a Hiding_Spot area, THE Game_System SHALL display a "Hide" button on the UI within 100 milliseconds.

3. WHEN the player taps the "Hide" button, THE Game_System SHALL make the Player_Character semi-transparent (50 percent opacity) and mark them as hidden.

4. WHILE the Player_Character is hidden, THE Enemy_AI SHALL not detect the player even if within detection radius.

5. WHEN the player taps the screen to move OR presses any movement key while hidden, THE Game_System SHALL exit hiding mode and restore full opacity within 100 milliseconds.

### Requirement 7: Level Completion

**User Story:** Como jugador, quiero alcanzar un objetivo claro para completar el arco, para tener un sentido de progresión y logro.

#### Acceptance Criteria

1. THE Game_System SHALL place an exit door at the far end of the Game_Scene marked with a glowing indicator.

2. WHEN the Player_Character reaches the exit door, THE Game_System SHALL check if the Victory_Condition is met.

3. THE Victory_Condition SHALL be met when the Player_Character reaches the exit door regardless of Evidence_Items collected.

4. WHEN the Victory_Condition is met, THE Game_System SHALL trigger the victory sequence within 200 milliseconds.

5. THE Game_System SHALL display a completion screen showing collected Evidence_Items count, time taken, and a "Continue" button.

### Requirement 8: Game Over and Retry

**User Story:** Como jugador, quiero poder reintentar el arco si fallo, para aprender de mis errores y mejorar mi estrategia.

#### Acceptance Criteria

1. WHEN the Game_Over_State is triggered, THE Game_System SHALL pause all gameplay within 100 milliseconds.

2. WHEN the Game_Over_State occurs, THE Game_System SHALL display a game over screen with a message from Mateo within 500 milliseconds.

3. THE Game_System SHALL provide two buttons on the game over screen: "Retry" and "Exit to Menu".

4. WHEN the player taps "Retry", THE Game_System SHALL restart the arco from the beginning with all Evidence_Items reset within 2 seconds.

5. WHEN the player taps "Exit to Menu", THE Game_System SHALL return to the main menu screen within 1 second.

### Requirement 9: Scene and Environment

**User Story:** Como jugador, quiero explorar un escenario visualmente coherente y atmosférico, para sentirme inmerso en la narrativa del juego.

#### Acceptance Criteria

1. THE Game_System SHALL render the Game_Scene as a 2D side-scrolling environment using procedurally generated shapes and rectangles.

2. THE Game_Scene SHALL measure 3000 pixels in width and 1000 pixels in height.

3. THE Game_System SHALL display the food court theme using colored rectangles and shapes to represent tables, chairs, food counters, and obstacles.

4. THE Game_System SHALL use a color palette of reds, oranges, and dark browns to represent the Gula theme without requiring image assets.

5. THE Game_System SHALL render all visual elements at 60 frames per second with tolerance of minus 5 frames per second on target devices.

### Requirement 10: Integration with Existing Systems

**User Story:** Como jugador, quiero que el arco se integre perfectamente con el resto del juego, para tener una experiencia cohesiva.

#### Acceptance Criteria

1. WHEN the arco is completed, THE Game_System SHALL mark Arc 1 as completed in the player's local progress data using the existing ArcProgressProvider.

2. WHEN the arco is completed, THE Game_System SHALL unlock the collected Evidence_Items in the Archive screen using the existing EvidenceProvider.

3. WHEN the arco is completed, THE Game_System SHALL award 100 coins to the player's inventory using the existing StoreProvider.

4. WHEN the player exits the arco, THE Game_System SHALL save the completion status locally and return to the Arc Selection screen.

5. THE Game_System SHALL load the player's existing settings (volume, controls) from the SettingsProvider when the arco starts.
