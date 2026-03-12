# Requirements Document - Sistema de Tienda

## Introduction

El Sistema de Tienda permite a los jugadores adquirir items, skins, y contenido adicional usando monedas del juego o compras reales. Incluye un sistema de monedas virtuales, pase de batalla, y cosméticos que mantienen la estética oscura del juego.

## Glossary

- **Store System**: Sistema que gestiona la tienda y transacciones
- **Store Screen**: Pantalla donde el jugador navega y compra items
- **Currency**: Monedas virtuales del juego
- **Store Item**: Producto disponible para compra (skin, item, etc.)
- **Battle Pass**: Pase de temporada con recompensas progresivas
- **Transaction**: Compra de un item con monedas o dinero real
- **Inventory**: Colección de items que posee el jugador
- **Player**: Usuario que interactúa con el sistema

## Requirements

### Requirement 1

**User Story:** As a Player, I want to see my current currency balance, so that I know how much I can spend

#### Acceptance Criteria

1. THE Store Screen SHALL display the Player's current coin balance prominently
2. THE Store System SHALL update the balance in real-time after purchases
3. THE Store System SHALL persist the currency balance in Firebase
4. WHEN the Player earns coins, THE Store System SHALL update the balance immediately
5. THE Store Screen SHALL show currency with an icon and formatted number

### Requirement 2

**User Story:** As a Player, I want to browse available items, so that I can see what I can purchase

#### Acceptance Criteria

1. THE Store Screen SHALL display items organized in categories (Items, Skins, Battle Pass)
2. WHEN displaying an item, THE Store System SHALL show name, description, price, and preview
3. THE Store System SHALL indicate if an item is already owned
4. THE Store System SHALL show if an item is on sale or discounted
5. THE Store Screen SHALL use a scrollable grid or list layout

### Requirement 3

**User Story:** As a Player, I want to purchase items with coins, so that I can unlock new content

#### Acceptance Criteria

1. WHEN the Player taps on an item, THE Store System SHALL show a purchase confirmation dialog
2. THE confirmation SHALL display item details and final price
3. WHEN confirmed, THE Store System SHALL deduct coins and add item to inventory
4. IF the Player has insufficient coins, THE Store System SHALL show an error message
5. WHEN purchase is complete, THE Store System SHALL show a success message

### Requirement 4

**User Story:** As a Player, I want to see the Battle Pass, so that I can track seasonal rewards

#### Acceptance Criteria

1. THE Store Screen SHALL have a dedicated Battle Pass section
2. THE Battle Pass SHALL display current level and progress
3. THE Battle Pass SHALL show rewards for each level (free and premium tracks)
4. THE Store System SHALL indicate which rewards are unlocked
5. THE Store System SHALL allow purchasing the premium Battle Pass

### Requirement 5

**User Story:** As a Player, I want the store to match the game's aesthetic, so that it feels cohesive

#### Acceptance Criteria

1. THE Store Screen SHALL use the VHS/glitch aesthetic consistent with other screens
2. THE Store Screen SHALL display a video background with dark overlay
3. THE Store Screen SHALL use the Courier Prime font for all text
4. THE Store Screen SHALL include the REC indicator in the corner
5. THE Store Screen SHALL use dark colors with red accents

### Requirement 6

**User Story:** As a Player, I want to return to the menu from the store, so that I can access other features

#### Acceptance Criteria

1. THE Store Screen SHALL display a back button in the top-left corner
2. WHEN the Player taps the back button, THE Store System SHALL navigate back to the menu
3. WHEN navigating back, THE Store System SHALL dispose of resources properly
4. THE Store System SHALL save any pending changes before navigating
5. WHEN the Player uses the system back gesture, THE Store System SHALL return to the menu screen
