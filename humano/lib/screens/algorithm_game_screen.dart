import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/services/multiplayer_service.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class AlgorithmGameScreen extends StatefulWidget {
  final String matchId;
  final String arcId;

  const AlgorithmGameScreen({
    super.key,
    required this.matchId,
    required this.arcId,
  });

  @override
  State<AlgorithmGameScreen> createState() => _AlgorithmGameScreenState();
}

class _AlgorithmGameScreenState extends State<AlgorithmGameScreen> with TickerProviderStateMixin {
  final MultiplayerService _multiplayerService = MultiplayerService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // Game State
  double _algorithmEnergy = 50.0;
  final double _maxEnergy = 100.0;
  Map<String, dynamic>? _userState;
  final List<Offset> _noiseSignals = [];
  
  // Animations
  late AnimationController _radarController;
  late AnimationController _glitchController;
  Timer? _energyTimer;
  Timer? _cleanupTimer;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    // Energy regeneration
    _energyTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          if (_algorithmEnergy < _maxEnergy) {
            _algorithmEnergy += 2.0; // Faster regen
          }
        });
      }
    });

    // Cleanup old signals
    _cleanupTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_noiseSignals.length > 5) {
            _noiseSignals.removeAt(0);
          }
        });
      }
    });
    
    _playAmbient();
  }

  void _playAmbient() async {
    try {
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(AssetSource('sounds/tape-player-sounds-90780.mp3'), volume: 0.3);
    } catch (e) {
      debugPrint("Error playing ambient: $e");
    }
  }

  @override
  void dispose() {
    _radarController.dispose();
    _glitchController.dispose();
    _energyTimer?.cancel();
    _cleanupTimer?.cancel();
    _audioPlayer.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Timestamp? _lastSignalTimestamp;

  void _performAction(String type, double cost, String description) async {
    if (_algorithmEnergy >= cost) {
      // Haptic & Visual Feedback
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 100);
      }
      
      _glitchController.forward(from: 0).then((_) => _glitchController.reverse());

      setState(() {
        _algorithmEnergy -= cost;
      });
      
      _multiplayerService.performAction(widget.matchId, type, {});
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.black),
                const SizedBox(width: 12),
                Text(
                  'EJECUTANDO: $type',
                  style: GoogleFonts.vt323(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(milliseconds: 500),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      // Error feedback
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 50);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: _glitchController,
        builder: (context, child) {
          return Stack(
            children: [
              // Background
              Positioned.fill(
                child: CustomPaint(
                  painter: OppressiveRadarPainter(_radarController.value),
                ),
              ),
              
              // Glitch Overlay
              if (_glitchController.value > 0)
                Positioned.fill(
                  child: Container(
                    color: Colors.red.withOpacity(_glitchController.value * 0.2),
                  ),
                ),

              StreamBuilder<DocumentSnapshot>(
                stream: _multiplayerService.matchStream(widget.matchId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: Colors.red));
                  }

                  final data = snapshot.data!.data() as Map<String, dynamic>;
                  _userState = data['userState'] as Map<String, dynamic>?;

                  // Process signals
                  if (data.containsKey('lastSignal')) {
                    final signal = data['lastSignal'] as Map<String, dynamic>;
                    final timestamp = signal['timestamp'] as Timestamp?;
                    
                    if (timestamp != null && timestamp != _lastSignalTimestamp) {
                      _lastSignalTimestamp = timestamp;
                      final signalData = signal['data'] as Map<String, dynamic>;
                      final x = (signalData['x'] as num).toDouble();
                      final y = (signalData['y'] as num).toDouble();
                      
                      // Normalize
                      final normX = x / 1200.0;
                      final normY = y / 800.0;
                      
                      _noiseSignals.add(Offset(normX, normY));
                      HapticFeedback.lightImpact();
                    }
                  }

                  return SafeArea(
                    child: Column(
                      children: [
                        _buildTopBar(),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              return Stack(
                                children: [
                                  // Signals
                                  ..._noiseSignals.map((normOffset) {
                                    final screenX = normOffset.dx * constraints.maxWidth;
                                    final screenY = normOffset.dy * constraints.maxHeight;
                                    
                                    return Positioned(
                                      left: screenX - 10,
                                      top: screenY - 10,
                                      child: TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0.0, end: 1.0),
                                        duration: const Duration(milliseconds: 800),
                                        builder: (context, value, child) {
                                          return Opacity(
                                            opacity: 1.0 - value,
                                            child: Transform.scale(
                                              scale: 1.0 + (value * 3.0),
                                              child: Container(
                                                width: 20,
                                                height: 20,
                                                decoration: BoxDecoration(
                                                  border: Border.all(color: Colors.red, width: 2),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  }),
                                  
                                  // Crosshair
                                  Center(
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 4,
                                          height: 4,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        _buildControlPanel(),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopBar() {
    final sanity = _userState?['sanity'] ?? 1.0;
    final evidence = _userState?['evidenceCount'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      color: Colors.black.withOpacity(0.8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OBJETIVO DETECTADO',
                style: GoogleFonts.shareTechMono(color: Colors.red[900], fontSize: 10, letterSpacing: 2),
              ),
              Text(
                'SUJETO #849',
                style: GoogleFonts.vt323(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'INTEGRIDAD MENTAL',
                style: GoogleFonts.shareTechMono(color: Colors.grey, fontSize: 10),
              ),
              Text(
                '${(sanity * 100).toInt()}%',
                style: GoogleFonts.vt323(
                  color: sanity < 0.3 ? Colors.red : Colors.white,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border(top: BorderSide(color: Colors.red[900]!, width: 2)),
        boxShadow: [
          BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: Column(
        children: [
          // Energy Bar
          Row(
            children: [
              Text('ENERGÍA', style: GoogleFonts.shareTechMono(color: Colors.red, fontSize: 12)),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: _algorithmEnergy / _maxEnergy,
                    backgroundColor: Colors.grey[900],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.red),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                '${_algorithmEnergy.toInt()}',
                style: GoogleFonts.vt323(color: Colors.red, fontSize: 20),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Skills
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSkillButton(
                'SONDA',
                'Vibración',
                Icons.waves,
                20.0,
                () => _performAction('ping', 20.0, 'Vibración enviada'),
              ),
              _buildSkillButton(
                'GLITCH',
                'Ceguera',
                Icons.broken_image_outlined,
                40.0,
                () => _performAction('glitch', 40.0, 'Pantalla corrupta'),
              ),
              _buildSkillButton(
                'LAG',
                'Congelar',
                Icons.hourglass_empty,
                60.0,
                () => _performAction('lag', 60.0, 'Input lag aplicado'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkillButton(String label, String subLabel, IconData icon, double cost, VoidCallback onTap) {
    final canAfford = _algorithmEnergy >= cost;
    
    return GestureDetector(
      onTap: canAfford ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: canAfford ? 1.0 : 0.3,
        child: Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(
              color: canAfford ? Colors.red : Colors.grey[800]!,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: canAfford ? [
              BoxShadow(color: Colors.red.withOpacity(0.1), blurRadius: 10, spreadRadius: 0),
            ] : [],
          ),
          child: Column(
            children: [
              Icon(icon, color: canAfford ? Colors.red : Colors.grey, size: 28),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.vt323(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subLabel.toUpperCase(),
                style: GoogleFonts.shareTechMono(
                  color: Colors.grey[600],
                  fontSize: 9,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '-${cost.toInt()} E',
                style: GoogleFonts.shareTechMono(
                  color: Colors.red[900],
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OppressiveRadarPainter extends CustomPainter {
  final double scanValue;

  OppressiveRadarPainter(this.scanValue);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.6;
    final paint = Paint()
      ..color = Colors.red.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Concentric circles
    for (int i = 1; i <= 4; i++) {
      canvas.drawCircle(center, radius * (i / 4), paint);
    }

    // Cross lines
    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), paint);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), paint);

    // Rotating Scan
    final scanPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          Colors.red.withOpacity(0.0),
          Colors.red.withOpacity(0.3),
        ],
        stops: const [0.8, 1.0],
        transform: GradientRotation(scanValue * 2 * pi),
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, scanPaint);
  }

  @override
  bool shouldRepaint(covariant OppressiveRadarPainter oldDelegate) => true;
}
