# Requirements Document

## Introduction

Este documento define los requisitos para el sistema de fragmentos de rompecabezas en el juego. Los jugadores recolectan 5 fragmentos por arco que forman una evidencia completa tipo rompecabezas. Cada fragmento tiene una forma única que debe conectarse correctamente con los demás fragmentos para revelar la imagen/evidencia completa.

## Glossary

- **Fragment**: Pieza individual de rompecabezas que el jugador recolecta durante el gameplay
- **Evidence**: Imagen/documento completo formado por 5 fragmentos ensamblados correctamente
- **Puzzle System**: Sistema que gestiona la lógica de conexión y validación de fragmentos
- **Assembly UI**: Interfaz donde el jugador ensambla los fragmentos manualmente
- **Connection Point**: Punto específico en un fragmento donde puede conectarse con otro fragmento
- **Arc**: Historia específica del juego (Gula, Avaricia, Envidia, etc.)

## Requirements

### Requirement 1

**User Story:** Como jugador, quiero recolectar fragmentos de rompecabezas durante el gameplay, para que pueda ensamblarlos y descubrir la evidencia completa.

#### Acceptance Criteria

1. WHEN the player collects a fragment THEN the system SHALL store the fragment with its unique shape data and position information
2. WHEN a fragment is collected THEN the system SHALL display a notification showing the fragment preview and collection progress
3. WHEN the player has collected all 5 fragments THEN the system SHALL unlock the assembly interface for that evidence
4. WHEN the player views collected fragments THEN the system SHALL display each fragment with its unique puzzle piece shape
5. WHERE a fragment belongs to a specific arc THEN the system SHALL associate the fragment with that arc's evidence data

### Requirement 2

**User Story:** Como jugador, quiero que cada fragmento tenga una forma única de rompecabezas, para que el ensamblaje sea un desafío visual y lógico.

#### Acceptance Criteria

1. WHEN the system generates fragment shapes THEN the system SHALL create 5 unique interlocking puzzle piece shapes per evidence
2. WHEN displaying a fragment THEN the system SHALL render the fragment with tabs (protrusions) and blanks (indentations) that match adjacent pieces
3. WHEN two fragments are adjacent THEN the system SHALL ensure their connection points are complementary (tab matches blank)
4. WHEN rendering fragment shapes THEN the system SHALL use SVG paths or custom clipping to create authentic puzzle piece appearance
5. WHERE fragments form the complete evidence THEN the system SHALL ensure all 5 pieces fit together in a specific arrangement

### Requirement 3

**User Story:** Como jugador, quiero una interfaz interactiva y desafiante para ensamblar los fragmentos, para que resolver el rompecabezas sea entretenido pero no trivial.

#### Acceptance Criteria

1. WHEN the player opens the assembly interface THEN the system SHALL display all collected fragments in random positions and random rotations
2. WHEN the player drags a fragment THEN the system SHALL move the fragment smoothly following the touch/mouse position with physics-based momentum
3. WHEN the player taps a fragment THEN the system SHALL rotate the fragment by 90 degrees with smooth animation
4. WHEN the player drops a fragment near its correct position AND correct rotation THEN the system SHALL snap the fragment into place with magnetic effect
5. WHEN a fragment is placed incorrectly THEN the system SHALL shake the fragment and return it to a random position with bounce animation
6. WHEN all fragments are correctly assembled THEN the system SHALL reveal the complete evidence with an elaborate completion animation sequence

### Requirement 4

**User Story:** Como jugador, quiero ver la evidencia completa una vez ensamblada, para que pueda entender la historia revelada por los fragmentos.

#### Acceptance Criteria

1. WHEN all fragments are correctly placed THEN the system SHALL display the complete evidence image without puzzle lines
2. WHEN viewing the complete evidence THEN the system SHALL show the evidence title and narrative description
3. WHEN the evidence is completed THEN the system SHALL save the completion state to the player's archive
4. WHEN the player revisits a completed evidence THEN the system SHALL display the assembled version by default
5. WHERE the evidence contains narrative content THEN the system SHALL display the full story text associated with that evidence

### Requirement 5

**User Story:** Como jugador, quiero que cada arco tenga fragmentos temáticos únicos, para que cada evidencia sea visualmente distintiva y narrativamente coherente.

#### Acceptance Criteria

1. WHEN fragments belong to Arc 1 (Gula) THEN the system SHALL display fragments with content related to Mateo's viral video
2. WHEN fragments belong to Arc 2 (Avaricia) THEN the system SHALL display fragments with content related to Valeria's doxxing
3. WHEN fragments belong to Arc 3 (Envidia) THEN the system SHALL display fragments with content related to Lucía's comparison
4. WHEN displaying fragment content THEN the system SHALL ensure each fragment shows a portion of the complete evidence image
5. WHERE multiple arcs are available THEN the system SHALL maintain separate fragment collections per arc

### Requirement 6

**User Story:** Como jugador, quiero feedback visual y auditivo rico durante el ensamblaje, para que la experiencia sea altamente satisfactoria e inmersiva.

#### Acceptance Criteria

1. WHEN a fragment is picked up THEN the system SHALL scale the fragment with elastic animation, add a dynamic shadow, and play a pickup sound
2. WHEN a fragment is being dragged THEN the system SHALL show a trailing particle effect following the fragment's movement
3. WHEN a fragment is near its correct position THEN the system SHALL highlight the target area with pulsing glow effect and play proximity sound
4. WHEN a fragment snaps into place THEN the system SHALL play a satisfying click sound, show explosion particle effect, and flash the fragment briefly
5. WHEN a fragment is placed incorrectly THEN the system SHALL play an error sound, shake the fragment with haptic feedback, and show red particles
6. WHEN the puzzle is completed THEN the system SHALL play a triumphant sound sequence, show confetti particles, and animate puzzle lines dissolving
7. WHEN hovering over a fragment THEN the system SHALL provide subtle scale pulse and glow indicating the fragment is interactive

### Requirement 7

**User Story:** Como jugador, quiero mecánicas adicionales que aumenten el desafío del rompecabezas, para que resolver cada evidencia sea único y memorable.

#### Acceptance Criteria

1. WHEN the assembly interface opens THEN the system SHALL apply a time pressure indicator that increases difficulty without hard time limits
2. WHEN a fragment is incorrectly placed multiple times THEN the system SHALL temporarily lock that fragment for 3 seconds with a cooldown animation
3. WHEN fragments are close to each other but not in correct positions THEN the system SHALL create false magnetic attraction to increase challenge
4. WHEN the player has assembled 2 or more fragments correctly THEN the system SHALL slightly increase the snap distance tolerance as reward
5. WHERE the puzzle has been attempted multiple times THEN the system SHALL offer an optional hint system that highlights one correct position

### Requirement 9

**User Story:** Como desarrollador, quiero un sistema de datos flexible para fragmentos, para que sea fácil agregar nuevos arcos y evidencias.

#### Acceptance Criteria

1. WHEN defining a new evidence THEN the system SHALL accept fragment data including shape paths, positions, and image regions
2. WHEN the system loads fragment data THEN the system SHALL validate that all 5 fragments have compatible connection points
3. WHEN storing fragment collection state THEN the system SHALL persist which fragments have been collected per arc per player
4. WHEN the system initializes THEN the system SHALL load all fragment definitions from a centralized data provider
5. WHERE fragment data is modified THEN the system SHALL support hot-reload for development without breaking saved progress

### Requirement 10

**User Story:** Como jugador, quiero acceder a la interfaz de ensamblaje desde el archivo, para que pueda completar rompecabezas que dejé incompletos.

#### Acceptance Criteria

1. WHEN the player opens the archive THEN the system SHALL display all evidences with their fragment collection status
2. WHEN an evidence has incomplete fragments THEN the system SHALL show which fragments are collected and which are missing
3. WHEN the player selects an evidence with all fragments collected THEN the system SHALL open the assembly interface
4. WHEN the player selects an evidence with missing fragments THEN the system SHALL display a message indicating fragments needed
5. WHERE multiple evidences exist THEN the system SHALL organize them by arc with clear visual separation
