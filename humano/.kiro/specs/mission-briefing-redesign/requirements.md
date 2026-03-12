# Requirements Document

## Introduction

Rediseño del manual de misión (briefing) que se muestra antes de iniciar un arco en el juego. El objetivo es mejorar la experiencia visual y de usabilidad eliminando el scroll, optimizando el uso del espacio de pantalla, y organizando el contenido en un layout de dos columnas: información del arco a la izquierda y botones de acción a la derecha.

## Glossary

- **Mission Briefing Dialog**: El diálogo modal que muestra información sobre un arco antes de iniciarlo
- **Arc Information Section**: La sección izquierda que contiene título, objetivo, controles y advertencias
- **Action Buttons Section**: La sección derecha que contiene los botones de cancelar e iniciar
- **Viewport**: El área visible de la pantalla sin necesidad de scroll

## Requirements

### Requirement 1

**User Story:** Como jugador, quiero ver toda la información del manual de misión sin hacer scroll, para poder revisar rápidamente los detalles antes de iniciar

#### Acceptance Criteria

1. THE Mission Briefing Dialog SHALL display all content within the viewport without requiring scroll
2. THE Mission Briefing Dialog SHALL use a two-column layout with arc information on the left and action buttons on the right
3. THE Mission Briefing Dialog SHALL maintain readability on screens with height greater than or equal to 600 pixels
4. THE Mission Briefing Dialog SHALL adapt font sizes and spacing to fit content within the viewport
5. THE Mission Briefing Dialog SHALL prevent content overflow by using appropriate constraints

### Requirement 2

**User Story:** Como jugador, quiero que la información del arco esté organizada en la parte izquierda, para poder leerla de manera natural antes de decidir si iniciar

#### Acceptance Criteria

1. THE Arc Information Section SHALL occupy the left portion of the dialog
2. THE Arc Information Section SHALL display the arc number and title at the top
3. THE Arc Information Section SHALL show objective, controls, and danger information in a vertical layout
4. THE Arc Information Section SHALL use consistent spacing between information blocks
5. THE Arc Information Section SHALL use icons and colors to differentiate information types

### Requirement 3

**User Story:** Como jugador, quiero que los botones de acción estén en la parte derecha, para poder acceder a ellos fácilmente después de revisar la información

#### Acceptance Criteria

1. THE Action Buttons Section SHALL occupy the right portion of the dialog
2. THE Action Buttons Section SHALL display the cancel button above the start button
3. THE Action Buttons Section SHALL use vertical alignment for buttons
4. THE Action Buttons Section SHALL maintain consistent button sizing and spacing
5. THE Action Buttons Section SHALL use visual hierarchy with the start button more prominent than the cancel button

### Requirement 4

**User Story:** Como jugador, quiero que el diseño sea responsivo, para que se vea bien en diferentes tamaños de pantalla

#### Acceptance Criteria

1. WHEN the screen height is less than 700 pixels, THE Mission Briefing Dialog SHALL reduce font sizes and padding
2. THE Mission Briefing Dialog SHALL maintain the two-column layout on screens wider than 500 pixels
3. THE Mission Briefing Dialog SHALL use flexible sizing to adapt to different screen dimensions
4. THE Mission Briefing Dialog SHALL ensure buttons remain fully visible and clickable
5. THE Mission Briefing Dialog SHALL maintain visual balance between left and right sections
