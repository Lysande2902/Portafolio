# Requirements Document

## Introduction

A pesar de múltiples intentos de solución (GlobalKey, ValueListenableBuilder, deferred updates, safe component addition), el error "Game attachment error" persiste en los arcos del juego. El análisis del código revela que el problema tiene múltiples causas raíz que no han sido completamente resueltas:

1. **Inicialización durante build**: El juego se inicializa en `initState()` pero los componentes se agregan durante `onLoad()`, que puede ocurrir durante el build
2. **Múltiples puntos de actualización de estado**: El código tiene varios lugares donde se actualiza el estado del juego que pueden causar rebuilds
3. **Falta de sincronización**: No hay garantía de que el GameWidget esté completamente montado antes de que el juego intente agregar componentes

## Glossary

- **GameWidget**: Widget de Flame que renderiza el juego
- **Game attachment**: Proceso de vincular una instancia de juego a un GameWidget
- **Build phase**: Fase de construcción del widget tree en Flutter
- **onLoad**: Método de Flame que se ejecuta cuando el juego se carga
- **onMount**: Método de Flame que se ejecuta cuando el juego se monta al widget tree
- **Component**: Entidad del juego en Flame (jugador, enemigo, evidencia, etc.)

## Requirements

### Requirement 1

**User Story:** Como desarrollador, quiero que el juego se inicialice correctamente sin errores de attachment, para que los jugadores puedan jugar sin problemas

#### Acceptance Criteria

1. WHEN the game screen is opened THEN the system SHALL initialize the game instance before creating the GameWidget
2. WHEN the GameWidget is created THEN the system SHALL ensure the game is fully attached before adding any components
3. WHEN components are added during initialization THEN the system SHALL defer their addition until after the mount phase completes
4. WHEN the game is reset THEN the system SHALL properly dispose all components before reinitializing
5. WHEN state updates occur during initialization THEN the system SHALL queue them until after the first frame completes

### Requirement 2

**User Story:** Como desarrollador, quiero un ciclo de vida claro y predecible del juego, para que sea fácil mantener y depurar

#### Acceptance Criteria

1. WHEN the game initializes THEN the system SHALL follow a strict sequence: create instance → attach to widget → mount → add components
2. WHEN the game is running THEN the system SHALL only update state through the designated update loop
3. WHEN the game is paused THEN the system SHALL stop all updates but maintain component state
4. WHEN the game is disposed THEN the system SHALL clean up all resources in reverse order of creation
5. WHEN errors occur during initialization THEN the system SHALL log detailed information about the lifecycle state

### Requirement 3

**User Story:** Como jugador, quiero que el juego funcione consistentemente en todos los arcos, para que mi experiencia sea fluida

#### Acceptance Criteria

1. WHEN any arc is loaded THEN the system SHALL use the same initialization pattern
2. WHEN evidence is collected THEN the system SHALL update state without causing rebuilds
3. WHEN the game is reset THEN the system SHALL restore to initial state without errors
4. WHEN items are used THEN the system SHALL update state through the notifier system
5. WHEN the game ends (victory or game over) THEN the system SHALL properly clean up before showing the end screen
