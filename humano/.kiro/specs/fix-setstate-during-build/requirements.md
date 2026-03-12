# Requirements Document

## Introduction

This document specifies the requirements for fixing the "setState() or markNeedsBuild() called during build" error that is causing game attachment issues in the ArcGameScreen. The error occurs when game initialization triggers widget rebuilds, which causes the Flame GameWidget to attempt re-attachment while already attached.

## Glossary

- **GameWidget**: The Flame engine widget that hosts the game instance
- **Game Instance**: The Flame game object (GluttonyArcGame, GreedArcGame, etc.)
- **setState()**: Flutter method that triggers a widget rebuild
- **Build Phase**: The period when Flutter is constructing the widget tree
- **Game Attachment**: The process of connecting a game instance to a GameWidget

## Requirements

### Requirement 1

**User Story:** As a developer, I want the game to initialize without triggering setState during build, so that the game attachment error does not occur.

#### Acceptance Criteria

1. WHEN the ArcGameScreen initializes THEN the system SHALL NOT call setState() during the build phase
2. WHEN game state changes occur during initialization THEN the system SHALL defer state updates until after the build phase completes
3. WHEN the GameWidget is created THEN the system SHALL ensure the game instance is fully initialized before attachment
4. WHEN providers are configured THEN the system SHALL NOT trigger widget rebuilds during the build phase
5. WHEN the game starts THEN the system SHALL complete all initialization without causing game attachment errors

### Requirement 2

**User Story:** As a developer, I want clear separation between initialization and reactive updates, so that the widget lifecycle is predictable and error-free.

#### Acceptance Criteria

1. WHEN initialization occurs THEN the system SHALL complete all setup in initState() or didChangeDependencies()
2. WHEN reactive updates are needed THEN the system SHALL use ValueListenableBuilder or similar mechanisms that don't trigger setState during build
3. WHEN the game needs to communicate state changes THEN the system SHALL use callbacks or post-frame callbacks to avoid build-phase updates
4. WHEN debugging THEN the system SHALL log clear messages about initialization phases without triggering rebuilds

### Requirement 3

**User Story:** As a player, I want the game to load smoothly without errors, so that I can start playing immediately.

#### Acceptance Criteria

1. WHEN I navigate to a game arc THEN the system SHALL display the game without console errors
2. WHEN the game initializes THEN the system SHALL show no "setState during build" warnings
3. WHEN the game starts THEN the system SHALL show no "Game attachment error" messages
4. WHEN I play the game THEN the system SHALL maintain stable performance without attachment issues
5. WHEN I retry after game over THEN the system SHALL reset cleanly without attachment errors
