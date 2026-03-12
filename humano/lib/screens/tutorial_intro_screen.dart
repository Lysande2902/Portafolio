import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'arc_selection_screen.dart';

/// Tutorial interactivo que enseña las mecánicas básicas del juego
/// y proporciona contexto narrativo para los 3 arcos
/// Se ejecuta ANTES de la selección de arcos
class TutorialIntroScreen extends StatefulWidget {
  const TutorialIntroScreen({super.key});

  @override
  State<TutorialIntroScreen> createState() => _TutorialIntroScreenState();
}

class _TutorialIntroScreenState extends State<TutorialIntroScreen>
    with TickerProviderStateMixin {
  int _currentPhase = 0;
  String _currentText = '';
  bool _showGameplay = false;
  
  // Gameplay tutorial
  Offset _playerPosition = const Offset(200, 400);
  Offset _joystickPosition = Offset.zero;
  bool _evidenceCollected = false;
  int _tutorialStep = 0;
  
  // Audio
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _glitchPlayer = AudioPlayer();
  
  // Animaciones
  late AnimationController _fadeController;
  late AnimationController _glitchController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startIntro();
  }

  void _startIntro() async {
    // FASE 0: Silencio
    await Future.delayed(const Duration(seconds: 2));
    
    // FASE 1: Sistema de verificación
    if (!mounted) return;
    setState(() => _currentPhase = 1);
    _fadeController.forward(from: 0);
    await _typeText('SISTEMA DE VERIFICACIÓN ACTIVO');
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    setState(() => _currentText = '');
    await Future.delayed(const Duration(milliseconds: 500));
    await _typeText('Identidad: U-S-U-A-R-I-O');
    await Future.delayed(const Duration(milliseconds: 1200));
    
    if (!mounted) return;
    setState(() => _currentText = '');
    await Future.delayed(const Duration(milliseconds: 500));
    await _typeText('Iniciando protocolo de entrenamiento');
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // FASE 2: Contexto narrativo
    if (!mounted) return;
    setState(() {
      _currentPhase = 2;
      _currentText = '';
    });
    await Future.delayed(const Duration(milliseconds: 800));
    await _typeText('Tres víctimas esperan');
    await Future.delayed(const Duration(milliseconds: 2000));
    
    if (!mounted) return;
    setState(() => _currentText = '');
    await Future.delayed(const Duration(milliseconds: 500));
    await _typeText('Cada uno guarda evidencias');
    await Future.delayed(const Duration(milliseconds: 2000));
    
    if (!mounted) return;
    setState(() => _currentText = '');
    await Future.delayed(const Duration(milliseconds: 500));
    await _typeText('De TU culpa');
    await Future.delayed(const Duration(milliseconds: 2500));
    
    // FASE 3: Tutorial de movimiento
    if (!mounted) return;
    setState(() {
      _currentPhase = 3;
      _showGameplay = true;
      _tutorialStep = 1;
    });
    await Future.delayed(const Duration(milliseconds: 500));
    await _typeText('Usa el joystick para moverte');
    
    // Esperar a que el jugador se mueva
    while (_joystickPosition == Offset.zero && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // FASE 4: Tutorial de recolección
    if (!mounted) return;
    setState(() {
      _tutorialStep = 2;
      _currentText = '';
    });
    await Future.delayed(const Duration(milliseconds: 500));
    await _typeText('Acércate a la evidencia para recolectarla');
    
    // Esperar a que recolecte la evidencia (automático al acercarse)
    while (!_evidenceCollected && mounted) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // FASE 5: Los tres pecados
    if (!mounted) return;
    setState(() {
      _currentPhase = 4;
      _showGameplay = false;
      _currentText = '';
    });
    await Future.delayed(const Duration(milliseconds: 800));
    await _typeText('ARCO 1: GULA');
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    setState(() => _currentText = '');
    await Future.delayed(const Duration(milliseconds: 400));
    await _typeText('Un chef destruido por tus risas');
    await Future.delayed(const Duration(milliseconds: 2000));
    
    if (!mounted) return;
    setState(() => _currentText = '');
    await Future.delayed(const Duration(milliseconds: 600));
    await _typeText('ARCO 2: AVARICIA');
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    setState(() => _currentText = '');
    await Future.delayed(const Duration(milliseconds: 400));
    await _typeText('Una familia arruinada por tu codicia');
    await Future.delayed(const Duration(milliseconds: 2000));
    
    if (!mounted) return;
    setState(() => _currentText = '');
    await Future.delayed(const Duration(milliseconds: 600));
    await _typeText('ARCO 3: ENVIDIA');
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    setState(() => _currentText = '');
    await Future.delayed(const Duration(milliseconds: 400));
    await _typeText('Una vida robada por tu envidia');
    await Future.delayed(const Duration(milliseconds: 2500));
    
    // FASE 6: Mensaje final
    if (!mounted) return;
    setState(() {
      _currentPhase = 5;
      _currentText = '';
    });
    await Future.delayed(const Duration(milliseconds: 800));
    await _typeText('Tus decisiones tienen consecuencias');
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;
    setState(() => _currentText = '');
    await Future.delayed(const Duration(milliseconds: 500));
    await _typeText('Cada respuesta será recordada');
    await Future.delayed(const Duration(milliseconds: 2500));
    
    // FASE FINAL
    if (!mounted) return;
    setState(() => _currentPhase = 6);
    _fadeController.forward(from: 0);
  }

  Future<void> _typeText(String text) async {
    for (int i = 0; i <= text.length; i++) {
      if (!mounted) return;
      setState(() {
        _currentText = text.substring(0, i);
      });
      await Future.delayed(const Duration(milliseconds: 60));
    }
  }

  void _playGlitchSound() async {
    try {
      await _glitchPlayer.setAsset('assets/sounds/glitch_09-226602.mp3');
      await _glitchPlayer.setLoopMode(LoopMode.one);
      await _glitchPlayer.setVolume(0.4);
      await _glitchPlayer.play();
    } catch (e) {
      print('Error playing glitch sound: $e');
    }
  }

  void _stopGlitchSound() {
    _glitchPlayer.stop();
  }

  void _skipIntro() {
    _stopGlitchSound();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const ArcSelectionScreen()),
    );
  }

  void _onJoystickMove(Offset delta) {
    if (!_showGameplay) return;
    
    setState(() {
      _joystickPosition = delta;
      
      // Mover jugador
      final speed = 3.0;
      _playerPosition = Offset(
        (_playerPosition.dx + delta.dx * speed).clamp(50.0, MediaQuery.of(context).size.width - 50),
        (_playerPosition.dy + delta.dy * speed).clamp(50.0, MediaQuery.of(context).size.height - 150),
      );
      
      // Recolección automática al acercarse
      if (_tutorialStep == 2 && !_evidenceCollected) {
        final evidencePos = Offset(
          MediaQuery.of(context).size.width / 2,
          MediaQuery.of(context).size.height / 2,
        );
        final distance = (_playerPosition - evidencePos).distance;
        
        // Recolectar automáticamente cuando está cerca
        if (distance < 70) {
          _evidenceCollected = true;
        }
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _glitchController.dispose();
    _pulseController.dispose();
    _ambientPlayer.dispose();
    _glitchPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildPhaseContent(),
          
          // Gameplay overlay
          if (_showGameplay) _buildGameplayOverlay(),
          
          // Botón Skip
          Positioned(
            top: 30,
            right: 30,
            child: GestureDetector(
              onTap: _skipIntro,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  border: Border.all(color: Colors.grey[700]!, width: 1),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.skip_next, color: Colors.grey[500], size: 18),
                    const SizedBox(width: 6),
                    Text(
                      'SKIP',
                      style: GoogleFonts.courierPrime(
                        fontSize: 12,
                        color: Colors.grey[500],
                        letterSpacing: 2,
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

  Widget _buildGameplayOverlay() {
    return Stack(
      children: [
        // Fondo oscuro
        Container(
          color: Colors.black.withOpacity(0.3),
        ),
        
        // Jugador
        Positioned(
          left: _playerPosition.dx - 20,
          top: _playerPosition.dy - 20,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 24),
          ),
        ),
        
        // Evidencia (si no ha sido recolectada)
        if (_tutorialStep == 2 && !_evidenceCollected)
          Positioned(
            left: MediaQuery.of(context).size.width / 2 - 25,
            top: MediaQuery.of(context).size.height / 2 - 25,
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B0000),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B0000).withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.article, color: Colors.white, size: 28),
                  ),
                );
              },
            ),
          ),
        
        // Joystick
        Positioned(
          bottom: 40,
          left: 40,
          child: GestureDetector(
            onPanUpdate: (details) {
              final center = const Offset(60, 60);
              final delta = details.localPosition - center;
              final distance = delta.distance;
              
              if (distance > 0) {
                final normalized = delta / distance;
                final clamped = distance.clamp(0.0, 50.0) / 50.0;
                _onJoystickMove(normalized * clamped);
              }
            },
            onPanEnd: (_) {
              _onJoystickMove(Offset.zero);
            },
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
              ),
              child: Center(
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
        

        // Texto de instrucción
        Positioned(
          top: 100,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF8B0000), width: 2),
              ),
              child: Text(
                _currentText,
                style: GoogleFonts.courierPrime(
                  fontSize: 14,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhaseContent() {
    switch (_currentPhase) {
      case 0:
        return Container(color: Colors.black);
      case 1:
        return _buildSystemText();
      case 2:
        return _buildNarrativeText();
      case 3:
        return Container(color: Colors.black); // Gameplay activo
      case 4:
        return _buildArcsText();
      case 5:
        return _buildFinalMessage();
      case 6:
        return _buildFinalScreen();
      default:
        return Container(color: Colors.black);
    }
  }

  Widget _buildSystemText() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              _currentText,
              style: GoogleFonts.courierPrime(
                fontSize: 18,
                color: const Color(0xFF00FF00),
                letterSpacing: 2,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNarrativeText() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: AnimatedBuilder(
            animation: _glitchController,
            builder: (context, child) {
              final glitch = _glitchController.value > 0.92;
              return Transform.translate(
                offset: Offset(
                  glitch ? (Random().nextDouble() - 0.5) * 3 : 0,
                  glitch ? (Random().nextDouble() - 0.5) * 3 : 0,
                ),
                child: Text(
                  _currentText,
                  style: GoogleFonts.courierPrime(
                    fontSize: 24,
                    color: const Color(0xFF8B0000),
                    letterSpacing: 2,
                    height: 1.5,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildArcsText() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _currentText,
            style: GoogleFonts.courierPrime(
              fontSize: 20,
              color: Colors.grey[500],
              letterSpacing: 2,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }



  Widget _buildFinalMessage() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _currentText,
            style: GoogleFonts.courierPrime(
              fontSize: 22,
              color: Colors.grey[600],
              letterSpacing: 2,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildFinalScreen() {
    return GestureDetector(
      onTap: _skipIntro,
      child: Container(
        color: Colors.black,
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ENTRENAMIENTO COMPLETO',
                    style: GoogleFonts.courierPrime(
                      fontSize: 14,
                      color: const Color(0xFF8B0000),
                      letterSpacing: 4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Elige tu pecado',
                    style: GoogleFonts.courierPrime(
                      fontSize: 32,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 60),
                  AnimatedBuilder(
                    animation: _glitchController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: _glitchController.value > 0.5 ? 0.7 : 0.3,
                        child: Text(
                          'Presiona para continuar_',
                          style: GoogleFonts.courierPrime(
                            fontSize: 12,
                            color: Colors.grey[700],
                            letterSpacing: 2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Painters
class IntenseGlitchPainter extends CustomPainter {
  final double animationValue;

  IntenseGlitchPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random((animationValue * 1000).toInt());
    
    for (int i = 0; i < 40; i++) {
      final y = random.nextDouble() * size.height;
      final height = random.nextDouble() * 8;
      
      canvas.drawRect(
        Rect.fromLTWH(0, y, size.width, height),
        Paint()..color = Colors.red.withOpacity(0.4),
      );
    }
  }

  @override
  bool shouldRepaint(IntenseGlitchPainter oldDelegate) => true;
}

class StaticNoisePainter extends CustomPainter {
  final double animationValue;

  StaticNoisePainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random((animationValue * 1000).toInt());

    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(
        Offset(x, y),
        1,
        Paint()..color = Colors.white.withOpacity(random.nextDouble() * 0.3),
      );
    }
  }

  @override
  bool shouldRepaint(StaticNoisePainter oldDelegate) => true;
}
