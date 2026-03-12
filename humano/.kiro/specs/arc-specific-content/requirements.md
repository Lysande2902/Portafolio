# Requirements Document

## Introduction

Personalización del contenido específico de cada arco en el juego, incluyendo el manual de misión (briefing), mensajes de game over, y cinemáticas de victoria. Actualmente todos los arcos muestran contenido genérico o del Arco 1 (Gula), lo cual rompe la inmersión y no refleja las mecánicas únicas de cada arco.

## Glossary

- **Arc**: Un nivel o capítulo del juego que representa uno de los 7 pecados capitales
- **Briefing**: Pantalla de información que se muestra antes de iniciar un arco
- **Game Over Screen**: Pantalla que se muestra cuando el jugador pierde
- **Victory Cinematic**: Secuencia animada que se muestra cuando el jugador completa un arco
- **Arc Data Provider**: Componente que provee información estática sobre cada arco
- **Greed Arc (Arco 2)**: Arco de Avaricia con mecánicas de robo de recursos y cajas registradoras

## Requirements

### Requirement 1

**User Story:** Como jugador, quiero ver información específica del arco en el manual de misión, para entender las mecánicas únicas antes de jugar

#### Acceptance Criteria

1. WHEN el jugador abre el briefing de Arco 2 (Avaricia), THE Briefing Screen SHALL display "AVARICIA" como título
2. WHEN el jugador abre el briefing de Arco 2, THE Briefing Screen SHALL display "El Precio de un Click" como subtítulo
3. WHEN el jugador abre el briefing de Arco 2, THE Briefing Screen SHALL display información sobre la mecánica de robo de evidencias por la Hiena
4. WHEN el jugador abre el briefing de Arco 2, THE Briefing Screen SHALL display información sobre las cajas registradoras para recuperar cordura
5. WHEN el jugador abre el briefing de cualquier arco, THE Briefing Screen SHALL display el objetivo específico del arco (no genérico)

### Requirement 2

**User Story:** Como jugador, quiero ver mensajes de game over personalizados para cada arco, para mantener la inmersión temática

#### Acceptance Criteria

1. WHEN el jugador pierde en Arco 2 (Avaricia), THE Game Over Screen SHALL display mensajes relacionados con avaricia y robo
2. WHEN el jugador pierde en Arco 2, THE Game Over Screen SHALL NOT display mensajes de Gula o comida
3. WHEN el jugador pierde en cualquier arco, THE Game Over Screen SHALL display el título correcto del arco
4. WHEN el jugador pierde en cualquier arco, THE Game Over Screen SHALL display mensajes temáticos consistentes con el pecado del arco

### Requirement 3

**User Story:** Como jugador, quiero ver estadísticas relevantes al arco en la pantalla de victoria, para entender mi desempeño en las mecánicas específicas

#### Acceptance Criteria

1. WHEN el jugador completa Arco 2 (Avaricia), THE Victory Screen SHALL display estadísticas de evidencias robadas por la Hiena
2. WHEN el jugador completa Arco 2, THE Victory Screen SHALL display estadísticas de cajas registradoras saqueadas
3. WHEN el jugador completa Arco 2, THE Victory Screen SHALL display cordura robada y recuperada
4. WHEN el jugador completa cualquier arco, THE Victory Screen SHALL display estadísticas específicas a las mecánicas del arco
5. WHEN el jugador completa cualquier arco, THE Victory Screen SHALL NOT display estadísticas irrelevantes de otros arcos

### Requirement 4

**User Story:** Como jugador, quiero que las cinemáticas de victoria reflejen la historia del arco, para sentir el impacto emocional de mis acciones

#### Acceptance Criteria

1. WHEN el jugador completa Arco 2 (Avaricia), THE Victory Cinematic SHALL display la historia de Valeria (la Hiena)
2. WHEN el jugador completa Arco 2, THE Victory Cinematic SHALL display información sobre el doxing bancario
3. WHEN el jugador completa Arco 2, THE Victory Cinematic SHALL display el mensaje "¿Valió la pena los likes?"
4. WHEN el jugador completa Arco 2, THE Victory Cinematic SHALL display el número de likes obtenidos (15,632)
5. WHEN el jugador completa cualquier arco, THE Victory Cinematic SHALL display contenido único para ese arco

### Requirement 5

**User Story:** Como desarrollador, quiero un sistema centralizado para gestionar contenido específico de arcos, para facilitar la adición de nuevos arcos

#### Acceptance Criteria

1. THE System SHALL provide a centralized data structure for arc-specific content
2. THE System SHALL allow easy addition of new arc content without modifying multiple files
3. THE System SHALL include briefing information for each arc
4. THE System SHALL include game over messages for each arc
5. THE System SHALL include victory statistics configuration for each arc
