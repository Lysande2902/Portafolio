# Enemigo Caracol (Samuel) - Arco 6: Pereza

## ✅ IMPLEMENTACIÓN COMPLETA

### Concepto
**Samuel (Caracol)** - Víctima de "cringe content" que intentó suicidarse 3 veces después del video viral.

### Características Únicas

#### 1. Estados del Enemigo
```dart
enum SlothState {
  sleeping,  // Dormido, no se mueve
  patrol,    // Patrullando lentamente
  chase,     // Persiguiendo al jugador (aún lento)
}
```

#### 2. Mecánica de Sueño/Despertar
- **Estado inicial**: Dormido (sleeping)
- **Despertar**: Cuando el ruido del jugador > 70%
- **Volver a dormir**: Cuando ruido < 30% Y jugador está lejos (>300px)

#### 3. Velocidades
```dart
static const double sleepSpeed = 0.0;      // Inmóvil cuando duerme
static const double patrolSpeed = 40.0;    // 40% de velocidad normal
static const double chaseSpeed = 60.0;     // 40% de velocidad de persecución normal
```

#### 4. Rastro de Baba Tóxica
- **Frecuencia**: Cada 0.5 segundos cuando se mueve
- **Efecto**: Reduce velocidad del jugador a 50%
- **Duración**: 10 segundos, luego desaparece
- **Visual**: Charco verdoso con brillo tóxico

#### 5. Detección
- **Radio de detección**: 200px
- **Método**: Visual (cuando está despierto) + Ruido (siempre)
- **Pérdida de objetivo**: Si jugador se aleja >300px

---

## 🎨 Sistema de Animación

### Sprite LPC
- **Ruta**: `assets/animations/lpc_enemigo_caracol/standard/`
- **Animaciones**: idle.png, walk.png
- **Tamaño**: 64x64 pixels
- **Velocidad de animación**: 0.25s por frame (4 FPS) - Muy lento

### Componente de Animación
```dart
AnimatedSlothEnemySprite
- Hereda de SpriteAnimationGroupComponent
- Maneja 4 direcciones (up, left, down, right)
- Fallback visual: Rectángulo verde-grisáceo
```

### Integración
```dart
animatedSprite = AnimatedSlothEnemySprite();
animatedSprite.scale = Vector2(0.78, 1.09);
await add(animatedSprite);
```

---

## 🎮 Mecánicas de Juego

### Sistema de Ruido
```dart
// En SlothArcGame
double noiseLevel = 0.0; // 0.0 a 1.0

// Actualización
if (movementMagnitude > 0.5) {
  noiseLevel += dt * 2.0;  // Movimiento rápido
} else {
  noiseLevel -= dt * 1.0;  // Movimiento lento/quieto
}

// Despertar enemigo
if (noiseLevel > 0.7 && enemy.isAsleep) {
  enemy.wakeUp();
}

// Dormir enemigo
if (noiseLevel < 0.3 && !enemy.isAsleep && distanceToPlayer > 300) {
  enemy.goToSleep();
}
```

### Sistema de Baba Tóxica
```dart
// Generación automática
void _spawnSlimeTrail(double dt) {
  slimeSpawnTimer += dt;
  
  if (slimeSpawnTimer >= 0.5) {
    slimeSpawnTimer = 0.0;
    
    final slime = ToxicSlimeComponent(
      position: position.clone(),
      size: Vector2(80, 80),
    );
    
    parent?.add(slime);
  }
}
```

### Aplicación de Slowdown
```dart
// En SlothArcGame
void _checkSlimeSlowdown() {
  currentSpeedModifier = 1.0; // Reset
  
  for (final component in world.children) {
    if (component is ToxicSlimeComponent) {
      if (component.containsPoint(_player!.position)) {
        currentSpeedModifier = 0.5; // 50% velocidad
        break;
      }
    }
  }
  
  _player!.speedModifier = currentSpeedModifier;
}
```

---

## 🎯 Comportamiento IA

### Sleeping State
```dart
void _updateSleeping(double dt) {
  velocity = Vector2.zero();
  currentAnimationState = PlayerAnimationState.idle;
  // Espera señal de despertar desde el juego
}
```

### Patrol State
```dart
void _updatePatrol(double dt) {
  // 1. Verificar si jugador está en rango
  if (distanceToPlayer < detectionRadius) {
    state = SlothState.chase;
    return;
  }
  
  // 2. Moverse hacia waypoint actual
  velocity = direction * patrolSpeed;
  
  // 3. Cambiar waypoint al llegar
  if (reachedWaypoint) {
    currentWaypointIndex = (currentWaypointIndex + 1) % waypoints.length;
  }
  
  // 4. Dejar rastro de baba
  _spawnSlimeTrail(dt);
}
```

### Chase State
```dart
void _updateChase(double dt) {
  // 1. Verificar si jugador está muy lejos
  if (distanceToPlayer > detectionRadius * 1.5) {
    state = SlothState.patrol;
    return;
  }
  
  // 2. Perseguir jugador (lentamente)
  velocity = direction * chaseSpeed;
  
  // 3. Dejar rastro de baba
  _spawnSlimeTrail(dt);
}
```

---

## 📊 Valores de Balance

### Velocidades
| Estado | Velocidad | % Normal |
|--------|-----------|----------|
| Sleeping | 0 px/s | 0% |
| Patrol | 40 px/s | 40% |
| Chase | 60 px/s | 40% |

### Jugador (SlowPlayerComponent)
| Condición | Velocidad | % Normal |
|-----------|-----------|----------|
| Normal | 90 px/s | 50% |
| En baba | 45 px/s | 25% |

### Detección y Ruido
| Parámetro | Valor |
|-----------|-------|
| Radio de detección | 200px |
| Umbral despertar | 70% ruido |
| Umbral dormir | 30% ruido |
| Distancia para dormir | >300px |

### Baba Tóxica
| Parámetro | Valor |
|-----------|-------|
| Frecuencia spawn | 0.5s |
| Duración | 10s |
| Slowdown | 50% |
| Tamaño | 80x80px |

---

## 🎬 Cinemática Final

### Textos
```
"Lo grabaste en su peor momento"
"'CRINGE COMPILATION #47'"
[Glitch. Estática breve]
"Tres intentos"
"Tres veces que no llegó al amanecer"
```

### Diálogo Final (Pendiente)
> "Yo también era humano"

Samuel no ataca al final, solo mira al jugador antes de desaparecer en las sombras.

---

## 🔧 Archivos Modificados/Creados

### Nuevos Archivos
- ✅ `lib/game/arcs/sloth/components/sloth_enemy_component.dart` - Enemigo completo
- ✅ `lib/game/arcs/sloth/components/animated_sloth_enemy_sprite.dart` - Animación
- ✅ `lib/game/arcs/sloth/components/toxic_slime_component.dart` - Baba tóxica

### Archivos Modificados
- ✅ `lib/game/arcs/sloth/sloth_arc_game.dart` - Integración de mecánicas
- ✅ `lib/game/arcs/sloth/components/slow_player_component.dart` - Speed modifier
- ✅ `lib/game/core/animation/player_animation_types.dart` - SlothEnemyAssets

---

## ✅ Checklist de Funcionalidad

### Implementado
- [x] Sprite animado LPC del Caracol
- [x] Sistema de estados (sleeping/patrol/chase)
- [x] Mecánica de despertar por ruido
- [x] Generación de rastro de baba tóxica
- [x] Slowdown del jugador en baba
- [x] Velocidades muy lentas (40% normal)
- [x] Detección visual y por ruido
- [x] Patrullaje por waypoints
- [x] Persecución lenta del jugador
- [x] Volver a dormir cuando hay silencio

### Pendiente
- [ ] Cinemática final con diálogo
- [ ] Efecto de glitch en cinemática
- [ ] Sonidos de movimiento lento
- [ ] Sonido de despertar
- [ ] Partículas de baba al moverse
- [ ] Testing de balance

---

## 🎮 Cómo Jugar Contra el Caracol

### Estrategia
1. **Movimiento lento**: Mantén el joystick a menos de 50% para evitar hacer ruido
2. **Observa el enemigo**: Si está dormido, puedes moverte más libremente
3. **Evita la baba**: Los charcos verdes te ralentizan mucho
4. **Usa hiding spots**: Reduce el ruido a 0 cuando te escondes
5. **Planifica la ruta**: La baba bloquea caminos, planea con anticipación

### Dificultad
- **Fácil**: Enemigo muy lento, fácil de evitar
- **Medio**: La baba acumulada dificulta el movimiento
- **Difícil**: Mantener el sigilo mientras recolectas evidencias

---

## 💡 Notas de Diseño

### Tema: Depresión y Pereza
- **Lentitud**: Representa la parálisis de la depresión
- **Sueño**: La desconexión del mundo
- **Baba tóxica**: El peso emocional que deja el trauma
- **Sigilo**: La necesidad de ser cuidadoso con personas vulnerables

### Mensaje
El juego no glorifica la depresión, sino que muestra las consecuencias de burlarse del sufrimiento mental de otros. Samuel no es un monstruo agresivo, es una víctima que fue empujada al límite.

---

## 🐛 Testing Checklist

- [ ] Enemigo se carga correctamente con sprite
- [ ] Animaciones funcionan en las 4 direcciones
- [ ] Enemigo comienza dormido
- [ ] Despierta cuando ruido > 70%
- [ ] Vuelve a dormir cuando ruido < 30% y jugador lejos
- [ ] Genera baba cada 0.5s al moverse
- [ ] Baba ralentiza al jugador correctamente
- [ ] Baba desaparece después de 10s
- [ ] Patrullaje funciona correctamente
- [ ] Persecución funciona correctamente
- [ ] No hay lag con múltiples charcos de baba
- [ ] Cinemática se muestra correctamente

---

## 🚀 Próximos Pasos

1. **Testing exhaustivo** de todas las mecánicas
2. **Ajustar balance** basado en playtesting
3. **Agregar sonidos** temáticos
4. **Implementar cinemática final** con diálogo
5. **Optimizar** generación de baba si causa lag
6. **Documentar** cualquier bug encontrado

---

## 📚 Referencias

- Ver `arc-1-gula-documentation.md` para estructura base
- Ver `arcs-2-and-6-implementation-summary.md` para contexto
- Seguir patrones de optimización establecidos
