# Design Document - Arco 1: Gula

## Overview

El Arco 1: Gula es el primer nivel jugable de CONDICIÓN: HUMANO, implementado usando Flutter con Flame Engine. Este documento detalla la arquitectura técnica, componentes, sistemas de juego, y decisiones de diseño para crear una experiencia de gameplay funcional y reutilizable.

**Objetivos de diseño:**
- Crear un sistema de gameplay 2D modular y reutilizable para los 6 arcos restantes
- Implementar mecánicas core: movimiento, colisiones, IA enemiga, sigilo
- Generar el escenario completamente con código (sin assets de imagen)
- Integrar con los sistemas existentes del juego (providers, navegación)
- Mantener 60 FPS en dispositivos móviles de gama media

**Tecnologías:**
- Flutter 3.x
- Flame Engine 1.x (game loop, rendering, components)
- Provider (state management)
- SharedPreferences (persistencia local)

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
│                   GluttonyArcGame                           │
│                  (FlameGame subclass)                       │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Game World (Components)                             │  │
│  │  ├─ PlayerComponent                                  │  │
│  │  ├─ EnemyComponent (Mateo)                           │  │
│  │  ├─ SceneComponent (environment)                     │  │
│  │  ├─ EvidenceComponent (x3)                           │  │
│  │  ├─ HidingSpotComponent (x5)                         │  │
│  │  └─ ExitDoorComponent                                │  │
│  └──────────────────────────────────────────────────────┘  │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Game Systems                                        │  │
│  │  ├─ CollisionSystem                                  │  │
│  │  ├─ SanitySystem                                     │  │
│  │  └─ EnemyAISystem                                    │  │
│  └──────────────────────────────────────────────────────┘  │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                  Game State Providers                       │
│  ├─ ArcProgressProvider (completion, coins)                │
│  ├─ EvidenceProvider (unlocked evidence)                   │
│  └─ SettingsProvider (volume, controls)                    │
└─────────────────────────────────────────────────────────────┘
```

### Directory Structure


```
lib/
├── game/
│   ├── arcs/
│   │   └── gluttony/
│   │       ├── gluttony_arc_game.dart          # Main game class
│   │       ├── gluttony_scene.dart             # Scene generation
│   │       └── components/
│   │           ├── player_component.dart
│   │           ├── enemy_component.dart
│   │           ├── evidence_component.dart
│   │           ├── hiding_spot_component.dart
│   │           └── exit_door_component.dart
│   ├── core/
│   │   ├── systems/
│   │   │   ├── collision_system.dart
│   │   │   ├── sanity_system.dart
│   │   │   └── enemy_ai_system.dart
│   │   └── base/
│   │       ├── base_arc_game.dart              # Reusable base class
│   │       └── game_component.dart
│   └── ui/
│       ├── game_hud.dart                       # Overlay UI
│       ├── game_over_screen.dart
│       └── victory_screen.dart
└── screens/
    └── arc_game_screen.dart                    # Flutter wrapper
```

## Components and Interfaces

### 1. BaseArcGame (Abstract Base Class)

Base class for all arc games to promote code reuse.

```dart
abstract class BaseArcGame extends FlameGame with HasCollisionDetection {
  // Core systems
  late CollisionSystem collisionSystem;
  late SanitySystem sanitySystem;
  
  // State
  bool isGameOver = false;
  bool isVictory = false;
  int evidenceCollected = 0;
  
  // Abstract methods to be implemented by each arc
  void setupScene();
  void setupPlayer();
  void setupEnemy();
  void setupCollectibles();
  
  // Common methods
  void onGameOver();
  void onVictory();
  void pauseGame();
  void resumeGame();
}
```

### 2. PlayerComponent

Handles player movement, animation, and state.

**Properties:**
- `position: Vector2` - Current position in world space
- `velocity: Vector2` - Current movement velocity
- `speed: double = 150.0` - Movement speed in pixels/second
- `isHidden: bool = false` - Whether player is currently hiding
- `size: Vector2 = Vector2(40, 60)` - Hitbox size

**Methods:**
- `move(Vector2 direction)` - Move player in direction
- `hide()` - Enter hiding state
- `unhide()` - Exit hiding state
- `onCollision(PositionComponent other)` - Handle collisions

**Rendering:**
- Simple colored rectangle (blue for player)
- Semi-transparent when hidden (opacity 0.5)
- No sprite animations initially (can add later)

### 3. EnemyComponent (Mateo)

AI-controlled enemy with patrol and chase behaviors.

**Properties:**
- `position: Vector2` - Current position
- `speed: double = 100.0` - Patrol speed
- `chaseSpeed: double = 120.0` - Chase speed
- `detectionRadius: double = 200.0` - Detection range
- `waypoints: List<Vector2>` - Patrol waypoints
- `currentWaypointIndex: int` - Current target waypoint
- `state: EnemyState` - Current AI state (patrol/chase/waiting)
- `size: Vector2 = Vector2(50, 70)` - Hitbox size

**AI States:**
```dart
enum EnemyState {
  patrol,    // Moving between waypoints
  waiting,   // Paused at waypoint
  chase,     // Pursuing player
  returning  // Returning to patrol after losing player
}
```

**Methods:**
- `updateAI(double dt)` - Main AI update loop
- `patrolBehavior()` - Move to next waypoint
- `chaseBehavior(Vector2 playerPos)` - Chase player
- `detectPlayer(Vector2 playerPos, bool isHidden)` - Check if player is in range
- `onReachWaypoint()` - Handle waypoint arrival

**Rendering:**
- Red rectangle with darker outline
- Direction indicator (small triangle pointing forward)



### 4. EvidenceComponent

Collectible items that reveal story fragments.

**Properties:**
- `position: Vector2` - Fixed position in scene
- `evidenceId: String` - Unique identifier
- `isCollected: bool = false` - Collection state
- `glowIntensity: double = 0.0` - Pulsing glow effect
- `size: Vector2 = Vector2(30, 30)` - Hitbox size

**Methods:**
- `onPlayerNearby()` - Activate glow effect
- `collect()` - Mark as collected and trigger event
- `updateGlow(double dt)` - Animate glow effect

**Rendering:**
- Yellow/gold square with pulsing glow
- Disappears when collected

### 5. HidingSpotComponent

Areas where player can hide from enemy.

**Properties:**
- `position: Vector2` - Position in scene
- `size: Vector2` - Area dimensions
- `isOccupied: bool = false` - Whether player is hiding here

**Methods:**
- `canHide()` - Check if spot is available
- `onPlayerEnter()` - Player enters hiding spot
- `onPlayerExit()` - Player leaves hiding spot

**Rendering:**
- Dark gray rectangle with dashed border
- Slightly transparent to show it's a special area

### 6. ExitDoorComponent

Victory trigger at the end of the level.

**Properties:**
- `position: Vector2` - Position at far end of scene
- `size: Vector2 = Vector2(60, 100)` - Door dimensions
- `isActive: bool = true` - Whether door can be used

**Methods:**
- `onPlayerReach()` - Trigger victory condition

**Rendering:**
- Green rectangle with bright outline
- Pulsing glow to indicate it's the goal

### 7. SceneComponent

Generates the food court environment procedurally.

**Properties:**
- `obstacles: List<RectangleComponent>` - Walls and barriers
- `decorations: List<RectangleComponent>` - Visual elements (tables, counters)
- `background: RectangleComponent` - Background color

**Methods:**
- `generateScene()` - Create all scene elements
- `createObstacle(Vector2 pos, Vector2 size, Color color)` - Helper to create obstacles
- `createDecoration(Vector2 pos, Vector2 size, Color color)` - Helper for decorations

**Scene Layout:**
```
[Start] ─── [Area 1] ─── [Area 2] ─── [Area 3] ─── [Exit]
  │           │            │            │            │
Player    Evidence 1   Evidence 2   Evidence 3    Door
         Hiding x2     Hiding x2    Hiding x1
         Enemy patrol  Enemy patrol Enemy patrol
```

**Color Palette:**
- Background: Dark red (#2D0A0A)
- Walls: Dark brown (#3D2314)
- Tables/Counters: Orange-brown (#8B4513)
- Floor: Dirty red (#4A1414)
- Accents: Bright orange (#FF6B35)

## Data Models

### GameState

```dart
class GameState {
  bool isPlaying;
  bool isPaused;
  bool isGameOver;
  bool isVictory;
  double sanity;              // 0.0 to 1.0
  int evidenceCollected;      // 0 to 3
  double elapsedTime;         // seconds
  
  GameState({
    this.isPlaying = false,
    this.isPaused = false,
    this.isGameOver = false,
    this.isVictory = false,
    this.sanity = 1.0,
    this.evidenceCollected = 0,
    this.elapsedTime = 0.0,
  });
}
```

### EvidenceData

```dart
class EvidenceData {
  final String id;
  final String title;
  final String description;
  final String arcId;
  
  EvidenceData({
    required this.id,
    required this.title,
    required this.description,
    required this.arcId,
  });
}
```

**Evidence for Arco 1:**
1. `gluttony_evidence_1`: "Screenshot del meme viral"
2. `gluttony_evidence_2`: "Comentarios crueles sobre Mateo"
3. `gluttony_evidence_3`: "Video de Mateo llorando"



## Game Systems

### CollisionSystem

Handles all collision detection and response.

**Responsibilities:**
- Detect player-obstacle collisions
- Detect player-enemy collisions
- Detect player-evidence collisions
- Detect player-hiding spot overlaps
- Detect player-exit door overlap

**Implementation:**
- Use Flame's built-in `HasCollisionDetection` mixin
- Add `RectangleHitbox` to all collidable components
- Implement `onCollision` callbacks in components

**Collision Layers:**
```dart
enum CollisionLayer {
  player,
  enemy,
  obstacle,
  evidence,
  hidingSpot,
  exitDoor,
}
```

### SanitySystem

Manages the player's "Cordura Digital" (sanity/health).

**Properties:**
- `currentSanity: double` - Current value (0.0 to 1.0)
- `drainRate: double = 0.05` - Drain per second when near enemy
- `regenRate: double = 0.10` - Regen per second when hiding

**Methods:**
- `update(double dt, bool nearEnemy, bool isHiding)` - Update sanity value
- `drain(double amount)` - Decrease sanity
- `regenerate(double amount)` - Increase sanity
- `getStaticIntensity()` - Calculate visual static effect intensity

**Visual Effect:**
- Overlay a semi-transparent noise texture
- Intensity increases as sanity decreases
- At 0% sanity: full static, trigger game over

**Implementation:**
```dart
class SanitySystem {
  double currentSanity = 1.0;
  
  void update(double dt, bool nearEnemy, bool isHiding) {
    if (nearEnemy && !isHiding) {
      currentSanity -= 0.05 * dt;
    } else if (isHiding) {
      currentSanity += 0.10 * dt;
    }
    currentSanity = currentSanity.clamp(0.0, 1.0);
  }
  
  double getStaticIntensity() {
    return 1.0 - currentSanity; // 0% sanity = 100% static
  }
}
```

### EnemyAISystem

Controls enemy behavior and decision-making.

**State Machine:**
```
    ┌─────────┐
    │ PATROL  │◄──────────┐
    └────┬────┘           │
         │                │
    Player detected       │
         │                │
         ▼                │
    ┌─────────┐      Lost player
    │  CHASE  │           │
    └────┬────┘           │
         │                │
    Caught player    ┌────┴─────┐
         │           │ RETURNING │
         ▼           └──────────┘
    ┌─────────┐
    │GAME OVER│
    └─────────┘
```

**Patrol Behavior:**
1. Move toward current waypoint at patrol speed
2. When within 10 pixels of waypoint, stop
3. Wait for 2 seconds
4. Move to next waypoint (cycle through list)

**Chase Behavior:**
1. Calculate direction to player
2. Move toward player at chase speed
3. If player enters hiding spot or exits detection radius, start return timer
4. After 3 seconds, return to patrol

**Detection Logic:**
```dart
bool detectPlayer(Vector2 playerPos, bool isHidden) {
  if (isHidden) return false;
  double distance = (playerPos - position).length;
  return distance <= detectionRadius;
}
```

## UI and HUD

### GameHUD (Overlay Widget)

Displays game information over the Flame game.

**Elements:**
- **Sanity Indicator**: Progress bar (top-left)
  - Green (100-70%), Yellow (70-30%), Red (30-0%)
  - Shows static effect preview
  
- **Evidence Counter**: Text (top-right)
  - Format: "📄 X/3"
  - Glows briefly when evidence collected
  
- **Virtual Joystick**: (bottom-left, mobile only)
  - Circular joystick for 360° movement
  - Appears on touch, fades when released
  
- **Action Button**: (bottom-right)
  - Context-sensitive: "Hide" when near hiding spot
  - Circular button with icon
  
- **Pause Button**: (top-center)
  - Hamburger menu icon
  - Opens pause overlay

**Implementation:**
```dart
class GameHUD extends StatelessWidget {
  final GameState gameState;
  final VoidCallback onPause;
  final VoidCallback onHide;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Sanity bar
        Positioned(
          top: 40,
          left: 20,
          child: SanityBar(sanity: gameState.sanity),
        ),
        // Evidence counter
        Positioned(
          top: 40,
          right: 20,
          child: Text('📄 ${gameState.evidenceCollected}/3'),
        ),
        // Virtual joystick (mobile)
        if (Platform.isAndroid || Platform.isIOS)
          Positioned(
            bottom: 40,
            left: 40,
            child: VirtualJoystick(),
          ),
        // Action button
        Positioned(
          bottom: 40,
          right: 40,
          child: ActionButton(onPressed: onHide),
        ),
      ],
    );
  }
}
```



### GameOverScreen

Displayed when player loses (sanity reaches 0 or caught by enemy).

**Elements:**
- Dark overlay (80% opacity black)
- Message from Mateo: "¿Valió la pena el meme?"
- Retry button
- Exit to Menu button

**Animation:**
- Fade in over 0.5 seconds
- Message appears with typewriter effect

### VictoryScreen

Displayed when player reaches the exit door.

**Elements:**
- Semi-transparent overlay
- "Arco Completado" title
- Statistics:
  - Evidence collected: X/3
  - Time taken: MM:SS
  - Coins earned: 100
- Continue button

**Animation:**
- Slide up from bottom
- Stats count up with animation

## Input Handling

### Mobile Controls

**Virtual Joystick:**
- Drag finger to move player
- Release to stop
- 360° movement direction

**Action Button:**
- Tap to hide/unhide
- Only visible when near hiding spot

### Desktop Controls (for testing)

**Keyboard:**
- WASD or Arrow Keys: Move player
- Space: Hide/unhide
- Escape: Pause game

**Mouse:**
- Click action button
- Click pause button

### Input Processing

```dart
class InputController {
  Vector2 movementDirection = Vector2.zero();
  bool hidePressed = false;
  
  void updateFromJoystick(JoystickData data) {
    movementDirection = data.direction;
  }
  
  void updateFromKeyboard(Set<LogicalKeyboardKey> keys) {
    double x = 0, y = 0;
    if (keys.contains(LogicalKeyboardKey.keyA)) x -= 1;
    if (keys.contains(LogicalKeyboardKey.keyD)) x += 1;
    if (keys.contains(LogicalKeyboardKey.keyW)) y -= 1;
    if (keys.contains(LogicalKeyboardKey.keyS)) y += 1;
    movementDirection = Vector2(x, y).normalized();
  }
}
```

## Performance Optimization

### Target Performance
- 60 FPS on mid-range Android devices (Snapdragon 660+)
- 60 FPS on iPhone 8+
- Scene size: 3000x1000 pixels
- Max components: ~50

### Optimization Strategies

1. **Component Pooling:**
   - Reuse components instead of creating/destroying
   - Pool for evidence notifications, particles

2. **Culling:**
   - Only render components within camera view
   - Disable AI updates for off-screen enemies (future arcs)

3. **Simplified Rendering:**
   - Use solid colors instead of textures
   - Minimal particle effects
   - No complex shaders

4. **Efficient Collision Detection:**
   - Use spatial partitioning (quadtree) if needed
   - Limit collision checks to nearby objects

5. **State Management:**
   - Minimize provider rebuilds
   - Use `const` widgets where possible
   - Separate game state from UI state

## Integration with Existing Systems

### ArcProgressProvider Integration

When arc is completed:
```dart
void onArcComplete() async {
  final progressProvider = context.read<ArcProgressProvider>();
  
  // Mark arc as completed
  await progressProvider.completeArc(
    arcId: 'arc_1_gluttony',
    evidenceCollected: evidenceCollected,
    timeSpent: elapsedTime,
  );
  
  // Award coins
  await progressProvider.addCoins(100);
}
```

### EvidenceProvider Integration

When evidence is collected:
```dart
void onEvidenceCollected(String evidenceId) {
  final evidenceProvider = context.read<EvidenceProvider>();
  evidenceProvider.unlockEvidence(evidenceId);
  
  // Show notification
  showEvidenceNotification(evidenceId);
}
```

### SettingsProvider Integration

Load settings on game start:
```dart
void loadSettings() {
  final settings = context.read<SettingsProvider>();
  
  // Apply volume settings
  FlameAudio.bgm.volume = settings.musicVolume;
  FlameAudio.sfx.volume = settings.sfxVolume;
  
  // Apply control preferences
  useVirtualJoystick = settings.useVirtualJoystick;
}
```

## Error Handling

### Common Error Scenarios

1. **Game Initialization Failure:**
   - Catch exceptions in `onLoad()`
   - Show error dialog
   - Return to menu

2. **Save/Load Errors:**
   - Wrap provider calls in try-catch
   - Show toast notification on failure
   - Continue game without saving (graceful degradation)

3. **Performance Issues:**
   - Monitor FPS
   - If FPS drops below 30, reduce particle effects
   - Log performance metrics for debugging

### Error Recovery

```dart
try {
  await progressProvider.completeArc(...);
} catch (e) {
  print('Failed to save progress: $e');
  // Show notification but don't block user
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Progreso no guardado')),
  );
  // Still allow navigation
  Navigator.pop(context);
}
```



## Testing Strategy

### Unit Tests

**Components to Test:**
1. **SanitySystem:**
   - Test sanity drain when near enemy
   - Test sanity regen when hiding
   - Test clamping (0.0 to 1.0)
   - Test static intensity calculation

2. **EnemyAISystem:**
   - Test waypoint navigation
   - Test player detection
   - Test state transitions
   - Test chase behavior

3. **CollisionSystem:**
   - Test collision detection accuracy
   - Test collision response
   - Test layer filtering

### Integration Tests

1. **Player Movement:**
   - Test movement in all directions
   - Test collision with obstacles
   - Test hiding mechanic

2. **Enemy Behavior:**
   - Test patrol loop
   - Test player detection and chase
   - Test game over on collision

3. **Evidence Collection:**
   - Test collection trigger
   - Test evidence unlock in provider
   - Test UI update

4. **Victory Condition:**
   - Test reaching exit door
   - Test completion save
   - Test coin reward

### Manual Testing Checklist

- [ ] Player can move smoothly in all directions
- [ ] Player stops at walls/obstacles
- [ ] Enemy patrols between waypoints
- [ ] Enemy chases player when detected
- [ ] Enemy returns to patrol after losing player
- [ ] Hiding spots work correctly
- [ ] Sanity drains near enemy
- [ ] Sanity regenerates when hiding
- [ ] Game over triggers at 0 sanity
- [ ] Game over triggers when caught by enemy
- [ ] Evidence can be collected
- [ ] Evidence counter updates
- [ ] Exit door triggers victory
- [ ] Victory screen shows correct stats
- [ ] Progress saves correctly
- [ ] Coins are awarded
- [ ] Evidence unlocks in archive
- [ ] Return to menu works
- [ ] Retry works correctly
- [ ] Performance is 60 FPS

## Design Decisions and Rationale

### Why Flame Engine?

**Pros:**
- Built for Flutter, seamless integration
- Component-based architecture (ECS-like)
- Built-in game loop and rendering
- Good performance for 2D games
- Active community and documentation

**Cons:**
- Learning curve for team
- Less mature than Unity/Godot
- Limited tooling

**Decision:** Use Flame because we're already using Flutter, and the game is simple enough that Flame's features are sufficient.

### Why Procedural Scene Generation?

**Rationale:**
- No need for image assets (saves storage)
- Faster iteration (change code, not assets)
- Easier to maintain and modify
- Can be parameterized for future arcs
- Reduces app size significantly

**Trade-off:** Less visual polish, but acceptable for MVP.

### Why Simple Rectangle-Based Graphics?

**Rationale:**
- Fastest to implement
- No asset creation time
- Good performance
- Can be upgraded later with sprites
- Fits the "digital glitch" aesthetic

**Future Enhancement:** Add sprite sheets after MVP is proven.

### Why Local Storage Only?

**Rationale:**
- No backend costs
- Faster development
- No network dependency
- Simpler architecture
- User data stays private

**Trade-off:** No cross-device sync, but acceptable for single-player game.

### Why 3 Evidence Items Instead of 7?

**Rationale:**
- Faster to implement
- Easier to balance level design
- Reduces playtime (better for MVP testing)
- Can be increased later

**From Plan:** Aligns with 2-week survival plan.

## Future Enhancements

### Post-MVP Improvements

1. **Visual Polish:**
   - Add sprite animations
   - Particle effects
   - Screen shake on impacts
   - Better lighting effects

2. **Audio:**
   - Background music
   - Footstep sounds
   - Enemy sounds
   - Ambient noise

3. **Gameplay:**
   - More enemy types
   - Power-ups
   - Multiple paths through level
   - Difficulty settings

4. **Narrative:**
   - Cutscenes before/after arc
   - Voice acting
   - More evidence items

5. **Technical:**
   - Save replay system
   - Leaderboards
   - Achievements

### Reusability for Other Arcs

This design is intentionally modular to support the other 6 arcs:

- **BaseArcGame** can be extended for each arc
- **EnemyAISystem** can be configured with different behaviors
- **SceneComponent** can generate different layouts
- **UI components** are reusable

**Arc-specific changes needed:**
- Enemy behavior parameters
- Scene layout and colors
- Evidence content
- Victory conditions (if different)

## Conclusion

This design provides a solid foundation for the Arco 1: Gula gameplay while maintaining flexibility for future arcs. The focus is on core functionality, performance, and reusability rather than visual polish, aligning with the 2-week MVP timeline.

**Key Strengths:**
- Modular, reusable architecture
- Simple, performant rendering
- Clear separation of concerns
- Integration with existing systems
- Testable components

**Next Steps:**
- Review and approve design
- Create implementation task list
- Begin development with Day 1-2 tasks (movement and controls)
