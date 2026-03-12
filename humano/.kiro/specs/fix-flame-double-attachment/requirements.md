# Requirements Document

## Introduction

El sistema actualmente presenta un error crítico donde Flame intenta adjuntar un juego que ya está adjuntado, causando la excepción "A game instance can only be attached to one widget at a time". Este error ocurre durante la navegación y reconstrucción de widgets, impidiendo que los usuarios puedan jugar correctamente.

## Glossary

- **FlameGame**: La clase base de Flame que maneja el ciclo de vida del juego
- **GameWidget**: El widget de Flutter que envuelve y renderiza un FlameGame
- **Attachment**: El proceso por el cual Flame conecta una instancia de juego a un GameWidget
- **Widget Tree**: El árbol de widgets de Flutter que se reconstruye cuando cambia el estado
- **Game Instance**: Una instancia específica de una clase que extiende FlameGame
- **ArcGameScreen**: La pantalla de Flutter que contiene el GameWidget y la UI del juego

## Requirements

### Requirement 1

**User Story:** Como jugador, quiero que el juego se cargue correctamente sin errores de attachment, para poder jugar sin interrupciones.

#### Acceptance Criteria

1. WHEN el usuario navega a ArcGameScreen THEN el sistema SHALL crear una única instancia del juego y adjuntarla correctamente
2. WHEN Flutter reconstruye el widget tree THEN el sistema SHALL mantener la misma instancia del juego sin intentar re-adjuntarla
3. WHEN el usuario sale de ArcGameScreen THEN el sistema SHALL limpiar correctamente la instancia del juego
4. WHEN ocurre un hot reload durante desarrollo THEN el sistema SHALL manejar el ciclo de vida sin errores de attachment
5. WHEN el juego está activo THEN el sistema SHALL prevenir cualquier intento de adjuntar la misma instancia a múltiples widgets

### Requirement 2

**User Story:** Como desarrollador, quiero que el ciclo de vida del juego esté claramente separado del ciclo de vida del widget, para evitar conflictos de estado.

#### Acceptance Criteria

1. WHEN se crea ArcGameScreen THEN el sistema SHALL inicializar el juego exactamente una vez en initState
2. WHEN Flutter llama a build() múltiples veces THEN el sistema SHALL reutilizar la misma instancia de GameWidget
3. WHEN se destruye ArcGameScreen THEN el sistema SHALL llamar a dispose() del juego para liberar recursos
4. WHEN el widget se desactiva temporalmente THEN el sistema SHALL mantener el estado del juego sin desadjuntarlo
5. WHEN se reactiva el widget THEN el sistema SHALL continuar usando la misma instancia del juego

### Requirement 3

**User Story:** Como desarrollador, quiero logs claros del ciclo de vida del juego, para poder diagnosticar problemas de attachment.

#### Acceptance Criteria

1. WHEN se crea una instancia del juego THEN el sistema SHALL registrar la creación en los logs
2. WHEN se adjunta el juego a un widget THEN el sistema SHALL registrar el attachment
3. WHEN se desadjunta el juego THEN el sistema SHALL registrar el detachment
4. WHEN se destruye el juego THEN el sistema SHALL registrar la destrucción
5. WHEN ocurre un error de attachment THEN el sistema SHALL registrar el estado completo del juego y widget
