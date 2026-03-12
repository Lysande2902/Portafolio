# CRITICAL FIX: Move GameWidget Creation to initState()

## Problem

El juego crasheaba con:
```
Game attachment error: A game instance can only be attached to one widget at a time
```

Los logs mostraban:
```
🔗 [ATTACH] Already attached: false  ← Nuestro flag dice FALSE
❌ [ATTACH] Attachment failed        ← Pero Flame dice que YA está attached
```

## Root Cause

**El problema NO era el método `attach()`**. El problema era **DÓNDE** estábamos creando el GameWidget.

### Problema Original:

```dart
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  
  // ❌ PROBLEMA: didChangeDependencies() se llama MÚLTIPLES VECES
  if (_gameWidget == null && !_isDisposing && _isInitialized) {
    _gameWidget = GameWidget(
      key: _gameWidgetKey,
      game: game,
    );
  }
}
```

**Por qué falla:**
1. `didChangeDependencies()` se llama múltiples veces durante el lifecycle
2. Cada vez que se llama, puede crear un nuevo GameWidget
3. Esto causa que el mismo juego intente attacharse múltiples veces
4. Flame detecta esto y lanza el error

## Solution

**Mover la creación del GameWidget a `initState()`**, que se llama **UNA SOLA VEZ**:

```dart
@override
void initState() {
  super.initState();
  
  // Create game instance
  game = GluttonyArcGame();
  
  // ✅ SOLUCIÓN: Crear GameWidget en initState (llamado UNA SOLA VEZ)
  _gameWidget = GameWidget(
    key: _gameWidgetKey,
    game: game,
  );
  
  _isInitialized = true;
}

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  
  // ✅ Solo setup de providers (seguro llamar múltiples veces)
  if (_isInitialized && !_isDisposing) {
    game.buildContext = context;
    final fragmentsProvider = Provider.of<FragmentsProvider>(context, listen: false);
    game.setFragmentsProvider(fragmentsProvider);
    _loadInventory();
  }
}
```

## Why This Works

1. **`initState()`** se llama **UNA SOLA VEZ** cuando el widget se crea
2. **`didChangeDependencies()`** se llama **MÚLTIPLES VECES** (cuando cambian dependencias, providers, etc.)
3. Al crear el GameWidget en `initState()`, garantizamos que se crea **UNA SOLA VEZ**
4. El setup de providers en `didChangeDependencies()` es seguro porque no crea nuevos widgets

## Additional Fix: Remove attach() Override

También removimos el override de `attach()` y `detach()` en `BaseArcGame`:

```dart
// ❌ REMOVIDO - Causaba desincronización con Flame
@override
void attach(...) {
  if (_isAttached) return;
  _isAttached = true;
  super.attach(...);
}

// ✅ SOLUCIÓN - Dejar que Flame maneje todo
// NO override attach() ni detach()
```

**Por qué:**
- Overriding `attach()` causaba desincronización entre nuestro flag y el estado interno de Flame
- Flame ya maneja correctamente el attachment
- No necesitamos interferir con su lifecycle

## Files Modified

1. **lib/screens/arc_game_screen.dart**
   - Moved GameWidget creation from `didChangeDependencies()` to `initState()`
   - Kept provider setup in `didChangeDependencies()` (safe to call multiple times)

2. **lib/game/core/base/base_arc_game.dart**
   - Removed `attach()` override
   - Removed `detach()` override
   - Removed `_isAttached` flag

## Testing

Para verificar que funciona:

1. Navega a cualquier arc
2. Verifica en los logs:
   ```
   🎮 [INIT] Creating game instance
   ✅ [INIT] Game created: XXXXXXXX
   🎮 [INIT] Creating GameWidget
   ✅ [INIT] GameWidget created: XXXXXXXX
   🔄 [DID_CHANGE_DEPS] Called - setting up providers
   ✅ [DID_CHANGE_DEPS] Providers setup complete
   ```
3. NO deberías ver:
   - Múltiples "Creating GameWidget" messages
   - "Game attachment error"
   - "Already attached" warnings

## Key Learnings

1. **`initState()` = UNA VEZ** - Usar para crear widgets/objetos
2. **`didChangeDependencies()` = MÚLTIPLES VECES** - Usar solo para setup que es idempotente
3. **No override Flame lifecycle methods** - Deja que Flame maneje su propio lifecycle
4. **Trust the framework** - Flutter y Flame saben lo que hacen

## Impact

- ✅ Elimina completamente el error de attachment
- ✅ Simplifica el código (menos overrides)
- ✅ Más robusto (no depende de flags manuales)
- ✅ Sigue las best practices de Flutter
