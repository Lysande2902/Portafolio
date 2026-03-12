import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import 'prologue_tutorial_screen.dart';

class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with TickerProviderStateMixin {
  int _currentPhase = 0;
  String _leftText = '';
  String _rightText = '';
  String _centerText = '';
  double _scanningLinePos = 0.0;
  bool _showGlitch = false;
  
  // Audio players
  final AudioPlayer _backgroundPlayer = AudioPlayer();
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _heartbeatPlayer = AudioPlayer();

  late AnimationController _glitchController;
  late AnimationController _scanningController;

  @override
  void initState() {
    super.initState();

    // Forzar modo horizontal para la intro
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Ocultar barras de sistema para mayor inmersión
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    )..repeat();

    _scanningController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _initAudio();
    _startIntroSequence();
  }

  void _initAudio() async {
    try {
      // Usar la música global del AudioProvider
      // Provider.of lo llamamos en el build o por context.read si es seguro
      // Aquí usamos context.read
      Provider.of<AudioProvider>(context, listen: false).playArcMusic('current');
    } catch (e) {
       debugPrint('Error audio: $e');
    }
  }

  Future<void> _playSFX(String asset, {double volume = 0.5}) async {
    try {
      await _sfxPlayer.setAsset(asset);
      await _sfxPlayer.setVolume(volume);
      await _sfxPlayer.play();
    } catch (e) {
       debugPrint('Error SFX: $e');
    }
  }

  Future<void> _startIntroSequence() async {
    // FASE -1: ADVERTENCIA
    setState(() {
      _currentPhase = -1;
    });
    await Future.delayed(const Duration(seconds: 5));

    // Fase 1: El Vacío y la Dicotomía
    if (!mounted) return;
    setState(() {
      _currentPhase = 0;
    });
    await Future.delayed(const Duration(seconds: 2));
    
    // _startHeartbeat(); // Desactivado por petición del usuario (eliminar efectos)

    // FASE: SUBIMINAL 0
    _triggerSubliminal('¿ESTÁS AHÍ?');
    await Future.delayed(const Duration(milliseconds: 1000));

    // "Los humanos no son ángeles" (Izquierda)
    if (!mounted) return;
    await _typeText('Los humanos no son ángeles.', (text) => setState(() => _leftText = text), speed: 100);
    _triggerSubliminal('MENTIRA');
    await Future.delayed(const Duration(seconds: 2));
    
    // "Tampoco demonios" (Derecha)
    if (!mounted) return;
    await _typeText('Tampoco demonios.', (text) => setState(() => _rightText = text), speed: 100);
    _triggerSubliminal('PEOR');
    await Future.delayed(const Duration(seconds: 2));
    
    // "Son testigos con libre albedrío" (Centro)
    if (!mounted) return;
    setState(() => _currentPhase = 1);
    await _typeText('Son testigos con libre albedrío.', (text) => setState(() => _centerText = text), speed: 80);
    _triggerSubliminal('CÓMPLICES');
    await Future.delayed(const Duration(seconds: 3));

    // Fase 2: El Juicio y el Crimen
    if (!mounted) return;
    setState(() {
      _currentPhase = 2;
      _leftText = '';
      _rightText = '';
      _centerText = '';
    });
    await Future.delayed(const Duration(milliseconds: 1000));
    await _typeText('Son el juicio', (text) => setState(() => _leftText = text), speed: 80);
    await Future.delayed(const Duration(milliseconds: 500));
    await _typeText('y el crimen', (text) => setState(() => _rightText = text), speed: 80);
    _triggerSubliminal('TÚ ERES EL CRIMEN');
    await Future.delayed(const Duration(milliseconds: 500));
    await _typeText('en el mismo cuerpo.', (text) => setState(() => _centerText = text), speed: 80);
    await Future.delayed(const Duration(seconds: 3));

    // Fase 3: El Miedo
    if (!mounted) return;
    // _playSFX('assets/sounds/glitch_09-226602.mp3', volume: 0.6); // Efecto eliminado
    setState(() {
      _currentPhase = 3;
      _leftText = '';
      _rightText = '';
      _centerText = '';
    });
    await _typeText('La pregunta no es si les temes.', (text) => setState(() => _centerText = text), speed: 80);
    _triggerSubliminal('MÍRAME');
    await Future.delayed(const Duration(seconds: 3));

    // Fase 4: El Final
    if (!mounted) return;
    setState(() {
      _currentPhase = 4;
      _centerText = '';
    });
    await _typeText('La pregunta es:', (text) => setState(() => _centerText = text), speed: 80);
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    _triggerSubliminal('NADIE ESCAPA');
    setState(() => _centerText = '');
    await _typeText('cuando llegue el final,', (text) => setState(() => _centerText = text), speed: 80);
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted) return;
    setState(() => _centerText = '');
    await _typeText('cuando todo arda y nadie mire…', (text) => setState(() => _centerText = text), speed: 90);
    _triggerSubliminal('TODO ARDE');
    await Future.delayed(const Duration(seconds: 3));

    // Fase 5: La Gran Pregunta
    if (!mounted) return;
    // _playSFX('assets/sounds/i-see-you-313586.mp3', volume: 0.9); // Efecto eliminado
    setState(() {
      _currentPhase = 5;
      _centerText = '';
    });
    await _typeText('¿qué parte de ti querrás que sea vista?', (text) => setState(() => _centerText = text), speed: 150);
    
    // Glitch Masivo Final
    for(int i=0; i<5; i++) {
      _triggerSubliminal('DAME TU ALMA');
      await Future.delayed(const Duration(milliseconds: 300));
    }
    
    await Future.delayed(const Duration(seconds: 5));

    if (!mounted) return;
    _skipIntro();
  }

  void _startHeartbeat() {
    // Iniciar audio de latidos en bucle
    _heartbeatPlayer.setAsset('assets/sounds/latidos.mp3').then((_) {
      _heartbeatPlayer.setLoopMode(LoopMode.one);
      _heartbeatPlayer.setVolume(0.6);
      _heartbeatPlayer.play();
    }).catchError((e) => debugPrint('Error latidos: $e'));

    // Vibración háptica sincronizada
    Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      if (!mounted || _currentPhase >= 6) {
        timer.cancel();
        _heartbeatPlayer.stop();
        return;
      }
      HapticFeedback.lightImpact();
      Future.delayed(const Duration(milliseconds: 150), () => HapticFeedback.mediumImpact());
    });
  }

  void _triggerSubliminal(String text) {
    if (!mounted) return;
    setState(() {
      _centerText = text;
      _showGlitch = true;
    });
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 70), () {
      if (mounted) {
        setState(() {
          _showGlitch = false;
          _centerText = '';
        });
      }
    });
  }

  Future<void> _typeText(String text, Function(String) onUpdate, {int speed = 60}) async {
    for (int i = 0; i <= text.length; i++) {
      if (!mounted) return;
      onUpdate(text.substring(0, i));
      if (Random().nextDouble() > 0.9) {
        // Glitch de tipeo
        onUpdate(text.substring(0, i) + r'_#$@');
        await Future.delayed(const Duration(milliseconds: 30));
      }
      await Future.delayed(Duration(milliseconds: speed));
    }
  }

  bool _isRebooting = false;
  List<String> _rebootLogs = [];

  Future<void> _skipIntro() async {
    setState(() {
      _isRebooting = true;
      _currentPhase = 6;
      _centerText = '';
      _leftText = '';
      _rightText = '';
    });

    final logs = [
      'purging_witness_os_memory...',
      'disconnecting_neural_link...',
      'saving_session_log: [SUITE_00]',
      'recalibrating_screen_orientation: PORTRAIT',
      'initializing_prologue_protocol...',
      'SYSTEM_REBOOT_STARTED'
    ];

    for (var log in logs) {
      if (!mounted) return;
      setState(() => _rebootLogs.add('>> $log'));
      // _playSFX('assets/sounds/glitch_09-226602.mp3', volume: 0.1); // Efecto eliminado
      await Future.delayed(const Duration(milliseconds: 400));
    }

    await Future.delayed(const Duration(seconds: 1));

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const PrologueTutorialScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 1500),
      ),
    );
  }

  @override
  void dispose() {
    _glitchController.dispose();
    _scanningController.dispose();
    _backgroundPlayer.dispose();
    _sfxPlayer.dispose();
    _heartbeatPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // HEAVY NOISE LAYER
          if (_currentPhase > 0)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _glitchController,
                builder: (context, child) {
                  return CustomPaint(
                    painter: HeavyNoisePainter(
                      intensity: (_currentPhase / 5.0) + (_showGlitch ? 0.4 : 0.0),
                      animValue: _glitchController.value,
                    ),
                  );
                },
              ),
            ),

          // SCANNING LINE (Erratic)
          AnimatedBuilder(
            animation: _scanningController,
            builder: (context, child) {
              final jitter = _showGlitch ? (Random().nextDouble() - 0.5) * 100 : 0.0;
              return Positioned(
                left: (_scanningController.value * MediaQuery.of(context).size.width) + jitter,
                top: 0,
                bottom: 0,
                child: Container(
                  width: _showGlitch ? 10 : 2,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: _showGlitch ? Colors.white : Colors.red.withOpacity(0.5),
                        blurRadius: _showGlitch ? 20 : 10,
                        spreadRadius: _showGlitch ? 5 : 2,
                      ),
                    ],
                    color: _showGlitch ? Colors.white : Colors.red.withOpacity(0.8),
                  ),
                ),
              );
            },
          ),

          // AMBIENT NOISE / VIGNETTE
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.9),
                  ],
                  stops: const [0.3, 1.0],
                ),
              ),
            ),
          ),

          // CONTENT
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60),
              child: _buildLayout(),
            ),
          ),

          // TERMINAL OVERLAY (UI)
          _buildTerminalUI(),

          // SKIP BUTTON
          Positioned(
            bottom: 30,
            right: 40,
            child: GestureDetector(
              onTap: _skipIntro,
              child: Text(
                'TERM_SESSION // SKIP',
                style: GoogleFonts.shareTechMono(
                  color: Colors.grey[800],
                  fontSize: 10,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          
          // BLOODY OVERLAY FLASH
          if (_showGlitch)
            Positioned.fill(
              child: Container(
                color: Colors.red.withOpacity(0.1),
              ),
            ),
          
          // REBOOT OVERLAY
          if (_isRebooting)
            Positioned.fill(
              child: Container(
                color: Colors.black,
                padding: const EdgeInsets.all(40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CRITICAL_SYSTEM_REBOOT',
                      style: GoogleFonts.shareTechMono(
                        color: Colors.red,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: _rebootLogs.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _rebootLogs[index],
                              style: GoogleFonts.shareTechMono(
                                color: Colors.greenAccent.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLayout() {
    if (_currentPhase == -1) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.amber.withOpacity(0.5), size: 40),
          const SizedBox(height: 20),
          Text(
            'ADVERTENCIA_DE_SEGURIDAD // PROTOCOLO_DE_ACCESO',
            style: GoogleFonts.shareTechMono(
              color: Colors.amber.withOpacity(0.7),
              fontSize: 14,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 30),
          _warningText('ESTA EXPERIENCIA CONTIENE LUCES INTERMITENTES Y EFECTOS DE GLITCH QUE PUEDEN AFECTAR A PERSONAS CON FOTOSENSIBILIDAD.'),
          const SizedBox(height: 12),
          _warningText('CONTIENE TEMÁTICAS PSICOLÓGICAS INTENSAS Y USO DE VIBRACIÓN HÁPTICA CONSTANTE.'),
          const SizedBox(height: 12),
          _warningText('SE RECOMIENDA EL USO DE AURICULARES PARA UNA INMERSIÓN TOTAL.'),
          const SizedBox(height: 40),
          Text(
            'INICIANDO_ENLACE...',
            style: GoogleFonts.shareTechMono(
              color: Colors.white24,
              fontSize: 10,
              letterSpacing: 4,
            ),
          ),
        ],
      );
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Opacity(
                opacity: _showGlitch ? 0.3 : 1.0,
                child: Text(
                  _leftText,
                  style: GoogleFonts.shareTechMono(
                    color: Colors.white70,
                    fontSize: 18,
                    letterSpacing: 1,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
            ),
            const SizedBox(width: 40),
            Expanded(
              child: Opacity(
                opacity: _showGlitch ? 0.3 : 1.0,
                child: Text(
                  _rightText,
                  style: GoogleFonts.shareTechMono(
                    color: const Color(0xFF8B0000),
                    fontSize: 18,
                    letterSpacing: 1,
                    shadows: [
                      Shadow(color: Colors.red.withOpacity(0.5), blurRadius: 8),
                    ],
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ],
        ),
        if (_centerText.isNotEmpty) ...[
          const SizedBox(height: 60),
          AnimatedBuilder(
            animation: _glitchController,
            builder: (context, child) {
              final jitter = _showGlitch ? (Random().nextDouble() - 0.5) * 40 : (Random().nextDouble() - 0.5) * 5;
              return Transform.translate(
                offset: Offset(jitter, 0),
                child: Text(
                  _centerText,
                  style: GoogleFonts.shareTechMono(
                    color: _showGlitch ? Colors.red : (_currentPhase == 5 ? Colors.white : Colors.grey[400]),
                    fontSize: _showGlitch ? 32 : (_currentPhase == 5 ? 24 : 20),
                    fontWeight: FontWeight.bold,
                    letterSpacing: _showGlitch ? 10 : 4,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildTerminalUI() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _terminalLabel('SYS_RECOVERY: ACTIVE'),
                  _terminalLabel(_showGlitch ? 'HELL_LINK: ESTABLISHED' : 'ENCRYPTION: AES_256_WITNESS'),
                ],
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _terminalLabel(_showGlitch ? 'EYE_OF_JUDGMENT: WATCHING' : 'LOC: UNKNOWN_NODE'),
                  _terminalLabel('SUBJECT: [REDACTED]'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _terminalLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.shareTechMono(
        color: Colors.white.withOpacity(0.1),
        fontSize: 10,
        letterSpacing: 1,
      ),
    );
  }

  Widget _warningText(String text) {
    return Text(
      text,
      style: GoogleFonts.shareTechMono(
        color: Colors.grey[500],
        fontSize: 11,
        letterSpacing: 1,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }
}

class HeavyNoisePainter extends CustomPainter {
  final double intensity;
  final double animValue;

  HeavyNoisePainter({required this.intensity, required this.animValue});

  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random((animValue * 1000).toInt());
    final paint = Paint();

    // Scanlines distorsionadas
    for (int i = 0; i < 50; i++) {
      paint.color = Colors.white.withOpacity(rand.nextDouble() * 0.05 * intensity);
      final y = rand.nextDouble() * size.height;
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, rand.nextDouble() * 2), paint);
    }

    // Bloques de color aleatorios (fugas de memoria)
    if (rand.nextDouble() < 0.2 * intensity) {
      paint.color = (rand.nextBool() ? Colors.red : Colors.blue).withOpacity(0.05 * intensity);
      canvas.drawRect(
        Rect.fromLTWH(
          rand.nextDouble() * size.width,
          rand.nextDouble() * size.height,
          rand.nextDouble() * 100,
          rand.nextDouble() * 20,
        ),
        paint,
      );
    }
    
    // Grano de película
    for (int i = 0; i < 1000 * intensity; i++) {
      paint.color = Colors.white.withOpacity(rand.nextDouble() * 0.1 * intensity);
      canvas.drawCircle(
        Offset(rand.nextDouble() * size.width, rand.nextDouble() * size.height),
        0.5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(HeavyNoisePainter oldDelegate) => true;
}

