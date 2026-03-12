# Requirements Document

## Introduction

This specification addresses a critical bug in the Flame game integration where the game instance is being re-attached to multiple GameWidget instances, causing the error "A game instance can only be attached to one widget at a time." The root cause is that Flutter rebuilds the GameWidget on every build cycle, and Flame detects this as an attempt to attach the same game instance to multiple widgets.

## Glossary

- **GameWidget**: A Flame framework widget that wraps a game instance and renders it
- **Game Instance**: The Flame game object (e.g., GluttonyArcGame, GreedArcGame) that contains game logic and state
- **Widget Rebuild**: Flutter's process of recreating widgets when state changes
- **Game Attachment**: The process where Flame connects a game instance to a GameWidget for rendering
- **StatefulWidget**: A Flutter widget that maintains mutable state across rebuilds
- **initState**: A lifecycle method in StatefulWidget that runs once when the widget is first created
- **build**: A lifecycle method in StatefulWidget that runs every time the widget needs to be redrawn

## Requirements

### Requirement 1

**User Story:** As a game developer, I want the game instance to remain attached to a single stable GameWidget, so that the game runs without attachment errors.

#### Acceptance Criteria

1. WHEN the ArcGameScreen widget is created THEN the system SHALL create exactly one GameWidget instance in initState
2. WHEN the ArcGameScreen widget rebuilds THEN the system SHALL reuse the same GameWidget instance created in initState
3. WHEN the game is running THEN the system SHALL NOT create new GameWidget instances during build cycles
4. WHEN the widget tree rebuilds THEN the system SHALL maintain the same game-to-widget attachment throughout the widget's lifetime
5. WHEN the ArcGameScreen is disposed THEN the system SHALL properly clean up the game instance

### Requirement 2

**User Story:** As a game developer, I want the game instance to be created once and reused, so that game state is preserved across widget rebuilds.

#### Acceptance Criteria

1. WHEN the ArcGameScreen initializes THEN the system SHALL create the game instance exactly once in initState
2. WHEN Flutter rebuilds the widget THEN the system SHALL NOT recreate the game instance
3. WHEN the game state changes THEN the system SHALL preserve the same game instance reference
4. WHEN the widget rebuilds due to parent changes THEN the system SHALL maintain the existing game instance
