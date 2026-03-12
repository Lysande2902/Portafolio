import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:humano/data/providers/arc_data_provider.dart';
import 'package:humano/data/models/arc_content.dart';
import 'package:vibration/vibration.dart';
import 'package:humano/game/ui/rotate_phone_prompt.dart';

/// Victory screen with VHS-style cinematic for Arc completion
class ArcVictoryCinematic extends StatefulWidget {
  final String arcId;
  final String arcTitle;
  final Map<String, dynamic> gameStats;
  final VoidCallback onComplete;

  const ArcVictoryCinematic({
    super.key,
    required this.arcId,
    required this.arcTitle,
    required this.gameStats,
    required this.onComplete,
  });

  @override
  State<ArcVictoryCinematic> createState() => _ArcVictoryCinematicState();
}

class _ArcVictoryCinematicState extends State<ArcVictoryCinematic>
    with SingleTickerProviderStateMixin {
  int _currentPhase = -1; // Empezar en -1 para mostrar el aviso de rotación primero
  late AnimationController _glitchController;
  bool _showStats = false;
  bool _showTeaser = false;

  // Cinematic texts and stats from arc content
  late final List<String> _cinematicTexts;
  late final List<StatConfig> _statsConfig;
  
  @override
  void initState() {
    super.initState();
    
    // Get arc-specific content
    final arcDataProvider = ArcDataProvider();
    final arcContent = arcDataProvider.getArcContent(widget.arcId);
    
    _cinematicTexts = arcContent?.victory.cinematicLines ?? ['Victoria'];
    _statsConfig = arcContent?.victory.stats ?? [];
    
    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    // No iniciar la cinemática automáticamente
  }

  final int _currentTextIndex = 0;
  bool _showText = false;
  bool _glitchActive = false;



  void _startCinematic() async {
    // CAMBIAR A HORIZONTAL para cinemática
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Phase 0: Black screen (2 seconds)
    setState(() {
      _currentPhase = 0;
    });
    
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Phase 1: Show single text with glitch and vibration
    setState(() {
      _currentPhase = 1;
      _glitchActive = true;
    });
    
    // Vibrate on text appearance
    try {
      bool? hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 400]);
      }
    } catch (e) {
      // Ignore vibration errors
    }
    
    // System sound effect (haptic feedback for glitch)
    try {
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.mediumImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.heavyImpact();
    } catch (e) {
      // Ignore haptic errors
    }
    
    // Glitch effect
    _glitchController.repeat();
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    
    _glitchController.stop();
    setState(() {
      _glitchActive = false;
      _showText = true;
    });

    // Hold text for 4 seconds
    await Future.delayed(const Duration(seconds: 4));
    if (!mounted) return;

    // Fade out text
    setState(() => _showText = false);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;

    // MANTENER VERTICAL para estadísticas
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    // Phase 3: Show stats directly (skip teaser)
    setState(() {
      _currentPhase = 3;
      _showStats = true;
    });

    // Auto-continue after 5 seconds
    await Future.delayed(const Duration(seconds: 5));
    if (!mounted) return;
    widget.onComplete();
  }

  @override
  void dispose() {
    _glitchController.dispose();
    super.dispose();
  }

  void _skipToStats() {
    if (!mounted) return;
    setState(() {
      _currentPhase = 3;
      _showStats = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Mostrar aviso de rotación primero
    if (_currentPhase == -1) {
      return RotatePhonePrompt(
        onContinue: () {
          setState(() {
            _startCinematic();
          });
        },
      );
    }
    
    return Material(
      color: Colors.black,
      child: Stack(
        children: [
          // Main content
          if (_currentPhase == 0)
            _buildBlackScreen()
          else if (_currentPhase == 1)
            _buildCinematicText()
          else if (_currentPhase == 3)
            _buildStatsScreen(),

          // VHS scanlines overlay
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: VHSScanlinesPainter(),
              ),
            ),
          ),
          
          // Skip button (only show during cinematic, not on stats screen)
          if (_currentPhase < 3)
            Positioned(
              top: 20,
              right: 20,
              child: SafeArea(
                child: TextButton(
                  onPressed: _skipToStats,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.7),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fast_forward, color: Colors.grey[400], size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'SKIP',
                        style: GoogleFonts.courierPrime(
                          fontSize: 12,
                          color: Colors.grey[400],
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBlackScreen() {
    return const SizedBox.expand();
  }

  Widget _buildNextArcTeaser() {
    // Determinar qué arcos mostrar basado en el arco actual
    List<Map<String, dynamic>> upcomingArcs = _getUpcomingArcs();
    
    return AnimatedOpacity(
      opacity: _showTeaser ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black,
              Colors.grey[900]!,
              Colors.black,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.visibility,
                    size: 60,
                    color: Colors.white70,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'PRÓXIMAMENTE...',
                    style: GoogleFonts.courierPrime(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Lista de próximos arcos
                  ...upcomingArcs.map((arc) => _buildArcTeaser(arc)),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Los secretos más oscuros están por revelarse...',
                      style: GoogleFonts.courierPrime(
                        fontSize: 16,
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                        letterSpacing: 1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getUpcomingArcs() {
    switch (widget.arcId) {
      case 'arc_1_gula':
        return [
          {
            'title': 'Arco II: Avaricia',
            'subtitle': 'La codicia consume todo a su paso',
            'icon': Icons.attach_money,
            'color': Colors.green[400],
          },
          {
            'title': 'Arco III: Envidia',
            'subtitle': 'Los celos revelan la verdadera naturaleza',
            'icon': Icons.remove_red_eye,
            'color': Colors.purple[400],
          },
        ];
      case 'arc_2_greed':
        return [
          {
            'title': 'Arco III: Envidia',
            'subtitle': 'Los celos revelan la verdadera naturaleza',
            'icon': Icons.remove_red_eye,
            'color': Colors.purple[400],
          },
          {
            'title': 'Arco IV: Lujuria',
            'subtitle': 'La pasión descontrolada destruye vidas',
            'icon': Icons.favorite,
            'color': Colors.pink[400],
          },
        ];
      case 'arc_3_envy':
        return [
          {
            'title': 'Arco IV: Lujuria',
            'subtitle': 'La pasión descontrolada destruye vidas',
            'icon': Icons.favorite,
            'color': Colors.pink[400],
          },
          {
            'title': 'Arco V: Soberbia',
            'subtitle': 'El orgullo precede a la caída',
            'icon': Icons.star,
            'color': Colors.amber[400],
          },
        ];
      case 'arc_4_lust':
        return [
          {
            'title': 'Arco V: Soberbia',
            'subtitle': 'El orgullo precede a la caída',
            'icon': Icons.star,
            'color': Colors.amber[400],
          },
          {
            'title': 'Arco VI: Pereza',
            'subtitle': 'La inacción es el mayor de los pecados',
            'icon': Icons.bed,
            'color': Colors.blue[400],
          },
        ];
      case 'arc_5_pride':
        return [
          {
            'title': 'Arco VI: Pereza',
            'subtitle': 'La inacción es el mayor de los pecados',
            'icon': Icons.bed,
            'color': Colors.blue[400],
          },
          {
            'title': 'Arco VII: Ira',
            'subtitle': 'La furia final que consume todo',
            'icon': Icons.whatshot,
            'color': Colors.red[400],
          },
        ];
      case 'arc_6_sloth':
        return [
          {
            'title': 'Arco VII: Ira',
            'subtitle': 'La furia final que consume todo',
            'icon': Icons.whatshot,
            'color': Colors.red[400],
          },
          {
            'title': 'Final: Revelación',
            'subtitle': 'La verdad detrás de todo será revelada',
            'icon': Icons.auto_awesome,
            'color': Colors.white,
          },
        ];
      default:
        return [
          {
            'title': 'Más misterios',
            'subtitle': 'La investigación continúa...',
            'icon': Icons.search,
            'color': Colors.white70,
          },
        ];
    }
  }

  Widget _buildArcTeaser(Map<String, dynamic> arc) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 40.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (arc['color'] as Color?) ?? Colors.white70,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              arc['icon'] as IconData,
              size: 32,
              color: arc['color'] as Color?,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    arc['title'] as String,
                    style: GoogleFonts.courierPrime(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    arc['subtitle'] as String,
                    style: GoogleFonts.courierPrime(
                      fontSize: 14,
                      color: Colors.white70,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCinematicText() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return Stack(
      children: [
        // Static/noise effect when glitching
        if (_glitchActive)
          Positioned.fill(
            child: Opacity(
              opacity: 0.15,
              child: CustomPaint(
                painter: _StaticNoisePainter(
                  seed: (_glitchController.value * 1000).toInt(),
                ),
              ),
            ),
          ),
        
        // Main text
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimatedOpacity(
              opacity: _showText ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: AnimatedBuilder(
                animation: _glitchController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: _glitchActive
                        ? Offset(
                            (math.Random().nextDouble() * 20 - 10),
                            (math.Random().nextDouble() * 10 - 5),
                          )
                        : Offset.zero,
                    child: Text(
                      _cinematicTexts.join('\n\n'),
                      style: GoogleFonts.shareTechMono(
                        fontSize: isSmallScreen ? 18 : 22,
                        color: _glitchActive
                            ? const Color(0xFF00B2FF)
                            : const Color(0xFF00F0FF), // Cyber cyan
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.bold,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: null, // Allow multiple lines
                      softWrap: true,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsScreen() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return AnimatedOpacity(
      opacity: _showStats ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 800),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(isSmallScreen ? 20 : 40),
              child: Row(
                children: [
                  // Left side: Arc title
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ARCO ${_getArcNumber(widget.arcId)}',
                          style: GoogleFonts.courierPrime(
                            fontSize: isSmallScreen ? 12 : 18,
                            color: Colors.grey[600],
                            letterSpacing: 2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.arcTitle.toUpperCase(),
                          style: GoogleFonts.courierPrime(
                            fontSize: isSmallScreen ? 24 : 48,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: isSmallScreen ? 2 : 4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 20),

                  // Right side: Stats (from arc content configuration)
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: _buildConfiguredStats(isSmallScreen),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildConfiguredStats(bool isSmallScreen) {
    final List<Widget> statWidgets = [];
    
    for (int i = 0; i < _statsConfig.length; i++) {
      final config = _statsConfig[i];
      final value = widget.gameStats[config.key];
      
      // Only show stat if value exists
      if (value != null) {
        final formattedValue = config.formatter(value);
        
        statWidgets.add(
          _buildStatRow(config.label, formattedValue, isSmallScreen),
        );
        
        // Add spacing between stats (except last one)
        if (i < _statsConfig.length - 1) {
          statWidgets.add(SizedBox(height: isSmallScreen ? 1 : 25));
        }
      }
    }
    
    return statWidgets;
  }

  Widget _buildStatRow(String label, String value, bool isSmallScreen) {
    Color valueColor = Colors.white;
    if (label.contains('FRAGMENTOS')) valueColor = const Color(0xFFFFD700); // Evidence Yellow
    if (label.contains('TIEMPO')) valueColor = const Color(0xFF00F0FF);      // Neon Cyan
    if (label.contains('SEGUIDORES')) valueColor = const Color(0xFF00F0FF); // Neon Cyan

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.courierPrime(
            fontSize: isSmallScreen ? 10 : 12,
            color: Colors.grey[600],
            letterSpacing: 0.5,
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          value,
          style: GoogleFonts.courierPrime(
            fontSize: isSmallScreen ? 18 : 24,
            color: valueColor,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            height: 1.2,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  String _formatTime(double seconds) {
    final minutes = (seconds / 60).floor();
    final secs = (seconds % 60).floor();
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  String _getArcNumber(String arcId) {
    // Extract arc number from arcId (e.g., "arc_2_greed" -> "2")
    final match = RegExp(r'arc_(\d+)').firstMatch(arcId);
    return match?.group(1) ?? '?';
  }
}

class VHSScanlinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    // Draw horizontal scanlines
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StaticNoisePainter extends CustomPainter {
  final int seed;
  
  _StaticNoisePainter({required this.seed});
  
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(seed);
    final paint = Paint()..color = Colors.white;
    
    // Draw random noise pixels
    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = random.nextDouble() * 0.8;
      
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), 1, paint);
    }
  }
  
  @override
  bool shouldRepaint(_StaticNoisePainter oldDelegate) => oldDelegate.seed != seed;
}
