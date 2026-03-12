# Design Document - Arc Code Review and Fixes

## Overview

This document outlines the comprehensive design for reviewing and fixing all issues in the three implemented arcs (Gula, Avaricia, Envidia) of "The Quiescent Heart". The goal is to ensure robust, bug-free gameplay with proper UI reactivity, Firebase synchronization, memory management, and error handling.

## Architecture

### Current Architecture Analysis

The game follows a layered architecture:

1. **Presentation Layer** (`lib/screens/`)
   - `arc_game_screen.dart`: Main game screen that hosts Flame games
   - Handles UI overlays (HUD, pause menu, victory/game over screens)
   - Manages user input and item usage

2. **Game Logic Layer** (`lib/game/arcs/`)
   - `gluttony_arc_game.dart`: Arco 1 (Gula) game logic
   - `greed_arc_game.dart`: Arco 2 (Avaricia) game logic
   - `envy_arc_game.dart`: Arco 3 (Envidia) game logic
   - Each extends `BaseArcGame` for common functionality

3. **State Management Layer** (`lib/providers/`)
   - `UserDataProvider`: Global user state
   - `StoreProvider`: Inventory and consumables
   - `ArcProgressProvider`: Arc completion tracking
   - `EvidenceProvider`: Evidence collection
   - `PuzzleDataProvider`: Fragment collection

4. **Data Layer** (`lib/data/`)
   - `UserRepository`: Firebase operations
   - `UserData` model: Data structure

### Key Issues Identified

Based on code analysis, the following issues need attention:

**Arco 1 (Gula):**
- Food inventory system needs UI reactivity verification
- Food throw mechanic needs range validation
- Memory cleanup in `resetGame()` needs verification
- DiscomfortEffectsManager disposal needs checking

**Arco 2 (Avaricia):**
- Coin inventory system needs atomic operations
- Cash register recovery needs balance verification
- Enemy steal mechanic needs proper state synchronization
- Background music disposal needs verification

**Arco 3 (Envidia):**
- Camera/photograph system needs UI updates
- Enemy phase transitions need smooth handling
- Screen shake effects need performance optimization
- Memory management for photograph components

**Cross-Arc Issues:**
- Firebase persistence timing
- Provider state synchronization
- Memory leaks from listeners
- Error handling consistency
- UI reactivity delays

## Components and Interfaces

### 1. Arc Game Screen Interface

```dart
class ArcGameScreen extends StatefulWidget {
  final String arcId;
  
  // State management
  Map<String, int> availableItems;
  bool showPauseMenu;
  bool _throwMode;
  
  // Core methods
  void _initializeGame();
  void _loadInventory();
  void _useItem(String itemId);
  Future<void> _saveProgress();
  void _handleThrowTap(Offset screenPos);
}
```

### 2. Base Arc Game Interface

```dart
abstract class BaseArcGame extends FlameGame {
  // Core game state
  int evidenceCollected;
  bool isGameOver;
  bool isVictory;
  double elapsedTime;
  
  // Skins
  String? equippedPlayerSkin;
  String? equippedEnemySkin;
  
  // Lifecycle methods
  Future<void> setupPlayer();
  Future<void> setupScene();
  Future<void> setupEnemy();
  Future<void> setupCollectibles();
  void updateGame(double dt);
  Future<void> resetGame();
  
  // Game state methods
  void onVictory();
  void onGameOver();
}
```

### 3. Provider Interfaces

```dart
// UserDataProvider
class UserDataProvider extends ChangeNotifier {
  UserData? userData;
  Future<void> loadUserData();
  Future<void> updateUserData(UserData data);
}

// StoreProvider
class StoreProvider extends ChangeNotifier {
  Inventory inventory;
  Future<bool> useConsumable(String itemId);
  Future<void> addCoins(int amount);
}

// ArcProgressProvider
class ArcProgressProvider extends ChangeNotifier {
  Future<void> completeArc(String arcId, List<String> evidenceIds);
  bool isArcCompleted(String arcId);
}
```

## Data Models

### Arc-Specific Inventory Models

**Arco 1 (Gula):**
```dart
class FoodInventory {
  List<FoodType> items;
  int maxCapacity = 2;
  
  bool canCollect() => items.length < maxCapacity;
  void add(FoodType food);
  FoodType? removeFirst();
}

enum FoodType { apple, salad }
```

**Arco 2 (Avaricia):**
```dart
class CoinInventory {
  List<CoinType> items;
  int maxCapacity = 2;
  
  bool canCollect() => items.length < maxCapacity;
  void add(CoinType coin);
  CoinType? removeFirst();
}

enum CoinType { gold, silver }
```

**Arco 3 (Envidia):**
```dart
class CameraInventory {
  int photoCount;
  int maxCapacity = 3;
  
  bool canTakePhoto() => photoCount < maxCapacity;
  void addPhoto();
  void usePhoto();
}
```

### Game State Model

```dart
class GameState {
  Vector2 playerPosition;
  Vector2 enemyPosition;
  double sanityLevel;
  int evidenceCount;
  bool isPlayerHidden;
  bool isEnemyEnraged;
  
  // Arc-specific state
  Map<String, dynamic> arcSpecificData;
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Inventory UI Synchronization
*For any* inventory change (food, coins, photos), the UI SHALL reflect the new state within 100ms and Firebase SHALL be updated within 2 seconds.
**Validates: Requirements 1.1, 2.1, 3.1, 4.1, 5.1**

### Property 2: Inventory Capacity Enforcement
*For any* inventory type, when at maximum capacity, the system SHALL prevent collection and display feedback to the user.
**Validates: Requirements 1.3, 2.2, 3.2**

### Property 3: Atomic State Updates
*For any* state-modifying operation (collecting, consuming, spending), the operation SHALL be atomic to prevent race conditions and data corruption.
**Validates: Requirements 2.3, 5.4**

### Property 4: State Persistence Round-Trip
*For any* arc, saving game state then loading it SHALL restore the exact same state (evidence count, inventory, progress).
**Validates: Requirements 1.5, 2.5, 3.5**

### Property 5: Firebase Retry on Failure
*For any* Firebase operation that fails, the system SHALL retry with exponential backoff and notify the user if all retries fail.
**Validates: Requirements 5.2, 7.2**

### Property 6: Offline Queue Synchronization
*For any* state change while offline, the system SHALL queue the change locally and sync to Firebase when connection is restored.
**Validates: Requirements 5.3**

### Property 7: Resource Cleanup on Navigation
*For any* navigation between arcs or screens, all listeners, subscriptions, and resources SHALL be properly disposed to prevent memory leaks.
**Validates: Requirements 6.2, 6.4**

### Property 8: Asset Caching Efficiency
*For any* loaded asset (images, sounds), the system SHALL cache it for reuse and release it when no longer needed.
**Validates: Requirements 6.3**

### Property 9: Lifecycle State Restoration
*For any* app backgrounding and resuming, the system SHALL restore game state without memory spikes or data loss.
**Validates: Requirements 6.5**

### Property 10: Error Handling Without Crashes
*For any* unexpected error (null data, parsing errors, Firebase failures), the system SHALL handle it gracefully without crashing.
**Validates: Requirements 7.1, 7.2, 7.3, 7.4**

### Property 11: Input Validation and Feedback
*For any* invalid user action, the system SHALL prevent execution and provide clear feedback explaining why.
**Validates: Requirements 7.5**

### Property 12: Async Error Handling
*For any* async operation, the system SHALL have proper try-catch blocks and error handling to prevent unhandled exceptions.
**Validates: Requirements 8.4**

### Property 13: UI Reactivity Under Load
*For any* rapid sequence of state changes, the UI SHALL update correctly without freezing, stuttering, or dropping updates.
**Validates: Requirements 4.4**

### Property 14: Immediate Visual Feedback
*For any* user interaction (button press, item use, collection), the system SHALL provide immediate visual feedback within 50ms.
**Validates: Requirements 4.5, 4.6**

### Property 16: Collection Visual Feedback
*For any* collectible item (food, evidence, coins, photos), when collected, the system SHALL display an immediate in-game visual effect (particle, animation, or floating text) at the collection point.
**Validates: Requirements 1.1, 2.1, 3.1, 4.6**

### Property 15: Provider State Consistency
*For any* state change in a Provider, all listening widgets SHALL receive the update and re-render correctly.
**Validates: Requirements 4.3**

## Error Handling

### Error Categories

1. **Network Errors**
   - Firebase connection failures
   - Timeout errors
   - Offline state

2. **Data Errors**
   - Null or invalid data
   - Parsing failures
   - Type mismatches

3. **Game Logic Errors**
   - Invalid state transitions
   - Boundary condition violations
   - Race conditions

4. **Resource Errors**
   - Asset loading failures
   - Memory allocation failures
   - Disposal errors

### Error Handling Strategy

```dart
// Pattern 1: Try-Catch with Logging
try {
  await riskyOperation();
} catch (e, stackTrace) {
  print('❌ Error in operation: $e');
  print('Stack trace: $stackTrace');
  // Show user-friendly message
  showErrorSnackBar('Operation failed. Please try again.');
}

// Pattern 2: Null Safety with Defaults
final value = nullableValue ?? safeDefault;

// Pattern 3: Validation Before Operation
if (!isValidState()) {
  showFeedback('Cannot perform action in current state');
  return;
}

// Pattern 4: Firebase Retry Logic
Future<void> retryableFirebaseOperation() async {
  int attempts = 0;
  const maxAttempts = 3;
  
  while (attempts < maxAttempts) {
    try {
      await firebaseOperation();
      return;
    } catch (e) {
      attempts++;
      if (attempts >= maxAttempts) {
        throw e;
      }
      await Future.delayed(Duration(seconds: pow(2, attempts).toInt()));
    }
  }
}
```

## Testing Strategy

### Unit Testing

Unit tests will cover:
- Individual component logic (inventory management, state transitions)
- Provider methods (add/remove items, update state)
- Utility functions (validation, calculations)
- Error handling paths

Example unit tests:
```dart
test('Food inventory prevents collection when full', () {
  final inventory = FoodInventory();
  inventory.add(FoodType.apple);
  inventory.add(FoodType.salad);
  
  expect(inventory.canCollect(), false);
});

test('Firebase retry logic attempts 3 times', () async {
  int attempts = 0;
  final operation = () async {
    attempts++;
    throw Exception('Firebase error');
  };
  
  await expectLater(
    retryOperation(operation, maxAttempts: 3),
    throwsException,
  );
  expect(attempts, 3);
});
```

### Property-Based Testing

We will use the **test** package with custom generators for property-based testing in Dart/Flutter.

Configuration:
- Minimum 100 iterations per property test
- Custom generators for game state, inventory, and user actions
- Shrinking enabled to find minimal failing cases

Property test structure:
```dart
import 'package:test/test.dart';

void main() {
  group('Property Tests', () {
    test('Property 1: Inventory UI Synchronization', () {
      // **Feature: arc-code-review-fixes, Property 1: Inventory UI Synchronization**
      for (int i = 0; i < 100; i++) {
        final inventory = generateRandomInventory();
        final initialState = captureUIState();
        
        inventory.addItem(generateRandomItem());
        
        final uiUpdateTime = measureUIUpdateTime();
        expect(uiUpdateTime, lessThan(Duration(milliseconds: 100)));
        
        final firebaseUpdateTime = measureFirebaseUpdateTime();
        expect(firebaseUpdateTime, lessThan(Duration(seconds: 2)));
      }
    });
  });
}
```

Each property test MUST:
1. Be tagged with the format: `**Feature: arc-code-review-fixes, Property {number}: {property_text}**`
2. Run at least 100 iterations
3. Test the universal property across all valid inputs
4. Verify both positive and negative cases

### Integration Testing

Integration tests will verify:
- Complete arc playthrough (collect evidence, reach exit)
- Cross-provider communication (UserDataProvider ↔ StoreProvider)
- Firebase persistence and retrieval
- UI navigation flows

### Performance Testing

Performance tests will measure:
- UI update latency (target: <100ms)
- Firebase operation timing (target: <2s)
- Memory usage over time (target: stable, no leaks)
- Frame rate during gameplay (target: 60fps)

### Manual Testing Checklist

For each arc, manually verify:
- [ ] Collect all evidence types
- [ ] Use all consumable items
- [ ] Reach maximum inventory capacity
- [ ] Complete arc and verify Firebase save
- [ ] Exit and re-enter arc to verify state restoration
- [ ] Test offline mode and sync
- [ ] Trigger all error conditions
- [ ] Play for extended period (30+ minutes)
- [ ] Background and resume app
- [ ] Navigate between arcs multiple times

## Implementation Plan

The implementation will follow these phases:

### Phase 1: Code Analysis and Issue Identification
- Review all arc game files for bugs
- Check provider implementations for race conditions
- Analyze Firebase operations for proper error handling
- Identify memory leak sources

### Phase 2: Core Fixes
- Fix inventory synchronization issues
- Implement atomic state updates
- Add proper error handling to all async operations
- Fix memory leaks in resetGame() and disposal

### Phase 3: UI Reactivity Improvements
- Optimize provider notifications
- Reduce UI update latency
- Add immediate visual feedback
- Fix stuttering and freezing issues

### Phase 4: Firebase Robustness
- Implement retry logic with exponential backoff
- Add offline queue and sync
- Improve error messages
- Add operation timing logs

### Phase 5: Testing and Validation
- Write unit tests for all fixes
- Implement property-based tests
- Run integration tests
- Perform manual testing
- Measure performance metrics

### Phase 6: Documentation and Cleanup
- Document all fixes made
- Update code comments
- Clean up debug logs
- Create testing guide

## Performance Considerations

### Target Metrics

- **UI Update Latency:** <100ms from state change to UI render
- **Firebase Write:** <2s from state change to Firebase confirmation
- **Frame Rate:** Maintain 60fps during gameplay
- **Memory Usage:** Stable over 1-hour session, <200MB growth
- **App Launch:** <3s from splash to menu
- **Arc Load:** <2s from selection to gameplay

### Optimization Strategies

1. **Debouncing:** Batch rapid state changes
2. **Lazy Loading:** Load assets on-demand
3. **Caching:** Cache frequently accessed data
4. **Disposal:** Aggressively dispose unused resources
5. **Async Operations:** Use isolates for heavy computations

## Security Considerations

### Firebase Security

- Validate all user inputs before Firebase writes
- Use Firebase Security Rules to prevent unauthorized access
- Sanitize data to prevent injection attacks
- Rate limit operations to prevent abuse

### Data Integrity

- Use transactions for atomic updates
- Validate data types and ranges
- Handle concurrent modifications
- Implement optimistic locking where needed

## Monitoring and Logging

### Logging Strategy

```dart
// Structured logging with levels
enum LogLevel { debug, info, warning, error }

void log(LogLevel level, String message, [dynamic data]) {
  final timestamp = DateTime.now().toIso8601String();
  final prefix = {
    LogLevel.debug: '🐛',
    LogLevel.info: 'ℹ️',
    LogLevel.warning: '⚠️',
    LogLevel.error: '❌',
  }[level];
  
  print('$prefix [$timestamp] $message');
  if (data != null) {
    print('   Data: $data');
  }
}
```

### Key Metrics to Track

- Evidence collection rate
- Item usage frequency
- Arc completion time
- Death/retry count
- Firebase operation success rate
- Error occurrence frequency
- Memory usage trends
- Frame rate drops

## Rollback Plan

If critical issues are discovered:

1. **Immediate:** Revert to last known good commit
2. **Short-term:** Fix critical bug in isolation
3. **Long-term:** Re-run full test suite before deployment

## Success Criteria

The arc code review and fixes will be considered successful when:

1. ✅ All 15 correctness properties pass property-based tests
2. ✅ All unit tests pass (target: 100% coverage of fixed code)
3. ✅ All integration tests pass
4. ✅ Manual testing checklist completed for all 3 arcs
5. ✅ Performance metrics meet targets
6. ✅ No memory leaks detected in 1-hour test session
7. ✅ No crashes or unhandled exceptions in testing
8. ✅ Firebase operations succeed with <1% failure rate
9. ✅ UI remains responsive under all tested conditions
10. ✅ Code review approved by team

## Conclusion

This design provides a comprehensive approach to reviewing and fixing all issues in the three implemented arcs. By following the correctness properties, implementing robust error handling, and thoroughly testing all changes, we will ensure a stable, performant, and bug-free gaming experience for all players.
