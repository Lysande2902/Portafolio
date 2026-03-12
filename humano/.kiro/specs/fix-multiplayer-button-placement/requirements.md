# Requirements Document

## Introduction

Este documento define los requisitos para corregir la ubicación incorrecta del botón de multijugador en la aplicación. Actualmente, el botón "PROTOCOLO MULTIJUGADOR [BETA]" aparece en la pantalla de selección de arcos cuando debería estar únicamente en el lobby principal (MenuScreen), debajo del botón PLAY.

## Glossary

- **MenuScreen**: La pantalla principal del lobby donde el usuario ve el botón PLAY y otras opciones principales
- **ArcSelectionScreen**: La pantalla donde el usuario selecciona qué arco del juego desea jugar
- **MultiplayerLobbyScreen**: La pantalla del lobby multijugador a la que navega el botón
- **Sistema**: La aplicación de juego Humano

## Requirements

### Requirement 1

**User Story:** Como usuario, quiero que el botón de multijugador esté solo en el lobby principal, para que la navegación sea clara y consistente con el diseño de la interfaz.

#### Acceptance Criteria

1. WHEN el usuario está en MenuScreen THEN el sistema SHALL mostrar el botón "PROTOCOLO MULTIJUGADOR [BETA]" debajo del botón PLAY
2. WHEN el usuario hace clic en el botón de multijugador en MenuScreen THEN el sistema SHALL navegar a MultiplayerLobbyScreen
3. WHEN el usuario está en ArcSelectionScreen THEN el sistema SHALL NOT mostrar el botón "PROTOCOLO MULTIJUGADOR [BETA]"
4. WHEN el usuario hace clic en el botón de multijugador THEN el sistema SHALL mantener el estilo visual consistente con otros botones secundarios del menú
5. WHEN el usuario navega entre pantallas THEN el sistema SHALL mantener la funcionalidad de multijugador accesible solo desde MenuScreen
