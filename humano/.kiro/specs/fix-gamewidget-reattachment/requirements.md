# Requirements Document

## Introduction

The game experiences a persistent "A game instance can only be attached to one widget at a time" error when entering arcs. The logs show that the game instance is created correctly in `initState()`, but the `GameWidget` is being rebuilt during the widget lifecycle, causing Flame to attempt reattachment of the same game instance, which is not allowed.

## Glossary

- **GameWidget**: The Flame framework widget that renders a game instance
- **Game Instance**: A single instance of a Flame game (e.g., GluttonyArcGame, GreedArcGame)
- **Widget Rebuild**: When Flutter reconstructs a widget due to state changes or parent rebuilds
- **Attachment**: The process of connecting a game instance to a GameWidget's render tree
- **ValueListenableBuilder**: A Flutter widget that rebuilds when a ValueNotifier changes
- **Widget Key**: A Flutter identifier that helps the framework track widget identity across rebuilds

## Requirements

### Requirement 1

**User Story:** As a player, I want to enter any arc without encountering attachment errors, so that I can play the game smoothly.

#### Acceptance Criteria

1. WHEN a player navigates to an arc screen THEN the system SHALL create exactly one game instance in initState
2. WHEN the GameWidget is built THEN the system SHALL attach the game instance exactly once
3. WHEN parent widgets rebuild THEN the system SHALL preserve the GameWidget identity and prevent reattachment
4. WHEN ValueListenableBuilders rebuild THEN the system SHALL not trigger GameWidget rebuilds
5. WHEN the screen is disposed THEN the system SHALL properly detach the game instance

### Requirement 2

**User Story:** As a developer, I want the GameWidget to maintain stable identity across rebuilds, so that Flame doesn't attempt reattachment.

#### Acceptance Criteria

1. WHEN the GameWidget is created THEN the system SHALL assign it a stable key based on the game instance
2. WHEN the widget tree rebuilds THEN the system SHALL use the key to identify the same GameWidget
3. WHEN the game instance changes THEN the system SHALL create a new key to allow proper reattachment
4. WHEN using keys THEN the system SHALL ensure they are unique per game instance

### Requirement 3

**User Story:** As a developer, I want to understand why rebuilds are happening, so that I can prevent unnecessary GameWidget reconstructions.

#### Acceptance Criteria

1. WHEN investigating the issue THEN the system SHALL identify all sources of widget rebuilds
2. WHEN ValueListenableBuilders are used THEN the system SHALL ensure they don't wrap or trigger GameWidget rebuilds
3. WHEN the Stack widget rebuilds THEN the system SHALL ensure GameWidget maintains its identity
4. WHEN debugging THEN the system SHALL provide clear logs showing widget lifecycle events
