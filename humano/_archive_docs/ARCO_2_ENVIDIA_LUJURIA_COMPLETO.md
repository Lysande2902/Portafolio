# ✅ ARCO 2: ENVIDIA Y LUJURIA - IMPLEMENTACIÓN COMPLETA

**Fecha:** 27 de Enero de 2025  
**Estado:** ✅ COMPLETADO (90% - Falta testing)

---

## 📋 RESUMEN

Arco fusionado que combina las mecánicas de Envidia (Lucía - Camaleón) y Lujuria (Adriana - Araña) en un solo mapa expandido de 4800x1600 píxeles.

**Característica única:** Fase 1 NO tiene escondites - desafío de movimiento puro.

---

## 📁 ARCHIVOS CREADOS

### Estructura Completa

```
lib/game/arcs/envidia_lujuria/
├── envidia_lujuria_arc_game.dart    ✅ COMPLETADO
├── envidia_lujuria_scene.dart       ✅ COMPLETADO
└── components/
    ├── evidence_component.dart      ✅ COMPLETADO
    ├── exit_door_component.dart     ✅ COMPLETADO
    ├── hiding_spot_component.dart   ✅ COMPLETADO
    └── spider_enemy.dart            ✅ COMPLETADO
```

---

## 🎮 MECÁNICAS IMPLEMENTADAS

### Fase 1: Lucía (Camaleón) - ENVIDIA
**Ubicación:** x = 0 a 2400 (Gym)  
**Fragmentos:** 0-5

**Características:**
- ❌ **SIN ESCONDITES** - Desafío de movimiento puro
- Velocidad progresiva: 160 → 180 → 200 (aumenta cada 2 evidencias)
- Mecánica de fotos para distraer (6 segundos)
- Tema visual: Gym con equipo metálico verde

**Waypoints:**
```dart
Vector2(500, 600),
Vector2(900, 1000),
Vector2(1300, 600),
Vector2(1700, 1100),
Vector2(2100, 700),
Vector2(1700, 1300),
Vector2(1100, 1200),
Vector2(700, 900),
```

### Fase 2: Adriana (Araña) - LUJURIA
**Ubicación:** x = 2400 a 4800 (Club)  
**Fragmentos:** 5-10

**Características:**
- ✅ **4 ESCONDITES DISPONIBLES**
- Teletransporte cada 10 segundos (200-350px del jugador)
- Velocidad base: 90, chase: 120
- Mecánica de redes (TODO: implementar trampas)
- Tema visual: Club con muebles de madera morada

**Waypoints:**
```dart
Vector2(2700, 800),
Vector2(3100, 1200),
Vector2(3500, 800),
Vector2(3900, 1300),
Vector2(4300, 900),
Vector2(3900, 1400),
Vector2(3300, 1300),
Vector2(2900, 1000),
```

---

## 🗺️ DISEÑO DEL MAPA

### Dimensiones
- **Ancho total:** 4800 píxeles (doble del normal)
- **Alto:** 1600 píxeles
- **Checkpoint:** x = 2400 (línea morada vertical)

### Distribución de Elementos

**Fase 1 (Gym - 0 a 2400):**
- 5 fragmentos de evidencia
- 0 escondites (mecánica única)
- ~25 obstáculos (equipo de gym)
- 2 obstáculos grandes centrales
- Textura: Concreto verde oscuro + metal verde

**Fase 2 (Club - 2400 a 4800):**
- 5 fragmentos de evidencia
- 4 escondites
- ~25 obstáculos (muebles de club)
- 2 obstáculos grandes centrales
- Textura: Metal morado + madera morada
- Puerta de salida en x=4600

### Posiciones de Evidencias

```dart
// Fase 1 (Gym)
Vector2(600, 800),
Vector2(1100, 1200),
Vector2(1600, 800),
Vector2(2000, 1300),
Vector2(1300, 1400),

// Fase 2 (Club)
Vector2(2800, 900),
Vector2(3300, 1300),
Vector2(3800, 900),
Vector2(4200, 1400),
Vector2(3500, 1400),
```

### Posiciones de Escondites (Solo Fase 2)

```dart
HidingSpotComponent(position: Vector2(2800, 700), size: Vector2(170, 170)),
HidingSpotComponent(position: Vector2(3400, 1100), size: Vector2(180, 180)),
HidingSpotComponent(position: Vector2(4000, 800), size: Vector2(160, 160)),
HidingSpotComponent(position: Vector2(4400, 1400), size: Vector2(170, 170)),
```

---

## 🎨 TEXTURAS PROCEDURALES

### Fase 1: Gym (Verde)

**Background:**
- Tipo: `concrete`
- Color base: `#0a1a0a` (verde muy oscuro)
- Seed: 10

**Obstáculos:**
- Tipo: `metal` (equipo de gym)
- Color base: `#2a3a2a` (metal con tinte verde)
- Tamaño: 120x120 (medium), 160x160 (large)

### Fase 2: Club (Morado)

**Background:**
- Tipo: `metal`
- Color base: `#1a0a1a` (morado muy oscuro)
- Seed: 20

**Obstáculos:**
- Tipo: `wood` (muebles de club)
- Color base: `#3a2a3a` (madera con tinte morado)
- Tamaño: 120x120 (medium), 160x160 (large)

---

## 🔧 SISTEMA DE CHECKPOINT

### Trigger
```dart
if (evidenceCollected >= 5 && currentPhase == 1 && !checkpointReached) {
  _triggerCheckpoint();
}
```

### Proceso
1. Marcar checkpoint como alcanzado
2. Cambiar a Fase 2
3. Remover enemigo Fase 1 (Lucía)
4. Delay de 500ms (efecto dramático)
5. Spawner enemigo Fase 2 (Adriana)
6. Mensaje de debug: "NOW HIDING SPOTS AVAILABLE!"

### Código
```dart
void _triggerCheckpoint() async {
  checkpointReached = true;
  currentPhase = 2;
  
  debugPrint('🎯 [CHECKPOINT] Reached! Switching from Lucía to Adriana');
  debugPrint('   Fragments collected: $evidenceCollected/10');
  debugPrint('   NOW HIDING SPOTS AVAILABLE!');
  
  if (_currentEnemy != null && _currentEnemy!.isMounted) {
    _currentEnemy!.removeFromParent();
  }
  
  await Future.delayed(const Duration(milliseconds: 500));
  await _spawnPhase2Enemy();
}
```

---

## 🕷️ SPIDER ENEMY (Adriana)

### Características Técnicas

**Movimiento:**
- Velocidad base: 90 px/s
- Velocidad chase: 120 px/s
- Distancia de detección: 280 px

**Teletransporte:**
- Intervalo: 10 segundos
- Distancia del jugador: 200-350 px
- Ángulo: Aleatorio (0-360°)
- Límites del mapa: x=2440-4760, y=80-1520

**Mecánica de Redes:**
- Intervalo: 15 segundos
- Estado: TODO (pendiente implementación)
- Efecto planeado: Ralentizar jugador 50% por 3 segundos

**Grace Period:**
- Duración: 1 segundo
- Trigger: Cuando jugador sale de escondite
- Efecto: Enemigo no puede atrapar durante este tiempo

### Código de Teletransporte

```dart
void _teleportNearPlayer() {
  if (targetPlayer == null) return;

  final distance = 200 + _random.nextDouble() * 150;
  final angle = _random.nextDouble() * 2 * pi;

  final newX = targetPlayer!.position.x + cos(angle) * distance;
  final newY = targetPlayer!.position.y + sin(angle) * distance;

  // Clamp to Phase 2 area
  final clampedX = newX.clamp(2440.0, 4760.0);
  final clampedY = newY.clamp(80.0, 1520.0);

  position = Vector2(clampedX, clampedY);
  debugPrint('🕷️ [SPIDER-ENEMY] Teleported near player!');
}
```

---

## 🎯 SISTEMA DE COLISIONES

### Tamaños Estandarizados

```dart
static const double wallThickness = 40.0;
static const double obstacleSmall = 80.0;
static const double obstacleMedium = 120.0;
static const double obstacleLarge = 160.0;
```

### Alineación a Cuadrícula

Todos los obstáculos en múltiplos de 100:
- Fase 1: x = 300, 400, 500, 600, 700, 800, 900, 1000, 1100, 1300, 1400, 1500, 1800, 1900, 2000, 2100
- Fase 2: x = 2600, 2700, 2800, 2900, 3200, 3300, 3400, 3700, 3800, 3900, 4100, 4200, 4300

### Sistema de Filas

5 filas horizontales en cada fase:
- y = 200 (top)
- y = 500 (upper middle)
- y = 800 (center)
- y = 1100 (lower middle)
- y = 1400 (bottom)

---

## 📊 ESTADÍSTICAS DEL ARCO

### Elementos del Mapa

| Elemento | Cantidad | Ubicación |
|----------|----------|-----------|
| Fragmentos | 10 | 5 por fase |
| Escondites | 4 | Solo Fase 2 |
| Obstáculos pequeños | ~50 | Ambas fases |
| Obstáculos grandes | 4 | 2 por fase |
| Enemigos | 2 | 1 por fase |
| Puerta de salida | 1 | x=4600 |

### Dificultad Progresiva

**Fase 1 (Lucía):**
- Fragmentos 0-1: Velocidad 160 (fácil)
- Fragmentos 2-3: Velocidad 180 (medio)
- Fragmentos 4-5: Velocidad 200 (difícil)

**Fase 2 (Adriana):**
- Velocidad constante: 90/120
- Teletransporte cada 10s (impredecible)
- Escondites disponibles (alivio)

---

## 🎮 MECÁNICAS ESPECIALES

### Fase 1: Sin Escondites

**Implementación:**
```dart
void toggleHide() {
  if (_player == null) return;
  
  // Phase 1: NO hiding allowed
  if (currentPhase == 1) {
    debugPrint('⚠️ [PHASE1] No hiding in gym! Keep moving!');
    return;
  }
  
  // Phase 2: Hiding allowed
  if (_player!.isNearHidingSpot && !_player!.isHidden) {
    _player!.hide();
  } else if (_player!.isHidden) {
    _player!.unhide();
  }
}
```

**Razón de diseño:**
- Fuerza al jugador a dominar el movimiento
- Aumenta la tensión en la primera mitad
- Hace que los escondites de Fase 2 sean un alivio bienvenido

### Fase 2: Teletransporte

**Implementación:**
```dart
teleportTimer += dt;
if (teleportTimer >= teleportInterval) {
  _teleportNearPlayer();
  teleportTimer = 0.0;
}
```

**Efecto en gameplay:**
- Impredecibilidad constante
- No se puede "aprender" el patrón
- Requiere reacción rápida del jugador

---

## 🐛 TESTING PENDIENTE

### Checklist de Testing

- [ ] **Fase 1:**
  - [ ] Lucía patrulla correctamente
  - [ ] Velocidad aumenta en fragmentos 2 y 4
  - [ ] Intentar esconderse muestra mensaje de error
  - [ ] Fotos distraen correctamente
  - [ ] Colisiones funcionan (sin paredes invisibles)

- [ ] **Checkpoint:**
  - [ ] Se activa exactamente a los 5 fragmentos
  - [ ] Lucía desaparece correctamente
  - [ ] Adriana aparece después del delay
  - [ ] Mensaje de debug se muestra

- [ ] **Fase 2:**
  - [ ] Adriana patrulla correctamente
  - [ ] Teletransporte funciona cada 10s
  - [ ] Teletransporte respeta límites del mapa
  - [ ] Escondites funcionan correctamente
  - [ ] Grace period funciona al salir de escondite
  - [ ] Colisiones funcionan

- [ ] **Victoria:**
  - [ ] Puerta se desbloquea con 10 fragmentos
  - [ ] Jugador puede salir y ganar
  - [ ] Estadísticas se guardan correctamente

- [ ] **Performance:**
  - [ ] 30+ FPS en móvil
  - [ ] 60+ FPS en desktop
  - [ ] Sin lag en teletransporte

---

## 📝 NOTAS DE IMPLEMENTACIÓN

### Decisiones de Diseño

1. **Sin escondites en Fase 1:**
   - Hace el arco único
   - Enseña al jugador a moverse bien
   - Aumenta la dificultad progresivamente

2. **Teletransporte cada 10s:**
   - No tan frecuente como para ser frustrante
   - Suficiente para mantener tensión
   - Da tiempo al jugador para reaccionar

3. **4 escondites en Fase 2:**
   - Suficientes para dar opciones
   - No tantos como para hacer el arco fácil
   - Bien distribuidos por el mapa

4. **Texturas procedurales:**
   - 0 KB de assets
   - Variación infinita con seeds
   - Fácil de ajustar colores

### Problemas Conocidos

1. **Mecánica de redes no implementada:**
   - TODO: Crear componente WebTrap
   - TODO: Lógica de ralentización
   - TODO: Visual de red en el suelo

2. **Audio no implementado:**
   - TODO: Sonido de teletransporte
   - TODO: Música de gym (Fase 1)
   - TODO: Música de club (Fase 2)

---

## 🔗 ARCHIVOS RELACIONADOS

- `PLAN_ARCOS_FUSIONADOS.md` - Plan general
- `SISTEMA_COLISIONES_MEJORADO.md` - Sistema de colisiones
- `TEXTURAS_PROCEDURALES_GUIA.md` - Guía de texturas
- `PROGRESO_ARCOS_FUSIONADOS_2025_01_27.md` - Progreso general

---

## ✅ PRÓXIMOS PASOS

1. **Testing completo del arco**
   - Probar ambas fases
   - Verificar checkpoint
   - Confirmar colisiones

2. **Implementar mecánica de redes**
   - Crear componente WebTrap
   - Lógica de ralentización
   - Visual de red

3. **Continuar con Arco 3**
   - Soberbia y Pereza
   - Nuevos enemigos (León y Babosa)

---

**Estado final:** ✅ Estructura completa, listo para testing  
**Tiempo de implementación:** ~2 horas  
**Próximo arco:** Soberbia y Pereza (Arco 3)
