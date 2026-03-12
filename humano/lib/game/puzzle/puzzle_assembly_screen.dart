import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/puzzle_evidence.dart';
import '../../data/models/puzzle_fragment.dart';
import '../../data/providers/puzzle_data_provider.dart';
import 'components/draggable_fragment.dart';
import 'logic/puzzle_validator.dart';
import 'logic/difficulty_manager.dart';
import 'effects/particle_system.dart';
import 'effects/sound_manager.dart';

class PuzzleAssemblyScreen extends StatefulWidget {
  final String evidenceId;

  const PuzzleAssemblyScreen({
    super.key,
    required this.evidenceId,
  });

  @override
  State<PuzzleAssemblyScreen> createState() => _PuzzleAssemblyScreenState();
}

class _PuzzleAssemblyScreenState extends State<PuzzleAssemblyScreen>
    with TickerProviderStateMixin {
  late PuzzleEvidence _evidence;
  late DifficultyManager _difficultyManager;
  late SoundManager _soundManager;

  // Fragment states
  final Map<String, Offset> _fragmentPositions = {};
  final Map<String, double> _fragmentRotations = {};
  final Map<String, int> _fragmentErrors = {};
  final Map<String, DateTime> _fragmentLocks = {};
  final Set<String> _correctlyPlacedFragments = {};

  // Particles
  final List<Particle> _particles = [];

  // UI state
  bool _isCompleted = false;
  bool _showHint = false;
  String? _hintFragmentId;
  DateTime? _startTime;

  @override
  void initState() {
    super.initState();
    _difficultyManager = DifficultyManager();
    _soundManager = SoundManager();
    _startTime = DateTime.now();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePuzzle();
    });
  }

  void _initializePuzzle() {
    final provider = context.read<PuzzleDataProvider>();
    final evidence = provider.getEvidence(widget.evidenceId);

    if (evidence == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _evidence = evidence;
      _randomizeFragments();
    });

    // Increment attempt count
    provider.incrementAttemptCount(widget.evidenceId);
  }

  void _randomizeFragments() {
    final random = Random();
    final screenSize = MediaQuery.of(context).size;

    for (var fragment in _evidence.fragments) {
      // Random position (avoiding edges)
      _fragmentPositions[fragment.id] = Offset(
        random.nextDouble() * (screenSize.width - 200) + 50,
        random.nextDouble() * (screenSize.height - 300) + 100,
      );

      // Random rotation (0, 90, 180, 270)
      _fragmentRotations[fragment.id] = (random.nextInt(4) * 90).toDouble();

      // Initialize error count
      _fragmentErrors[fragment.id] = 0;
    }
  }

  void _onFragmentPickup(PuzzleFragment fragment) {
    _soundManager.playPickupSound();
    _soundManager.lightHaptic();

    // Add trail particles
    setState(() {
      _particles.addAll(
        ParticleEmitter.emitTrailParticles(_fragmentPositions[fragment.id]!),
      );
    });
  }

  void _onFragmentDrag(PuzzleFragment fragment, Offset globalPosition) {
    final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final localPosition = renderBox.globalToLocal(globalPosition);

    setState(() {
      _fragmentPositions[fragment.id] = localPosition;

      // Add trail particles
      if (_particles.length < 100) {
        _particles.addAll(
          ParticleEmitter.emitTrailParticles(localPosition),
        );
      }
    });

    // Check proximity for feedback
    if (PuzzleValidator.isNearCorrectPosition(
      fragment: fragment,
      currentPosition: localPosition,
    )) {
      _soundManager.playProximitySound();
    }
  }

  void _onFragmentDrop(PuzzleFragment fragment, Offset position) {
    _difficultyManager.incrementTotalAttempts();

    // Check if fragment is locked
    if (_isFragmentLocked(fragment.id)) {
      return;
    }

    // Apply false magnetic attraction
    final otherPositions = _fragmentPositions.values
        .where((pos) => pos != _fragmentPositions[fragment.id])
        .toList();

    final attractedPosition = _difficultyManager.applyFalseMagneticAttraction(
      position,
      otherPositions,
    );

    // Validate placement
    final isCorrect = PuzzleValidator.isCorrectPlacement(
      fragment: fragment,
      currentPosition: attractedPosition,
      currentRotation: _fragmentRotations[fragment.id]!,
      customTolerance: _difficultyManager.getSnapTolerance(),
    );

    if (isCorrect) {
      _snapFragment(fragment);
    } else {
      _rejectFragment(fragment);
    }
  }

  void _onFragmentTap(PuzzleFragment fragment) {
    if (_isFragmentLocked(fragment.id)) return;
    if (_correctlyPlacedFragments.contains(fragment.id)) return;

    setState(() {
      _fragmentRotations[fragment.id] =
          (_fragmentRotations[fragment.id]! + 90) % 360;
    });

    _soundManager.playRotateSound();
    _soundManager.lightHaptic();
  }

  void _snapFragment(PuzzleFragment fragment) {
    setState(() {
      // Snap to correct position
      _fragmentPositions[fragment.id] = Offset(
        fragment.correctPosition.x,
        fragment.correctPosition.y,
      );
      _fragmentRotations[fragment.id] = fragment.correctRotation;

      // Mark as correctly placed
      _correctlyPlacedFragments.add(fragment.id);

      // Reset error count
      _fragmentErrors[fragment.id] = 0;

      // Add snap particles
      _particles.addAll(
        ParticleEmitter.emitSnapParticles(_fragmentPositions[fragment.id]!),
      );
    });

    // Play effects
    _soundManager.playSnapSound();
    _soundManager.mediumHaptic();

    // Update difficulty manager
    _difficultyManager.incrementCorrectPlacements();

    // Check completion
    _checkCompletion();
  }

  void _rejectFragment(PuzzleFragment fragment) {
    // Increment error count
    _fragmentErrors[fragment.id] = (_fragmentErrors[fragment.id] ?? 0) + 1;

    // Check if should lock
    if (_difficultyManager.shouldLockFragment(
      fragment.id,
      _fragmentErrors,
    )) {
      _lockFragment(fragment.id);
    }

    // Return to random position
    final random = Random();
    final screenSize = MediaQuery.of(context).size;

    setState(() {
      _fragmentPositions[fragment.id] = Offset(
        random.nextDouble() * (screenSize.width - 200) + 50,
        random.nextDouble() * (screenSize.height - 300) + 100,
      );

      // Add error particles
      _particles.addAll(
        ParticleEmitter.emitErrorParticles(_fragmentPositions[fragment.id]!),
      );
    });

    // Play effects
    _soundManager.playErrorSound();
    _soundManager.errorHaptic();
  }

  void _lockFragment(String fragmentId) {
    setState(() {
      _fragmentLocks[fragmentId] =
          DateTime.now().add(_difficultyManager.getLockDuration());
    });

    // Unlock after duration
    Future.delayed(_difficultyManager.getLockDuration(), () {
      if (mounted) {
        setState(() {
          _fragmentLocks.remove(fragmentId);
          _fragmentErrors[fragmentId] = 0;
        });
      }
    });
  }

  bool _isFragmentLocked(String fragmentId) {
    final lockTime = _fragmentLocks[fragmentId];
    if (lockTime == null) return false;
    return DateTime.now().isBefore(lockTime);
  }

  void _checkCompletion() {
    if (_correctlyPlacedFragments.length == 5) {
      _completePuzzle();
    }
  }

  void _completePuzzle() {
    setState(() {
      _isCompleted = true;

      // Add confetti
      _particles.addAll(
        ParticleEmitter.emitConfettiParticles(MediaQuery.of(context).size),
      );
    });

    // Play completion effects
    _soundManager.playCompletionSound();
    _soundManager.successHaptic();

    // Save completion
    final provider = context.read<PuzzleDataProvider>();
    provider.completeEvidence(widget.evidenceId);

    // Show completion dialog after animation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _showCompletionDialog();
      }
    });
  }

  void _showCompletionDialog() {
    final duration = DateTime.now().difference(_startTime!);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: const Text(
          '🎉 ¡ROMPECABEZAS COMPLETADO!',
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _evidence.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Tiempo: ${minutes}m ${seconds}s',
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              'Intentos: ${_difficultyManager.totalAttempts}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              _evidence.narrativeDescription,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Close puzzle screen
            },
            child: const Text('CONTINUAR'),
          ),
        ],
      ),
    );
  }

  void _toggleHint() {
    if (!_difficultyManager.shouldOfferHint()) return;

    setState(() {
      _showHint = !_showHint;
      if (_showHint) {
        // Show hint for first incorrect fragment
        _hintFragmentId = _evidence.fragments
            .firstWhere((f) => !_correctlyPlacedFragments.contains(f.id))
            .id;
      } else {
        _hintFragmentId = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          _evidence.title,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          // Hint button
          if (_difficultyManager.shouldOfferHint())
            IconButton(
              icon: Icon(
                _showHint ? Icons.lightbulb : Icons.lightbulb_outline,
                color: Colors.yellow,
              ),
              onPressed: _toggleHint,
            ),
          // Progress indicator
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Text(
                '${_correctlyPlacedFragments.length}/5',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Particle system
          Positioned.fill(
            child: ParticleSystem(particles: _particles),
          ),

          // Hint overlay
          if (_showHint && _hintFragmentId != null)
            _buildHintOverlay(),

          // Fragments
          ..._evidence.fragments.map((fragment) {
            return DraggableFragment(
              key: ValueKey(fragment.id),
              fragment: fragment,
              position: _fragmentPositions[fragment.id] ?? Offset.zero,
              rotation: _fragmentRotations[fragment.id] ?? 0,
              isLocked: _isFragmentLocked(fragment.id),
              onPickup: () => _onFragmentPickup(fragment),
              onDrag: (pos) => _onFragmentDrag(fragment, pos),
              onDrop: (pos) => _onFragmentDrop(fragment, pos),
              onTap: () => _onFragmentTap(fragment),
            );
          }),

          // Time pressure indicator
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1)),
                    builder: (context, snapshot) {
                      final duration = DateTime.now().difference(_startTime!);
                      final minutes = duration.inMinutes;
                      final seconds = duration.inSeconds % 60;
                      return Text(
                        '$minutes:${seconds.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintOverlay() {
    final fragment = _evidence.fragments.firstWhere((f) => f.id == _hintFragmentId);
    final correctPos = Offset(
      fragment.correctPosition.x,
      fragment.correctPosition.y,
    );

    return Positioned(
      left: correctPos.dx - 10,
      top: correctPos.dy - 10,
      child: Container(
        width: 120, // Fixed size for fragment highlight
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.yellow, width: 3),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.yellow.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
      ),
    );
  }

}
