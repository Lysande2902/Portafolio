# Requirements Document

## Introduction

Este documento especifica los requisitos para resolver dos problemas críticos identificados en el juego:

1. **Balance del Arco de Envidia**: El arco puede ser imposible de ganar debido a la velocidad excesiva del enemigo en fases avanzadas
2. **Disclaimer del Demo Ending**: El final de la demo puede ser demasiado perturbador sin advertencia previa

Estos problemas afectan directamente la experiencia del jugador y deben ser resueltos para asegurar que el juego sea desafiante pero justo, y que los jugadores estén preparados emocionalmente para el contenido sensible.

## Glossary

- **Envy Arc**: Arco 3 del juego (Envidia), con mecánica de espejo adaptativo
- **Chameleon Enemy**: Enemigo del arco de Envidia que aumenta su velocidad con cada evidencia recolectada
- **Phase**: Nivel de dificultad del enemigo basado en evidencias recolectadas
- **Demo Ending**: Final de la demo que se muestra después de completar el arco de Envidia
- **Disclaimer Screen**: Pantalla de advertencia que informa al jugador sobre contenido sensible
- **DemoEndingDisclaimerScreen**: Pantalla actual que muestra el disclaimer
- **Balance**: Ajuste de dificultad para hacer el juego desafiante pero ganable

## Requirements

### Requirement 1: Balance del Arco de Envidia

**User Story:** Como jugador, quiero que el arco de Envidia sea desafiante pero ganable, para que pueda completar el juego sin frustración excesiva.

#### Acceptance Criteria

1. WHEN the player collects 0-1 evidence THEN the Chameleon Enemy SHALL move at base patrol speed of 80 and chase speed of 110
2. WHEN the player collects 2-3 evidence THEN the Chameleon Enemy SHALL increase patrol speed to 90 and chase speed to 120
3. WHEN the player collects 4-5 evidence THEN the Chameleon Enemy SHALL increase patrol speed to 100 and chase speed to 130
4. WHEN the Chameleon Enemy increases phase THEN the speed increment SHALL be 10 units instead of 20 units
5. WHEN the player uses photo distraction THEN the Chameleon Enemy SHALL be distracted for 6 seconds minimum

### Requirement 2: Ajuste de Detección del Enemigo

**User Story:** Como jugador, quiero tener espacio para maniobrar sin ser detectado constantemente, para que pueda planear mi estrategia.

#### Acceptance Criteria

1. WHEN the Chameleon Enemy is patrolling THEN the chase detection range SHALL be 250 units
2. WHEN the player is hidden THEN the Chameleon Enemy SHALL not detect the player regardless of distance
3. WHEN the player exits hiding THEN the Chameleon Enemy SHALL have a 1 second grace period before detecting
4. WHEN the Chameleon Enemy loses sight of player THEN it SHALL return to patrol mode after 2 seconds
5. WHEN the player is near a hiding spot THEN the game SHALL provide visual feedback of the safe zone

### Requirement 3: Mejora de Mecánica de Fotos

**User Story:** Como jugador, quiero que la mecánica de fotos sea más útil, para que tenga más opciones estratégicas durante el juego.

#### Acceptance Criteria

1. WHEN the player places a photo THEN the Chameleon Enemy SHALL be distracted for 6 seconds
2. WHEN the Chameleon Enemy is distracted THEN it SHALL move to the photo location at base speed
3. WHEN the distraction ends THEN the Chameleon Enemy SHALL resume previous behavior smoothly
4. WHEN the player has no photos THEN the photo button SHALL be disabled with visual feedback
5. WHEN the player places a photo THEN the game SHALL provide audio and visual confirmation

### Requirement 4: Disclaimer del Demo Ending

**User Story:** Como jugador, quiero ser advertido sobre contenido sensible antes del final de la demo, para que pueda prepararme emocionalmente o decidir si quiero continuar.

#### Acceptance Criteria

1. WHEN the player completes the Envy Arc THEN the System SHALL display a disclaimer screen before the demo ending
2. WHEN the disclaimer screen is shown THEN it SHALL clearly state that the content contains sensitive themes
3. WHEN the disclaimer screen is shown THEN it SHALL provide specific warnings about self-harm, mental health, and disturbing content
4. WHEN the disclaimer screen is shown THEN it SHALL offer the player the option to skip the ending
5. WHEN the player chooses to skip THEN the System SHALL navigate directly to the main menu or archive screen

### Requirement 5: Contenido del Disclaimer

**User Story:** Como jugador, quiero que el disclaimer sea claro y específico, para que pueda tomar una decisión informada sobre continuar.

#### Acceptance Criteria

1. WHEN the disclaimer is displayed THEN it SHALL include a clear title indicating content warning
2. WHEN the disclaimer is displayed THEN it SHALL list specific content warnings including self-harm, mental health crisis, and disturbing imagery
3. WHEN the disclaimer is displayed THEN it SHALL explain that this is a demo ending and not the full game
4. WHEN the disclaimer is displayed THEN it SHALL provide context that the game explores serious social media issues
5. WHEN the disclaimer is displayed THEN it SHALL include a message of support and resources if needed

### Requirement 6: Opciones del Disclaimer

**User Story:** Como jugador, quiero tener control sobre si veo el contenido sensible, para que pueda proteger mi bienestar mental.

#### Acceptance Criteria

1. WHEN the disclaimer is shown THEN it SHALL display two clear options: "Continuar" and "Saltar"
2. WHEN the player selects "Continuar" THEN the System SHALL proceed to show the demo ending
3. WHEN the player selects "Saltar" THEN the System SHALL navigate to the archive screen
4. WHEN the player selects "Saltar" THEN the System SHALL still save the player's progress
5. WHEN either option is selected THEN the System SHALL provide smooth transition without jarring cuts

### Requirement 7: Diseño Visual del Disclaimer

**User Story:** Como jugador, quiero que el disclaimer sea visualmente claro y no intimidante, para que pueda leer la información sin ansiedad adicional.

#### Acceptance Criteria

1. WHEN the disclaimer is displayed THEN it SHALL use a calm, neutral color scheme
2. WHEN the disclaimer is displayed THEN it SHALL use readable font sizes of at least 18px
3. WHEN the disclaimer is displayed THEN it SHALL have sufficient padding and spacing for comfortable reading
4. WHEN the disclaimer is displayed THEN it SHALL use icons or symbols to reinforce the warning
5. WHEN the disclaimer is displayed THEN it SHALL maintain the game's visual style while being distinct

### Requirement 8: Persistencia de Decisión

**User Story:** Como jugador, quiero que mi decisión sobre ver el contenido sensible sea recordada, para que no tenga que verlo repetidamente si lo salté.

#### Acceptance Criteria

1. WHEN the player skips the demo ending THEN the System SHALL save this preference
2. WHEN the player returns to the demo ending THEN the System SHALL remember if they skipped it previously
3. WHEN the player wants to see the ending after skipping THEN the System SHALL provide an option in settings or archive
4. WHEN the preference is saved THEN it SHALL persist across game sessions
5. WHEN the player resets their data THEN the preference SHALL also be reset
