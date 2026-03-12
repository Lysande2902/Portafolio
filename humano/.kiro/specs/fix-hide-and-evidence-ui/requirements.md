# Requirements Document

## Introduction

Este documento define los requisitos para corregir dos problemas críticos en el juego:
1. El crash que ocurre al presionar el botón de ocultar
2. La falta de actualización en tiempo real del contador de evidencias en la UI

## Glossary

- **Player**: El componente del jugador controlado por el usuario
- **HUD**: Heads-Up Display - La interfaz de usuario que muestra información del juego
- **Evidence**: Fragmentos de evidencia que el jugador debe recolectar (5 en total)
- **Hide Button**: Botón que permite al jugador esconderse en lugares específicos
- **Game State**: El estado actual del juego incluyendo evidencias recolectadas
- **UI Update**: Actualización visual de la interfaz de usuario

## Requirements

### Requirement 1

**User Story:** Como jugador, quiero que el botón de ocultar funcione sin causar crashes, para poder usar la mecánica de esconderse durante el juego.

#### Acceptance Criteria

1. WHEN el jugador presiona el botón de ocultar THEN el sistema SHALL ejecutar la acción sin generar excepciones
2. WHEN el jugador está cerca de un escondite y presiona ocultar THEN el sistema SHALL cambiar el estado del jugador a oculto
3. WHEN el jugador está oculto y presiona el botón nuevamente THEN el sistema SHALL cambiar el estado del jugador a visible
4. WHEN el jugador presiona ocultar sin estar cerca de un escondite THEN el sistema SHALL mostrar un mensaje indicando que debe estar cerca de un escondite
5. WHEN ocurre un error durante la acción de ocultar THEN el sistema SHALL capturar la excepción y registrar información de depuración

### Requirement 2

**User Story:** Como jugador, quiero ver el contador de evidencias actualizarse inmediatamente cuando recolecto un fragmento, para tener retroalimentación visual clara de mi progreso.

#### Acceptance Criteria

1. WHEN el jugador recolecta un fragmento de evidencia THEN el sistema SHALL actualizar el contador en el HUD inmediatamente
2. WHEN el contador de evidencias cambia THEN el sistema SHALL reflejar el nuevo valor en todos los componentes de UI relevantes
3. WHEN se recolecta una evidencia THEN el sistema SHALL mostrar una notificación visual temporal
4. WHEN el HUD se renderiza THEN el sistema SHALL obtener el valor actual de evidencias recolectadas del estado del juego
5. WHEN el estado del juego cambia THEN el sistema SHALL notificar a la UI para que se actualice
