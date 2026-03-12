# Design Document: Puzzle Fragments System

## Overview

El sistema de fragmentos de rompecabezas transforma la recolección de evidencias en una experiencia interactiva y desafiante. Los jugadores recolectan 5 fragmentos por arco durante el gameplay, y luego deben ensamblarlos manualmente en una interfaz de rompecabezas para revelar la evidencia completa.

### Key Features

- **Fragmentos con formas únicas**: Cada fragmento tiene una forma de pieza de rompecabezas con pestañas y huecos que encajan específicamente
- **Ensamblaje interactivo**: Los jugadores arrastran, rotan y colocan fragmentos en una interfaz táctil
- **Dificultad progresiva**: Rotaciones aleatorias, atracción magnética falsa, y bloqueos temporales aumentan el desafío
- **Feedback rico**: Efectos de partículas, sonidos, animaciones y feedback háptico en cada interacción
- **Persistencia**: El progreso se guarda automáticamente y puede completarse desde el archivo

## Architecture

### Component Structure

```
lib/
├── data/
│   ├── models/
│   │   ├── puzzle_fragment.dart          # Modelo de fragmento individual
│   │   ├── puzzle_evidence.dart          # Modelo de evidencia completa
│   │   └── fragment_shape.dart           # Definición de forma de pieza
│   └── providers/
│       └── puzzle_data_provider.dart     # Proveedor de datos de fragmentos
├── game/
│   └── puzzle/
│       ├── puzzle_assembly_screen.dart   # Pantalla principal de ensamblaje
│       ├── components/
│       │   ├── draggable_fragment.dart   # Fragmento arrastrable
│       │   ├── fragment_slot.dart        # Slot de destino para fragmento
│       │   └── puzzle_board.dart         # Tablero de rompecabezas
│       ├── effects/
│       │   ├── particle_system.dart      # Sistema de partículas
│       │   ├── snap_effect.dart          # Efecto de snap magnético
│       │   └── completion_animation.dart # Animación de completado
│       └── logic/
│           ├── puzzle_validator.dart     # Validación de posiciones
│           ├── shape_generator.dart      # Generador de formas
│           └── difficulty_manager.dart   # Gestor de dificultad
└── screens/
    └── archive_screen.dart               # Actualizado para mostrar fragmentos
```

### Data Flow

1. **Recolección**: `EvidenceComponent` → `PuzzleDataProvider` → Guarda fragmento
2. **Visualización**: `ArchiveScreen` → Lee estado de fragmentos → Muestra progreso
3. **Ensamblaje**: `PuzzleAssemblyScreen` → Carga fragmentos → Valida posiciones → Guarda completado
4. **Persistencia**: `PuzzleDataProvider` → Firebase/Local Storage → Estado sincronizado

## Components and Interfaces

### 1. Data Models

#### PuzzleFragment

```dart
class PuzzleFragment {
  final String id;
  final String evidenceId;
  final int fragmentNumber; // 1-5
  final FragmentShape shape;
  final Rect imageRegion; // Región de la imagen completa
  final Vector2 correctPosition; // Posición correcta en el tablero
  final double correctRotation; // Rotación correcta (0, 90, 180, 270)
  final bool isCollected;
  final DateTime? collectedAt;
  
  // Metadata
  final String arcId;
  final String narrativeSnippet; // Texto narrativo de este fragmento
}
```

#### FragmentShape

```dart
class FragmentShape {
  final String svgPath; // Path SVG de la forma
  final List<ConnectionPoint> connectionPoints;
  final Size size;
  
  // Connection points define tabs and blanks
  // Top, Right, Bottom, Left
}

class ConnectionPoint {
  final EdgeSide side; // top, right, bottom, left
  final ConnectionType type; // tab (protrusion) or blank (indentation)
  final double position; // 0.0 to 1.0 along the edge
  final String matchId; // ID del connection point complementario
}

enum ConnectionType { tab, blank, flat }
enum EdgeSide { top, right, bottom, left }
```

#### PuzzleEvidence

```dart
class PuzzleEvidence {
  final String id;
  final String arcId;
  final String title;
  final String narrativeDescription;
  final String completeImagePath;
  final List<PuzzleFragment> fragments; // 5 fragments
  final bool isCompleted;
  final DateTime? completedAt;
  final int attemptCount;
}
```

### 2. Puzzle Assembly Screen

#### PuzzleAssemblyScreen

```dart
class PuzzleAssemblyScreen extends StatefulWidget {
  final PuzzleEvidence evidence;
  
  // Main screen that hosts the puzzle board
  // Manages game state and completion
}

class _PuzzleAssemblyScreenState extends State<PuzzleAssemblyScreen> {
  late PuzzleBoard _board;
  late DifficultyManager _difficultyManager;
  late ParticleSystem _particleSystem;
  
  int _correctPlacements = 0;
  int _incorrectAttempts = 0;
  Map<String, int> _fragmentErrors = {}; // Track errors per fragment
  Map<String, DateTime> _fragmentLocks = {}; // Track locked fragments
  
  void _onFragmentDragged(PuzzleFragment fragment, Offset position);
  void _onFragmentDropped(PuzzleFragment fragment, Offset position);
  void _onFragmentTapped(PuzzleFragment fragment); // Rotate
  void _validatePlacement(PuzzleFragment fragment, Offset position, double rotation);
  void _snapFragment(PuzzleFragment fragment);
  void _rejectFragment(PuzzleFragment fragment);
  void _checkCompletion();
  void _showCompletionAnimation();
}
```

### 3. Draggable Fragment Component

#### DraggableFragment

```dart
class DraggableFragment extends StatefulWidget {
  final PuzzleFragment fragment;
  final VoidCallback onPickup;
  final Function(Offset) onDrag;
  final Function(Offset) onDrop;
  final VoidCallback onTap;
  final bool isLocked;
  
  @override
  _DraggableFragmentState createState() => _DraggableFragmentState();
}

class _DraggableFragmentState extends State<DraggableFragment> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  double _currentRotation = 0.0;
  double _scale = 1.0;
  bool _isDragging = false;
  
  // Render fragment with custom shape clipping
  Widget _buildFragmentShape() {
    return ClipPath(
      clipper: FragmentShapeClipper(widget.fragment.shape),
      child: Image.asset(
        widget.fragment.imageRegion,
        fit: BoxFit.cover,
      ),
    );
  }
  
  // Handle rotation animation
  void _rotateFragment() {
    setState(() {
      _currentRotation = (_currentRotation + 90) % 360;
    });
  }
  
  // Handle pickup effects
  void _onPickup() {
    setState(() {
      _scale = 1.2;
      _isDragging = true;
    });
    _playPickupSound();
    _showPickupParticles();
    widget.onPickup();
  }
  
  // Handle drop effects
  void _onDrop(Offset position) {
    setState(() {
      _scale = 1.0;
      _isDragging = false;
    });
    widget.onDrop(position);
  }
}
```

### 4. Shape Generator

#### ShapeGenerator

```dart
class ShapeGenerator {
  // Generate 5 interlocking puzzle piece shapes
  static List<FragmentShape> generatePuzzleShapes({
    required Size totalSize,
    required int rows,
    required int cols,
  }) {
    // For 5 pieces, we use a 2x3 grid (with one empty slot)
    // Layout:
    // [0] [1] [2]
    // [3] [4] [ ]
    
    List<FragmentShape> shapes = [];
    
    // Generate connection points for each piece
    // Ensure tabs and blanks match between adjacent pieces
    
    for (int i = 0; i < 5; i++) {
      shapes.add(_generateFragmentShape(i, totalSize, rows, cols));
    }
    
    return shapes;
  }
  
  static FragmentShape _generateFragmentShape(
    int index,
    Size totalSize,
    int rows,
    int cols,
  ) {
    // Calculate base rectangle for this piece
    int row = index ~/ cols;
    int col = index % cols;
    
    // Generate SVG path with tabs and blanks
    String svgPath = _generatePuzzlePiecePath(
      row: row,
      col: col,
      totalRows: rows,
      totalCols: cols,
      pieceSize: Size(totalSize.width / cols, totalSize.height / rows),
    );
    
    // Define connection points
    List<ConnectionPoint> connections = _generateConnectionPoints(
      index: index,
      row: row,
      col: col,
      totalRows: rows,
      totalCols: cols,
    );
    
    return FragmentShape(
      svgPath: svgPath,
      connectionPoints: connections,
      size: Size(totalSize.width / cols, totalSize.height / rows),
    );
  }
  
  static String _generatePuzzlePiecePath({
    required int row,
    required int col,
    required int totalRows,
    required int totalCols,
    required Size pieceSize,
  }) {
    // Generate SVG path with bezier curves for tabs and blanks
    // This creates the classic jigsaw puzzle piece shape
    
    StringBuffer path = StringBuffer();
    double w = pieceSize.width;
    double h = pieceSize.height;
    double tabSize = w * 0.2; // Tab protrusion size
    
    // Start at top-left
    path.write('M 0 0 ');
    
    // Top edge (with tab or blank if not top row)
    if (row > 0) {
      path.write(_generateEdgeWithTab(w, tabSize, isTab: _shouldHaveTab(row, col, EdgeSide.top)));
    } else {
      path.write('L $w 0 ');
    }
    
    // Right edge
    if (col < totalCols - 1) {
      path.write(_generateEdgeWithTab(h, tabSize, isTab: _shouldHaveTab(row, col, EdgeSide.right), isVertical: true));
    } else {
      path.write('L $w $h ');
    }
    
    // Bottom edge
    if (row < totalRows - 1) {
      path.write(_generateEdgeWithTab(w, tabSize, isTab: _shouldHaveTab(row, col, EdgeSide.bottom), reverse: true));
    } else {
      path.write('L 0 $h ');
    }
    
    // Left edge
    if (col > 0) {
      path.write(_generateEdgeWithTab(h, tabSize, isTab: _shouldHaveTab(row, col, EdgeSide.left), isVertical: true, reverse: true));
    } else {
      path.write('L 0 0 ');
    }
    
    path.write('Z');
    return path.toString();
  }
  
  static bool _shouldHaveTab(int row, int col, EdgeSide side) {
    // Deterministic but pseudo-random tab/blank assignment
    // Ensures adjacent pieces have complementary connections
    int seed = row * 10 + col * 100 + side.index;
    return (seed % 2) == 0;
  }
}
```

### 5. Puzzle Validator

#### PuzzleValidator

```dart
class PuzzleValidator {
  static const double positionTolerance = 20.0; // pixels
  static const double rotationTolerance = 5.0; // degrees
  
  // Validate if fragment is in correct position and rotation
  static bool isCorrectPlacement({
    required PuzzleFragment fragment,
    required Offset currentPosition,
    required double currentRotation,
    double? customTolerance,
  }) {
    double tolerance = customTolerance ?? positionTolerance;
    
    // Check position
    double distance = (currentPosition - fragment.correctPosition.toOffset()).distance;
    if (distance > tolerance) return false;
    
    // Check rotation (normalized to 0-360)
    double rotDiff = (currentRotation - fragment.correctRotation).abs() % 360;
    if (rotDiff > rotationTolerance && rotDiff < (360 - rotationTolerance)) {
      return false;
    }
    
    return true;
  }
  
  // Calculate snap position if within range
  static Offset? calculateSnapPosition({
    required PuzzleFragment fragment,
    required Offset currentPosition,
    required double currentRotation,
    double? customTolerance,
  }) {
    if (isCorrectPlacement(
      fragment: fragment,
      currentPosition: currentPosition,
      currentRotation: currentRotation,
      customTolerance: customTolerance,
    )) {
      return fragment.correctPosition.toOffset();
    }
    return null;
  }
  
  // Check if all fragments are correctly placed
  static bool isPuzzleComplete(List<PuzzleFragment> fragments, Map<String, Offset> positions, Map<String, double> rotations) {
    for (var fragment in fragments) {
      if (!isCorrectPlacement(
        fragment: fragment,
        currentPosition: positions[fragment.id]!,
        currentRotation: rotations[fragment.id]!,
      )) {
        return false;
      }
    }
    return true;
  }
}
```

### 6. Difficulty Manager

#### DifficultyManager

```dart
class DifficultyManager {
  int correctPlacements = 0;
  int totalAttempts = 0;
  
  // Calculate current snap tolerance (increases with correct placements)
  double getSnapTolerance() {
    double baseTolerance = 20.0;
    double bonus = correctPlacements >= 2 ? 10.0 : 0.0;
    return baseTolerance + bonus;
  }
  
  // Check if fragment should be locked due to repeated errors
  bool shouldLockFragment(String fragmentId, Map<String, int> errorCounts) {
    return (errorCounts[fragmentId] ?? 0) >= 3;
  }
  
  // Calculate lock duration
  Duration getLockDuration() {
    return Duration(seconds: 3);
  }
  
  // Check if hints should be offered
  bool shouldOfferHint() {
    return totalAttempts >= 10 && correctPlacements < 2;
  }
  
  // Calculate false magnetic attraction strength
  double getFalseMagneticStrength(Offset fragmentPos, List<Offset> otherFragmentPositions) {
    // Create subtle attraction to nearby fragments even if incorrect
    double minDistance = double.infinity;
    
    for (var otherPos in otherFragmentPositions) {
      double dist = (fragmentPos - otherPos).distance;
      if (dist < minDistance && dist > 10) {
        minDistance = dist;
      }
    }
    
    // Stronger attraction when closer
    if (minDistance < 50) {
      return 0.3; // 30% pull towards nearby fragment
    }
    return 0.0;
  }
}
```

### 7. Particle System

#### ParticleSystem

```dart
class ParticleSystem extends StatefulWidget {
  final List<Particle> particles;
  
  @override
  _ParticleSystemState createState() => _ParticleSystemState();
}

class Particle {
  Vector2 position;
  Vector2 velocity;
  Color color;
  double size;
  double lifetime;
  double age;
  
  void update(double dt) {
    position += velocity * dt;
    age += dt;
    // Apply gravity
    velocity.y += 500 * dt;
  }
  
  bool get isDead => age >= lifetime;
}

class ParticleEmitter {
  // Emit trailing particles during drag
  static List<Particle> emitTrailParticles(Offset position) {
    return List.generate(3, (i) => Particle(
      position: Vector2(position.dx, position.dy),
      velocity: Vector2(
        (Random().nextDouble() - 0.5) * 50,
        (Random().nextDouble() - 0.5) * 50,
      ),
      color: Colors.white.withOpacity(0.6),
      size: 4.0,
      lifetime: 0.5,
      age: 0.0,
    ));
  }
  
  // Emit explosion particles on snap
  static List<Particle> emitSnapParticles(Offset position) {
    return List.generate(20, (i) {
      double angle = (i / 20) * 2 * pi;
      return Particle(
        position: Vector2(position.dx, position.dy),
        velocity: Vector2(cos(angle), sin(angle)) * 200,
        color: Colors.green,
        size: 6.0,
        lifetime: 1.0,
        age: 0.0,
      );
    });
  }
  
  // Emit error particles on incorrect placement
  static List<Particle> emitErrorParticles(Offset position) {
    return List.generate(15, (i) {
      double angle = (i / 15) * 2 * pi;
      return Particle(
        position: Vector2(position.dx, position.dy),
        velocity: Vector2(cos(angle), sin(angle)) * 150,
        color: Colors.red,
        size: 5.0,
        lifetime: 0.8,
        age: 0.0,
      );
    });
  }
  
  // Emit confetti on completion
  static List<Particle> emitConfettiParticles(Size screenSize) {
    return List.generate(100, (i) => Particle(
      position: Vector2(
        Random().nextDouble() * screenSize.width,
        -20,
      ),
      velocity: Vector2(
        (Random().nextDouble() - 0.5) * 100,
        Random().nextDouble() * 300 + 200,
      ),
      color: [Colors.red, Colors.blue, Colors.yellow, Colors.green][i % 4],
      size: 8.0,
      lifetime: 3.0,
      age: 0.0,
    ));
  }
}
```

### 8. Data Provider

#### PuzzleDataProvider

```dart
class PuzzleDataProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;
  
  Map<String, PuzzleEvidence> _evidences = {};
  Map<String, List<PuzzleFragment>> _collectedFragments = {};
  
  PuzzleDataProvider(this.userId) {
    _loadPuzzleData();
  }
  
  // Load all puzzle definitions and player progress
  Future<void> _loadPuzzleData() async {
    // Load puzzle definitions from assets or Firestore
    _evidences = await _loadEvidenceDefinitions();
    
    // Load player's collected fragments
    _collectedFragments = await _loadPlayerProgress();
    
    notifyListeners();
  }
  
  // Mark fragment as collected
  Future<void> collectFragment(String evidenceId, int fragmentNumber) async {
    final evidence = _evidences[evidenceId];
    if (evidence == null) return;
    
    final fragment = evidence.fragments[fragmentNumber - 1];
    fragment.isCollected = true;
    fragment.collectedAt = DateTime.now();
    
    // Save to Firestore
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('fragments')
        .doc(fragment.id)
        .set({
      'collected': true,
      'collectedAt': FieldValue.serverTimestamp(),
    });
    
    notifyListeners();
  }
  
  // Mark evidence as completed
  Future<void> completeEvidence(String evidenceId) async {
    final evidence = _evidences[evidenceId];
    if (evidence == null) return;
    
    evidence.isCompleted = true;
    evidence.completedAt = DateTime.now();
    
    // Save to Firestore
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('evidences')
        .doc(evidenceId)
        .set({
      'completed': true,
      'completedAt': FieldValue.serverTimestamp(),
      'attemptCount': evidence.attemptCount,
    });
    
    notifyListeners();
  }
  
  // Get evidence by ID
  PuzzleEvidence? getEvidence(String evidenceId) {
    return _evidences[evidenceId];
  }
  
  // Get all evidences for an arc
  List<PuzzleEvidence> getEvidencesForArc(String arcId) {
    return _evidences.values
        .where((e) => e.arcId == arcId)
        .toList();
  }
  
  // Check if evidence can be assembled (all fragments collected)
  bool canAssembleEvidence(String evidenceId) {
    final evidence = _evidences[evidenceId];
    if (evidence == null) return false;
    
    return evidence.fragments.every((f) => f.isCollected);
  }
}
```

## Data Models

### Fragment Shape Data Structure

Each evidence has 5 fragments arranged in a 2x3 grid:

```
Position Layout:
┌─────┬─────┬─────┐
│  0  │  1  │  2  │
├─────┼─────┼─────┤
│  3  │  4  │     │
└─────┴─────┴─────┘

Connection Points:
- Fragment 0: Right=tab, Bottom=blank
- Fragment 1: Left=blank, Right=tab, Bottom=tab
- Fragment 2: Left=blank, Bottom=blank
- Fragment 3: Top=tab, Right=blank
- Fragment 4: Top=blank, Left=tab
```

### Evidence Definitions

```dart
// Example: Arc 1 - Gula - Mateo
final arc1Evidence = PuzzleEvidence(
  id: 'arc1_evidence',
  arcId: 'gluttony',
  title: 'Video Viral de Mateo',
  narrativeDescription: 'El video que destruyó la vida de Mateo...',
  completeImagePath: 'assets/evidences/arc1_complete.png',
  fragments: [
    PuzzleFragment(
      id: 'arc1_frag_0',
      evidenceId: 'arc1_evidence',
      fragmentNumber: 1,
      shape: /* generated shape */,
      imageRegion: Rect.fromLTWH(0, 0, 200, 150),
      correctPosition: Vector2(100, 100),
      correctRotation: 0,
      narrativeSnippet: 'Inicio del video: Mateo se acerca al contenedor...',
    ),
    // ... 4 more fragments
  ],
);
```



## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system-essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Fragment persistence round-trip
*For any* collected fragment, storing it and then retrieving it should return the same fragment data including shape, position, and metadata.
**Validates: Requirements 1.1**

### Property 2: Collection notification triggers
*For any* fragment collection event, the notification system should be called with the correct fragment preview and progress count.
**Validates: Requirements 1.2**

### Property 3: Assembly unlock on completion
*For any* evidence, when the collected fragment count reaches 5, the assembly interface should become accessible.
**Validates: Requirements 1.3**

### Property 4: Fragment shape rendering
*For any* collected fragment, the display should include its unique puzzle piece shape data.
**Validates: Requirements 1.4**

### Property 5: Arc association integrity
*For any* fragment, it should maintain its arc association throughout its lifecycle.
**Validates: Requirements 1.5**

### Property 6: Unique shape generation
*For any* evidence, the shape generator should produce exactly 5 unique fragment shapes.
**Validates: Requirements 2.1**

### Property 7: Connection point compatibility
*For any* pair of adjacent fragments, their connection points should be complementary (tab matches blank).
**Validates: Requirements 2.2, 2.3**

### Property 8: Complete puzzle validity
*For any* evidence, all 5 fragments should have a valid arrangement where all connection points match.
**Validates: Requirements 2.5**

### Property 9: Random initialization
*For any* assembly session, fragments should be initialized with random positions and random rotations.
**Validates: Requirements 3.1**

### Property 10: Drag responsiveness
*For any* drag operation, the fragment should follow the input position smoothly.
**Validates: Requirements 3.2**

### Property 11: Rotation increment
*For any* fragment tap, the rotation should increment by exactly 90 degrees.
**Validates: Requirements 3.3**

### Property 12: Snap on correct placement
*For any* fragment within tolerance of correct position and rotation, the fragment should snap into place.
**Validates: Requirements 3.4**

### Property 13: Rejection on incorrect placement
*For any* fragment placed incorrectly, the fragment should be rejected and returned to a random position.
**Validates: Requirements 3.5**

### Property 14: Completion detection
*For any* puzzle state where all 5 fragments are in correct positions and rotations, the completion animation should trigger.
**Validates: Requirements 3.6**

### Property 15: Seamless final rendering
*For any* completed puzzle, the display should show the complete image without visible puzzle lines.
**Validates: Requirements 4.1**

### Property 16: Evidence metadata display
*For any* completed evidence, the title and narrative description should be displayed.
**Validates: Requirements 4.2**

### Property 17: Completion state persistence
*For any* completed evidence, the completion state should be saved and retrievable.
**Validates: Requirements 4.3**

### Property 18: Completed state restoration
*For any* completed evidence, reopening it should display the assembled version by default.
**Validates: Requirements 4.4**

### Property 19: Narrative content display
*For any* evidence with narrative content, the full story text should be displayed.
**Validates: Requirements 4.5**

### Property 20: Image region slicing
*For any* fragment, it should display the correct region of the source evidence image.
**Validates: Requirements 5.4**

### Property 21: Arc collection isolation
*For any* arc, its fragment collection should be independent from other arcs' collections.
**Validates: Requirements 5.5**

### Property 22: Pickup effects trigger
*For any* fragment pickup, scale animation, shadow, and sound should all trigger.
**Validates: Requirements 6.1**

### Property 23: Drag particle trail
*For any* drag operation, trailing particles should be generated continuously.
**Validates: Requirements 6.2**

### Property 24: Proximity feedback activation
*For any* fragment within range of its correct position, glow effect and proximity sound should activate.
**Validates: Requirements 6.3**

### Property 25: Snap effects trigger
*For any* successful snap, click sound, explosion particles, and flash should all trigger.
**Validates: Requirements 6.4**

### Property 26: Error effects trigger
*For any* incorrect placement, error sound, shake animation, haptic feedback, and red particles should all trigger.
**Validates: Requirements 6.5**

### Property 27: Completion effects trigger
*For any* puzzle completion, triumphant sound, confetti particles, and dissolve animation should all trigger.
**Validates: Requirements 6.6**

### Property 28: Hover feedback
*For any* fragment hover, scale pulse and glow should be provided.
**Validates: Requirements 6.7**

### Property 29: Time pressure indicator presence
*For any* assembly interface opening, the time pressure indicator should be displayed.
**Validates: Requirements 7.1**

### Property 30: Fragment locking on repeated errors
*For any* fragment with 3 or more incorrect placements, the fragment should be locked for 3 seconds.
**Validates: Requirements 7.2**

### Property 31: False magnetic attraction
*For any* fragments in proximity but incorrect positions, false magnetic attraction should be applied.
**Validates: Requirements 7.3**

### Property 32: Progressive tolerance increase
*For any* puzzle state with 2 or more correct placements, the snap tolerance should be increased.
**Validates: Requirements 7.4**

### Property 33: Hint availability
*For any* puzzle with multiple attempts and low success, the hint system should be offered.
**Validates: Requirements 7.5**

### Property 34: Evidence data validation
*For any* evidence definition, it should accept and validate shape paths, positions, and image regions.
**Validates: Requirements 9.1**

### Property 35: Connection point validation
*For any* loaded evidence, all connection points should be validated for compatibility.
**Validates: Requirements 9.2**

### Property 36: Collection state persistence
*For any* fragment collection event, the state should be correctly persisted per arc per player.
**Validates: Requirements 9.3**

### Property 37: Data initialization
*For any* system initialization, all fragment definitions should be loaded successfully.
**Validates: Requirements 9.4**

### Property 38: Archive evidence display
*For any* archive view, all evidences should be displayed with their fragment collection status.
**Validates: Requirements 10.1**

### Property 39: Incomplete evidence status display
*For any* incomplete evidence, the display should show which fragments are collected and which are missing.
**Validates: Requirements 10.2**

### Property 40: Complete evidence navigation
*For any* evidence selection with all fragments collected, the assembly interface should open.
**Validates: Requirements 10.3**

### Property 41: Incomplete evidence messaging
*For any* evidence selection with missing fragments, an appropriate message should be displayed.
**Validates: Requirements 10.4**

### Property 42: Arc-based organization
*For any* archive with multiple evidences, they should be organized and grouped by arc.
**Validates: Requirements 10.5**

## Error Handling

### Fragment Collection Errors

- **Duplicate Collection**: If a fragment is already collected, ignore the collection event
- **Invalid Fragment ID**: Log error and show user-friendly message
- **Network Failure**: Queue collection event for retry, show offline indicator

### Assembly Errors

- **Missing Fragments**: Prevent assembly interface from opening, show clear message
- **Invalid Placement**: Provide visual and audio feedback, return fragment to random position
- **Lock State**: Prevent interaction with locked fragments, show cooldown timer

### Data Errors

- **Corrupted Shape Data**: Fall back to simple rectangular shapes, log error
- **Missing Image Assets**: Show placeholder image, log error
- **Save Failure**: Retry save operation, show error toast if persistent

## Testing Strategy

### Unit Testing

We will write unit tests for:

- **Shape Generator**: Test that 5 unique shapes are generated with valid connection points
- **Puzzle Validator**: Test position and rotation validation logic
- **Difficulty Manager**: Test tolerance calculations and lock logic
- **Data Models**: Test serialization/deserialization of fragments and evidences

### Property-Based Testing

We will use the `test` and `faker` packages for property-based testing in Dart/Flutter.

**Configuration**: Each property test will run a minimum of 100 iterations.

**Test Tagging**: Each property-based test will be tagged with a comment in this format:
```dart
// **Feature: puzzle-fragments-system, Property {number}: {property_text}**
```

**Property Test Examples**:

```dart
// **Feature: puzzle-fragments-system, Property 1: Fragment persistence round-trip**
test('fragment persistence round-trip', () {
  for (int i = 0; i < 100; i++) {
    final fragment = generateRandomFragment();
    final saved = saveFragment(fragment);
    final loaded = loadFragment(saved.id);
    expect(loaded, equals(fragment));
  }
});

// **Feature: puzzle-fragments-system, Property 7: Connection point compatibility**
test('connection point compatibility', () {
  for (int i = 0; i < 100; i++) {
    final shapes = ShapeGenerator.generatePuzzleShapes(
      totalSize: Size(600, 400),
      rows: 2,
      cols: 3,
    );
    
    // Check all adjacent pairs
    expect(shapes[0].right.type, isComplementaryTo(shapes[1].left.type));
    expect(shapes[1].right.type, isComplementaryTo(shapes[2].left.type));
    expect(shapes[0].bottom.type, isComplementaryTo(shapes[3].top.type));
    expect(shapes[1].bottom.type, isComplementaryTo(shapes[4].top.type));
  }
});

// **Feature: puzzle-fragments-system, Property 11: Rotation increment**
test('rotation increment', () {
  for (int i = 0; i < 100; i++) {
    final initialRotation = Random().nextDouble() * 360;
    final fragment = generateRandomFragment(rotation: initialRotation);
    
    tapFragment(fragment);
    expect(fragment.rotation, equals((initialRotation + 90) % 360));
    
    tapFragment(fragment);
    expect(fragment.rotation, equals((initialRotation + 180) % 360));
  }
});
```

### Integration Testing

- Test complete flow: collect fragments → open archive → assemble puzzle → view completed evidence
- Test persistence across app restarts
- Test multiple arcs with separate fragment collections

### Visual Testing

- Verify fragment shapes render correctly with custom clipping
- Verify particle effects display properly
- Verify animations are smooth and performant

## Performance Considerations

### Optimization Strategies

1. **Shape Caching**: Cache generated SVG paths to avoid regeneration
2. **Particle Pooling**: Reuse particle objects instead of creating new ones
3. **Image Optimization**: Use appropriately sized images for fragments
4. **Lazy Loading**: Load evidence data only when needed
5. **Animation Performance**: Use `RepaintBoundary` for fragments to isolate repaints

### Memory Management

- Dispose animation controllers properly
- Clear particle lists when not in use
- Unload unused evidence images

## Future Enhancements

### Phase 1: Advanced Difficulty
- Multiple difficulty levels (easy, medium, hard)
- More complex puzzle shapes (6, 9, 12 pieces)
- Time-based challenges with rewards

### Phase 2: Social Features
- Share completed puzzles with friends
- Leaderboards for fastest completion times
- Collaborative puzzle solving

### Phase 3: Customization
- Custom puzzle piece shapes
- Themed particle effects per arc
- Unlockable puzzle frames and backgrounds

## Implementation Notes

### Flutter Packages Required

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.0.0
  cloud_firestore: ^4.0.0
  flutter_svg: ^2.0.0  # For SVG shape rendering
  audioplayers: ^5.0.0  # For sound effects
  vibration: ^1.8.0  # For haptic feedback
  
dev_dependencies:
  test: ^1.24.0
  faker: ^2.1.0  # For property-based testing
```

### Asset Structure

```
assets/
├── evidences/
│   ├── arc1_complete.png
│   ├── arc2_complete.png
│   ├── arc3_complete.png
│   └── ...
├── sounds/
│   ├── pickup.mp3
│   ├── snap.mp3
│   ├── error.mp3
│   ├── completion.mp3
│   └── proximity.mp3
└── shapes/
    └── puzzle_templates.json
```

### Development Workflow

1. Implement data models and shape generator
2. Create basic assembly UI without effects
3. Add drag and drop functionality
4. Implement validation and snapping
5. Add particle effects and animations
6. Implement difficulty mechanics
7. Add sound and haptic feedback
8. Integrate with archive screen
9. Add persistence layer
10. Write tests and optimize performance
