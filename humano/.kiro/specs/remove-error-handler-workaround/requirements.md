# Requirements Document: Remove Error Handler Workaround

## Introduction

El sistema actual incluye un error handler global (`ErrorHandler.initGlobalHandlers()`) que oculta el error "Game attachment error" en lugar de solucionarlo. Este workaround fue implementado como solución temporal, pero ahora que el error real está corregido en `EvidenceComponent`, este sistema de ocultación es innecesario y contraproducente. Ocultar errores dificulta el debugging y puede esconder problemas reales en el futuro.

## Glossary

- **ErrorHandler**: Clase que intercepta errores globales de Flutter y Flame
- **Game Attachment Error**: Error de Flame cuando se intenta agregar componentes durante el ciclo de actualización
- **EvidenceComponent**: Componente del juego que maneja la recolección de evidencias
- **Flame Engine**: Motor de juegos 2D usado en el proyecto

## Requirements

### Requirement 1

**User Story:** Como desarrollador, quiero eliminar el sistema de ocultación de errores, para que los errores reales sean visibles durante el desarrollo y debugging.

#### Acceptance Criteria

1. WHEN the application starts THEN the system SHALL NOT initialize any global error handlers that suppress game attachment errors
2. WHEN a game attachment error occurs THEN the system SHALL allow Flutter's default error handling to display the error
3. WHEN the ErrorHandler class is removed THEN the system SHALL continue functioning without crashes
4. WHEN evidence is collected in any arc THEN the system SHALL NOT produce game attachment errors

### Requirement 2

**User Story:** Como desarrollador, quiero limpiar el código relacionado al workaround, para mantener el codebase limpio y fácil de mantener.

#### Acceptance Criteria

1. WHEN reviewing the codebase THEN the system SHALL NOT contain the ErrorHandler class file
2. WHEN reviewing main.dart THEN the system SHALL NOT contain references to ErrorHandler initialization
3. WHEN reviewing base_arc_game.dart THEN the system SHALL NOT contain imports of error_handler
4. WHEN reviewing documentation THEN the system SHALL NOT contain references to the game attachment error workaround

### Requirement 3

**User Story:** Como desarrollador, quiero verificar que la solución real funciona, para asegurar que no dependemos del workaround.

#### Acceptance Criteria

1. WHEN collecting evidence in Arco Gula THEN the system SHALL animate the collection without errors
2. WHEN collecting evidence in Arco Ira THEN the system SHALL animate the collection without errors
3. WHEN collecting evidence in Arco Pereza THEN the system SHALL animate the collection without errors
4. WHEN collecting multiple evidence fragments rapidly THEN the system SHALL handle all collections without errors
