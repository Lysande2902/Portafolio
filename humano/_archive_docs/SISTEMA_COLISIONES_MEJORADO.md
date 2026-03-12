# 🎯 SISTEMA DE COLISIONES MEJORADO - ARCOS FUSIONADOS

## 📐 PROBLEMA IDENTIFICADO

**Síntoma:** Paredes invisibles, obstáculos que no coinciden con su apariencia visual

**Causa raíz:**
- Tamaños de obstáculos inconsistentes
- Posiciones no alineadas a una cuadrícula
- Colisiones mal definidas en componentes

---

## ✅ SOLUCIÓN IMPLEMENTADA

### 1. TAMAÑOS ESTANDARIZADOS

Todos los obstáculos usan tamaños fijos y consistentes:

```dart
// Constantes de colisión estandarizadas
static const double wallThickness = 40.0;      // Paredes del mapa
static const double obstacleSmall = 80.0;      // Obstáculos pequeños
static const double obstacleMedium = 120.0;    // Obstáculos medianos
static const double obstacleLarge = 160.0;     // Obstáculos grandes
```

**Ventajas:**
- Fácil de recordar y usar
- Colisiones predecibles
- Debugging más simple

---

### 2. ALINEACIÓN A CUADRÍCULA

Todos los obstáculos se colocan en posiciones múltiplos de 100:

```dart
// ❌ ANTES (posiciones arbitrarias)
Vector2(347, 523),
Vector2(891, 1247),

// ✅ AHORA (alineadas a cuadrícula)
Vector2(400, 500),
Vector2(900, 1200),
```

**Ventajas:**
- Obstáculos nunca se solapan accidentalmente
- Espacios de navegación consistentes
- Fácil visualizar el mapa mentalmente

---

### 3. SISTEMA DE FILAS

Obstáculos organizados en filas horizontales:

```dart
// Row 1 - Top area (y=200)
Vector2(400, 200),
Vector2(600, 200),
Vector2(1000, 200),

// Row 2 - Upper middle (y=500)
Vector2(300, 500),
Vector2(800, 500),
Vector2(1300, 500),

// Row 3 - Center (y=800)
Vector2(500, 800),
Vector2(1000, 800),
Vector2(1500, 800),
```

**Ventajas:**
- Pasillos claros entre filas
- Navegación intuitiva
- Balance entre desafío y jugabilidad

---

## 🗺️ MAPAS FUSIONADOS

### Dimensiones

**Arcos 1-3 (Fusionados):**
- Ancho: 4800 píxeles (doble del normal)
- Alto: 1600 píxeles
- Área total: 7,680,000 px² (4x el área de un arco normal)

**Arco 4 (Ira - Solo):**
- Ancho: 2400 píxeles (normal)
- Alto: 1600 píxeles
- Área total: 3,840,000 px²

---

### Distribución de Espacio

**Arco Fusionado (4800x1600):**

```
┌─────────────────────────────────────────────────────────┐
│  FASE 1 (0-2400)          │  FASE 2 (2400-4800)         │
│                           │                             │
│  Enemigo 1                │  Enemigo 2                  │
│  5 fragmentos             │  5 fragmentos               │
│  4 escondites             │  4 escondites               │
│                           │                             │
│  Checkpoint ──────────────┼─────────────────────────>   │
│  (x=2400)                 │                             │
│                           │                    Exit     │
└─────────────────────────────────────────────────────────┘
```

---

## 🎮 CHECKPOINT SYSTEM

### Funcionamiento

1. **Inicio:** Jugador en x=200, Enemigo 1 activo
2. **Recolección:** Jugador recoge fragmentos 1-5 en Fase 1
3. **Checkpoint (5 fragmentos):**
   - Enemigo 1 se elimina del mundo
   - Delay de 500ms (efecto dramático)
   - Enemigo 2 aparece en x=2600
   - Jugador continúa hacia Fase 2
4. **Recolección:** Jugador recoge fragmentos 6-10 en Fase 2
5. **Victoria:** Jugador llega a puerta de salida (x=4600) con 10 fragmentos

### Código del Checkpoint

```dart
void _triggerCheckpoint() async {
  checkpointReached = true;
  currentPhase = 2;
  
  // Remove Phase 1 enemy
  if (_currentEnemy != null && _currentEnemy!.isMounted) {
    _currentEnemy!.removeFromParent();
  }
  
  // Dramatic pause
  await Future.delayed(const Duration(milliseconds: 500));
  
  // Spawn Phase 2 enemy
  await _spawnPhase2Enemy();
}
```

---

## 📊 DISTRIBUCIÓN DE OBSTÁCULOS

### Fase 1 (Warehouse/Restaurant)

**Patrón:**
- 5 filas horizontales (y = 200, 500, 800, 1100, 1400)
- 4-5 obstáculos por fila
- 2 obstáculos grandes centrales
- **Total:** ~25 obstáculos

**Espaciado:**
- Entre obstáculos: 200-300px
- Entre filas: 300px
- Pasillos: 180px mínimo

### Fase 2 (Vault/Bank)

**Patrón:**
- 5 filas horizontales (y = 200, 500, 800, 1100, 1400)
- 4-5 obstáculos por fila
- 2 obstáculos grandes centrales
- **Total:** ~25 obstáculos

**Espaciado:**
- Entre obstáculos: 200-300px
- Entre filas: 300px
- Pasillos: 180px mínimo

---

## 🔧 COMPONENTES DE COLISIÓN

### ObstacleComponent

```dart
class ObstacleComponent extends PositionComponent with CollisionCallbacks {
  ObstacleComponent({
    required Vector2 position,
    required Vector2 size,
    required Color color,
  }) : super(
    position: position,
    size: size,
    anchor: Anchor.topLeft, // IMPORTANTE: Anchor consistente
  );
  
  @override
  Future<void> onLoad() async {
    // Hitbox EXACTAMENTE del mismo tamaño que el visual
    add(RectangleHitbox(
      size: size,
      anchor: Anchor.topLeft,
    ));
  }
}
```

**Reglas:**
- Hitbox = Visual (mismo tamaño)
- Anchor siempre topLeft
- Sin padding ni offset

---

## 🎨 TEMAS VISUALES

### Arco 1: Consumo y Codicia

**Fase 1 (Gula):**
- Color base: `#1a0f0a` (marrón oscuro)
- Obstáculos: `#3a2f2a` (cajas marrones)
- Tema: Almacén/Restaurante

**Fase 2 (Avaricia):**
- Color base: `#0a0a0f` (gris-azul oscuro)
- Obstáculos: `#2a2a3a` (cajas de seguridad grises)
- Tema: Bóveda/Banco

### Marcador de Checkpoint

- Color: `#8B0000` (rojo vino) con 30% opacidad
- Ancho: 10px
- Posición: x=2400 (línea vertical completa)

---

## 📝 CHECKLIST DE IMPLEMENTACIÓN

### Para cada arco fusionado:

- [ ] Crear archivo `{arco}_arc_game.dart`
- [ ] Crear archivo `{arco}_scene.dart`
- [ ] Definir constantes de colisión estandarizadas
- [ ] Crear obstáculos alineados a cuadrícula (múltiplos de 100)
- [ ] Organizar obstáculos en 5 filas horizontales
- [ ] Implementar sistema de checkpoint a los 5 fragmentos
- [ ] Distribuir 10 fragmentos (5 por fase)
- [ ] Colocar 8 escondites (4 por fase)
- [ ] Añadir puerta de salida al final (x=4600)
- [ ] Añadir marcador visual de checkpoint (x=2400)
- [ ] Testing de navegación (sin paredes invisibles)
- [ ] Testing de checkpoint (cambio de enemigo funciona)

---

## 🐛 DEBUGGING DE COLISIONES

### Síntomas comunes:

**1. "Pared invisible"**
- **Causa:** Hitbox más grande que visual
- **Solución:** Verificar que `hitbox.size == visual.size`

**2. "Puedo atravesar obstáculos"**
- **Causa:** Falta RectangleHitbox en componente
- **Solución:** Añadir hitbox en `onLoad()`

**3. "Obstáculos se solapan"**
- **Causa:** Posiciones no alineadas a cuadrícula
- **Solución:** Usar múltiplos de 100 para posiciones

**4. "Jugador se queda atascado"**
- **Causa:** Pasillos muy estrechos (<150px)
- **Solución:** Mantener pasillos de 180px mínimo

### Herramientas de debug:

```dart
// Activar visualización de hitboxes
debugMode = true;

// Log de colisiones
@override
void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
  debugPrint('Collision: ${other.runtimeType} at ${other.position}');
}
```

---

## 📐 PLANTILLA DE OBSTÁCULOS

```dart
/// Template para añadir obstáculos alineados
void _addObstacles() {
  // Definir filas (y-coordinates)
  final rows = [200.0, 500.0, 800.0, 1100.0, 1400.0];
  
  // Definir columnas para cada fila
  final columns = {
    200.0: [400, 600, 1000, 1400, 1800],
    500.0: [300, 800, 1300, 1800, 2100],
    800.0: [500, 1000, 1500, 2000],
    1100.0: [400, 900, 1400, 1900],
    1400.0: [600, 1100, 1600, 2100],
  };
  
  // Crear obstáculos
  for (final row in rows) {
    for (final x in columns[row]!) {
      world.add(ObstacleComponent(
        position: Vector2(x, row),
        size: Vector2(obstacleMedium, obstacleMedium),
        color: obstacleColor,
      ));
    }
  }
}
```

---

## 🎯 PRÓXIMOS PASOS

1. ✅ Arco 1: Consumo y Codicia (COMPLETADO)
2. ⏳ Arco 2: Envidia y Lujuria (PENDIENTE)
3. ⏳ Arco 3: Soberbia y Pereza (PENDIENTE)
4. ⏳ Arco 4: Ira (PENDIENTE)

**Tiempo estimado por arco:** 2-3 horas
- 1h: Estructura de archivos y componentes
- 1h: Scene con obstáculos alineados
- 30min: Testing y ajustes

---

**Fecha:** 27 de Enero de 2025  
**Estado:** Sistema de colisiones estandarizado e implementado en Arco 1
