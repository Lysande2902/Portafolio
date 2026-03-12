# Requirements Document

## Introduction

El juego presenta un error crítico "Game attachment error: A game instance can only be attached to one widget at a time" que ocurre cuando el widget de Flutter se reconstruye. Este error impide que el juego funcione correctamente y aparece constantemente durante la ejecución. El problema surge porque la instancia del juego de Flame intenta adjuntarse múltiples veces al árbol de widgets cuando ocurren reconstrucciones del UI.

## Glossary

- **GameWidget**: Widget de Flame que renderiza una instancia de FlameGame
- **Game Instance**: Instancia única de un juego de Flame (GluttonyArcGame, GreedArcGame, etc.)
- **Widget Rebuild**: Proceso de Flutter donde un widget se reconstruye en respuesta a cambios de estado
- **Game Attachment**: Proceso donde una instancia de juego se vincula a un GameWidget para renderizado
- **ArcGameScreen**: Widget de Flutter que contiene el GameWidget y la UI del juego
- **State Notifier**: Mecanismo de notificación de cambios de estado del juego

## Requirements

### Requirement 1

**User Story:** Como jugador, quiero que el juego funcione sin errores de attachment, para que pueda jugar sin interrupciones.

#### Acceptance Criteria

1. WHEN the game screen is displayed THEN the system SHALL attach the game instance to exactly one GameWidget
2. WHEN the UI state changes THEN the system SHALL update the UI without re-attaching the game instance
3. WHEN the game notifies state changes THEN the system SHALL rebuild only the necessary UI components without affecting the game attachment
4. WHEN the player pauses or resumes the game THEN the system SHALL maintain the same game attachment
5. WHEN the player uses items or interacts with the UI THEN the system SHALL update the UI without triggering game re-attachment

### Requirement 2

**User Story:** Como desarrollador, quiero separar la lógica de renderizado del juego de la lógica de UI de Flutter, para que los cambios de estado no causen conflictos de attachment.

#### Acceptance Criteria

1. WHEN the ArcGameScreen initializes THEN the system SHALL create the game instance and GameWidget once during initialization
2. WHEN setState is called THEN the system SHALL preserve the GameWidget identity to prevent re-attachment
3. WHEN the game state changes THEN the system SHALL use a separate mechanism to update UI overlays without rebuilding the GameWidget
4. WHEN the screen is disposed THEN the system SHALL properly detach the game instance
5. WHEN the game is reset THEN the system SHALL handle the reset without creating a new GameWidget

### Requirement 3

**User Story:** Como jugador, quiero que las pantallas de victoria, game over y pausa funcionen correctamente, para que pueda ver mi progreso y controlar el juego.

#### Acceptance Criteria

1. WHEN the game reaches victory state THEN the system SHALL display the victory screen without causing attachment errors
2. WHEN the game reaches game over state THEN the system SHALL display the game over screen without causing attachment errors
3. WHEN the player pauses the game THEN the system SHALL display the pause menu without causing attachment errors
4. WHEN the player resumes from pause THEN the system SHALL hide the pause menu without causing attachment errors
5. WHEN the player retries after game over THEN the system SHALL reset the game state without creating attachment errors
