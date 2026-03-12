# Design Document

## Overview

El Sistema de Tutorial de Controles es una solución integral para enseñar a los jugadores las mecánicas del juego de manera progresiva y no intrusiva. El sistema consta de dos componentes principales:

1. **First-Time Tutorial**: Tutorial general que se muestra solo la primera vez que el jugador inicia el juego, enseñando controles básicos universales
2. **Arc-Specific Tutorials**: Tutoriales específicos para cada arco que explican las mecánicas únicas de ese nivel

El sistema utiliza persistencia local para rastrear qué tutoriales ha completado el jugador, asegurando que no se muestren repetidamente. También se integra con el menú de pausa para permitir revisión manual de tutoriales.

## Architecture

### Component Hierarchy

```
ArcGameScreen (StatefulWidget)
├── Tutorial State Management
│   ├── _showTutorial (bool)
│   ├── _tutorialCheckComplete (bool)
│   └── Tutorial Persistence (SharedPreferences)
├── FirstTimeTutorialOverlay (Conditional)
│   ├── Tutorial Steps (5 steps)
│   ├── Progress Indicator
│   └── Skip Button
├── ArcSpecificTutorialOverlay (Conditional)
│   ├── Arc-Specific Steps
│   ├── Confirmation Dialog
│   └── Skip Button
└── PauseMenu
    └── "Ver Tutorial" Option
```

### Data Flow

```
Game Launch
    ↓
Check SharedPreferences
    ↓
First Time? → YES → Show FirstTimeTutorialOverlay
    ↓              ↓
    NO         Complete → Save to SharedPreferences
    ↓              ↓
Check Arc Tutorial State
    ↓
First Time in Arc? → YES → Show ArcSpecificTutorialOverlay
    ↓                   ↓
    NO              Complete → Save to SharedPreferences
    ↓                   ↓
Start Gameplay ←────────┘
```

## Components and Interfaces

### 1. TutorialStateManager

**Purpose**: Gestiona el estado de persistencia de los tutoriales

**Interface**:
```dart
class TutorialStateManager {
  static const String _keyFirstTimeTutorial = 'has_seen_tutorial';
  static const String _keyArcTutorialPrefix = 'has_seen_arc_tutorial_';
  
  /// Check if first-time tutorial has been completed
  Future<bool> hasCompletedFirstTimeTutorial();
  
  /// Mark first-time tutorial as completed
  Future<void> completeFirstTimeTutorial();
  
  /// Check if arc-specific tutorial has been completed
  Future<bool> hasCompletedArcTutorial(String arcId);
  
  /// Mark arc-specific tutorial as completed
  Future<void> completeArcTutorial(String arcId);
  
  /// Reset all tutorial states (for testing/debugging)
  Future<void> resetAllTutorials();
  
  /// Get completion timestamp for a tutorial
  Future<DateTime?> getTutorialCompletionTime(String tutorialId);
}
```

**Implementation Details**:
- Uses `SharedPreferences` for persistence
- Stores completion state as boolean flags
- Stores completion timestamps for analytics
- Handles storage failures gracefully with fallback to showing tutorials

### 2. FirstTimeTutorialOverlay (Enhanced)

**Purpose**: Overlay que muestra el tutorial de primera vez con 5 pasos

**Current State**: Ya existe en `lib/game/ui/first_time_tutorial_overlay.dart`

**Required Enhancements**:
- Integration with TutorialStateManager
- Proper game pause/resume integration
- Smooth fade in/out animations
- Accessibility improvements (larger touch targets, better contrast)

**Tutorial Steps**:
1. **MOVIMIENTO**: Joystick (abajo izquierda) para moverte
2. **ESCONDERSE**: Botón morado para esconderte
3. **FRAGMENTOS**: Recolecta 5 fragmentos brillantes
4. **CORDURA**: Barra de cordura (arriba izquierda), si llega a 0% pierdes
5. **¡LISTO!**: Escapa del enemigo y encuentra la salida

### 3. ArcSpecificTutorialOverlay (Enhanced)

**Purpose**: Overlay que muestra tutoriales específicos por arco

**Current State**: Existe como `TutorialOverlay` en `lib/game/ui/tutorial_overlay.dart`

**Required Enhancements**:
- Integration with TutorialStateManager
- Confirmation dialog before showing tutorial
- Arc-specific content for all three arcs
- Manual trigger capability from pause menu

**Arc-Specific Content**:

**Gluttony Arc (arc_1_gula)**:
- Objetivo: Recolecta 5 fragmentos en el restaurante
- Mecánica: Mateo devora evidencias cuando te atrapa
- Estrategia: Usa escondites estratégicamente
- Control especial: Botón morado para esconderte

**Greed Arc (arc_2_greed)**:
- Objetivo: Recolecta 5 fragmentos en el banco
- Mecánica: La Rata roba evidencias y 10% de cordura (cooldown 5s)
- Estrategia: Usa cajas registradoras (brillo dorado) para recuperar 50% cordura
- Control especial: Botón morado para esconderte

**Envy Arc (arc_3_envy)**:
- Objetivo: Recolecta 5 fragmentos en el gimnasio
- Mecánica: El enemigo imita tus movimientos, se vuelve más rápido con cada evidencia
- Estrategia: **NO HAY ESCONDITES** - Solo movimiento puro
- Control especial: Solo joystick, usa obstáculos para romper línea de visión

### 4. PauseMenu Integration

**Purpose**: Permitir acceso manual a tutoriales desde el menú de pausa

**Required Changes**:
```dart
class PauseMenu extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onExit;
  final VoidCallback onShowTutorial; // NEW
  
  // Add "Ver Tutorial" button in menu
  // When pressed, show arc-specific tutorial for current arc
  // Don't mark as "first time" completion
}
```

### 5. ArcGameScreen Integration

**Purpose**: Coordinar la presentación de tutoriales en el flujo del juego

**Required Changes**:
```dart
class _ArcGameScreenState extends State<ArcGameScreen> {
  bool _showFirstTimeTutorial = false;
  bool _showArcTutorial = false;
  bool _tutorialCheckComplete = false;
  TutorialStateManager _tutorialManager = TutorialStateManager();
  
  @override
  void initState() {
    super.initState();
    _checkTutorials();
  }
  
  Future<void> _checkTutorials() async {
    // Check first-time tutorial
    final hasSeenFirstTime = await _tutorialManager.hasCompletedFirstTimeTutorial();
    
    if (!hasSeenFirstTime) {
      setState(() {
        _showFirstTimeTutorial = true;
        _tutorialCheckComplete = true;
      });
      game.pauseGame();
      return;
    }
    
    // Check arc-specific tutorial
    final hasSeenArc = await _tutorialManager.hasCompletedArcTutorial(widget.arcId);
    
    if (!hasSeenArc) {
      setState(() {
        _showArcTutorial = true;
        _tutorialCheckComplete = true;
      });
      game.pauseGame();
      return;
    }
    
    setState(() {
      _tutorialCheckComplete = true;
    });
  }
  
  Future<void> _completeFirstTimeTutorial() async {
    await _tutorialManager.completeFirstTimeTutorial();
    setState(() {
      _showFirstTimeTutorial = false;
    });
    
    // Check if should show arc tutorial next
    final hasSeenArc = await _tutorialManager.hasCompletedArcTutorial(widget.arcId);
    if (!hasSeenArc) {
      setState(() {
        _showArcTutorial = true;
      });
    } else {
      game.resumeGame();
    }
  }
  
  Future<void> _completeArcTutorial() async {
    await _tutorialManager.completeArcTutorial(widget.arcId);
    setState(() {
      _showArcTutorial = false;
    });
    game.resumeGame();
  }
  
  void _showManualTutorial() {
    game.pauseGame();
    setState(() {
      _showArcTutorial = true;
    });
  }
}
```

## Data Models

### TutorialState

```dart
class TutorialState {
  final bool firstTimeTutorialCompleted;
  final Map<String, bool> arcTutorialsCompleted;
  final Map<String, DateTime> completionTimestamps;
  
  TutorialState({
    required this.firstTimeTutorialCompleted,
    required this.arcTutorialsCompleted,
    required this.completionTimestamps,
  });
  
  factory TutorialState.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### TutorialStep

```dart
class TutorialStep {
  final String title;
  final String message;
  final IconData icon;
  final Alignment alignment;
  final ArrowDirection arrowDirection;
  
  TutorialStep({
    required this.title,
    required this.message,
    required this.icon,
    required this.alignment,
    required this.arrowDirection,
  });
}
```

### ArcTutorialContent

```dart
class ArcTutorialContent {
  final String arcId;
  final String arcName;
  final String objective;
  final String mechanic;
  final String strategy;
  final String specialControl;
  final List<TutorialStep> steps;
  
  ArcTutorialContent({
    required this.arcId,
    required this.arcName,
    required this.objective,
    required this.mechanic,
    required this.strategy,
    required this.specialControl,
    required this.steps,
  });
  
  static ArcTutorialContent forArc(String arcId);
}
```

## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*


### Property 1: First-time tutorial displays on fresh install
*For any* fresh game installation (no tutorial completion state), launching the game should display the first-time tutorial overlay before gameplay begins
**Validates: Requirements 1.1**

### Property 2: Tutorial structure is always complete
*For any* first-time tutorial instance, it should contain exactly 5 steps with titles: MOVIMIENTO, ESCONDERSE, FRAGMENTOS, CORDURA, and ¡LISTO!
**Validates: Requirements 1.2**

### Property 3: Tutorial completion persists across sessions
*For any* completed tutorial, restarting the game should not show that tutorial again automatically
**Validates: Requirements 1.3, 3.4**

### Property 4: Skip has same effect as completion
*For any* tutorial, skipping it should have the same persistence effect as completing all steps
**Validates: Requirements 1.4, 3.3**

### Property 5: Tap advances tutorial steps
*For any* tutorial step (except the last), tapping the screen should advance to the next step
**Validates: Requirements 1.5**

### Property 6: Arc tutorials display on first arc entry
*For any* arc that hasn't been played before, entering that arc should display the arc-specific tutorial before gameplay
**Validates: Requirements 2.1**

### Property 7: Arc tutorial completion persists per arc
*For any* arc, completing its tutorial should persist that state independently of other arcs
**Validates: Requirements 2.5**

### Property 8: All tutorials have skip button
*For any* tutorial overlay, it should display a visible "SALTAR" button in the top-right corner
**Validates: Requirements 3.1**

### Property 9: Skip immediately closes tutorial
*For any* tutorial at any step, pressing skip should immediately close the tutorial without showing remaining steps
**Validates: Requirements 3.2**

### Property 10: Tutorial overlay has correct opacity
*For any* tutorial overlay, the background should have opacity of at least 0.85
**Validates: Requirements 4.1**

### Property 11: Tutorial text meets accessibility standards
*For any* tutorial text, it should use high-contrast colors and font size of at least 22px
**Validates: Requirements 4.2**

### Property 12: Progress indicator is accurate
*For any* tutorial step, the progress indicator should display the correct current step number and total steps
**Validates: Requirements 4.3**

### Property 13: Tutorial content doesn't overlap highlighted elements
*For any* tutorial step that highlights a UI element, the tutorial content should be positioned to avoid covering that element
**Validates: Requirements 4.4**

### Property 14: Animation durations are within bounds
*For any* tutorial animation, the duration should be between 300ms and 800ms
**Validates: Requirements 4.5, 6.4, 6.5**

### Property 15: Tutorial completion saves immediately
*For any* tutorial completion, the state should be saved to local storage immediately (within 100ms)
**Validates: Requirements 5.1**

### Property 16: Saved state has correct structure
*For any* saved tutorial state, it should contain a tutorial ID and completion timestamp
**Validates: Requirements 5.2**

### Property 17: Persisted state loads correctly
*For any* saved tutorial state, restarting the game should correctly load and initialize completion flags
**Validates: Requirements 5.3**

### Property 18: Storage failure defaults to showing tutorials
*For any* storage read failure, the system should default to showing all tutorials and log a warning
**Validates: Requirements 5.4**

### Property 19: Write failures don't crash the game
*For any* storage write failure, the system should handle it gracefully without crashing
**Validates: Requirements 5.5**

### Property 20: Active tutorial pauses game logic
*For any* active tutorial, all game logic including enemy AI and timers should be paused
**Validates: Requirements 6.1**

### Property 21: Tutorial completion resumes game smoothly
*For any* tutorial completion, game logic should resume without jarring transitions
**Validates: Requirements 6.2**

### Property 22: Tutorial blocks game input
*For any* active tutorial, all game input should be disabled except tutorial navigation controls
**Validates: Requirements 6.3**

### Property 23: Arc tutorials display correct objectives
*For any* arc tutorial, it should display the arc-specific objective clearly
**Validates: Requirements 7.4**

### Property 24: Tutorial terminology matches UI
*For any* tutorial text, the terminology should match the in-game UI labels
**Validates: Requirements 7.5**

### Property 25: Manual tutorial shows correct arc content
*For any* arc, triggering manual tutorial from pause menu should show that arc's specific tutorial
**Validates: Requirements 8.2**

### Property 26: Manual tutorial doesn't affect completion state
*For any* manual tutorial trigger, it should not mark the tutorial as "first time" completion
**Validates: Requirements 8.3, 8.5**

### Property 27: Manual tutorial returns to pause menu
*For any* manual tutorial completion, the player should return to the pause menu
**Validates: Requirements 8.4**

## Error Handling

### Storage Errors

**Scenario**: SharedPreferences is unavailable or fails to read/write

**Handling**:
1. Log warning with error details
2. Default to showing all tutorials (safe fallback)
3. Continue game execution without crashing
4. Retry storage operations on next tutorial interaction

**Example**:
```dart
try {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(key) ?? false;
} catch (e) {
  debugPrint('⚠️ [TUTORIAL] Storage read failed: $e');
  return false; // Default to showing tutorial
}
```

### Invalid Tutorial State

**Scenario**: Corrupted or invalid data in SharedPreferences

**Handling**:
1. Detect invalid state during load
2. Clear corrupted data
3. Reset to default state (show all tutorials)
4. Log error for debugging

### Game State Conflicts

**Scenario**: Tutorial tries to show while game is in invalid state

**Handling**:
1. Check game state before showing tutorial
2. If game is already paused/in menu, queue tutorial for later
3. If game is in critical state (loading, transitioning), skip tutorial
4. Log state conflicts for debugging

### Animation Failures

**Scenario**: Animation controller fails or is disposed prematurely

**Handling**:
1. Wrap animations in try-catch blocks
2. If animation fails, show tutorial without animation
3. Log animation errors
4. Continue tutorial flow

## Testing Strategy

### Unit Tests

**TutorialStateManager Tests**:
- Test persistence of first-time tutorial completion
- Test persistence of arc-specific tutorial completion
- Test storage failure handling
- Test state reset functionality
- Test timestamp recording

**FirstTimeTutorialOverlay Tests**:
- Test step progression
- Test skip functionality
- Test completion callback
- Test UI rendering for each step

**ArcSpecificTutorialOverlay Tests**:
- Test confirmation dialog
- Test arc-specific content loading
- Test skip functionality
- Test manual trigger mode

**Integration Tests**:
- Test full tutorial flow from game launch
- Test tutorial persistence across app restarts
- Test pause menu integration
- Test game pause/resume during tutorials

### Property-Based Tests

The system will use the `flutter_test` framework with custom property test utilities for Dart/Flutter.

**Property Test Configuration**:
- Minimum 100 iterations per property test
- Use random seed for reproducibility
- Generate diverse test data (different arcs, states, timings)

**Test Data Generators**:
```dart
// Generate random tutorial states
Generator<TutorialState> tutorialStateGen();

// Generate random arc IDs
Generator<String> arcIdGen();

// Generate random completion timestamps
Generator<DateTime> timestampGen();

// Generate random tutorial steps
Generator<TutorialStep> tutorialStepGen();
```

**Property Test Examples**:

**Property 3: Tutorial completion persists**
```dart
testProperty('completed tutorials persist across sessions', () {
  forAll(tutorialStateGen(), (state) async {
    // Complete tutorial
    await manager.completeFirstTimeTutorial();
    
    // Simulate app restart
    final newManager = TutorialStateManager();
    
    // Verify completion persists
    final hasCompleted = await newManager.hasCompletedFirstTimeTutorial();
    expect(hasCompleted, isTrue);
  });
});
```

**Property 7: Arc tutorial completion persists per arc**
```dart
testProperty('arc tutorials persist independently', () {
  forAll(arcIdGen(), arcIdGen(), (arc1, arc2) async {
    // Complete tutorial for arc1
    await manager.completeArcTutorial(arc1);
    
    // Verify arc1 is completed but arc2 is not
    final arc1Completed = await manager.hasCompletedArcTutorial(arc1);
    final arc2Completed = await manager.hasCompletedArcTutorial(arc2);
    
    expect(arc1Completed, isTrue);
    if (arc1 != arc2) {
      expect(arc2Completed, isFalse);
    }
  });
});
```

**Property 16: Saved state has correct structure**
```dart
testProperty('saved state contains required fields', () {
  forAll(tutorialStateGen(), (state) async {
    // Save state
    await manager.completeFirstTimeTutorial();
    
    // Read raw storage
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('tutorial_completion_timestamp');
    
    // Verify structure
    expect(timestamp, isNotNull);
    expect(timestamp, greaterThan(0));
  });
});
```

### Manual Testing Checklist

- [ ] First-time tutorial shows on fresh install
- [ ] First-time tutorial doesn't show on second launch
- [ ] Arc tutorials show on first arc entry
- [ ] Arc tutorials don't show on second arc entry
- [ ] Skip button works on all tutorial screens
- [ ] Tap to advance works on all steps
- [ ] Progress indicator updates correctly
- [ ] Tutorial pauses game properly
- [ ] Game resumes smoothly after tutorial
- [ ] Manual tutorial trigger from pause menu works
- [ ] Manual tutorial doesn't affect completion state
- [ ] All three arc tutorials have correct content
- [ ] Animations are smooth (300-800ms)
- [ ] Text is readable (high contrast, 22px+)
- [ ] Tutorial works on different screen sizes
- [ ] Tutorial works with different device orientations

## Performance Considerations

### Memory

- Tutorial overlays should be lightweight (< 5MB memory)
- Dispose animation controllers properly
- Clear tutorial state from memory when not in use
- Use const constructors where possible

### Storage

- Minimize SharedPreferences writes (only on completion)
- Batch multiple tutorial completions if possible
- Use efficient key naming (short, descriptive)
- Avoid storing redundant data

### Rendering

- Use RepaintBoundary for tutorial overlays
- Minimize widget rebuilds during animations
- Cache tutorial content (don't regenerate on each show)
- Use efficient layout algorithms (avoid nested Columns/Rows)

### Startup Time

- Load tutorial state asynchronously
- Don't block game initialization
- Show loading indicator if tutorial check takes > 100ms
- Cache tutorial completion state in memory after first load

## Accessibility

### Visual

- High contrast text (cyan on dark background)
- Large font sizes (minimum 22px)
- Clear progress indicators
- Smooth animations (not too fast)

### Motor

- Large touch targets (minimum 48x48 dp)
- Tap anywhere to advance (not just buttons)
- Skip button always accessible
- No time-based interactions

### Cognitive

- Simple, clear language
- One concept per step
- Visual icons to reinforce text
- Consistent terminology
- Progress indicator shows how many steps remain

## Future Enhancements

### Phase 2 (Post-MVP)

- **Interactive Tutorials**: Let players practice controls during tutorial
- **Tutorial Replay**: Add "Replay Tutorial" option in settings
- **Tutorial Analytics**: Track which steps players skip most
- **Localization**: Support multiple languages
- **Adaptive Tutorials**: Show different content based on player skill
- **Tutorial Hints**: Show contextual hints during gameplay
- **Video Tutorials**: Add optional video demonstrations
- **Tutorial Achievements**: Reward players for completing tutorials

### Phase 3 (Advanced)

- **AI-Powered Tutorials**: Adapt tutorial based on player behavior
- **Voice-Over**: Add audio narration for tutorials
- **Haptic Feedback**: Use vibration to reinforce tutorial steps
- **Tutorial Editor**: Allow designers to create tutorials without code
- **A/B Testing**: Test different tutorial approaches
- **Tutorial Metrics**: Detailed analytics on tutorial effectiveness
