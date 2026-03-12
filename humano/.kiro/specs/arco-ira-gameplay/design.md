# Design Document - Arco 7: Ira (Wrath)

## Overview

El Arco 7: Ira es el séptimo y más difícil nivel jugable de CONDICIÓN: HUMANO, implementado reutilizando la arquitectura del Arco 1: Gula. Este arco representa el pecado de la ira mediante un enemigo permanentemente enfurecido que se mueve a velocidades extremas y nunca se rinde en la persecución.

**Objetivos de diseño:**
- Reutilizar 90% de la arquitectura del Arco 1 (Gula)
- Crear el arco más difícil con enemigo ultra-agresivo
- Implementar mecánicas de rage: velocidad extrema, detección amplia, persecución infinita
- Atmósfera visual intensa con rojos brillantes y efectos de pantalla
- Implementación rápida: 20-30 minutos

**Tecnologías:**
- Flutter 3.x
- Flame Engine 1.x
- Reutilización de BaseArcGame y componentes existentes

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     ArcGameScreen                           │
│                   (Flutter Widget)                          │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                   WrathArcGame                              │
│              (extends BaseArcGame)                          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Game World (Reused + Modified Components)          │  │
│  │  ├─ PlayerComponent (normal speed) - reused         │  │
│  │  ├─ RagingBullEnemy (200-250% speed)                │  │
│  │  ├─ WrathScene (bright red theme)                   │  │
│  │  ├─ EvidenceComponent (x4) - reused                 │  │
│  │  ├─ ObstacleComponent - reused                      │  │
│  │  └─ ExitDoorComponent - reused                      │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Game Systems (Modified)                            │  │
│  │  ├─ CollisionSystem                                  │  │
│  │  ├─ AggressiveSanitySystem (faster drain)           │  │
│  │  └─ RageAISystem (always aggressive)                │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  New Visual Effects                                  │  │
│  │  ├─ ScreenShakeEffect                                │  │
│  │  ├─ RedFlashEffect                                   │  │
│  │  └─ ParticleTrailComponent                           │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Reused UI Components                           │
│  ├─ GameHUD                                                 │
│  ├─ PauseMenu                                               │
│  ├─ GameOverScreen                                          │
│  └─ VictoryScreen                                           │
└─────────────────────────────────────────────────────────────┘
```

### Directory Structure

```
lib/
├── game/
│   ├── arcs/
│   │   ├── gluttony/                    # Arco 1 (base)
│   │   │   └── ...                      # All base components
│   │   └── wrath/                       # Arco 7 (nuevo)
│   │       ├── wrath_arc_game.dart      # Main game class
│   │       ├── wrath_scene.dart         # Scene with bright red theme
│   │       └── components/
│   │           ├── raging_bull_enemy.dart       # Ultra-aggressive enemy
│   │           ├── screen_shake_effect.dart     # Screen shake component
│   │           ├── red_flash_effect.dart        # Red flash overlay
│   │           └── particle_trail_component.dart # Enemy trail effect
│   ├── core/                            # Reused systems
│   │   ├── base/
│   │   │   └── base_arc_game.dart       # Base class
│   │   └── systems/                     # Modified systems
│   └── ui/                              # All reused
└── screens/
    └── arc_game_screen.dart             # Reused wrapper
```

## Components and Interfaces

### 1. WrathArcGame (extends BaseArcGame)

Main game class for Wrath arc, extends BaseArcGame with aggressive parameters.

```dart
class WrathArcGame extends BaseArcGame {
  // Arc-specific constants
  static const String arcId = 'arc_7_wrath';
  static const int totalEvidence = 4;
  static const int coinsReward = 150;  // Higher reward for difficulty
  
  // Visual effects
  late ScreenShakeEffect screenShake;
  late RedFlashEffect redFlash;
  
  @override
  void onLoad() async {
    super.onLoad();
    
    // Add visual effects
    screenShake = ScreenShakeEffect();
    add(screenShake);
    
    redFlash = RedFlashEffect();
    add(redFlash);
  }
  
  @override
  void setupScene() {
    add(WrathScene());
  }
  
  @override
  void setupPlayer() {
    // Use normal PlayerComponent (no modifications)
    player = PlayerComponent();
    add(player);
  }
  
  @override
  void setupEnemy() {
    enemy = RagingBullEnemy(
      waypoints: [/* patrol points */],
      isAlwaysEnraged: true,
    );
    add(enemy);
  }
  
  @override
  void setupCollectibles() {
    // Spawn 4 evidence items
    for (int i = 0; i < 4; i++) {
      add(EvidenceComponent(
        evidenceId: 'wrath_evidence_$i',
        position: evidencePositions[i],
      ));
    }
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Update screen shake based on enemy proximity
    double distanceToEnemy = (player.position - enemy.position).length;
    if (distanceToEnemy < 200) {
      screenShake.intensity = 1.0 - (distanceToEnemy / 200);
    } else {
      screenShake.intensity = 0.0;
    }
    
    // Trigger red flash when enemy is chasing
    if (enemy.isChasing) {
      redFlash.pulse();
    }
  }
}
```

### 2. RagingBullEnemy (extends EnemyComponent)

Ultra-aggressive enemy that is always enraged.

**Modified Properties:**
```dart
class RagingBullEnemy extends EnemyComponent {
  // Always enraged
  bool isAlwaysEnraged = true;
  
  // Extremely fast patrol speed (200% of normal)
  @override
  double get patrolSpeed => 200.0;  // Normal: 100.0
  
  // Ultra-fast chase speed (250% of normal)
  @override
  double get chaseSpeed => 300.0;  // Normal: 120.0
  
  // Very large detection radius
  @override
  double get detectionRadius => 400.0;  // Normal: 200.0
  
  // Instant detection (no delay)
  @override
  double get detectionDelay => 0.0;  // Normal: 0.5
  
  // Never gives up chase
  @override
  double get chaseLostTimeout => double.infinity;  // Normal: 3.0
  
  // No wait at waypoints
  @override
  double get waypointWaitTime => 0.0;  // Normal: 2.0
  
  // Fast turn speed
  @override
  double get turnSpeed => 10.0;  // Normal: 3.0
  
  // Particle trail
  late ParticleTrailComponent trail;
  
  @override
  void onLoad() async {
    super.onLoad();
    
    // Add particle trail
    trail = ParticleTrailComponent(
      color: Colors.red,
      particleRate: 20,  // particles per second
    );
    add(trail);
  }
  
  @override
  void update(double dt) {
    super.update(dt);
    
    // Always in rage mode
    if (isAlwaysEnraged) {
      state = EnemyState.chase;
    }
  }
  
  // Special rage behavior: charge in last known direction
  Vector2? lastKnownPlayerPosition;
  double chargeTimer = 0.0;
  
  void onLosePlayer() {
    lastKnownPlayerPosition = player.position.clone();
    chargeTimer = 3.0;  // Charge for 3 seconds
  }
  
  void chargeBehavior(double dt) {
    if (chargeTimer > 0) {
      chargeTimer -= dt;
      // Move toward last known position at full speed
      Vector2 direction = (lastKnownPlayerPosition! - position).normalized();
      position += direction * chaseSpeed * dt;
    } else {
      // Start area search
      performAreaSearch();
    }
  }
  
  void performAreaSearch() {
    // Create circular search pattern around last known position
    // Implementation details...
  }
}
```

### 3. PlayerComponent (Reused)

**No modifications needed** - player uses normal speed and controls from base system.

```dart
// Reuse existing PlayerComponent
// Speed: 150.0 (normal)
// All controls and mechanics unchanged
```

### 4. WrathScene (extends SceneComponent)

Scene generator with bright red color palette for wrath atmosphere.

**Color Palette:**
```dart
class WrathScene {
  // Bright red background (intense rage)
  static const Color backgroundColor = Color(0xFF8B0000);  // Dark red
  
  // Walls: Deep crimson
  static const Color wallColor = Color(0xFF DC143C);  // Crimson
  
  // Obstacles: Bright red
  static const Color obstacleColor = Color(0xFFFF0000);  // Pure red
  
  // Floor: Blood red
  static const Color floorColor = Color(0xFF5C0000);  // Very dark red
  
  // Accents: Orange-red (fire)
  static const Color accentColor = Color(0xFFFF4500);  // Orange-red
}
```

**Scene Layout:**
- Similar layout to Gluttony arc
- 4 evidence items
- Fewer hiding spots (only 3) for increased difficulty
- More open spaces for enemy to chase

### 5. ScreenShakeEffect (New Component)

Creates screen shake effect based on enemy proximity.

```dart
class ScreenShakeEffect extends Component {
  double intensity = 0.0;  // 0.0 to 1.0
  double shakeAmount = 10.0;  // pixels
  Random random = Random();
  
  @override
  void update(double dt) {
    if (intensity > 0) {
      // Apply shake to camera
      double offsetX = (random.nextDouble() - 0.5) * 2 * shakeAmount * intensity;
      double offsetY = (random.nextDouble() - 0.5) * 2 * shakeAmount * intensity;
      
      camera.position += Vector2(offsetX, offsetY);
    }
  }
}
```

### 6. RedFlashEffect (New Component)

Creates pulsing red flash overlay when enemy is chasing.

```dart
class RedFlashEffect extends PositionComponent {
  double opacity = 0.0;
  bool isPulsing = false;
  double pulseSpeed = 2.0;
  
  void pulse() {
    isPulsing = true;
  }
  
  @override
  void update(double dt) {
    if (isPulsing) {
      opacity += pulseSpeed * dt;
      if (opacity >= 0.3) {
        opacity = 0.3;
        isPulsing = false;
      }
    } else {
      opacity -= pulseSpeed * dt;
      if (opacity < 0) opacity = 0;
    }
  }
  
  @override
  void render(Canvas canvas) {
    if (opacity > 0) {
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = Colors.red.withOpacity(opacity),
      );
    }
  }
}
```

### 7. ParticleTrailComponent (New Component)

Creates red particle trail behind enemy.

```dart
class ParticleTrailComponent extends Component {
  final Color color;
  final int particleRate;
  final List<Particle> particles = [];
  double spawnTimer = 0.0;
  
  ParticleTrailComponent({
    required this.color,
    required this.particleRate,
  });
  
  @override
  void update(double dt) {
    spawnTimer += dt;
    
    // Spawn particles
    if (spawnTimer >= 1.0 / particleRate) {
      spawnTimer = 0.0;
      particles.add(Particle(
        position: parent!.position.clone(),
        color: color,
        lifetime: 0.5,
      ));
    }
    
    // Update and remove dead particles
    particles.removeWhere((p) {
      p.update(dt);
      return p.isDead;
    });
  }
  
  @override
  void render(Canvas canvas) {
    for (var particle in particles) {
      particle.render(canvas);
    }
  }
}

class Particle {
  Vector2 position;
  Color color;
  double lifetime;
  double age = 0.0;
  
  Particle({
    required this.position,
    required this.color,
    required this.lifetime,
  });
  
  void update(double dt) {
    age += dt;
  }
  
  bool get isDead => age >= lifetime;
  
  void render(Canvas canvas) {
    double opacity = 1.0 - (age / lifetime);
    canvas.drawCircle(
      Offset(position.x, position.y),
      5.0,
      Paint()..color = color.withOpacity(opacity),
    );
  }
}
```

### 8. Reused Components

All other components are reused without modification:
- **EvidenceComponent** - Same collection mechanic
- **ObstacleComponent** - Same collision behavior
- **ExitDoorComponent** - Same victory trigger
- **VignetteOverlay** - Reused with red tint

## Data Models

### WrathEvidenceData

Evidence items specific to the Wrath arc.

```dart
final List<EvidenceData> wrathEvidences = [
  EvidenceData(
    id: 'wrath_evidence_1',
    title: 'Mensajes de odio',
    description: 'Capturas de comentarios violentos enviados en un momento de furia.',
    arcId: 'arc_7_wrath',
  ),
  EvidenceData(
    id: 'wrath_evidence_2',
    title: 'Relaciones destruidas',
    description: 'Conversaciones donde la ira arruinó amistades de años.',
    arcId: 'arc_7_wrath',
  ),
  EvidenceData(
    id: 'wrath_evidence_3',
    title: 'Consecuencias físicas',
    description: 'Fotos de objetos rotos en ataques de rabia.',
    arcId: 'arc_7_wrath',
  ),
  EvidenceData(
    id: 'wrath_evidence_4',
    title: 'Arrepentimiento tardío',
    description: 'Disculpas que llegaron demasiado tarde.',
    arcId: 'arc_7_wrath',
  ),
];
```

## Game Systems

### Modified SanitySystem Parameters

```dart
class AggressiveSanitySystem extends SanitySystem {
  // Much faster sanity drain near enemy
  @override
  double get drainRateNearEnemy => 0.08;  // Normal: 0.05
  
  // Extremely fast drain on contact
  @override
  double get drainRateContact => 0.15;  // Normal: 0.05
  
  // Faster regeneration when hiding (reward for hiding)
  @override
  double get regenRate => 0.01;  // Normal: 0.005
  
  // Larger "near enemy" radius
  @override
  double get nearEnemyRadius => 200.0;  // Normal: 150.0
}
```

### RageAISystem

AI system that keeps enemy always aggressive.

```dart
class RageAISystem extends EnemyAISystem {
  @override
  void update(double dt) {
    // Always in chase mode if player is visible
    if (canSeePlayer()) {
      state = EnemyState.chase;
    } else if (hasLastKnownPosition()) {
      // Charge toward last known position
      chargeBehavior(dt);
    } else {
      // Fast patrol
      patrolBehavior(dt);
    }
  }
  
  // No waiting, no hesitation
  @override
  double get reactionTime => 0.0;
  
  // Instant state transitions
  @override
  double get stateTransitionDelay => 0.0;
}
```

### CollisionSystem

**Modified for destructible obstacles:**

```dart
class WrathCollisionSystem extends CollisionSystem {
  @override
  void onEnemyObstacleCollision(Enemy enemy, Obstacle obstacle) {
    if (obstacle.isDestructible && enemy is RagingBullEnemy) {
      // Destroy obstacle
      obstacle.destroy();
      
      // Play destruction effect
      playDestructionEffect(obstacle.position);
    } else {
      // Normal collision response
      super.onEnemyObstacleCollision(enemy, obstacle);
    }
  }
}
```

## UI and Visual Effects

### Modified Visual Effects

1. **Screen Shake:**
   - Intensity based on enemy proximity (0-200 pixels)
   - Shake amount: 10 pixels at max intensity
   - Increases when sanity is low

2. **Red Flash:**
   - Pulses when enemy starts chasing
   - 30% opacity at peak
   - Fades over 0.5 seconds

3. **Particle Trails:**
   - 20 particles per second behind enemy
   - Red color with fade-out
   - 0.5 second lifetime

4. **Vignette:**
   - Red tint instead of dark
   - Increases with low sanity
   - Pulsing effect when enemy is near

### Reused UI Components

All UI components are reused:
- **GameHUD** - Same layout
- **PauseMenu** - Same options
- **GameOverScreen** - Modified message: "La ira te consumió"
- **VictoryScreen** - Shows higher coin reward (150)

## Performance Optimization

### Performance Considerations

**Potential issues:**
- Screen shake every frame
- Many particles spawning
- Red flash overlay rendering

**Optimizations:**
1. **Particle Pooling:**
   - Reuse particle objects
   - Limit max particles to 100

2. **Conditional Rendering:**
   - Only render effects when visible
   - Skip shake if intensity < 0.1

3. **Efficient Flash:**
   - Use single rectangle overlay
   - No complex shaders

**Expected performance:** 60 FPS (same as Arco 1)

## Integration with Existing Systems

### ArcProgressProvider Integration

```dart
void onArcComplete() async {
  final progressProvider = context.read<ArcProgressProvider>();
  
  await progressProvider.completeArc(
    arcId: 'arc_7_wrath',
    evidenceCollected: evidenceCollected,
    timeSpent: elapsedTime,
  );
  
  // Higher reward for difficulty
  await progressProvider.addCoins(150);
  
  // Unlock achievement
  await progressProvider.unlockAchievement('wrath_master');
}
```

### Arc Selection Integration

```dart
final Arc wrathArc = Arc(
  id: 'arc_7_wrath',
  title: 'Arco 7: Ira',
  subtitle: 'El Rage Quit',
  description: 'El Toro enfurecido nunca descansa. Velocidad extrema, persecución infinita.',
  enemy: 'Toro',
  difficulty: 5,  // Hardest
  estimatedTime: '10-15 min',
  requiredArc: 'arc_1_gluttony',
);
```

## Testing Strategy

### Unit Tests

**New Components to Test:**
1. **RagingBullEnemy:**
   - Verify always enraged state
   - Verify 200-250% speed
   - Verify infinite chase
   - Verify charge behavior

2. **ScreenShakeEffect:**
   - Verify intensity calculation
   - Verify shake amount
   - Verify camera offset

3. **RedFlashEffect:**
   - Verify pulse timing
   - Verify opacity range
   - Verify fade-out

4. **ParticleTrailComponent:**
   - Verify particle spawn rate
   - Verify particle lifetime
   - Verify particle cleanup

### Integration Tests

1. **Difficulty Balance:**
   - Verify game is challenging but fair
   - Verify hiding spots provide safety
   - Verify completion is possible

2. **Visual Effects:**
   - Verify screen shake feels good
   - Verify red flash is not annoying
   - Verify particles don't lag

### Manual Testing Checklist

- [ ] Enemy moves at 200% patrol speed
- [ ] Enemy chases at 250% speed
- [ ] Enemy detects player at 400 pixels
- [ ] Enemy never gives up chase (unless player hides)
- [ ] Screen shakes when enemy is near
- [ ] Red flash pulses when chasing
- [ ] Particle trail follows enemy
- [ ] Sanity drains faster
- [ ] 4 evidence items spawn
- [ ] Exit door unlocks after collecting all
- [ ] Victory awards 150 coins
- [ ] Performance is 60 FPS
- [ ] Game is difficult but beatable

## Implementation Comparison

### What's Different from Arco 1

| Component | Arco 1 (Gula) | Arco 7 (Ira) |
|-----------|---------------|--------------|
| Player Speed | 150.0 | 150.0 (same) |
| Enemy Patrol Speed | 100.0 | 200.0 (200%) |
| Enemy Chase Speed | 120.0 | 300.0 (250%) |
| Detection Radius | 200.0 | 400.0 (200%) |
| Detection Delay | 0.5s | 0.0s (instant) |
| Chase Timeout | 3.0s | ∞ (never) |
| Waypoint Wait | 2.0s | 0.0s (none) |
| Sanity Drain (near) | 0.05 | 0.08 (160%) |
| Sanity Drain (contact) | 0.05 | 0.15 (300%) |
| Sanity Regen | 0.005 | 0.01 (200%) |
| Evidence Count | 3 | 4 |
| Hiding Spots | 5 | 3 (harder) |
| Coins Reward | 100 | 150 |
| Color Palette | Dark red-orange | Bright red |
| Screen Shake | None | Yes |
| Red Flash | None | Yes |
| Particle Trail | None | Yes |

### What's Reused (90% of code)

- BaseArcGame architecture
- PlayerComponent (unchanged)
- All collision logic
- All UI components
- Scene generation logic
- Input handling
- Save/load integration
- Victory/defeat conditions

## Design Decisions and Rationale

### Why 200-250% Enemy Speed?

**Rationale:**
- Fast enough to be threatening
- Player can still outmaneuver with skill
- Creates intense, adrenaline-filled gameplay
- Rewards strategic use of hiding spots

### Why Infinite Chase Timeout?

**Rationale:**
- Represents unstoppable rage
- Forces player to hide, not just run
- Creates unique challenge vs other arcs
- Hiding becomes essential, not optional

### Why 400 Pixel Detection Radius?

**Rationale:**
- Player is almost always in danger
- Encourages careful movement
- Rewards planning and strategy
- Makes hiding spots more valuable

### Why Only 3 Hiding Spots?

**Rationale:**
- Increases difficulty
- Makes each hiding spot precious
- Forces strategic positioning
- Prevents hiding spam

### Why Screen Shake and Red Flash?

**Rationale:**
- Communicates danger intensity
- Creates visceral, intense feel
- Reinforces theme of rage
- Provides visual feedback for enemy proximity

### Why Higher Coin Reward (150)?

**Rationale:**
- Rewards difficulty
- Incentivizes players to attempt hard arc
- Balances risk vs reward
- Acknowledges skill required

## Future Enhancements

### Post-MVP Improvements

1. **Visual Polish:**
   - Add bull charge animation
   - Add destruction particles for obstacles
   - Add fire effects around enemy
   - Add screen distortion when hit

2. **Audio:**
   - Aggressive, fast-paced music
   - Bull snorting sounds
   - Heavy footstep sounds
   - Destruction sound effects

3. **Gameplay:**
   - Destructible obstacles
   - Temporary speed boost power-ups
   - Multiple difficulty levels
   - Time attack mode

## Conclusion

El Arco 7: Ira es el arco más difícil del juego, diseñado para jugadores que buscan un desafío extremo. Reutiliza 90% del código del Arco 1 mientras introduce mecánicas únicas de rage que crean una experiencia intensa y memorable.

**Key Strengths:**
- Alta reutilización de código
- Dificultad balanceada pero extrema
- Efectos visuales impactantes
- Experiencia única de gameplay
- Recompensa apropiada por dificultad

**Implementation Priority:**
1. Create WrathArcGame class (5 min)
2. Create RagingBullEnemy with extreme speeds (7 min)
3. Create WrathScene with red palette (5 min)
4. Implement ScreenShakeEffect (5 min)
5. Implement RedFlashEffect (3 min)
6. Implement ParticleTrailComponent (5 min)
7. Add evidence data (2 min)
8. Test and balance difficulty (8 min)

**Total estimated time: 40 minutes**
