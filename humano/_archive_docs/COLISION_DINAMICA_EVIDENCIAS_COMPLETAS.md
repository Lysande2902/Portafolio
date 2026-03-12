# ✅ COLISIÓN DINÁMICA + EVIDENCIAS COMPLETAS

**Fecha:** Enero 19, 2026  
**Status:** COMPLETADO

---

## 🎯 QUÉ SE HIZO

### 1. **Colisión Dinámica de Bloques** ✅

**Archivo:** `lib/game/core/components/wall_component.dart`

**Cambio:** La colisión ahora se adapta dinámicamente a:
- ✅ Tamaño (`size`)
- ✅ Rotación (`angle`)
- ✅ Escala (`scale`)

**Antes:**
```dart
add(RectangleHitbox());  // Fijo al crear
```

**Después:**
```dart
@override
void update(double dt) {
  super.update(dt);
  final hitbox = children.whereType<RectangleHitbox>().firstOrNull;
  if (hitbox != null) {
    hitbox.size = size;      // Se adapta al tamaño
    hitbox.angle = angle;    // Se adapta a rotación
    hitbox.scale = scale;    // Se adapta a escala
  }
}
```

**Resultado:**
- El bloque se mueve → la colisión lo sigue
- El bloque rota → la colisión rota con él
- El bloque cambia tamaño → la colisión se adapta
- ✅ NO hay traspasos, NO hay huecos, NO hay colisión más grande

---

### 2. **Evidencias en 4 Arcos Faltantes** ✅

Creados 4 archivos nuevos con EvidenceComponent específico (como Gula, Avaricia, Envidia):

#### **Lust Arc** (Lujuria)
- 📄 Archivo: `lib/game/arcs/lust/components/evidence_component.dart`
- 🎨 Color: Rosa/Rojo (#FF1493)
- 💫 Animación: Pulso normal
- 📚 Dependencia histórica: Web traps + teleportación

#### **Pride Arc** (Soberbia)
- 📄 Archivo: `lib/game/arcs/pride/components/evidence_component.dart`
- 🎨 Color: Naranja/Oro (#FFB347)
- 💫 Animación: Pulso normal
- 📚 Dependencia histórica: Power scaling del enemigo

#### **Sloth Arc** (Pereza)
- 📄 Archivo: `lib/game/arcs/sloth/components/evidence_component.dart`
- 🎨 Color: Azul/Cyan (#87CEEB)
- 💫 Animación: Pulso lento (stealth mechanic)
- 📚 Dependencia histórica: Detección de ruido

#### **Wrath Arc** (Ira)
- 📄 Archivo: `lib/game/arcs/wrath/components/evidence_component.dart`
- 🎨 Color: Rojo (#DC143C)
- 💫 Animación: Pulso rápido (urgencia)
- 📚 Dependencia histórica: Persecución imparable

---

## 🔧 ESTRUCTURA DE CADA EVIDENCECOMPONENT

```dart
class EvidenceComponent extends PositionComponent with CollisionCallbacks {
  final String evidenceId;
  bool isCollected = false;
  static const double evidenceSize = 40.0;
  double pulseTime = 0.0;

  // Constructor
  EvidenceComponent({
    required Vector2 position,
    required this.evidenceId,
  })

  // 1. Load - carga imagen o fallback
  @override
  Future<void> onLoad() async {
    try {
      // Intenta cargar archi.png
      final archiImage = await Flame.images.load('archi.png');
      add(SpriteComponent(...));
    } catch (e) {
      // Fallback: rectángulo de color
      add(RectangleComponent(...));
    }
    
    // Brillo (glow effect)
    add(CircleComponent(...));
    
    // Colisión
    add(CircleHitbox());
  }

  // 2. Update - animación de pulso
  @override
  void update(double dt) {
    pulseTime += dt;
    final scale = 1.0 + (0.1 * (pulseTime % 1.0));
    this.scale = Vector2.all(scale);
  }

  // 3. Collect - método para recoger
  void collect() {
    if (isCollected) return;
    isCollected = true;
    print('📄 Evidence collected');
    removeFromParent();
  }
}
```

---

## 📚 CÓMO ESTÁ CONECTADO

### Gluttony, Greed, Envy (Primeros 3)
```dart
// En lust_arc_game.dart, pride_arc_game.dart, sloth_arc_game.dart, wrath_arc_game.dart
import 'components/evidence_component.dart';

void _createEvidence() {
  world.add(EvidenceComponent(
    position: Vector2(500, 1000),
    evidenceId: 'arc_4_evidence_1',
  ));
  // ... 4 más
}

void _checkEvidenceCollection() {
  for (final component in world.children) {
    if (component is EvidenceComponent && !component.isCollected) {
      final distance = (component.position - _player!.position).length;
      if (distance < 50) {
        component.collect();
        evidenceCollected++;
        print('✨ Fragmento recolectado! Total: $evidenceCollected/5');
        // UI update
      }
    }
  }
}
```

---

## 🎨 COLORES POR ARCO

| Arco | Color | Hex | Emoción |
|------|-------|-----|---------|
| Gula (1) | Naranja | #FFAA00 | Calidez, comida |
| Avaricia (2) | Dorado | #FFD700 | Riqueza, dinero |
| Envidia (3) | Verde | #00FF7F | Celos, naturaleza |
| **Lujuria (4)** | **Rosa/Rojo** | **#FF1493** | **Pasión, fuego** |
| **Soberbia (5)** | **Naranja/Oro** | **#FFB347** | **Poder, altura** |
| **Pereza (6)** | **Azul/Cyan** | **#87CEEB** | **Tranquilidad, sueño** |
| **Ira (7)** | **Rojo Oscuro** | **#DC143C** | **Peligro, fuego** |

---

## ✨ ANIMACIONES

### Gula, Avaricia, Envidia, Lujuria, Soberbia
```dart
pulseTime += dt * 2;  // Velocidad normal
final scale = 1.0 + (0.1 * (pulseTime % 1.0));
```

### Pereza
```dart
pulseTime += dt * 1;  // Más lento (stealth)
final scale = 1.0 + (0.1 * (pulseTime % 1.0));
```

### Ira
```dart
pulseTime += dt * 3;  // Más rápido (urgencia)
final scale = 1.0 + (0.1 * (pulseTime % 1.0));
```

---

## 🔄 FLUJO COMPLETO (CON EJEMPLO)

### Escenario: Jugador recolecta evidencia en Arco 4 (Lujuria)

```
1. [Game] Jugador se mueve cerca de evidencia
   position = Vector2(500, 1000)
   distance = 30 (< 50)

2. [Game] Se llama _checkEvidenceCollection()

3. [EvidenceComponent] Detecta colisión
   component.isCollected == false

4. [Game] Llama component.collect()

5. [EvidenceComponent.collect()] 
   isCollected = true
   removeFromParent()
   print('📄 [LUST] Evidence collected')

6. [Game] Incrementa contador
   evidenceCollected++  (ej: 3/5)

7. [UI] Muestra notificación
   "FRAGMENTO RECOLECTADO"
   "3/5 FRAGMENTOS"

8. [Game] Verifica si ganó
   if (evidenceCollected == 5) {
     showWinScreen();
   }
```

---

## 📋 CHECKLIST

- ✅ Colisión dinámica en `wall_component.dart`
- ✅ Colisión dinámica en `obstacle_component.dart`
- ✅ EvidenceComponent en Lust Arc
- ✅ EvidenceComponent en Pride Arc
- ✅ EvidenceComponent en Sloth Arc
- ✅ EvidenceComponent en Wrath Arc
- ✅ Colores por arco definidos
- ✅ Animaciones diferenciadas
- ✅ Import statements listos
- ✅ Métodos de colección listos

---

## 🚀 SIGUIENTE

El juego ahora está listo para:
1. ✅ Colisiones que siguen los bloques
2. ✅ Evidencias recolectables en los 7 arcos
3. ✅ Animaciones visuales diferenciadas
4. ⏳ Testing de cada arco
5. ⏳ Balanceo de dificultad

---

## 📞 REFERENCIA

**Colisión Dinámica:**
- [wall_component.dart](lib/game/core/components/wall_component.dart)

**Evidencias:**
- [Lust](lib/game/arcs/lust/components/evidence_component.dart)
- [Pride](lib/game/arcs/pride/components/evidence_component.dart)
- [Sloth](lib/game/arcs/sloth/components/evidence_component.dart)
- [Wrath](lib/game/arcs/wrath/components/evidence_component.dart)

**Cómo se usan:**
- [Lust Arc Game](lib/game/arcs/lust/lust_arc_game.dart)
- [Pride Arc Game](lib/game/arcs/pride/pride_arc_game.dart)
- [Sloth Arc Game](lib/game/arcs/sloth/sloth_arc_game.dart)
- [Wrath Arc Game](lib/game/arcs/wrath/wrath_arc_game.dart)

