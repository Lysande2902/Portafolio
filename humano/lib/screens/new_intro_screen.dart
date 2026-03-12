import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'menu_screen.dart';

/// Tutorial interactivo que enseña las mecánicas básicas
/// y da contexto narrativo a los 3 arcos antes de empezar
class NewIntroScreen extends StatefulWidget {
  const NewIntroScreen({super.key});

  @override
  State<NewIntroScreen> createState() => _NewIntroScreenState();
}

class _NewIntroScreenState extends State<NewIntroScreen>
    with TickerProviderStateMixin {
  int _currentPhase = 0;
  String _currentText = '';
  final int _currentChoice = -1;
  
  // Audio
  final AudioPlayer _ambientPlayer = AudioPlayer();
  final AudioPlayer _glitchPlayer = AudioPlayer();
  
  // Animaciones
  late AnimationController _fadeController;
  late AnimationController _glitchController;
  late Animation<double> _fadeAnimation;

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

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _startIntro();
  }

  void _startIntro() async {
    // FASE 0: Silencio absoluto
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
    await _typeText('Conexión establecida');
    await Future.delayed(const Duration(milliseconds: 2000));
    
    // FASE 2: Interrogatorio - Pregunta 1
    if (!mounted) return;
    setState(() {
      _currentPhase = 2;
      _currentText = '';
    });
    await Future.delayed(const Duration(milliseconds: 800));
    await _typeText('¿Recuerdas lo que compartiste?');
    await Future.delayed(const Duration(milliseconds: 2500));
    
    // Mostrar opciones
    if (!mounted) return;
    setState(() => _currentPhase = 3);
    await Future.delayed(const Duration(seconds: 4)); // Tiempo para "elegir"
    
    // FASE 3: Consecuencias (independiente de elección)
    if (!mounted) return;
    setState(() {
      _currentPhase = 4;
      _currentText = '';
    });
    await Future.delayed(const Duration(milliseconds: 800));
    await _typeText('Ellos no olvidaron');
    await Future.delayed(const Duration(milliseconds: 2000));
    
    if (!mounted) return;
    setState(() => _currentText = '');
    await Future.delayed(const Duration(milliseconds: 500));
    await _typeText('Cada like tiene un precio');
    await Future.delayed(const Duration(milliseconds: 2000));
    
    if (!mounted) return;
    setState(() => _currentText = '');
    await Future.delayed(const Duration(milliseconds: 500));
    await _typeText('Cada compartir deja una cicatriz');
    await Future.delayed(const Duration(milliseconds: 2500));
    
    // FASE 4: Glitch transition
    if (!mounted) return;
    _playGlitchSound();
    setState(() => _currentPhase = 5);
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // FASE 5: Los pecados
    if (!mounted) return;
    setState(() {
      _currentPhase = 6;
      _currentText = '';
    });
    await Future.delayed(const Duration(milliseconds: 800));
    await _typeText('Tres víctimas');
    await Future.delayed(const Duration(milliseconds: 1800));
    
    if (!mounted) return;
    setState(() => _currentText = '');
    await Future.delayed(const Duration(milliseconds: 500));
    await _typeText('Tres pecados');
    await Future.delayed(const Duration(milliseconds: 1800));
    
    if (!mounted) return;
    setState(() => _currentText = '');
    await Future.delayed(const Duration(milliseconds: 500));
    await _typeText('Una sola verdad');
    await Future.delayed(const Duration(milliseconds: 2500));
    
    // FASE 6: Teaser Temporada 2 - EL LOBO
    if (!mounted) return;
    _stopGlitchSound();
    setState(() {
      _currentPhase = 7;
      _currentText = '';
    });
    await Future.delayed(const Duration(milliseconds: 1000));
    
    // Glitch intenso
    if (!mounted) return;
    _playGlitchSound();
    setState(() => _currentPhase = 8);
    await Future.delayed(const Duration(milliseconds: 800));
    
    // Mensaje del Lobo
    if (!mounted) return;
    setState(() {
      _currentPhase = 9;
      _currentText = '';
    });
    await Future.delayed(const Duration(milliseconds: 600));
    await _typeText('TEMPORADA 2:');
    await Future.delayed(const Duration(milliseconds: 1500));
    
    if (!mounted) return;
    setState(() => _currentText = '');
    await Future.delayed(const Duration(milliseconds: 400));
    await _typeText('¿Quién vigila a los vigilantes?');
    await Future.delayed(const Duration(milliseconds: 2500));
    
    if (!mounted) return;
    setState(() => _currentText = '');
    await Future.delayed(const Duration(milliseconds: 400));
    await _typeText('[CLASIFICADO]');
    await Future.delayed(const Duration(milliseconds: 1200));
    
    // Imagen del Lobo (si existe)
    if (!mounted) return;
    setState(() => _currentPhase = 10);
    await Future.delayed(const Duration(milliseconds: 2500));
    
    // FASE FINAL: Título del juego
    if (!mounted) return;
    _stopGlitchSound();
    setState(() => _currentPhase = 11);
    _fadeController.forward(from: 0);
    await Future.delayed(const Duration(seconds: 3));
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
      MaterialPageRoute(builder: (context) => const MenuScreen()),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _glitchController.dispose();
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

  Widget _buildPhaseContent() {
    switch (_currentPhase) {
      case 0:
        return Container(color: Colors.black);
      case 1:
        return _buildSystemText();
      case 2:
        return _buildQuestionText();
      case 3:
        return _buildChoices();
      case 4:
        return _buildConsequenceText();
      case 5:
        return _buildGlitchPhase();
      case 6:
        return _buildSinsText();
      case 7:
        return Container(color: Colors.black);
      case 8:
        return _buildGlitchPhase();
      case 9:
        return _buildSeason2Teaser();
      case 10:
        return _buildWolfReveal();
      case 11:
        return _buildFinalTitle();
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

  Widget _buildQuestionText() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _currentText,
            style: GoogleFonts.courierPrime(
              fontSize: 22,
              color: Colors.grey[400],
              letterSpacing: 1.5,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildChoices() {
    final choices = [
      'No recuerdo nada',
      'Era solo una broma',
      'Todo el mundo lo hace',
      '[Silencio]',
    ];

    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿Recuerdas lo que compartiste?',
                style: GoogleFonts.courierPrime(
                  fontSize: 20,
                  color: Colors.grey[400],
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ...choices.asMap().entries.map((entry) {
                final index = entry.key;
                final choice = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey[700]!,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '→ $choice',
                      style: GoogleFonts.courierPrime(
                        fontSize: 14,
                        color: Colors.grey[500],
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsequenceText() {
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
                  glitch ? (Random().nextDouble() - 0.5) * 4 : 0,
                  glitch ? (Random().nextDouble() - 0.5) * 4 : 0,
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

  Widget _buildGlitchPhase() {
    return AnimatedBuilder(
      animation: _glitchController,
      builder: (context, child) {
        return Container(
          color: _glitchController.value > 0.5 ? Colors.white : Colors.black,
          child: CustomPaint(
            painter: IntenseGlitchPainter(animationValue: _glitchController.value),
          ),
        );
      },
    );
  }

  Widget _buildSinsText() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _currentText,
            style: GoogleFonts.courierPrime(
              fontSize: 26,
              color: Colors.grey[600],
              letterSpacing: 3,
              height: 1.6,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSeason2Teaser() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: AnimatedBuilder(
            animation: _glitchController,
            builder: (context, child) {
              final glitch = _glitchController.value > 0.88;
              return Transform.translate(
                offset: Offset(
                  glitch ? (Random().nextDouble() - 0.5) * 6 : 0,
                  glitch ? (Random().nextDouble() - 0.5) * 6 : 0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentText,
                      style: GoogleFonts.courierPrime(
                        fontSize: 28,
                        color: Colors.red[700],
                        letterSpacing: 4,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildWolfReveal() {
    return Container(
      color: Colors.black,
      child: Stack(
        children: [
          // Efecto de estática
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glitchController,
              builder: (context, child) {
                return CustomPaint(
                  painter: StaticNoisePainter(animationValue: _glitchController.value),
                );
              },
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono del Lobo (placeholder)
                AnimatedBuilder(
                  animation: _glitchController,
                  builder: (context, child) {
                    final glitch = _glitchController.value > 0.9;
                    return Transform.translate(
                      offset: Offset(
                        glitch ? (Random().nextDouble() - 0.5) * 8 : 0,
                        glitch ? (Random().nextDouble() - 0.5) * 8 : 0,
                      ),
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.red[900]!,
                            width: 3,
                          ),
                        ),
                        child: Icon(
                          Icons.warning,
                          size: 100,
                          color: Colors.red[900],
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 40),
                
                // Texto misterioso
                AnimatedBuilder(
                  animation: _glitchController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _glitchController.value > 0.5 ? 1.0 : 0.3,
                      child: Text(
                        'Él está observando',
                        style: GoogleFonts.courierPrime(
                          fontSize: 20,
                          color: Colors.red[800],
                          letterSpacing: 3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                Text(
                  '[SEÑAL PERDIDA]',
                  style: GoogleFonts.courierPrime(
                    fontSize: 14,
                    color: Colors.grey[700],
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinalTitle() {
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
                    'C O N D I C I Ó N :',
                    style: GoogleFonts.courierPrime(
                      fontSize: 16,
                      color: const Color(0xFF8B0000),
                      letterSpacing: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'H U M A N O',
                    style: GoogleFonts.courierPrime(
                      fontSize: 48,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w900,
                      letterSpacing: 16,
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
      canvas.drawRect(
        Rect.fromLTWH(4, y + 2, size.width, height),
        Paint()..color = Colors.green.withOpacity(0.3),
      );
      canvas.drawRect(
        Rect.fromLTWH(-4, y - 2, size.width, height),
        Paint()..color = Colors.blue.withOpacity(0.3),
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
