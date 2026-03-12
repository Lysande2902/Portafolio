# Requirements Document - Galería de Evidencias

## Introduction

La Galería de Evidencias es un sistema narrativo que permite a los jugadores revisar y coleccionar fragmentos de su pasado digital: capturas de pantalla, mensajes, videos, y otros "pecados" que fueron revelados durante los arcos. Funciona como un museo inquietante de las acciones del jugador, manteniendo la tensión narrativa del juego.

## Glossary

- **Archive System**: Sistema que gestiona la colección y visualización de evidencias
- **Archive Screen**: Pantalla donde el jugador explora las evidencias coleccionadas
- **Evidence**: Pieza coleccionable que revela parte de la historia (imagen, texto, audio, video)
- **Evidence Type**: Categoría de evidencia (screenshot, mensaje, video, audio, documento)
- **Locked Evidence**: Evidencia que aún no ha sido desbloqueada
- **Evidence Detail View**: Vista ampliada de una evidencia específica
- **Collection Progress**: Porcentaje de evidencias coleccionadas
- **Player**: Usuario que interactúa con el sistema

## Requirements

### Requirement 1

**User Story:** As a Player, I want to see all available evidences organized by arc, so that I can explore the narrative content I've unlocked

#### Acceptance Criteria

1. THE Archive Screen SHALL display evidences grouped by arc (Gula, Avaricia, etc.)
2. WHEN the Player opens the archive, THE Archive System SHALL show the total collection progress percentage
3. THE Archive System SHALL display locked evidences as silhouettes or placeholders
4. WHEN an evidence is unlocked, THE Archive System SHALL display a preview thumbnail or icon
5. THE Archive Screen SHALL use a grid layout for easy browsing

### Requirement 2

**User Story:** As a Player, I want to view evidence details, so that I can read/see the full content

#### Acceptance Criteria

1. WHEN the Player taps on an unlocked evidence, THE Archive System SHALL open a detail view
2. THE detail view SHALL display the full evidence content (image, text, video, or audio)
3. THE detail view SHALL show the evidence title and description
4. THE detail view SHALL indicate which arc the evidence belongs to
5. WHEN the Player taps outside or presses back, THE Archive System SHALL close the detail view

### Requirement 3

**User Story:** As a Player, I want to see which evidences I'm missing, so that I know what to look for

#### Acceptance Criteria

1. THE Archive Screen SHALL display locked evidences with a lock icon
2. WHEN the Player taps a locked evidence, THE Archive System SHALL show a hint about how to unlock it
3. THE Archive System SHALL display the number of evidences collected per arc
4. THE Archive System SHALL show total progress (e.g., "15/49 evidencias")
5. THE Archive System SHALL persist evidence unlock status in Firebase

### Requirement 4

**User Story:** As a Player, I want the archive to match the game's aesthetic, so that it feels like part of the experience

#### Acceptance Criteria

1. THE Archive Screen SHALL use the VHS/glitch aesthetic consistent with other screens
2. THE Archive Screen SHALL display a video background with dark overlay
3. THE Archive Screen SHALL use the Courier Prime font for all text
4. THE Archive Screen SHALL include the REC indicator in the corner
5. THE Archive Screen SHALL use a dark, ominous color scheme (blacks, reds, greys)

### Requirement 5

**User Story:** As a Player, I want to filter evidences by type, so that I can find specific content easily

#### Acceptance Criteria

1. THE Archive Screen SHALL provide filter buttons for evidence types (All, Screenshots, Messages, Videos, Audio)
2. WHEN the Player selects a filter, THE Archive System SHALL show only evidences of that type
3. THE Archive System SHALL maintain the selected filter when navigating between arcs
4. THE Archive System SHALL show the count of evidences for each filter
5. THE filter SHALL update in real-time as evidences are unlocked

### Requirement 6

**User Story:** As a Player, I want to return to the menu from the archive, so that I can access other features

#### Acceptance Criteria

1. THE Archive Screen SHALL display a back button in the top-left corner
2. WHEN the Player taps the back button, THE Archive System SHALL navigate back to the menu
3. WHEN navigating back, THE Archive System SHALL dispose of resources properly
4. THE Archive System SHALL save the current scroll position
5. WHEN the Player uses the system back gesture, THE Archive System SHALL return to the menu screen
