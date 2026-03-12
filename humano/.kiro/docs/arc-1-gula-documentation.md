# Documentación Completa: Arco 1 - GULA

## Índice
1. [Visión General](#visión-general)
2. [Estructura del Arco](#estructura-del-arco)
3. [Sistemas Core](#sistemas-core)
4. [Mecánicas de Juego](#mecánicas-de-juego)
5. [Efectos Visuales y Audio](#efectos-visuales-y-audio)
6. [UI y Pantallas](#ui-y-pantallas)
7. [Optimizaciones Críticas](#optimizaciones-críticas)
8. [Errores Comunes a Evitar](#errores-comunes-a-evitar)

---

## Visión General

### Tema del Pecado: GULA
- **Concepto**: Exceso, consumo desmedido, peso de la culpa
- **Ambiente**: Food court oscuro y opresivo
- **Enemigo**: Mateo (figura que representa el exceso)
- **Objetivo**: Recolectar 5 evidencias y escapar

### Filosofía de Diseño
- **Horror psicológico** sobre horror de saltos
- **Tensión gradual** que aumenta con el progreso
- **Mecánicas que reflejan el pecado**: Mientras más evidencias recolectas, más lento te vuelves (peso de la culpa)

---

## Estructura del Arco

### Archivos Principales

```
lib/game/arcs/gluttony/
├── gluttony_arc_game.dart          # Clase principal del juego
├── gluttony_scene.dart             # Generación de escenario
├── components/
│   ├── player_component.dart       # Jugador
│   ├── enemy_component.dart        # Enemigo (Mateo)
│   ├── evidence_component.dart     # Evidencias coleccionables
│   ├── hiding_spot_component.dart  # Lugares para esconderse
│   ├── exit_door_component.dart    # Puerta de salida
│   ├── food_projectile_component.dart # Proyectiles del enemigo
│   ├── vignette_overlay.dart       # Viñeta visual
│   └── effects/                    # Efectos visuales
│       ├── screen_distortion_component.dart
│       ├── breathing_camera_component.dart
│       ├── grease_stain_overlay.dart
│       ├── chromatic_aberration_effect.dart
│       ├── screen_shake_component.dart
│       └── light_mask_component.dart
└── systems/
    ├── discomfort_effects_manager.dart  # Gestor de efectos
    ├── visual_distortion_system.dart
    ├── audio_horror_system.dart
    ├── lighting_system.dart
    ├── haptic_feedback_system.dart
    ├── psychological_pressure_system.dart
    └── game_state.dart
```

---

## Sistemas Core

### 1. Sistema de Cordura (SanitySystem)

**Ubicación**: `lib/game/core/systems/sanity_system.dart`

**Propósito**: Representa la salud mental del jugador (0.0 a 1.0)

```dart
class SanitySystem {
  double currentSanity = 1.0; // 0.0 = agotada, 1.0 = completa
  
  static const double drainRate = 0.06;  // 6% por segundo
  static const double regenRate = 0.15;  // 15% por segundo
  
  void update(double dt, bool nearEnemy, bool isHiding) {
    if (nearEnemy && !isHiding) {
      currentSanity -= drainRate * dt;
    } else if (isHiding) {
      currentSanity += regenRate * dt;
    }
    currentSanity = currentSanity.clamp(0.0, 1.0);
  }
  
  void takeDamage(double percentage) {
    currentSanity -= percentage / 100.0;
    currentSanity = currentSanity.clamp(0.0, 1.0);
  }
}
```

**Reglas Importantes**:
- Se drena cuando estás cerca del enemigo (150px)
- Se regenera cuando te escondes
- Pierdes 4% al recolectar evidencia
- Los efectos visuales comienzan en 80% de cordura
- El enemigo se teletransporta cerca cuando cordura ≤ 85%

### 2. Sistema de Efectos de Incomodidad

**Ubicación**: `lib/game/arcs/gluttony/systems/discomfort_effects_manager.dart`

**Propósito**: Coordina todos los efectos visuales, audio y hápticos

**Subsistemas**:
1. **Visual Distortion**: Distorsión de pantalla
2. **Audio Horror**: Sonidos ambientales y de tensión
3. **Lighting**: Control de visibilidad
4. **Haptic Feedback**: Vibraciones
5. **Psychological Pressure**: Presión psicológica (claustrofobia, control invertido)

**OPTIMIZACIÓN CRÍTICA**:
```dart
// Actualizar efectos cada 50ms en vez de cada frame
double _updateAccumulator = 0.0;
static const double _updateInterval = 0.05;

void update(double dt, GameState state) {
  _updateAccumulator += dt;
  
  if (_updateAccumulator >= _updateInterval) {
    _updateAccumulator = 0.0;
    // Actualizar efectos visuales pesados
    visualSystem.update(dt, proximity, sanity);
    lightingSystem.update(dt, sanity, proximity, evidence);
  }
  
  // Audio y haptics siempre en tiempo real
  audioSystem.update(dt, state);
  hapticSystem.update(dt, state);
}
```

---

## Mecánicas de Juego

### 1. Mecánica de GULA: Peso del Exceso

**Concepto**: Mientras más evidencias recolectas, más lento te vuelves

```dart
void _applyGluttonyPenalty() {
  // Cada evidencia reduce velocidad en 8% (máx 40% con 5 evidencias)
  final speedPenalty = evidenceCollected * 0.08;
  final newSpeed = PlayerComponent.speed * (1.0 - speedPenalty);
  
  _player!.currentSpeed = newSpeed.clamp(
    PlayerComponent.speed * 0.6,  // Mínimo 60% velocidad
    PlayerComponent.speed
  );
}
```

### 2. Teletransporte del Enemigo

**Activación**: Cuando cordura ≤ 85% y recolectas evidencia

```dart
void _teleportEnemyNearPlayer() {
  // Posición aleatoria a 300-400px del jugador
  final angle = random.nextDouble() * 2 * pi;
  final distance = 300 + random.nextDouble() * 100;
  
  final offset = Vector2(
    cos(angle) * distance,
    sin(angle) * distance,
  );
  
  final newPosition = _player!.position + offset;
  
  // Asegurar límites del mapa
  newPosition.x = newPosition.x.clamp(100.0, 2900.0);
  newPosition.y = newPosition.y.clamp(100.0, sceneHeight - 100.0);
  
  _enemy!.position = newPosition;
}
```

### 3. Sistema de Proyectiles

**Frecuencia**: Cada 5 segundos si el jugador está en rango (150-400px)

```dart
void _tryEnemyShoot(double dt) {
  lastProjectileTime += dt;
  
  if (lastProjectileTime >= 5.0) {
    final distance = (_player!.position - _enemy!.position).length;
    
    if (distance > 150 && distance < 400 && !_player!.isHidden) {
      _shootProjectileFromEnemy();
      lastProjectileTime = 0.0;
    }
  }
}
```

**Efecto**: Si te golpea, pierdes 1 evidencia que reaparece en otro lugar

### 4. Posicionamiento de Evidencias

**CRÍTICO**: Las evidencias deben estar en espacios completamente libres

```dart
// Posiciones verificadas sin obstáculos
final safePositions = [
  Vector2(550, 500),    // Entre obstáculos iniciales
  Vector2(1000, 400),   // Entre obstáculos y counter
  Vector2(1400, 500),   // Entre counters
  Vector2(2000, 500),   // Entre obstáculos
  Vector2(2700, 300),   // Después del obstáculo grande
];
```

**Regla**: Verificar contra `gluttony_scene.dart` que no haya obstáculos en esas coordenadas

---

## Efectos Visuales y Audio

### 1. Efectos Visuales por Nivel de Cordura

| Cordura | Efectos Activos |
|---------|----------------|
| 100-81% | Ninguno |
| 80-50% | Breathing camera, Grease stains, Lighting reducido |
| 49-0% | Todos los anteriores + Distorsión intensa |

### 2. Optimizaciones de Efectos

**Screen Distortion**:
```dart
// ❌ MALO: Ondas animadas (muy costoso)
for (double x = 0; x < viewportSize.x; x += 10) {
  final offset = sin(wavePhase + x * 0.02) * intensity * 20;
  path.lineTo(x, y + offset);
}

// ✅ BUENO: Solo gradiente radial
final paint = Paint()
  ..shader = RadialGradient(
    colors: [Colors.transparent, Color.fromRGBO(100, 0, 0, intensity * 0.2)],
  ).createShader(rect);
canvas.drawRect(rect, paint);
```

**Grease Stains**:
```dart
// ❌ MALO: 12 manchas con texturas múltiples
for (int i = 0; i < 3; i++) {
  canvas.drawCircle(offset, size * 0.3, texturePaint);
}

// ✅ BUENO: 8 manchas simples sin texturas extras
canvas.drawCircle(Offset.zero, stain.size, paint);
```

**Breathing Camera**:
```dart
// ❌ MALO: ±10% zoom
final scale = 1.0 + (breathingCycle * 0.1);

// ✅ BUENO: ±5% zoom
final scale = 1.0 + (breathingCycle * 0.05);
```

### 3. Sistema de Iluminación

```dart
// Reducir visibilidad basado en cordura
void updateVisibilityRadius(double sanity, int evidence) {
  double radius = baseVisibilityRadius; // 250px
  
  if (sanity <= 0.8) {
    radius *= 0.8;  // -20% cuando cordura ≤ 80%
  }
  
  if (evidence >= 3) {
    radius *= 0.85;  // -15% adicional con 3+ evidencias
  }
  
  lightMask!.visibilityRadius = radius;
}
```

---

## UI y Pantallas

### 1. Cinemática de Victoria

**Ubicación**: `lib/game/ui/arc_victory_cinematic.dart`

**Fases**:
1. **Fase 0**: Pantalla negra (3 segundos)
2. **Fase 1**: Textos cinemáticos uno por uno
   - "¿Viste el video?"
   - "Todo el mundo lo vio"
   - "1,247,891 reproducciones" (con efecto glitch)
   - "Ya no puede salir de su casa"
3. **Fase 2**: Estadísticas (5 segundos)
4. **Auto-continuar**: Llama a `onComplete()`

**Layout Crítico**:
```dart
// Estructura horizontal sin scroll
Row(
  children: [
    Expanded(child: ArcTitle),  // Izquierda
    Expanded(child: Stats),     // Derecha
  ],
)
```

**PROBLEMA COMÚN**: Overflow vertical en la columna de estadísticas

**Solución**:
```dart
Column(
  mainAxisSize: MainAxisSize.min,  // ¡IMPORTANTE!
  children: [
    _buildStatRow('EVIDENCIAS', '3/5', isSmallScreen),
    SizedBox(height: isSmallScreen ? 1 : 25),  // Espacios mínimos
    _buildStatRow('TIEMPO', '02:34', isSmallScreen),
    SizedBox(height: isSmallScreen ? 1 : 25),
    _buildStatRow('RECOMPENSA', '+100', isSmallScreen),
  ],
)
```

**Tamaños de Fuente para Pantallas Pequeñas**:
```dart
// Labels
fontSize: isSmallScreen ? 7 : 14

// Valores
fontSize: isSmallScreen ? 11 : 32

// Espacios
height: isSmallScreen ? 1 : 25
```

### 2. HUD del Juego

**Elementos**:
- Barra de cordura (arriba izquierda)
- Contador de evidencias (arriba centro)
- Botón de pausa (arriba derecha)
- Botón de esconderse (cuando está cerca de hiding spot)
- Items disponibles (abajo derecha)
- Joystick virtual (solo móvil, abajo izquierda)

### 3. Pantalla de Game Over

**Opciones**:
- **Retry**: Reinicia el juego completo
- **Exit**: Regresa al menú

**Reset Completo**:
```dart
Future<void> resetGame() async {
  inputController.reset();
  sanitySystem.reset();
  discomfortManager?.reset();
  
  // Limpiar items activos
  modoIncognitoActive = false;
  firewallActive = false;
  vpnActive = false;
  
  // Limpiar referencias
  _player = null;
  _enemy = null;
  
  // Llamar reset del padre
  await super.resetGame();
}
```

---

## Optimizaciones Críticas

### 1. Actualización de Efectos por Intervalos

```dart
// En vez de actualizar cada frame (60 FPS)
// Actualizar cada 50ms (20 FPS para efectos)
double _updateAccumulator = 0.0;
static const double _updateInterval = 0.05;
```

**Ahorro**: ~66% menos cálculos de efectos visuales

### 2. Simplificación de Renderizado

**Antes**:
- 12 grease stains con 3 texturas cada una = 36 draw calls
- Ondas animadas con paths complejos
- Gradientes de 4 colores

**Después**:
- 8 grease stains simples = 8 draw calls
- Solo gradientes radiales
- Gradientes de 2-3 colores

**Resultado**: ~70% menos draw calls

### 3. Reducción de Blur

```dart
// Antes
maskFilter: MaskFilter.blur(BlurStyle.normal, 15)

// Después
maskFilter: MaskFilter.blur(BlurStyle.normal, 8)
```

**Impacto**: Blur es muy costoso en móviles

---

## Errores Comunes a Evitar

### 1. ❌ Evidencias en Obstáculos

**Problema**: Colocar evidencias sin verificar obstáculos

**Solución**: 
1. Revisar `gluttony_scene.dart` para ver posiciones de obstáculos
2. Colocar evidencias en espacios con mínimo 100px de clearance
3. Probar en el juego que sean accesibles

### 2. ❌ Overflow en UI

**Problema**: No considerar pantallas pequeñas

**Solución**:
- Usar `mainAxisSize: MainAxisSize.min`
- Tamaños de fuente adaptativos con `isSmallScreen`
- Espacios mínimos en móvil (1-2px)
- Probar en diferentes resoluciones

### 3. ❌ Efectos Visuales Costosos

**Problema**: Demasiados efectos o muy complejos

**Solución**:
- Actualizar efectos cada 50ms, no cada frame
- Simplificar gradientes y eliminar texturas extras
- Reducir blur y número de elementos
- Usar `mainAxisSize: MainAxisSize.min` en columnas

### 4. ❌ No Resetear Estado

**Problema**: Al hacer retry, el juego queda en estado inconsistente

**Solución**:
```dart
Future<void> resetGame() async {
  // Resetear TODOS los sistemas
  inputController.reset();
  sanitySystem.reset();
  discomfortManager?.reset();
  
  // Limpiar TODAS las variables de estado
  modoIncognitoActive = false;
  evidenceCollected = 0;
  lastProjectileTime = 0.0;
  
  // Limpiar referencias
  _player = null;
  _enemy = null;
  
  await super.resetGame();
}
```

### 5. ❌ Métodos Inexistentes

**Problema**: Llamar métodos que no existen en las clases

**Ejemplo**: `sanitySystem.takeDamage()` no existía originalmente

**Solución**: Verificar la clase antes de usar métodos, o agregarlos:
```dart
void takeDamage(double percentage) {
  currentSanity -= percentage / 100.0;
  currentSanity = currentSanity.clamp(0.0, 1.0);
}
```

### 6. ❌ Teletransporte Fuera del Mapa

**Problema**: Enemigo aparece fuera de los límites

**Solución**: Siempre clamp las posiciones:
```dart
newPosition.x = newPosition.x.clamp(100.0, 2900.0);
newPosition.y = newPosition.y.clamp(100.0, sceneHeight - 100.0);
```

---

## Checklist para Nuevos Arcos

### Planificación
- [ ] Definir tema del pecado y cómo se refleja en mecánicas
- [ ] Diseñar escenario apropiado al tema
- [ ] Planear mecánica única que refleje el pecado
- [ ] Definir enemigo y su comportamiento

### Implementación
- [ ] Crear estructura de archivos siguiendo patrón de Gula
- [ ] Implementar mecánica única del pecado
- [ ] Posicionar evidencias en espacios libres verificados
- [ ] Configurar sistema de cordura con valores apropiados
- [ ] Implementar efectos visuales optimizados
- [ ] Crear cinemática de victoria temática

### Optimización
- [ ] Actualizar efectos cada 50ms, no cada frame
- [ ] Simplificar efectos visuales (menos blur, menos elementos)
- [ ] Probar en móvil para verificar rendimiento
- [ ] Verificar que no haya overflow en UI

### Testing
- [ ] Probar en diferentes resoluciones
- [ ] Verificar que evidencias sean accesibles
- [ ] Probar retry y verificar reset completo
- [ ] Verificar que efectos comiencen en cordura correcta
- [ ] Probar mecánica única del pecado

### UI
- [ ] Adaptar cinemática al tema del pecado
- [ ] Verificar que no haya overflow (usar `mainAxisSize: MainAxisSize.min`)
- [ ] Probar en pantallas pequeñas
- [ ] Verificar auto-continuar después de estadísticas

---

## Valores de Referencia

### Cordura
- Drain rate: 6% por segundo
- Regen rate: 15% por segundo
- Daño por evidencia: 4%
- Umbral efectos: 80%
- Umbral teletransporte: 85%

### Velocidad
- Velocidad base jugador: 200 px/s
- Penalidad por evidencia: 8% cada una
- Velocidad mínima: 60% de la base

### Distancias
- Rango detección enemigo: 150px
- Rango proyectiles: 150-400px
- Distancia teletransporte: 300-400px
- Radio colección evidencia: 50px

### Tiempos
- Frecuencia proyectiles: 5 segundos
- Intervalo actualización efectos: 50ms (0.05s)
- Duración cinemática fase 1: ~10 segundos
- Duración estadísticas: 5 segundos

### Escenario
- Ancho: 3000px
- Alto: 1000px
- Evidencias: 5 totales
- Hiding spots: 3 totales

---

## Notas Finales

Esta documentación debe servir como guía para implementar los otros 6 arcos. Cada arco debe:

1. **Mantener la estructura base** pero adaptar mecánicas al pecado
2. **Optimizar desde el inicio** (no esperar a tener problemas de rendimiento)
3. **Probar en móvil** desde el principio
4. **Verificar UI en pantallas pequeñas** antes de dar por terminado
5. **Documentar decisiones específicas** del arco para referencia futura

**Recuerda**: La clave es el balance entre atmósfera inmersiva y rendimiento fluido.
