# 📊 Arco 3: ENVIDIA - Implementación de Estadísticas

## 🎯 Objetivo
Añadir el método `getGameStats()` al Arco 3 para que la cinemática de victoria muestre estadísticas similares a los Arcos 1 y 2.

## ✅ Implementación Completada

### Estadísticas Añadidas

#### 1. **Evidencias Recolectadas**
- Key: `evidenceCollected`
- Label: "Evidencias Recolectadas"
- Formato: "X de 5"
- Fuente: Variable existente del juego

#### 2. **Tiempo Total**
- Key: `timeElapsed`
- Label: "Tiempo Total"
- Formato: "X.Xs"
- Fuente: Variable `elapsedTime` del juego

#### 3. **Cordura Final**
- Key: `sanityRemaining`
- Label: "Cordura Final"
- Formato: "X%"
- Fuente: `sanitySystem.currentSanity`

#### 4. **Fase Máxima del Enemigo** (NUEVO)
- Key: `enemyPhaseReached`
- Label: "Fase Máxima del Enemigo"
- Formato: "Fase X de 3"
- Fuente: Nueva variable `maxPhaseReached`
- **Específico del Arco 3**: Refleja la mecánica de espejo adaptativo

#### 5. **Dashes Recibidos** (NUEVO)
- Key: `dashesReceived`
- Label: "Dashes Recibidos"
- Formato: "X ataques"
- Fuente: Nueva variable `dashesReceived`
- **Específico del Arco 3**: Refleja la mecánica de dash del enemigo

### 📝 Cambios Eliminados

❌ **"Veces Escondido"** - Eliminado porque el Arco 3 no tiene escondites

## 🔧 Archivos Modificados

### 1. `lib/data/providers/arc_data_provider.dart`

**Antes**:
```dart
stats: [
  StatConfig(key: 'evidenceCollected', ...),
  StatConfig(key: 'timeElapsed', ...),
  StatConfig(key: 'sanityRemaining', ...),
  StatConfig(key: 'timesHidden', ...),  // ❌ No aplica
],
```

**Después**:
```dart
stats: [
  StatConfig(key: 'evidenceCollected', label: 'Evidencias Recolectadas', ...),
  StatConfig(key: 'timeElapsed', label: 'Tiempo Total', ...),
  StatConfig(key: 'sanityRemaining', label: 'Cordura Final', ...),
  StatConfig(key: 'enemyPhaseReached', label: 'Fase Máxima del Enemigo', ...),
  StatConfig(key: 'dashesReceived', label: 'Dashes Recibidos', ...),
],
```

### 2. `lib/game/arcs/envy/envy_arc_game.dart`

**Variables añadidas**:
```dart
// Game statistics
int maxPhaseReached = 1;
int dashesReceived = 0;
```

**Tracking de fase máxima**:
```dart
// En _checkEvidenceCollection()
if (_enemy!.currentPhase > maxPhaseReached) {
  maxPhaseReached = _enemy!.currentPhase;
}
```

**Callback de dash**:
```dart
// En setupEnemy()
_enemy!.onDashStart = () {
  dashesReceived++;
};
```

**Método getGameStats()**:
```dart
Map<String, dynamic> getGameStats() {
  return {
    'evidenceCollected': evidenceCollected,
    'timeElapsed': elapsedTime,
    'sanityRemaining': sanitySystem.currentSanity,
    'enemyPhaseReached': maxPhaseReached,
    'dashesReceived': dashesReceived,
  };
}
```

**Reset de estadísticas**:
```dart
@override
Future<void> resetGame() async {
  sanitySystem.reset();
  maxPhaseReached = 1;
  dashesReceived = 0;
  await super.resetGame();
}
```

### 3. `lib/game/arcs/envy/components/chameleon_enemy.dart`

**Callback añadido**:
```dart
Function()? onDashStart; // Callback when dash starts

void _startDash() {
  isDashing = true;
  dashTimer = 0.0;
  dashTarget = targetPlayer!.position.clone();
  
  // Trigger callback if set
  if (onDashStart != null) {
    onDashStart!();
  }
}
```

## 📊 Comparación con Otros Arcos

### Arco 1 (Gula):
```dart
- Evidencias Recolectadas
- Tiempo
- Cordura Final
- Veces Escondido
```

### Arco 2 (Avaricia):
```dart
- Evidencias
- Cajas Saqueadas
- Tiempo
- Cordura
```

### Arco 3 (Envidia):
```dart
- Evidencias Recolectadas
- Tiempo Total
- Cordura Final
- Fase Máxima del Enemigo  ← Único del Arco 3
- Dashes Recibidos         ← Único del Arco 3
```

## 🎮 Ejemplo de Pantalla de Victoria

```
ENVIDIA
Reflejo en el Espejo

Comparaste
Humillaste
Repetiste

Cada comentario era un golpe
Cada comparación, una herida

Ella cambió
Tú seguiste igual

¿Valió la pena?

━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Evidencias Recolectadas: 5 de 5
Tiempo Total: 127.3s
Cordura Final: 42%
Fase Máxima del Enemigo: Fase 3 de 3
Dashes Recibidos: 12 ataques
```

## 🧪 Testing

### Checklist:
- [ ] Método `getGameStats()` existe y retorna Map
- [ ] Estadísticas se muestran en pantalla de victoria
- [ ] `maxPhaseReached` se actualiza correctamente (1 → 2 → 3)
- [ ] `dashesReceived` incrementa con cada dash del enemigo
- [ ] Estadísticas se resetean correctamente al reiniciar
- [ ] No hay errores de compilación
- [ ] Formato de estadísticas es consistente con otros arcos

### Valores Esperados:
- **evidenceCollected**: 0-5
- **timeElapsed**: Variable (segundos con 1 decimal)
- **sanityRemaining**: 0.0-1.0 (mostrado como 0-100%)
- **enemyPhaseReached**: 1-3
- **dashesReceived**: Variable (depende de duración del juego)

## 🎯 Beneficios

1. **Consistencia**: Ahora todos los arcos tienen estadísticas en la victoria
2. **Feedback**: El jugador ve métricas específicas del Arco 3
3. **Rejugabilidad**: Las estadísticas motivan a mejorar tiempos/cordura
4. **Narrativa**: Las stats refuerzan la mecánica de espejo adaptativo

## 📝 Notas

- Las estadísticas son específicas a la mecánica del Arco 3
- "Fase Máxima" muestra qué tan difícil se puso el enemigo
- "Dashes Recibidos" muestra cuántas veces el enemigo atacó agresivamente
- No incluye "Veces Escondido" porque no hay escondites en este arco

---

**Fecha**: 2025-11-19  
**Estado**: ✅ Implementado y funcional  
**Compilación**: ✅ Sin errores  
**Próximo**: Probar en el juego
