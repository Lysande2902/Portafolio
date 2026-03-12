# Requirements Document

## Introduction

This specification addresses two UI polish issues in the game: removing the redundant continue button from the arc intro screen and redesigning the tutorial button in the pause menu for a more subtle appearance.

## Glossary

- **Arc Intro Screen**: The narrative screen shown before starting each arc with typewriter text effect
- **Pause Menu**: The overlay menu displayed when the game is paused
- **Continue Button**: The "TOCA PARA CONTINUAR" button that appears at the bottom of the arc intro screen
- **Skip Button**: The "SALTAR [ESC]" button in the top-right corner of screens
- **Tutorial Button**: The "VER TUTORIAL" button in the pause menu

## Requirements

### Requirement 1

**User Story:** As a player viewing the arc intro screen, I want a cleaner interface without redundant controls, so that I can focus on the narrative without visual clutter.

#### Acceptance Criteria

1. WHEN the arc intro typewriter animation completes THEN the system SHALL automatically continue after 2 seconds without displaying a continue button
2. WHEN a player wants to skip the intro THEN the system SHALL provide only the skip button in the top-right corner
3. WHEN the intro screen is displayed THEN the system SHALL NOT show the "TOCA PARA CONTINUAR" button at the bottom
4. WHEN the auto-continue timer triggers THEN the system SHALL transition to the next screen smoothly

### Requirement 2

**User Story:** As a player accessing the pause menu, I want the tutorial button to have a more subtle and refined appearance, so that the menu feels cohesive and well-designed.

#### Acceptance Criteria

1. WHEN the pause menu is displayed THEN the system SHALL show the tutorial button with a subtle, text-only design
2. WHEN the tutorial button is rendered THEN the system SHALL use a minimal style without prominent borders or backgrounds
3. WHEN the tutorial button is displayed THEN the system SHALL maintain visual hierarchy with the primary action buttons
4. WHEN a player interacts with the tutorial button THEN the system SHALL provide appropriate visual feedback
5. WHEN the pause menu layout is rendered THEN the system SHALL ensure the tutorial button does not compete visually with continue and exit buttons
