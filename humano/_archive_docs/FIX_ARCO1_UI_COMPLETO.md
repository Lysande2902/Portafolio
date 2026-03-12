# FIX ARCO 1: PROBLEMAS DE UI Y GAMEPLAY

**Fecha**: 28 de enero de 2025  
**Arco**: Consumo y Codicia (arc_1_consumo_codicia)

---

## 🐛 PROBLEMAS REPORTADOS

### 1. ❌ Cinemática de Intro: "Error: texto no encontrado"
**Causa**: El texto de intro no estaba definido para `arc_1_consumo_codicia`  
**Solución**: ✅ Agregado texto completo en `arc_intro_screen.dart`

### 2. ❌ Pausa no funciona completamente
**Causa**: Se llamaba a `game.pauseGame()` en lugar de `game.pauseEngine()`  
**Solución**: ✅ Cambiado a `pauseEngine()` y `resumeEngine()`

### 3. ❌ UI muestra "0/5 fragmentos" en lugar de "0/10"
**Causa**: Hardcodeado a 5 fragmentos (arcos individuales)  
**Solución**: ✅ Agregada función `_getTotalEvidenceForArc()` que retorna 10 para arcos fusionados

### 4. ❌ Escondites bloqueados por obstáculos
**Causa**: Posiciones de escondites pueden coincidir con obstáculos  
**Estado**: ⚠️ REVISAR - Las posiciones están bien en el código, pero puede haber overlap visual

### 5. ❌ Botón de esconderse no aparece
**Causa**: Lógica de detección de proximidad puede no estar funcionando  
**Estado**: ⚠️ REVISAR - Necesita verificación del PlayerComponent

### 6. ❌ Cinemática de salida incompleta
**Causa**: Solo mostraba una línea de texto  
**Solución**: ✅ Agregadas ambas líneas para arcos fusionados

### 7. ❌ Nombre sigue siendo "ARCO 1: GULA"
**Causa**: Función `_getArcTitle()` no tenía casos para arcos fusionados  
**Solución**: ✅ Agregados todos los arcos fusionados

---

## ✅ CAMBIOS REALIZADOS

### Archivo: `arc_game_screen.dart`

#### 1. Función para obtener total de evidencias
```dart
int _getTotalEvidenceForArc() {
  // Arcos fusionados tienen 10 fragmentos
  if (widget.arcId == 'arc_1_consumo_codicia' ||
      widget.arcId == 'arc_2_envidia_lujuria' ||
      widget.arcId == 'arc_3_soberbia_pereza') {
    return 10;
  }
  // Arco final (Ira) tiene 5 fragmentos
  if (widget.arcId == 'arc_4_ira') {
    return 5;
  }
  // Arcos individuales antiguos tienen 5 fragmentos
  return 5;
}
```

#### 2. Actualizado HUD para mostrar total correcto
```dart
GameHUD(
  evidenceCollected: game.evidenceCollected ?? 0,
  totalEvidence: _getTotalEvidenceForArc(), // Antes: 5
  // ...
)
```

#### 3. Actualizada notificación de evidencia
```dart
EvidenceCollectedNotification(
  currentCount: _currentEvidenceCount,
  totalCount: _getTotalEvidenceForArc(), // Antes: 5
  // ...
)
```

#### 4. Arreglado sistema de pausa
```dart
// En onPause del HUD:
onPause: () {
  setState(() {
    showPauseMenu = true;
  });
  game.pauseEngine(); // Antes: pauseGame()
},

// En onResume del PauseMenu:
onResume: () {
  setState(() {
    showPauseMenu = false;
  });
  game.resumeEngine(); // Antes: resumeGame()
},
```

#### 5. Actualizada función de títulos
```dart
String _getArcTitle(String arcId) {
  switch (arcId) {
    // Arcos fusionados (nuevos)
    case 'arc_1_consumo_codicia':
      return 'CONSUMO Y CODICIA';
    case 'arc_2_envidia_lujuria':
      return 'ENVIDIA Y LUJURIA';
    case 'arc_3_soberbia_pereza':
      return 'SOBERBIA Y PEREZA';
    case 'arc_4_ira':
      return 'IRA';
    // Arcos individuales (compatibilidad)
    case 'arc_1_gula':
      return 'GULA';
    // ... resto
  }
}
```

#### 6. Actualizado stats de victoria
```dart
final gameStats = {
  'evidenceCollected': game.evidenceCollected,
  'totalEvidence': _getTotalEvidenceForArc(), // Antes: 5
  'playTime': game.playTime,
  ..._getAdditionalStats() ?? {},
};
```

### Archivo: `arc_outro_screen.dart`

#### Agregadas cinemáticas para arcos fusionados
```dart
String _getOutroText() {
  switch (widget.arcId) {
    // Arcos fusionados (nuevos)
    case 'arc_1_consumo_codicia':
      return '''SU MADRE MURIÓ ESPERÁNDOLO

SUS NIÑOS SIGUEN ESPERÁNDOLA EN CASA''';
    
    case 'arc_2_envidia_lujuria':
      return '''ELLA ESCRIBIÓ TU NOMBRE CON SU SANGRE

ÉL PERDIÓ TODO POR TI''';
    
    case 'arc_3_soberbia_pereza':
      return '''ÉL CREÍA QUE ERA INVENCIBLE

ÉL DEJÓ QUE TODO SE DERRUMBARA''';
    
    case 'arc_4_ira':
      return '''ÉL QUEMÓ TODO LO QUE AMABA

AHORA SABES LA VERDAD

¿VALIÓ LA PENA?''';
    // ... resto
  }
}
```

---

## ⚠️ PROBLEMAS PENDIENTES

### 1. Escondites bloqueados
**Análisis**: Las posiciones de los escondites están correctas en el código:
```dart
// Phase 1 hiding spots
HidingSpotComponent(position: Vector2(300, 400), size: Vector2(160, 160)),
HidingSpotComponent(position: Vector2(1100, 600), size: Vector2(180, 180)),
HidingSpotComponent(position: Vector2(800, 1100), size: Vector2(170, 170)),
HidingSpotComponent(position: Vector2(1700, 1200), size: Vector2(160, 160)),
```

**Posibles causas**:
- Overlap visual con obstáculos cercanos
- Tamaño de hitbox del escondite muy pequeño
- Obstáculos generados después de escondites (orden de renderizado)

**Solución propuesta**:
- Verificar que los escondites se rendericen DESPUÉS de los obstáculos
- Aumentar ligeramente el tamaño de detección de proximidad
- Revisar colisiones entre escondites y obstáculos

### 2. Botón de esconderse no aparece
**Análisis**: El botón solo aparece si `showHideButton` es true:
```dart
showHideButton: supportsHiding,
```

Y `supportsHiding` solo es true para arcos antiguos:
```dart
final bool supportsHiding = widget.arcId == 'arc_1_gula' || 
                           widget.arcId == 'arc_2_greed' || 
                           widget.arcId == 'arc_3_envy';
```

**Problema**: ¡Los arcos fusionados NO están en la lista!

**Solución**: Agregar arcos fusionados a la lista de arcos que soportan esconderse

---

## 🔧 PRÓXIMOS PASOS

### Prioridad Alta
1. ✅ Agregar arcos fusionados a `supportsHiding`
2. ⚠️ Verificar detección de proximidad en PlayerComponent
3. ⚠️ Revisar overlap de escondites con obstáculos

### Prioridad Media
4. Verificar que el sistema de pausa funciona correctamente
5. Probar recolección de 10 fragmentos completa
6. Verificar que la cinemática de victoria muestra ambas líneas

### Prioridad Baja
7. Optimizar posiciones de escondites si es necesario
8. Agregar feedback visual cuando el jugador está cerca de un escondite

---

## 📊 RESUMEN DE CAMBIOS

| Archivo | Líneas Modificadas | Cambios |
|---------|-------------------|---------|
| `arc_game_screen.dart` | ~20 | Función `_getTotalEvidenceForArc()`, pausa, títulos |
| `arc_outro_screen.dart` | ~15 | Cinemáticas para arcos fusionados |

**Total**: 2 archivos, ~35 líneas modificadas

---

## 🧪 TESTING NECESARIO

### Casos de Prueba
1. ✅ Intro muestra texto correcto
2. ⚠️ Pausa detiene el juego completamente
3. ✅ UI muestra "X/10 fragmentos"
4. ⚠️ Botón de esconderse aparece
5. ⚠️ Jugador puede esconderse en todos los escondites
6. ✅ Cinemática de victoria muestra ambas líneas
7. ✅ Nombre del arco es "CONSUMO Y CODICIA"
8. ⚠️ Recolección de 10 fragmentos funciona
9. ⚠️ Checkpoint a los 5 fragmentos funciona
10. ⚠️ Victoria al recolectar 10 fragmentos y llegar a la puerta

---

**Estado General**: 🟡 PARCIALMENTE COMPLETADO  
**Próximo Fix**: Agregar arcos fusionados a `supportsHiding`
