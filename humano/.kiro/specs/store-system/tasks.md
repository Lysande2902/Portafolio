# Implementation Plan - Sistema de Tienda

- [x] 1. Create store data models


  - Create StoreItem model with all properties
  - Create StoreItemType enum (consumable, skin, battlePass)
  - Create PlayerInventory model
  - Add serialization methods
  - _Requirements: 1.1, 2.2, 3.1_



- [ ] 2. Create StoreDataProvider with static items
  - Define store items (consumables, skins, battle pass)
  - Organize items by category




  - Add helper methods to get items by type
  - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [ ] 3. Implement StoreProvider with Firebase
- [ ] 3.1 Create StoreProvider with ChangeNotifier
  - Implement loadInventory method

  - Implement purchaseItem method
  - Implement addCoins method
  - Implement canAfford and ownsItem checks
  - Add local caching
  - _Requirements: 1.2, 1.3, 1.4, 3.2, 3.3, 3.4_


- [ ] 3.2 Add transaction logic
  - Validate purchase (sufficient coins, not owned)
  - Deduct coins and add item to inventory
  - Save to Firebase
  - Show success/error feedback
  - _Requirements: 3.2, 3.3, 3.4, 3.5_



- [ ] 4. Build StoreItemCard widget
  - Design card layout with icon, name, price
  - Show "OWNED" badge if already purchased
  - Show "FREE" badge for free items
  - Add tap interaction
  - Apply game aesthetic

  - _Requirements: 2.2, 2.3, 2.4_

- [ ] 5. Create StoreScreen
- [ ] 5.1 Build screen structure
  - Setup video background and overlay

  - Add header with back button and currency display
  - Add category tabs (Items, Skins, Battle Pass)
  - Add REC indicator
  - _Requirements: 1.1, 1.5, 5.1, 5.2, 5.3, 5.4, 5.5, 6.1_

- [x] 5.2 Implement currency display

  - Show coin balance with icon
  - Update in real-time after purchases
  - Format numbers with commas
  - _Requirements: 1.1, 1.2, 1.5_

- [ ] 5.3 Implement item grid
  - Create grid layout for items
  - Filter items by selected category
  - Show StoreItemCards
  - Handle empty states
  - _Requirements: 2.1, 2.5_

- [x] 5.4 Implement purchase dialog

  - Show item details and price

  - Add confirm/cancel buttons
  - Check if player can afford
  - Execute purchase on confirm
  - Show success/error messages

  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5_

- [ ]* 6. Add Battle Pass view
  - Create Battle Pass section
  - Show current level and progress
  - Display rewards (free and premium tracks)
  - Allow purchasing premium pass
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5_

- [x] 7. Integrate with existing systems


- [x] 7.1 Register StoreProvider in main.dart

  - Add StoreProvider to MultiProvider
  - Initialize inventory on app start
  - _Requirements: 1.3_

- [ ] 7.2 Connect to MenuScreen
  - Update MenuScreen STORE button handler
  - Add navigation to StoreScreen

  - Test navigation flow
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [ ]* 8. Add coin earning system
  - Create method to award coins for completing arcs
  - Add coins for achievements
  - Show coin reward animations
  - _Requirements: 1.4_

- [ ] 9. Final integration testing
- [ ] 9.1 Test complete store flow
  - Test navigation: Menu → Store → Back
  - Verify purchases work correctly
  - Test insufficient funds error
  - Verify owned items are marked
  - Test persistence after app restart
  - _Requirements: All requirements_

- [ ] 9.2 Verify visual consistency
  - Check aesthetic matches other screens
  - Verify fonts, colors, spacing
  - Test on different screen sizes
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_
