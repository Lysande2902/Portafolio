# Requirements Document

## Introduction

Este documento especifica los requisitos para implementar un sistema completo de tutorial de controles en el juego. El juego actualmente carece de un tutorial funcional que enseñe a los jugadores los controles básicos y las mecánicas específicas de cada arco. Esto resulta en confusión, frustración y una curva de aprendizaje innecesariamente empinada que afecta negativamente la experiencia del jugador.

El sistema de tutorial debe enseñar progresivamente los controles básicos (movimiento, esconderse) y las mecánicas específicas de cada arco (Gula, Avaricia, Envidia) de manera clara, no intrusiva y memorable.

## Glossary

- **Tutorial System**: El sistema completo que gestiona la presentación de tutoriales al jugador
- **First-Time Tutorial**: Tutorial que se muestra solo la primera vez que el jugador inicia el juego
- **Arc-Specific Tutorial**: Tutorial que explica las mecánicas únicas de cada arco del juego
- **Tutorial Overlay**: Componente visual que se superpone al juego para mostrar información del tutorial
- **Tutorial State**: Estado persistente que rastrea qué tutoriales ha completado el jugador
- **Joystick**: Control virtual en pantalla para el movimiento del personaje
- **Hide Button**: Botón morado que permite al jugador esconderse
- **Fragment**: Fragmento de evidencia que el jugador debe recolectar
- **Sanity**: Cordura del jugador, recurso que disminuye con el tiempo
- **Arc**: Uno de los tres niveles del juego (Gula, Avaricia, Envidia)
- **Gluttony Arc**: Arco 1 - Gula, con mecánica de devorador
- **Greed Arc**: Arco 2 - Avaricia, con mecánica de robo de recursos
- **Envy Arc**: Arco 3 - Envidia, con mecánica de espejo adaptativo

## Requirements

### Requirement 1

**User Story:** Como jugador nuevo, quiero ver un tutorial claro de controles básicos la primera vez que juego, para que pueda entender cómo moverme e interactuar con el juego.

#### Acceptance Criteria

1. WHEN the player launches the game for the first time THEN the Tutorial System SHALL display the first-time tutorial overlay before any gameplay begins
2. WHEN the first-time tutorial is displayed THEN the Tutorial System SHALL show exactly 5 sequential steps covering movement, hiding, fragments, sanity, and objective
3. WHEN the player completes all tutorial steps THEN the Tutorial System SHALL persist this completion state and never show the first-time tutorial again
4. WHEN the player taps the skip button THEN the Tutorial System SHALL immediately close the tutorial and mark it as completed
5. WHEN the player taps anywhere on screen during a tutorial step THEN the Tutorial System SHALL advance to the next step

### Requirement 2

**User Story:** Como jugador, quiero ver tutoriales específicos para cada arco antes de jugar, para que pueda entender las mecánicas únicas de ese nivel.

#### Acceptance Criteria

1. WHEN the player enters an arc for the first time THEN the Tutorial System SHALL display the arc-specific tutorial before gameplay begins
2. WHEN the Gluttony Arc tutorial is shown THEN the Tutorial System SHALL explain the devourer mechanic and hiding strategy
3. WHEN the Greed Arc tutorial is shown THEN the Tutorial System SHALL explain the resource theft mechanic and sanity recovery through cash registers
4. WHEN the Envy Arc tutorial is shown THEN the Tutorial System SHALL explain the adaptive mirror mechanic and the absence of hiding spots
5. WHEN the player completes an arc-specific tutorial THEN the Tutorial System SHALL persist this completion state for that specific arc

### Requirement 3

**User Story:** Como jugador, quiero poder saltar tutoriales que ya he visto, para que no pierda tiempo en información que ya conozco.

#### Acceptance Criteria

1. WHEN any tutorial is displayed THEN the Tutorial System SHALL show a visible "SALTAR" button in the top-right corner
2. WHEN the player presses the skip button THEN the Tutorial System SHALL immediately close the tutorial without showing remaining steps
3. WHEN the player skips a tutorial THEN the Tutorial System SHALL mark that tutorial as completed in persistent storage
4. WHEN the player has completed a tutorial previously THEN the Tutorial System SHALL not show that tutorial again on subsequent plays
5. WHEN the player wants to review tutorials THEN the Tutorial System SHALL provide a way to manually trigger tutorials from the pause menu

### Requirement 4

**User Story:** Como jugador, quiero que los tutoriales sean visualmente claros y no obstruyan información importante, para que pueda aprender sin frustración.

#### Acceptance Criteria

1. WHEN a tutorial overlay is displayed THEN the Tutorial System SHALL use a semi-transparent dark background with opacity of at least 0.85
2. WHEN tutorial text is shown THEN the Tutorial System SHALL use high-contrast colors (cyan on dark background) with font size of at least 22px
3. WHEN tutorial steps are presented THEN the Tutorial System SHALL show a progress indicator displaying current step number and total steps
4. WHEN a tutorial step highlights a UI element THEN the Tutorial System SHALL position the tutorial content to avoid covering that element
5. WHEN tutorial animations play THEN the Tutorial System SHALL use smooth transitions with duration between 300ms and 800ms

### Requirement 5

**User Story:** Como desarrollador, quiero que el estado de los tutoriales se persista correctamente, para que los jugadores no vean tutoriales repetidos innecesariamente.

#### Acceptance Criteria

1. WHEN a tutorial is completed THEN the Tutorial System SHALL save the completion state to local storage immediately
2. WHEN the Tutorial System saves state THEN it SHALL use a structured format with tutorial ID and completion timestamp
3. WHEN the game loads THEN the Tutorial System SHALL read the persisted state and initialize tutorial completion flags
4. WHEN local storage is unavailable THEN the Tutorial System SHALL default to showing all tutorials and log a warning
5. WHEN the Tutorial System writes to storage THEN it SHALL handle write failures gracefully without crashing the game

### Requirement 6

**User Story:** Como jugador, quiero que los tutoriales se integren naturalmente con el flujo del juego, para que la experiencia sea fluida y no disruptiva.

#### Acceptance Criteria

1. WHEN a tutorial is active THEN the Tutorial System SHALL pause all game logic including enemy AI and timers
2. WHEN a tutorial completes THEN the Tutorial System SHALL resume game logic smoothly without jarring transitions
3. WHEN the player is in a tutorial THEN the Tutorial System SHALL disable all game input except tutorial navigation controls
4. WHEN a tutorial overlay appears THEN the Tutorial System SHALL fade in over 300ms for smooth visual transition
5. WHEN a tutorial overlay disappears THEN the Tutorial System SHALL fade out over 300ms before resuming gameplay

### Requirement 7

**User Story:** Como jugador, quiero que los tutoriales me enseñen las diferencias clave entre arcos, para que pueda adaptar mi estrategia apropiadamente.

#### Acceptance Criteria

1. WHEN the Gluttony Arc tutorial is shown THEN the Tutorial System SHALL explicitly state that hiding is available and recommended
2. WHEN the Envy Arc tutorial is shown THEN the Tutorial System SHALL explicitly state that NO hiding spots are available
3. WHEN the Greed Arc tutorial is shown THEN the Tutorial System SHALL explain the sanity theft mechanic with specific percentage values
4. WHEN any arc tutorial is shown THEN the Tutorial System SHALL display the arc-specific objective clearly
5. WHEN arc mechanics are explained THEN the Tutorial System SHALL use consistent terminology matching in-game UI labels

### Requirement 8

**User Story:** Como jugador, quiero poder acceder a los tutoriales desde el menú de pausa, para que pueda revisar los controles si los olvido durante el juego.

#### Acceptance Criteria

1. WHEN the player opens the pause menu THEN the Tutorial System SHALL display a "Ver Tutorial" option
2. WHEN the player selects "Ver Tutorial" from pause menu THEN the Tutorial System SHALL show the arc-specific tutorial for the current arc
3. WHEN a manual tutorial is triggered THEN the Tutorial System SHALL not mark it as "first time" completion
4. WHEN a manual tutorial completes THEN the Tutorial System SHALL return the player to the pause menu
5. WHEN the player is viewing a manual tutorial THEN the Tutorial System SHALL allow skipping without affecting completion state
