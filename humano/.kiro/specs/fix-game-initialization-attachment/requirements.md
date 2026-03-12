# Requirements Document

## Introduction

El error "Unsupported operation: Game attachment error" persiste a pesar de haber implementado GlobalKey y ValueListenableBuilder. El análisis de los logs revela que el error ocurre DURANTE la inicialización del juego, no durante los rebuilds del widget. Esto indica que el problema real es que algo en el código de inicialización del juego está causando que el GameWidget intente re-adjuntar la instancia del juego, posiblemente debido a que el widget se está reconstruyendo internamente durante la fase de inicialización.

## Glossary

- **Game Initialization**: Proceso donde el juego carga recursos, configura componentes y se prepara para ejecutarse
- **Widget Lifecycle**: Secuencia de métodos que Flutter llama durante la vida de un widget (initState, didChangeDependencies, build, dispose)
- **Post-Frame Callback**: Callback que se ejecuta después de que Flutter completa un frame de renderizado
- **Provider Setup**: Configuración de providers de Flutter que el juego necesita para funcionar
- **Build Phase**: Fase donde Flutter construye el árbol de widgets
- **Attachment Phase**: Fase donde Flame adjunta una instancia de juego a un GameWidget

## Requirements

### Requirement 1

**User Story:** Como jugador, quiero que el juego se inicialice correctamente sin errores de attachment, para que pueda empezar a jugar inmediatamente.

#### Acceptance Criteria

1. WHEN the game screen is opened THEN the system SHALL complete the widget build phase before initializing the game
2. WHEN the game initializes THEN the system SHALL attach to the GameWidget exactly once
3. WHEN providers are configured THEN the system SHALL not trigger widget rebuilds during initialization
4. WHEN the game loads resources THEN the system SHALL not cause the GameWidget to rebuild
5. WHEN the initialization completes THEN the system SHALL log success without any attachment errors

### Requirement 2

**User Story:** Como desarrollador, quiero separar claramente la fase de construcción del widget de la fase de inicialización del juego, para evitar conflictos de timing.

#### Acceptance Criteria

1. WHEN initState runs THEN the system SHALL only create the game instance without starting initialization
2. WHEN didChangeDependencies runs THEN the system SHALL only configure providers without triggering game initialization
3. WHEN the first build completes THEN the system SHALL use a post-frame callback to start game initialization
4. WHEN game initialization starts THEN the system SHALL ensure the widget tree is stable
5. WHEN setting providers on the game THEN the system SHALL not cause any widget rebuilds

### Requirement 3

**User Story:** Como desarrollador, quiero que el GameWidget use una key verdaderamente estable que nunca cambie, para garantizar que no se recree durante la vida del screen.

#### Acceptance Criteria

1. WHEN the ArcGameScreen is created THEN the system SHALL create a static GlobalKey for the GameWidget
2. WHEN the widget rebuilds THEN the system SHALL reuse the same GlobalKey instance
3. WHEN comparing widget identity THEN the system SHALL recognize the GameWidget as the same instance
4. WHEN the screen is disposed THEN the system SHALL properly clean up the GlobalKey
5. WHEN multiple game screens exist THEN the system SHALL use unique keys for each screen

### Requirement 4

**User Story:** Como desarrollador, quiero prevenir cualquier setState durante la fase de inicialización, para evitar rebuilds prematuros.

#### Acceptance Criteria

1. WHEN the game is initializing THEN the system SHALL defer all state updates until initialization completes
2. WHEN providers notify changes during initialization THEN the system SHALL queue the updates instead of applying them immediately
3. WHEN initialization completes THEN the system SHALL flush all queued updates
4. WHEN the game notifies state changes THEN the system SHALL only update ValueNotifiers, not call setState
5. WHEN local UI state changes THEN the system SHALL only call setState for local state, not game state

