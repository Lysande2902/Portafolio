# Requirements Document - Sistema de Arcos/Episodios

## Introduction

El Sistema de Arcos/Episodios es el núcleo narrativo del juego HUMANO. Permite a los jugadores seleccionar y jugar diferentes arcos narrativos (episodios) donde experimentan la vida bajo vigilancia constante. Cada arco presenta una historia con decisiones que afectan el desarrollo y desenlace.

## Glossary

- **Arc System**: Sistema que gestiona la selección y navegación de arcos narrativos
- **Arc**: Un episodio o capítulo narrativo completo con inicio, desarrollo y final
- **Episode**: Sinónimo de Arc, representa una historia jugable
- **Arc Selection Screen**: Pantalla donde el jugador elige qué arco jugar
- **Arc Progress**: Estado de completitud de un arco (no iniciado, en progreso, completado)
- **Arc Card**: Elemento visual que representa un arco en la pantalla de selección
- **Locked Arc**: Arco que no está disponible hasta cumplir ciertos requisitos
- **Player**: Usuario que interactúa con el sistema

## Requirements

### Requirement 1

**User Story:** As a Player, I want to see a list of available arcs, so that I can choose which story to experience

#### Acceptance Criteria

1. WHEN the Player navigates to the arc selection screen, THE Arc System SHALL display all available arcs in a scrollable list
2. WHEN displaying an arc, THE Arc System SHALL show the arc title, description, thumbnail image, and progress status
3. WHEN an arc is locked, THE Arc System SHALL display a lock icon and disable selection
4. WHEN an arc is completed, THE Arc System SHALL display a completion indicator
5. WHEN an arc is in progress, THE Arc System SHALL display the current progress percentage

### Requirement 2

**User Story:** As a Player, I want to select an arc to play, so that I can start experiencing the narrative

#### Acceptance Criteria

1. WHEN the Player taps on an unlocked arc card, THE Arc System SHALL navigate to the arc gameplay screen
2. WHEN the Player taps on a locked arc card, THE Arc System SHALL display a message explaining unlock requirements
3. WHEN navigating to an arc, THE Arc System SHALL load the arc data within 3 seconds
4. IF the arc fails to load, THEN THE Arc System SHALL display an error message and return to the selection screen
5. WHEN starting a new arc, THE Arc System SHALL initialize the arc state with default values

### Requirement 3

**User Story:** As a Player, I want to see my progress in each arc, so that I can track my advancement

#### Acceptance Criteria

1. WHEN viewing the arc selection screen, THE Arc System SHALL display the completion percentage for each started arc
2. WHEN an arc is not started, THE Arc System SHALL display "No iniciado" status
3. WHEN an arc is in progress, THE Arc System SHALL display the percentage completed
4. WHEN an arc is completed, THE Arc System SHALL display "Completado" status with a checkmark
5. THE Arc System SHALL persist progress data in Firebase for each Player

### Requirement 4

**User Story:** As a Player, I want the arc selection screen to match the game's aesthetic, so that the experience feels cohesive

#### Acceptance Criteria

1. THE Arc Selection Screen SHALL use the VHS/glitch aesthetic consistent with other screens
2. THE Arc Selection Screen SHALL display a video background with dark overlay
3. THE Arc Selection Screen SHALL use the Courier Prime font for all text
4. THE Arc Selection Screen SHALL include the REC indicator in the corner
5. THE Arc Selection Screen SHALL play ambient audio during browsing

### Requirement 5

**User Story:** As a Player, I want to return to the menu from the arc selection screen, so that I can access other features

#### Acceptance Criteria

1. THE Arc Selection Screen SHALL display a back button in the top-left corner
2. WHEN the Player taps the back button, THE Arc System SHALL navigate back to the menu screen
3. WHEN navigating back, THE Arc System SHALL dispose of resources properly
4. THE Arc System SHALL maintain the Player's session state when navigating between screens
5. WHEN the Player uses the system back gesture, THE Arc System SHALL return to the menu screen

### Requirement 6

**User Story:** As a Player, I want to see at least one playable arc, so that I can start experiencing the game

#### Acceptance Criteria

1. THE Arc System SHALL include at least one unlocked arc by default
2. THE default arc SHALL be titled "Arco 1: Despertar"
3. THE default arc SHALL have a description explaining the premise
4. THE default arc SHALL be accessible without any prerequisites
5. THE Arc System SHALL support adding additional arcs in future updates
