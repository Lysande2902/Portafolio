# Design Document

## Overview

Este diseño soluciona el problema crítico donde los fragmentos (expedientes) no se guardan en Firebase durante el gameplay. La solución elimina la dependencia frágil en `BuildContext` y establece una referencia directa al `FragmentsProvider` que se mantiene válida durante todo el ciclo de vida del juego.

### Problema Actual

```dart
// En gluttony_arc_game.dart (línea 476-483)
if (buildContext != null) {
    PuzzleIntegrationHelper.collectFragment(
      context: buildContext!,
      arcId: 'gluttony',
      fragmentNumber: evidenceCollected,
    );
}
```

**Problemas:**
1. `buildContext` puede ser `null` cuando se recolecta evidencia
2. Dependencia frágil en el contexto de Flutter desde el juego Flame
3. No hay validación de que el guardado fue exitoso
4. IDs de arcos inconsistentes ('gluttony' vs 'arc_1_gula')

### Solución Propuesta

Establecer una referencia directa al `FragmentsProvider` en el juego, eliminando la necesidad de `BuildContext` durante la recolección.

## Architecture

### Flujo Actual (Problemático)
```
Player collects evidence
  ↓
Game checks buildContext != null
  ↓
Calls PuzzleIntegrationHelper.collectFragment(context)
  ↓
Helper uses Provider.of<FragmentsProvider>(context)
  ↓
❌ FALLA si context es null
```

### Flujo Nuevo (Robusto)
```
ArcGameScreen.initState()
  ↓
Get FragmentsProvider reference
  ↓
Pass reference to game.setFragmentsProvider()
  ↓
Game stores provider reference
  ↓
Player collects evidence
  ↓
Game calls fragmentsProvider.unlockFragment() directly
  ↓
✅ SIEMPRE funciona (no depende de context)
```

## Components and Interfaces

### 1. BaseArcGame (Modificado)

Agregar soporte para referencia directa al provider:

```dart
abstract class BaseArcGame extends FlameGame {
  // Direct reference to FragmentsProvider (no BuildContext needed)
  FragmentsProvider? _fragmentsProvider;
  
  /// Set the fragments provider (called from screen)
  void setFragmentsProvider(FragmentsProvider provider) {
    _fragmentsProvider = provider;
    print('✅ FragmentsProvider set for game');
  }
  
  /// Save fragment directly using provider reference
  Future<void> saveFragment(String arcId, int fragmentNumber) async {
    if (_fragmentsProvider == null) {
      print('❌ FragmentsProvider not set - cannot save fragment');
      return;
    }
    
    try {
      // Normalize arc ID to standard format
      final normalizedArcId = _normalizeArcId(arcId);
      
      print('💾 Saving fragment: $normalizedArcId - Fragment $fragmentNumber');
      await _fragmentsProvider!.unlockFragment(normalizedArcId, fragmentNumber);
      print('✅ Fragment saved successfully');
    } catch (e, stackTrace) {
      print('❌ Error saving fragment: $e');
      print('Stack trace: $stackTrace');
    }
  }
  
  /// Normalize arc ID to standard format
  String _normalizeArcId(String arcId) {
    switch (arcId.toLowerCase()) {
      case 'gluttony':
      case 'gula':
        return 'arc_1_gula';
      case 'greed':
      case 'avaricia':
        return 'arc_2_greed';
      case 'envy':
      case 'envidia':
        return 'arc_3_envy';
      default:
        // Already in standard format or unknown
        return arcId;
    }
  }
}
```

### 2. ArcGameScreen (Modificado)

Pasar la referencia del provider al juego:

```dart
class _ArcGameScreenState extends State<ArcGameScreen> {
  @override
  void initState() {
    super.initState();
    
    // Create game instance
    game = _createGameForArc(widget.arcId);
    
    // ✅ NEW: Set FragmentsProvider reference
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final fragmentsProvider = Provider.of<FragmentsProvider>(context, listen: false);
      game.setFragmentsProvider(fragmentsProvider);
      print('✅ FragmentsProvider passed to game');
    });
    
    // Listen to game state changes
    game.stateNotifier.addListener(_onGameStateChanged);
  }
}
```

### 3. GluttonyArcGame (Modificado)

Usar el nuevo método de guardado:

```dart
void _checkEvidenceCollection() {
  if (_player == null || _enemy == null) return;

  for (final component in world.children) {
    if (component is EvidenceComponent && !component.isCollected) {
      final distance = (component.position - _player!.position).length;
      if (distance < 50) {
        // Collect evidence
        component.collect();
        evidenceCollected++;
        print('✨ Fragmento recolectado! Total: $evidenceCollected/5');
        
        // ✅ NEW: Save using direct provider reference
        saveFragment('gluttony', evidenceCollected);
        
        // Show notification
        onEvidenceCollected?.call(evidenceCollected, 5);
        
        // Apply sanity penalty
        sanitySystem.takeDamage(4.0);
        
        // Teleport enemy if low sanity
        if (sanitySystem.currentSanity <= 0.85) {
          _teleportEnemyNearPlayer();
        }
        
        // Trigger feedback
        discomfortManager?.triggerEvidenceCollection();
      }
    }
  }
}
```

### 4. PuzzleIntegrationHelper (Deprecado)

Este helper ya no es necesario, pero lo mantendremos por compatibilidad:

```dart
class PuzzleIntegrationHelper {
  @deprecated
  static Future<void> collectFragment({
    required BuildContext context,
    required String arcId,
    required int fragmentNumber,
  }) async {
    print('⚠️ PuzzleIntegrationHelper.collectFragment is deprecated');
    print('   Use game.saveFragment() instead');
    
    // Fallback implementation for compatibility
    try {
      final fragmentsProvider = Provider.of<FragmentsProvider>(context, listen: false);
      await fragmentsProvider.unlockFragment(arcId, fragmentNumber);
    } catch (e) {
      print('❌ Error in deprecated collectFragment: $e');
    }
  }
}
```

## Data Models

### FragmentData (Existing)

No requiere cambios. El modelo actual en `FragmentsProvider` ya maneja correctamente:

```dart
Map<String, Set<int>> _unlockedFragments = {
  'arc_1_gula': {},
  'arc_2_greed': {},
  'arc_3_envy': {},
  // ...
};
```

### Firebase Structure (Existing)

```
users/
  {userId}/
    progress/
      fragments/
        arc_1_gula: [1, 2, 3]
        arc_2_greed: [1, 2]
        arc_3_envy: [1]
        lastUpdated: Timestamp
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*


### Property Reflection

Revisando las propiedades identificadas en el prework:

**Redundancias identificadas:**
- Properties 5.2, 5.3, 5.4 son ejemplos específicos que están cubiertos por Property 5.1 (normalización general)
- Property 3.3 está implícita en Property 3.1 (si no requiere BuildContext, debe usar referencia directa)
- Property 2.1 y 2.3 están relacionadas - si un fragmento está desbloqueado, debe tener contenido

**Propiedades consolidadas:**
- Combinar 5.2, 5.3, 5.4 en ejemplos de unit tests, mantener 5.1 como property
- Eliminar 3.3 (redundante con 3.1)
- Mantener 2.1 y 2.3 separadas (diferentes aspectos: estado vs contenido)

### Correctness Properties

Property 1: Fragment persistence after collection
*For any* valid arcId and fragmentNumber (1-5), when a fragment is collected and saved, the fragment should exist in the FragmentsProvider's unlocked fragments for that arc
**Validates: Requirements 1.1, 1.3**

Property 2: Arc ID normalization consistency
*For any* arc ID in any format (short name, Spanish name, or standard format), normalizing the ID should always produce the correct standard format ('arc_X_name')
**Validates: Requirements 5.1, 5.5**

Property 3: Provider reference independence
*For any* fragment collection operation, the save operation should complete successfully without requiring a BuildContext parameter
**Validates: Requirements 3.1**

Property 4: Error handling without crashes
*For any* error condition during fragment saving (null provider, invalid arcId, network error), the system should log the error and continue execution without throwing an exception
**Validates: Requirements 1.4, 3.4**

Property 5: Fragment unlock state consistency
*For any* fragment that has been unlocked via the provider, querying the fragment's status should return unlocked=true
**Validates: Requirements 2.1**

Property 6: Fragment content availability
*For any* unlocked fragment, the fragment's narrative content should be non-empty and contain the expected title and description fields
**Validates: Requirements 2.3**

Property 7: Provider reference persistence across resets
*For any* game reset operation, if a FragmentsProvider reference was set before the reset, the reference should remain valid and usable after the reset
**Validates: Requirements 3.5**

Property 8: User ID validation before save
*For any* fragment save operation, the system should verify that a valid userId exists before attempting to save to Firebase
**Validates: Requirements 4.4**

Property 9: Local state synchronization
*For any* set of fragments loaded from Firebase, the local state in FragmentsProvider should exactly match the Firebase state
**Validates: Requirements 2.5**

Property 10: Idempotent normalization
*For any* arc ID that is already in standard format, normalizing it should return the same ID unchanged
**Validates: Requirements 5.5**

## Error Handling

### Error Scenarios

1. **Provider Not Set**
   - Detection: Check if `_fragmentsProvider` is null
   - Handling: Log error, skip save, continue game
   - Recovery: Provider can be set later via `setFragmentsProvider()`

2. **Invalid Arc ID**
   - Detection: Arc ID doesn't match known patterns
   - Handling: Log warning, use original ID, attempt save
   - Recovery: Normalization handles most cases

3. **Invalid Fragment Number**
   - Detection: Fragment number < 1 or > 5
   - Handling: Log error, skip save
   - Recovery: None needed (invalid operation)

4. **Firebase Save Failure**
   - Detection: Exception from `unlockFragment()`
   - Handling: Log error with stack trace, continue game
   - Recovery: Next save attempt will retry

5. **No Authenticated User**
   - Detection: `FirebaseAuth.currentUser` is null
   - Handling: Log warning, skip save
   - Recovery: User can authenticate later

### Error Logging Strategy

```dart
// Detailed logging for debugging
print('💾 [FRAGMENT] Saving: $arcId - Fragment $fragmentNumber');
print('✅ [FRAGMENT] Save successful');
print('❌ [FRAGMENT] Error: $e');
print('📋 [FRAGMENT] Stack trace: $stackTrace');
```

### Graceful Degradation

- Game continues even if fragment save fails
- Player can still complete the arc
- Fragments can be re-collected on next playthrough
- UI shows current session's collected fragments

## Testing Strategy

### Unit Tests

Unit tests will verify specific examples and edge cases:

1. **Arc ID Normalization Examples**
   - Test: 'gluttony' → 'arc_1_gula'
   - Test: 'greed' → 'arc_2_greed'
   - Test: 'envy' → 'arc_3_envy'
   - Test: 'arc_1_gula' → 'arc_1_gula' (idempotent)

2. **Provider Initialization**
   - Test: Setting provider makes it available
   - Test: Null provider is handled gracefully

3. **Error Cases**
   - Test: Null provider logs error
   - Test: Invalid fragment number is rejected
   - Test: No authenticated user is handled

### Property-Based Tests

Property-based tests will verify universal properties across all inputs using the `test` package with `package:test/test.dart` for Dart/Flutter.

**Configuration:**
- Minimum 100 iterations per property test
- Use `List.generate()` for generating test cases
- Tag each test with the property number from design doc

**Test Structure:**
```dart
test('Property X: Description', () {
  // Generate 100 random test cases
  for (int i = 0; i < 100; i++) {
    // Generate random inputs
    final input = generateRandomInput();
    
    // Execute operation
    final result = systemUnderTest(input);
    
    // Verify property holds
    expect(result, meetsProperty);
  }
}, tags: ['property', 'property-X']);
```

**Properties to Test:**

1. **Property 1: Fragment Persistence**
   - Generate: Random arcIds and fragment numbers
   - Verify: Fragment exists in provider after save

2. **Property 2: Arc ID Normalization**
   - Generate: Random arc ID formats
   - Verify: Output is always in standard format

3. **Property 3: BuildContext Independence**
   - Generate: Random fragment collections
   - Verify: Save completes without BuildContext

4. **Property 4: Error Handling**
   - Generate: Random error conditions
   - Verify: No exceptions thrown

5. **Property 5: Unlock State Consistency**
   - Generate: Random fragment unlocks
   - Verify: Query returns unlocked=true

6. **Property 6: Content Availability**
   - Generate: Random unlocked fragments
   - Verify: Content is non-empty

7. **Property 7: Provider Persistence**
   - Generate: Random reset sequences
   - Verify: Provider reference remains valid

8. **Property 8: User ID Validation**
   - Generate: Random save attempts
   - Verify: User ID checked before save

9. **Property 9: State Synchronization**
   - Generate: Random Firebase states
   - Verify: Local state matches Firebase

10. **Property 10: Idempotent Normalization**
    - Generate: Random standard format IDs
    - Verify: Normalization returns same ID

### Integration Tests

Integration tests will verify the complete flow:

1. **End-to-End Fragment Collection**
   - Start game
   - Collect fragment
   - Verify saved in provider
   - Open ARCHIVOS
   - Verify fragment appears

2. **Cross-Arc Fragment Persistence**
   - Collect fragments in Arc 1
   - Exit game
   - Start Arc 2
   - Verify Arc 1 fragments still saved

3. **Provider Reference Lifecycle**
   - Initialize game
   - Set provider
   - Collect fragment
   - Reset game
   - Collect another fragment
   - Verify both saved

## Implementation Notes

### Migration Strategy

1. **Phase 1: Add New Methods (Non-Breaking)**
   - Add `setFragmentsProvider()` to BaseArcGame
   - Add `saveFragment()` to BaseArcGame
   - Keep existing `buildContext` for compatibility

2. **Phase 2: Update Game Classes**
   - Update GluttonyArcGame to use `saveFragment()`
   - Update GreedArcGame to use `saveFragment()`
   - Update EnvyArcGame to use `saveFragment()`

3. **Phase 3: Update Screen**
   - Add provider reference passing in ArcGameScreen
   - Test thoroughly

4. **Phase 4: Deprecate Old Method**
   - Mark `PuzzleIntegrationHelper.collectFragment()` as deprecated
   - Remove `buildContext` from BaseArcGame in future version

### Performance Considerations

- Provider reference is lightweight (just a pointer)
- No performance impact from removing BuildContext dependency
- Firebase saves are async and don't block game loop
- Error handling is fast (just logging)

### Backwards Compatibility

- Old code using `buildContext` will continue to work
- New code can use `saveFragment()` directly
- Gradual migration path
- No breaking changes for existing saves

## Security Considerations

- User ID validation prevents unauthorized saves
- Firebase rules enforce user can only write to their own data
- No sensitive data in fragment IDs or numbers
- Error messages don't expose internal structure

## Monitoring and Observability

### Key Metrics

1. **Fragment Save Success Rate**
   - Track: Successful saves / Total attempts
   - Alert: If < 95%

2. **Provider Availability**
   - Track: Times provider was null when needed
   - Alert: If > 0

3. **Arc ID Normalization**
   - Track: Times normalization was needed
   - Info: For understanding usage patterns

### Logging

All operations log with consistent prefixes:
- `💾 [FRAGMENT]` - Save operations
- `✅ [FRAGMENT]` - Success
- `❌ [FRAGMENT]` - Errors
- `⚠️ [FRAGMENT]` - Warnings

## Future Enhancements

1. **Offline Support**
   - Queue fragment saves when offline
   - Sync when connection restored

2. **Optimistic UI Updates**
   - Show fragment as unlocked immediately
   - Rollback if save fails

3. **Fragment Validation**
   - Verify fragment data integrity
   - Detect and fix corrupted saves

4. **Analytics Integration**
   - Track which fragments are collected most
   - Identify collection patterns
