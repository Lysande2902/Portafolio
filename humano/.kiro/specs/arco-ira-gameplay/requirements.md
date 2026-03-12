# Requirements Document - Arco 7: Ira (Wrath)

## Introduction

El Arco 7: Ira representa el séptimo pecado capital en el juego "Humano". Este arco implementa una mecánica de juego donde el enemigo (Toro) está constantemente enfurecido, moviéndose a velocidades extremadamente altas y siendo extremadamente agresivo. El jugador debe ser rápido y estratégico para sobrevivir en un ambiente de furia constante. La atmósfera es intensa, roja brillante y caótica.

## Glossary

- **WrathArcGame**: El sistema de juego principal que gestiona el Arco de Ira
- **WrathScene**: La escena de juego que contiene todos los componentes del nivel de Ira
- **RagingBullEnemy**: El componente del enemigo toro que está siempre enfurecido
- **PlayerComponent**: El componente del jugador con velocidad normal
- **GameSystem**: El sistema base que gestiona el estado del juego
- **EvidenceSystem**: El sistema que gestiona la recolección de evidencias
- **SanitySystem**: El sistema que gestiona la cordura del jugador

## Requirements

### Requirement 1

**User Story:** Como jugador, quiero experimentar un arco donde el enemigo es extremadamente agresivo y rápido, para sentir la presión constante de la ira.

#### Acceptance Criteria

1. WHEN the WrathArcGame initializes, THE RagingBullEnemy SHALL be in permanent rage mode
2. WHILE the RagingBullEnemy is active, THE RagingBullEnemy SHALL move at 200% of normal patrol speed
3. WHILE the RagingBullEnemy is chasing, THE RagingBullEnemy SHALL move at 250% of normal chase speed
4. WHEN the RagingBullEnemy detects the player, THE RagingBullEnemy SHALL immediately start chasing without delay
5. WHILE the RagingBullEnemy is chasing, THE RagingBullEnemy SHALL never give up pursuit until player hides or dies

### Requirement 2

**User Story:** Como jugador, quiero que el enemigo enfurecido tenga un rango de detección muy amplio, para crear una sensación de peligro constante.

#### Acceptance Criteria

1. WHEN the RagingBullEnemy is active, THE RagingBullEnemy SHALL have a detection radius of 400 pixels
2. WHEN the player enters the detection radius, THE RagingBullEnemy SHALL detect the player instantly
3. WHILE the player is visible, THE RagingBullEnemy SHALL maintain line of sight tracking
4. WHEN the player hides, THE RagingBullEnemy SHALL search the area for 15 seconds before returning to patrol
5. WHILE the RagingBullEnemy is searching, THE RagingBullEnemy SHALL move at 150% of normal speed

### Requirement 3

**User Story:** Como jugador, quiero recolectar evidencias mientras evito un enemigo extremadamente peligroso, para completar el arco con alta dificultad.

#### Acceptance Criteria

1. WHEN the WrathScene initializes, THE EvidenceSystem SHALL spawn 4 evidence items in the level
2. WHEN the player collects an evidence item, THE EvidenceSystem SHALL increment the evidence counter by 1
3. WHEN the player collects all 4 evidence items, THE GameSystem SHALL unlock the exit door
4. WHILE the player is near an evidence item within 50 pixels, THE GameSystem SHALL display a collection prompt
5. WHEN the player collects an evidence item, THE RagingBullEnemy SHALL be alerted and move toward the collection location

### Requirement 4

**User Story:** Como jugador, quiero que la atmósfera visual refleje la ira, para una experiencia inmersiva del pecado.

#### Acceptance Criteria

1. WHEN the WrathScene loads, THE WrathScene SHALL apply a bright red color filter to the entire scene
2. WHILE the game is running, THE WrathScene SHALL display screen shake effects when enemy is nearby
3. WHILE the RagingBullEnemy is visible, THE WrathScene SHALL display red particle trails behind the enemy
4. WHEN the player's sanity drops below 30%, THE WrathScene SHALL increase screen shake intensity
5. WHILE the RagingBullEnemy is chasing, THE WrathScene SHALL pulse the screen with red flashes

### Requirement 5

**User Story:** Como jugador, quiero escapar del nivel cuando complete los objetivos, para progresar en el juego.

#### Acceptance Criteria

1. WHEN the player collects all 4 evidence items, THE GameSystem SHALL activate the exit door
2. WHEN the player reaches the exit door, THE GameSystem SHALL display an exit prompt within 60 pixels
3. WHEN the player interacts with the exit door, THE GameSystem SHALL trigger the victory screen
4. WHEN the victory screen appears, THE GameSystem SHALL save the arc completion status to the player profile
5. WHEN the arc is completed, THE GameSystem SHALL unlock achievements for completing the hardest arc

### Requirement 6

**User Story:** Como jugador, quiero que el sistema de cordura sea más punitivo en el arco de ira, para reflejar la intensidad del pecado.

#### Acceptance Criteria

1. WHEN the WrathArcGame starts, THE SanitySystem SHALL initialize the player sanity at 100%
2. WHILE the RagingBullEnemy is within 200 pixels of the player, THE SanitySystem SHALL drain sanity at 0.08 per frame
3. WHILE the RagingBullEnemy is in contact with the player, THE SanitySystem SHALL drain sanity at 0.15 per frame
4. WHEN the player sanity reaches 0%, THE GameSystem SHALL trigger the game over screen
5. WHILE the player is hiding, THE SanitySystem SHALL regenerate sanity at 0.01 per frame up to 100%

### Requirement 7

**User Story:** Como jugador, quiero controles responsivos y precisos, para poder reaccionar rápidamente al enemigo agresivo.

#### Acceptance Criteria

1. WHEN the player uses the virtual joystick, THE PlayerComponent SHALL respond instantly with no input lag
2. WHEN the player uses keyboard controls, THE PlayerComponent SHALL respond instantly with no input lag
3. WHILE the player is moving, THE PlayerComponent SHALL maintain normal movement speed of 150 pixels per second
4. WHEN the player changes direction, THE PlayerComponent SHALL rotate instantly without delay
5. WHEN the player enters a hiding spot, THE PlayerComponent SHALL hide within 0.1 seconds

### Requirement 8

**User Story:** Como jugador, quiero que el arco de ira reutilice la arquitectura existente, para una experiencia consistente con otros arcos.

#### Acceptance Criteria

1. WHEN the WrathArcGame is created, THE WrathArcGame SHALL extend the BaseArcGame class
2. WHEN the WrathScene is created, THE WrathScene SHALL reuse ObstacleComponent, EvidenceComponent, and ExitDoorComponent from the base system
3. WHEN the RagingBullEnemy is created, THE RagingBullEnemy SHALL extend the base EnemyComponent with modified speed and aggression parameters
4. WHEN the PlayerComponent is used, THE PlayerComponent SHALL be the same component from the base system without modifications
5. WHEN the WrathArcGame initializes, THE WrathArcGame SHALL use the existing GameHUD, PauseMenu, GameOverScreen, and VictoryScreen components

### Requirement 9

**User Story:** Como jugador, quiero que el enemigo tenga comportamientos especiales de ira, para una experiencia única.

#### Acceptance Criteria

1. WHEN the RagingBullEnemy collides with an obstacle, THE RagingBullEnemy SHALL destroy the obstacle if it is destructible
2. WHEN the RagingBullEnemy is chasing, THE RagingBullEnemy SHALL emit angry sound effects every 2 seconds
3. WHILE the RagingBullEnemy is moving, THE RagingBullEnemy SHALL leave red particle trails
4. WHEN the RagingBullEnemy loses sight of the player, THE RagingBullEnemy SHALL charge in the last known direction for 3 seconds
5. WHEN the RagingBullEnemy reaches the last known player position, THE RagingBullEnemy SHALL perform an area search pattern
