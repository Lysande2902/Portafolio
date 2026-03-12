# Evidence Notification & Retry Fix

## Problems Fixed

### 1. No Visual Feedback When Collecting Evidence
**Problem:** Cuando el jugador recolectaba una evidencia, solo había sonido (squelch) pero no había retroalimentación visual clara.

**Solution:** Agregada notificación visual animada que muestra:
- "FRAGMENTO RECOLECTADO"
- Contador actual (ej: "3/5 FRAGMENTOS")
- Animación de slide-down desde arriba
- Desaparece automáticamente después de 2.5 segundos

### 2. Game Breaks When Retrying After Game Over
**Problem:** Cuando el jugador perdía y presionaba "REINTENTAR", se creaba una nueva instancia del juego pero los callbacks no se reconectaban, causando que:
- El contador de evidencias no se actualizara
- La pantalla de game over no apareciera si perdías de nuevo
- La notificación de evidencia no se mostrara

**Solution:** Al reiniciar el juego, ahora se reconectan todos los callbacks:
- `onPlayerNoise` - Para multiplayer
- `onEvidenceCollectedChanged` - Para actualizar UI y mostrar notificación
- `onGameStateChanged` - Para mostrar game over/victory screens

## Implementation Details

### Evidence Notification

**New State Variables:**
```dart
bool _showEvidenceNotification = false;
int _currentEvidenceCount = 0;
```

**Updated Callback:**
```dart
baseGame.onEvidenceCollectedChanged = () {
  if (mounted && !_isDisposing) {
    setState(() {
      _showEvidenceNotification = true;
      _currentEvidenceCount = game.evidenceCollected;
    });
    
    // Hide notification after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _showEvidenceNotification = false;
        });
      }
    });
  }
};
```

**UI Widget:**
```dart
if (_showEvidenceNotification)
  Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: EvidenceCollectedNotification(
      currentCount: _currentEvidenceCount,
      totalCount: 5,
      onComplete: () {
        setState(() {
          _showEvidenceNotification = false;
        });
      },
    ),
  ),
```

### Retry Fix

**Before:**
```dart
onRetry: () {
  setState(() {
    game = _createGameInstance();  // ❌ Callbacks not reconnected
  });
},
```

**After:**
```dart
onRetry: () {
  setState(() {
    // Create new game instance
    game = _createGameInstance();
    
    // Reconnect callbacks for the new game instance
    if (game is BaseArcGame) {
      final baseGame = game as BaseArcGame;
      
      // Multiplayer noise callback
      baseGame.onPlayerNoise = (pos) { ... };
      
      // Evidence collection callback
      baseGame.onEvidenceCollectedChanged = () { ... };
      
      // Game state callback
      baseGame.onGameStateChanged = () { ... };
    }
  });
},
```

## Files Modified

1. **lib/screens/arc_game_screen.dart**
   - Added import for `EvidenceCollectedNotification`
   - Added state variables for notification
   - Updated evidence callback to show notification
   - Fixed retry to reconnect all callbacks
   - Added notification widget to UI Stack

## Benefits

✅ **Clear Visual Feedback** - El jugador ahora ve claramente cuando recolecta evidencia
✅ **Consistent Experience** - El juego funciona correctamente después de reintentar
✅ **No More Broken State** - Todos los callbacks se reconectan apropiadamente
✅ **Better UX** - Retroalimentación visual + sonido = experiencia más satisfactoria

## Testing

Para probar:
1. ✅ Recolectar evidencia - Debe aparecer notificación animada
2. ✅ Perder el juego - Debe aparecer pantalla de game over
3. ✅ Presionar "REINTENTAR" - El juego debe reiniciar correctamente
4. ✅ Recolectar evidencia después de reiniciar - Notificación debe aparecer
5. ✅ Perder de nuevo - Game over debe aparecer correctamente
6. ✅ Contador de evidencias debe actualizarse en tiempo real

## Notes

La notificación usa el componente `EvidenceCollectedNotification` que ya existía pero no se estaba usando. Ahora está completamente integrado con el sistema de callbacks.
