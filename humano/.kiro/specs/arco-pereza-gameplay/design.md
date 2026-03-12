# Design Document - Arco 6: Pereza (Sloth)

## Overview

El Arco 6: Pereza es el sexto nivel jugable de CONDICIÓN: HUMANO, implementado reutilizando la arquitectura del Arco 1: Gula. Este arco representa el pecado de la pereza mediante una mecánica de "cámara lenta global" donde todo el gameplay se ralentiza, creando una experiencia opresiva y somnolienta.

**Objetivos de diseño:**
- Reutilizar 95% de la arquitectura del Arco 1 (Gula)
- Modificar únicamente velocidades y parámetros de tiempo
- Crear atmósfera visual de pereza con colores azul-gris oscuros
- Mantener la misma estructura de gameplay (recolectar evidencias, evitar enemigo, escapar)
- Implementación rápida: 15-20 minutos

**Tecnologías:**
- Flutter 3.x
- Flame Engine 1.x
- Reutilización de BaseArcGame y todos los componentes existentes

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
│                   SlothArcGame                              │
│              (extends BaseArcGame)                          │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Game World (Reused Components)                      │  │
│  │  ├─ SlowPlayerComponent (60% speed)                  │  │
│  │  ├─ SlothEnemyComponent (40-50% speed)               │  │
│  │  ├─ SceneComponent (blue-gray theme)                 │  │
│  │  ├─ EvidenceComponent (x5) - reused                  │  │
│  │  ├─ ObstacleComponent - reused                       │  │
│  │  └─ ExitDoorComponent - reused                       │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Game Systems (Reused)                               │  │
│  │  ├─ CollisionSystem                                  │  │
│  │  ├─ SanitySystem (slower drain)                      │  │
│  │  └─ EnemyAISystem (slower reactions)                 │  │
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
│   │   └── sloth/                       # Arco 6 (nuevo)
│   │       ├── sloth_arc_game.dart      # Main game class
│   │       ├── sloth_scene.dart         # Scene with blue-gray theme
│   │       └── components/
│   │           ├── slow_player_component.dart    # Player with 60% speed
│   │           └── sloth_enemy_component.dart    # Enemy with 40-50% speed
│   ├── core/                            # Reused systems
│   │   ├── base/
│   │   │   └── base_arc_game.dart       # Base class
│   │   └── systems/                     # All reused
│   └── ui/                              # All reused
└── screens/
    └── arc_game_screen.dart             # Reused wrapper
```

## Components and Interfaces

### 1. SlothArcGame (extends BaseArcGame)

Main game class for Sloth arc, extends BaseArcGame with minimal changes.

```dart
class SlothArcGame extends BaseArcGame {
  // Arc-specific constants
  static const String arcId = 'arc_6_sloth';
  static const int totalEvidence = 5;
  static const int coinsReward = 100;
  
  @override
  void setupScene() {
    // Use SlothScene with blue-gray theme
    add(SlothScene());
  }
  
  @override
  void setupPlayer() {
    // Use SlowPlayerComponent with 60% speed
    player = SlowPlayerComponent();
    add(player);
  }
  
  @override
  void setupEnemy() {
    // Use SlothEnemyComponent with 40-50% speed
    enemy = SlothEnemyComponent(
      waypoints: [/* patrol points */],
    );
    add(enemy);
  }
  
  @override
  void setupCollectibles() {
    // Spawn 5 evidence items
    for (int i = 0; i < 5; i++) {
      add(EvidenceComponent(
        evidenceId: 'sloth_evidence_$i',
        position: evidencePositions[i],
      ));
    }
  }
}
```

### 2. SlowPlayerComponent (extends PlayerComponent)

Player with reduced movement speed to simulate lethargy.

**Modified Properties:**
```dart
class SlowPlayerComponent extends PlayerComponent {
  // Reduced speed (60% of normal)
  @override
  double get speed => 90.0;  // Normal: 150.0
  
  // Slower animation speed
  @override
  double get animationSpeed => 0.7;  // 70% of normal
  
  // Everything else inherited from PlayerComponent
}
```

**No other changes needed** - all collision, hiding, and rendering logic is inherited.

### 3. SlothEnemyComponent (extends EnemyComponent)

Enemy with very slow movement to represent sloth.

**Modified Properties:**
```dart
class SlothEnemyComponent extends EnemyComponent {
  // Very slow patrol speed (40% of normal)
  @override
  double get patrolSpeed => 50.0;  // Normal: 100.0
  
  // Slow chase speed (50% of normal)
  @override
  double get chaseSpeed => 80.0;  // Normal: 120.0
  
  // Reduced detection radius
  @override
  double get detectionRadius => 250.0;  // Normal: 200.0
  
  // Longer wait at waypoints
  @override
  double get waypointWaitTime => 3.0;  // Normal: 2.0
  
  // Longer chase persistence
  @override
  double get chaseLostTimeout => 8.0;  // Normal: 3.0
  
  // Everything else inherited from EnemyComponent
}
```

### 4. SlothScene (extends SceneComponent)

Scene generator with blue-gray color palette for sloth atmosphere.

**Color Palette:**
```dart
class SlothScene {
  // Dark blue-gray background (drowsy atmosphere)
  static const Color backgroundColor = Color(0xFF1A1F2E);
  
  // Walls: Dark slate blue
  static const Color wallColor = Color(0xFF2C3E50);
  
  // Obstacles: Muted blue-gray
  static const Color obstacleColor = Color(0xFF34495E);
  
  // Floor: Very dark blue
  static const Color floorColor = Color(0xFF0F1419);
  
  // Accents: Dull purple-blue
  static const Color accentColor = Color(0xFF5D6D7E);
}
```

**Scene Layout:**
- Same layout as Gluttony arc
- 5 evidence items instead of 3
- Same obstacle placement
- Only colors change

### 5. Reused Components

All other components are reused without modification:
- **EvidenceComponent** - Same collection mechanic
- **ObstacleComponent** - Same collision behavior
- **ExitDoorComponent** - Same victory trigger
- **VignetteOverlay** - Increased opacity (60% → 80%)
- **FogParticleComponent** - Slower movement (50% speed)

## Data Models

### SlothEvidenceData

Evidence items specific to the Sloth arc.

```dart
final List<EvidenceData> slothEvidences = [
  EvidenceData(
    id: 'sloth_evidence_1',
    title: 'Notificaciones ignoradas',
    description: 'Cientos de mensajes sin leer de amigos preocupados.',
    arcId: 'arc_6_sloth',
  ),
  EvidenceData(
    id: 'sloth_evidence_2',
    title: 'Proyectos abandonados',
    description: 'Carpetas llenas de ideas que nunca se completaron.',
    arcId: 'arc_6_sloth',
  ),
  EvidenceData(
    id: 'sloth_evidence_3',
    title: 'Alarmas desactivadas',
    description: 'Historial de alarmas pospuestas infinitamente.',
    arcId: 'arc_6_sloth',
  ),
  EvidenceData(
    id: 'sloth_evidence_4',
    title: 'Oportunidades perdidas',
    description: 'Emails de trabajos y becas que expiraron sin respuesta.',
    arcId: 'arc_6_sloth',
  ),
  EvidenceData(
    id: 'sloth_evidence_5',
    title: 'Promesas rotas',
    description: 'Lista de "mañana lo hago" que nunca se cumplieron.',
    arcId: 'arc_6_sloth',
  ),
];
```

## Game Systems

### Modified SanitySystem Parameters

```dart
class SlothSanitySystem extends SanitySystem {
  // Slower sanity drain (more forgiving)
  @override
  double get drainRateNearEnemy => 0.02;  // Normal: 0.05
  
  // Slower sanity drain on contact
  @override
  double get drainRateContact => 0.03;  // Normal: 0.05
  
  // Same regeneration rate
  @override
  double get regenRate => 0.005;  // Same as normal
}
```

### Modified EnemyAISystem Parameters

```dart
class SlothEnemyAI extends EnemyAISystem {
  // Slower reaction time
  @override
  double get detectionDelay => 0.8;  // Normal: 0.5
  
  // Slower turn speed
  @override
  double get turnSpeed => 1.5;  // Normal: 3.0
  
  // Everything else same
}
```

### CollisionSystem

**No changes needed** - reuse existing collision system.

## UI and Visual Effects

### Modified Visual Effects

1. **Vignette Overlay:**
   - Increased base opacity: 60% (normal: 40%)
   - Darker blue-gray tint instead of red
   - Increases to 80% at low sanity

2. **Fog Particles:**
   - Slower movement: 50% speed
   - Blue-gray color instead of red
   - Spawn rate: 1 particle per 2 seconds (slower)

3. **Animation Speed:**
   - All animations play at 70% speed
   - Includes player walk, enemy movement, UI transitions

### Reused UI Components

All UI components are reused without modification:
- **GameHUD** - Same layout and functionality
- **PauseMenu** - Same options
- **GameOverScreen** - Same message structure
- **VictoryScreen** - Same stats display

## Performance Optimization

### Performance Impact

**Expected performance:** Same as Arco 1 (60 FPS)

**Why no performance degradation:**
- Same number of components
- Same collision detection
- Same rendering pipeline
- Only parameter changes, no new systems

**Potential improvement:**
- Slower movement might reduce collision checks
- Fewer particle spawns reduces particle count

## Integration with Existing Systems

### ArcProgressProvider Integration

```dart
void onArcComplete() async {
  final progressProvider = context.read<ArcProgressProvider>();
  
  await progressProvider.completeArc(
    arcId: 'arc_6_sloth',
    evidenceCollected: evidenceCollected,
    timeSpent: elapsedTime,
  );
  
  await progressProvider.addCoins(100);
}
```

### EvidenceProvider Integration

```dart
void onEvidenceCollected(String evidenceId) {
  final evidenceProvider = context.read<EvidenceProvider>();
  evidenceProvider.unlockEvidence(evidenceId);
}
```

### Arc Selection Integration

```dart
final Arc slothArc = Arc(
  id: 'arc_6_sloth',
  title: 'Arco 6: Pereza',
  subtitle: 'La Procrastinación Infinita',
  description: 'Todo se mueve en cámara lenta. El Perezoso te persigue sin prisa, pero sin pausa.',
  enemy: 'Perezoso',
  difficulty: 2,  // Easy-Medium
  estimatedTime: '8-10 min',
  requiredArc: 'arc_1_gluttony',  // Unlock after Arco 1
);
```

## Testing Strategy

### Unit Tests

**Modified Components to Test:**
1. **SlowPlayerComponent:**
   - Verify speed is 60% of normal
   - Verify animation speed is 70%

2. **SlothEnemyComponent:**
   - Verify patrol speed is 40% of normal
   - Verify chase speed is 50% of normal
   - Verify longer waypoint wait time
   - Verify longer chase timeout

3. **SlothSanitySystem:**
   - Verify slower drain rates
   - Verify same regeneration rate

### Integration Tests

1. **Gameplay Feel:**
   - Verify everything feels "slow motion"
   - Verify player can still control character
   - Verify enemy is threatening despite slow speed

2. **Balance:**
   - Verify game is not too easy
   - Verify game is not too hard
   - Verify 8-10 minute completion time

### Manual Testing Checklist

- [ ] Player moves at 60% speed
- [ ] Enemy patrols at 40% speed
- [ ] Enemy chases at 50% speed
- [ ] Animations play at 70% speed
- [ ] Blue-gray color palette applied
- [ ] Vignette is darker and blue-tinted
- [ ] Fog particles are slower and blue
- [ ] Sanity drains slower
- [ ] 5 evidence items spawn correctly
- [ ] All evidence can be collected
- [ ] Exit door works
- [ ] Victory screen shows correct arc
- [ ] Progress saves correctly
- [ ] Performance is 60 FPS

## Implementation Comparison

### What's Different from Arco 1

| Component | Arco 1 (Gula) | Arco 6 (Pereza) |
|-----------|---------------|-----------------|
| Player Speed | 150.0 | 90.0 (60%) |
| Enemy Patrol Speed | 100.0 | 50.0 (40%) |
| Enemy Chase Speed | 120.0 | 80.0 (50%) |
| Detection Radius | 200.0 | 250.0 |
| Waypoint Wait | 2.0s | 3.0s |
| Chase Timeout | 3.0s | 8.0s |
| Sanity Drain (near) | 0.05 | 0.02 |
| Sanity Drain (contact) | 0.05 | 0.03 |
| Animation Speed | 100% | 70% |
| Evidence Count | 3 | 5 |
| Color Palette | Red-orange | Blue-gray |
| Vignette Opacity | 40% | 60% |
| Fog Spawn Rate | 1/sec | 1/2sec |

### What's Reused (95% of code)

- BaseArcGame architecture
- All collision logic
- All UI components
- All game systems (with parameter tweaks)
- Scene generation logic
- Input handling
- Save/load integration
- Victory/defeat conditions

## Design Decisions and Rationale

### Why 60% Player Speed?

**Rationale:**
- Slow enough to feel lethargic
- Fast enough to maintain control
- Tested ratio that feels "sluggish" but not frustrating

### Why 40-50% Enemy Speed?

**Rationale:**
- Enemy must be slower than player
- But persistent enough to be threatening
- Creates tension through inevitability, not speed

### Why 5 Evidence Instead of 3?

**Rationale:**
- Compensates for slower movement
- Maintains similar completion time (8-10 min)
- More exploration of the slow environment

### Why Blue-Gray Color Palette?

**Rationale:**
- Blue = cold, drowsy, depressive
- Gray = dull, lifeless, unmotivated
- Contrasts with Arco 1's warm red-orange
- Reinforces theme of lethargy

### Why Longer Chase Timeout (8s)?

**Rationale:**
- Enemy is persistent, not easily discouraged
- Represents how procrastination "follows you"
- Balances the slower chase speed

## Future Enhancements

### Post-MVP Improvements

1. **Visual Polish:**
   - Add "yawn" animation to enemy
   - Add "tired" particle effects around player
   - Screen blur effect when sanity is low

2. **Audio:**
   - Slow, droning ambient music
   - Slowed-down footstep sounds
   - Yawning sound effects

3. **Gameplay:**
   - "Coffee" power-up that temporarily increases speed
   - "Alarm clock" items that wake up the player
   - Multiple difficulty levels with different speed ratios

## Conclusion

El Arco 6: Pereza es una implementación extremadamente eficiente que reutiliza 95% del código del Arco 1. Los únicos cambios son parámetros de velocidad y colores, lo que permite una implementación rápida (15-20 minutos) mientras mantiene una experiencia de juego única y temática.

**Key Strengths:**
- Máxima reutilización de código
- Implementación rápida
- Experiencia de juego única
- Mismo rendimiento que Arco 1
- Fácil de mantener y modificar

**Implementation Priority:**
1. Create SlothArcGame class (5 min)
2. Create SlowPlayerComponent and SlothEnemyComponent (5 min)
3. Create SlothScene with color palette (5 min)
4. Add evidence data (2 min)
5. Test and adjust parameters (3 min)

**Total estimated time: 20 minutes**
