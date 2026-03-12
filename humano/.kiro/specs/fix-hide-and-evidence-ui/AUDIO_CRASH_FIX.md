# Audio Crash Fix

## Problem

El juego se crasheaba cuando el jugador presionaba repetidamente el botón de esconderse. El error era:

```
E/AndroidRuntime: java.lang.IllegalStateException
E/AndroidRuntime:   at android.media.MediaPlayer.getPlaybackParams(Native Method)
E/AndroidRuntime:   at xyz.luan.audioplayers.player.MediaPlayerPlayer.setRate
```

### Root Cause

El problema NO era el botón de esconderse en sí, sino el **sistema de audio**:

1. Cuando el jugador se esconde, se reproduce un sonido de respiración pesada cada 4 segundos
2. El mismo `AudioPlayer` (_sfxPlayer) se reutilizaba para múltiples sonidos
3. Si se llamaba `play()` mientras el player estaba en un estado inválido (preparando otro sonido), causaba un crash
4. El heartbeat también se llamaba muy frecuentemente cuando el enemigo estaba cerca

## Solution

### 1. Debouncing

Agregamos cooldowns para evitar llamadas muy rápidas:

```dart
// Debounce for breathing sound
static DateTime? _lastBreathingTime;
static const Duration _breathingCooldown = Duration(seconds: 2);

// Debounce for heartbeat sound
static DateTime? _lastHeartbeatTime;
static const Duration _heartbeatCooldown = Duration(milliseconds: 800);
```

### 2. Isolated Audio Players

En lugar de reutilizar el mismo `_sfxPlayer`, creamos un nuevo `AudioPlayer` para cada sonido:

```dart
static void playHeavyBreathing() {
  if (!_initialized) return;
  
  // Debounce to prevent rapid calls
  final now = DateTime.now();
  if (_lastBreathingTime != null && 
      now.difference(_lastBreathingTime!) < _breathingCooldown) {
    return;
  }
  _lastBreathingTime = now;
  
  try {
    // Create a new player for this sound to avoid state conflicts
    final breathingPlayer = AudioPlayer();
    breathingPlayer.play(AssetSource(heavyBreathing), volume: 0.4);
    
    // Dispose after playing
    Future.delayed(const Duration(seconds: 3), () {
      breathingPlayer.dispose();
    });
  } catch (e) {
    debugPrint('⚠️ [GLUTTONY AUDIO] Failed to play breathing: $e');
  }
}
```

### 3. Automatic Cleanup

Cada AudioPlayer se dispone automáticamente después de reproducir el sonido, evitando memory leaks.

## Benefits

✅ **No más crashes** - Los AudioPlayers aislados evitan conflictos de estado
✅ **Mejor rendimiento** - El debouncing reduce llamadas innecesarias
✅ **Sin memory leaks** - Cleanup automático de recursos
✅ **Más robusto** - Try-catch mantiene el manejo de errores existente

## Files Modified

- `lib/game/arcs/gluttony/systems/gluttony_audio_manager.dart`
  - Agregado debouncing para `playHeavyBreathing()`
  - Agregado debouncing para `intensifyHeartbeat()`
  - Cambiado a AudioPlayers aislados en lugar de reutilizar `_sfxPlayer`
  - Agregado cleanup automático con `Future.delayed()`

## Testing

El fix previene:
- Crashes por tocar repetidamente el botón de esconderse
- Crashes por estar cerca del enemigo por mucho tiempo
- Conflictos de estado en el MediaPlayer de Android
- Sobrecarga de llamadas de audio

## Notes

Este patrón se puede aplicar a otros sonidos si se presentan problemas similares. Los sonidos que se llaman con menos frecuencia (como squelch, creak, drip) pueden seguir usando el `_sfxPlayer` compartido sin problemas.
