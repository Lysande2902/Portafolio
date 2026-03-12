# Design Document - Sistema de Tienda

## Overview

El Sistema de Tienda proporciona una interfaz para que los jugadores adquieran items, skins y el Battle Pass usando monedas virtuales. El diseño es minimalista, enfocándose en mostrar items disponibles, balance de monedas, y transacciones simples. Mantiene la estética oscura y atmosférica del juego.

## Architecture

### Component Structure

```
StoreScreen (StatefulWidget)
├── Video Background Layer
├── Overlay Layer (dark + VHS effects)
├── Header
│   ├── Back Button
│   ├── Title
│   └── Currency Display
├── Category Tabs
│   ├── Items Tab
│   ├── Skins Tab
│   └── Battle Pass Tab
├── Content Area
│   └── Item Grid / Battle Pass View
└── REC Indicator
```

### Data Flow

```
Firebase Firestore ←→ StoreProvider
                          ↓
                   StoreScreen
                          ↓
                   Purchase Dialog
                          ↓
                   Update Inventory
```

### State Management

- **StoreProvider**: Gestiona monedas, items, e inventario

## Components and Interfaces

### 1. Store Models

```dart
class StoreItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final StoreItemType type;
  final String iconPath;
  final bool isPremium;
}

enum StoreItemType {
  consumable,
  skin,
  battlePass
}

class PlayerInventory {
  final int coins;
  final Set<String> ownedItems;
  final bool hasBattlePass;
  final int battlePassLevel;
}
```

### 2. StoreProvider

```dart
class StoreProvider extends ChangeNotifier {
  PlayerInventory _inventory;
  
  Future<void> loadInventory(String userId);
  Future<bool> purchaseItem(StoreItem item);
  Future<void> addCoins(int amount);
  bool canAfford(int price);
  bool ownsItem(String itemId);
}
```

### 3. StoreScreen

**Responsabilidades:**
- Mostrar balance de monedas
- Listar items disponibles
- Gestionar compras
- Mostrar Battle Pass

**Key Features:**
- Video background con overlay
- Tabs para categorías
- Grid de items
- Dialogs de confirmación

## Data Models

### Firestore Structure

```
users/{userId}/
  └── inventory/
      ├── coins: 5000
      ├── ownedItems: ["item_1", "item_2"]
      ├── hasBattlePass: false
      └── battlePassLevel: 0
```

### Static Store Data

```dart
class StoreDataProvider {
  static final List<StoreItem> allItems = [
    // Consumables
    StoreItem(
      id: 'item_firewall',
      name: 'Firewall Digital',
      description: 'Escudo temporal (60s)',
      price: 500,
      type: StoreItemType.consumable,
    ),
    // Skins
    StoreItem(
      id: 'skin_anonymous',
      name: 'Anonymous',
      description: 'Máscara de Guy Fawkes',
      price: 0, // Free
      type: StoreItemType.skin,
    ),
    // Battle Pass
    StoreItem(
      id: 'battlepass_s1',
      name: 'Pase de Batalla T1',
      description: 'El Juicio Digital',
      price: 2500,
      type: StoreItemType.battlePass,
    ),
  ];
}
```

## UI/UX Design Details

### Visual Hierarchy

1. **Primary**: Currency balance y item cards
2. **Secondary**: Category tabs
3. **Tertiary**: Back button, REC indicator

### Color Scheme

- **Background**: Black with video overlay
- **Cards**: `Colors.black.withOpacity(0.8)` with red borders
- **Currency**: Gold/yellow color
- **Owned Items**: Green tint
- **Premium**: Red glow

### Typography

- **Title**: Courier Prime, 24px, Bold, Letter Spacing 4
- **Item Name**: Courier Prime, 16px, Bold, Letter Spacing 2
- **Price**: Courier Prime, 18px, White
- **Description**: Courier Prime, 12px, Grey[400]

### Layout

```
┌─────────────────────────────────────┐
│ [←] TIENDA          💰 5,000       │
├─────────────────────────────────────┤
│ [ITEMS] [SKINS] [BATTLE PASS]      │
├─────────────────────────────────────┤
│ ┌─────┐ ┌─────┐ ┌─────┐           │
│ │Item │ │Item │ │Item │           │
│ │500💰│ │1000│ │FREE │           │
│ └─────┘ └─────┘ └─────┘           │
└─────────────────────────────────────┘
```

## Implementation Notes

### Phase 1: Basic Structure (Day 1)
- Create Store models
- Setup StoreProvider
- Create basic StoreScreen layout

### Phase 2: Items & Purchase (Day 1)
- Implement item grid
- Add purchase dialog
- Connect to Firebase

### Phase 3: Battle Pass (Optional)
- Create Battle Pass view
- Add level progression
- Show rewards

### Phase 4: Polish (Day 1)
- Add animations
- Test purchases
- Verify persistence
