# ✅ Fix: Actualización en Tiempo Real de Evidencias en Arcos 2 y 3

## 🎯 Problema

En los arcos 2 (Greed) y 3 (Envy), cuando recolectas evidencias, el contador en el HUD no se actualiza en tiempo real. El número permanece en 0 hasta que reinicias o sales del juego.

**Causa:** Faltaba la llamada al callback `onEvidenceCollectedChanged?.call()` que notifica a la UI cuando se recolecta una evidencia.

---

## 🔧 Solución Implementada

### 1. Modificado: `lib/game/arcs/greed/greed_arc_game.dart`

#### Método `_checkEvidenceCollection()`:

**ANTES:**
```dart
if (distance < 50) {
  component.collect();
  evidenceCollected++;
  
  // Update door with new fragment count
  _updateDoorState();
  
  print('📄 [GREED] Evidence collected! Total: $evidenceCollected/5');
}
```

**DESPUÉS:**
```dart
if (distance < 50) {
  component.collect();
  evidenceCollected++;
  
  // Update door with new fragment count
  _updateDoorState();
  
  // Notify UI of evidence change
  onEvidenceCollectedChanged?.call();
  
  print('📄 [GREED] Evidence collected! Total: $evidenceCollected/5');
}
```

---

### 2. Modificado: `lib/game/arcs/envy/envy_arc_game.dart`

#### Método `_checkEvidenceCollection()`:

**ANTES:**
```dart
if (distance < 50) {
  component.collect();
  evidenceCollected++;
  
  // Update door with new fragment count
  _updateDoorState();
  
  print('📄 [ENVY] Evidence collected! Total: $evidenceCollected/5');
  
  // BALANCE: Increase enemy phase every 2 evidences
  if (evidenceCollected == 2 || evidenceCollected == 4) {
    _enemy?.increasePhase();
    print('⚡ [ENVY] Enemy difficulty increased!');
  }
}
```

**DESPUÉS:**
```dart
if (distance < 50) {
  component.collect();
  evidenceCollected++;
  
  // Update door with new fragment count
  _updateDoorState();
  
  // Notify UI of evidence change
  onEvidenceCollectedChanged?.call();
  
  print('📄 [ENVY] Evidence collected! Total: $evidenceCollected/5');
  
  // BALANCE: Increase enemy phase every 2 evidences
  if (evidenceCollected == 2 || evidenceCollected == 4) {
    _enemy?.increasePhase();
    print('⚡ [ENVY] Enemy difficulty increased!');
  }
}
```

---

## 🎮 Cómo Funciona

### Flujo de Actualización de UI:

```
1. Jugador se acerca a una evidencia (< 50 pixels)
2. Se llama a component.collect()
3. Se incrementa evidenceCollected++
4. Se actualiza el estado de la puerta (_updateDoorState)
5. Se llama a onEvidenceCollectedChanged?.call() ← NUEVO
6. El callback notifica a arc_game_screen.dart
7. arc_game_screen.dart llama a setState()
8. El HUD se reconstruye con el nuevo contador
9. El jugador ve el número actualizado inmediatamente
```

### Callback en `arc_game_screen.dart`:

```dart
// Evidence collection callback
baseGame.onEvidenceCollectedChanged = () {
  if (mounted && !_isDisposing) {
    setState(() {
      // Show evidence notification
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

---

## 🧪 Testing

### Para Probar el Fix:

1. **Arco 2 (Greed):**
   - Inicia el Arco 2
   - Recolecta una evidencia
   - **Verifica:** El contador en el HUD debe cambiar de 0/5 a 1/5 inmediatamente
   - **Verifica:** Debe aparecer la notificación de evidencia recolectada
   - Recolecta más evidencias y verifica que el contador se actualiza cada vez

2. **Arco 3 (Envy):**
   - Inicia el Arco 3
   - Recolecta una evidencia
   - **Verifica:** El contador en el HUD debe cambiar de 0/5 a 1/5 inmediatamente
   - **Verifica:** Debe aparecer la notificación de evidencia recolectada
   - Recolecta más evidencias y verifica que el contador se actualiza cada vez

3. **Arco 1 (Gluttony):**
   - Verifica que sigue funcionando correctamente (ya tenía el callback)

---

## 📊 Comparación con Arco 1

### Arco 1 (Gluttony) - Ya Funcionaba:
```dart
evidenceCollected++;
_updateDoorState();
GluttonyAudioManager.playSquelch();
onEvidenceCollectedChanged?.call(); // ← Ya estaba
print('📄 Evidence collected! Total: $evidenceCollected/5');
```

### Arco 2 (Greed) - Ahora Arreglado:
```dart
evidenceCollected++;
_updateDoorState();
onEvidenceCollectedChanged?.call(); // ← AGREGADO
print('📄 [GREED] Evidence collected! Total: $evidenceCollected/5');
```

### Arco 3 (Envy) - Ahora Arreglado:
```dart
evidenceCollected++;
_updateDoorState();
onEvidenceCollectedChanged?.call(); // ← AGREGADO
print('📄 [ENVY] Evidence collected! Total: $evidenceCollected/5');
```

---

## 🎨 Efectos Visuales

Cuando recolectas una evidencia, ahora verás:

1. **Contador del HUD actualizado** - El número cambia inmediatamente (ej: 0/5 → 1/5)
2. **Notificación de evidencia** - Aparece en la parte superior de la pantalla
3. **Efecto de pantalla rota** - Se intensifica con cada evidencia (ShatteredScreenOverlay)
4. **Sonido** - Se reproduce el sonido de recolección (si está implementado)

---

## ✅ Estado Actual

- ✅ Arco 1 (Gluttony) - Contador se actualiza en tiempo real
- ✅ Arco 2 (Greed) - Contador se actualiza en tiempo real (ARREGLADO)
- ✅ Arco 3 (Envy) - Contador se actualiza en tiempo real (ARREGLADO)
- ✅ Notificación de evidencia aparece correctamente
- ✅ Efecto de pantalla rota se actualiza correctamente

---

## 🔍 Archivos Relacionados

### Archivos Modificados:
1. `lib/game/arcs/greed/greed_arc_game.dart` - Agregado callback
2. `lib/game/arcs/envy/envy_arc_game.dart` - Agregado callback

### Archivos de Referencia:
1. `lib/game/arcs/gluttony/gluttony_arc_game.dart` - Implementación correcta
2. `lib/screens/arc_game_screen.dart` - Manejo del callback
3. `lib/game/core/base/base_arc_game.dart` - Definición del callback
4. `lib/game/ui/game_hud.dart` - Visualización del contador

---

## 🎉 Resultado

Ahora cuando recolectas evidencias en los arcos 2 y 3, el contador del HUD se actualiza inmediatamente, igual que en el arco 1. La experiencia de usuario es consistente en todos los arcos.
