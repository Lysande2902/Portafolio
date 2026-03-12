import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../game/puzzle/effects/sound_manager.dart';
import '../providers/audio_provider.dart';

/// Pantalla de introducción cinematográfica antes de cada arco
class ArcIntroScreen extends StatefulWidget {
  final String arcId;
  final VoidCallback onComplete;

  const ArcIntroScreen({
    super.key,
    required this.arcId,
    required this.onComplete,
  });

  @override
  State<ArcIntroScreen> createState() => _ArcIntroScreenState();
}

class _ArcIntroScreenState extends State<ArcIntroScreen>
    with SingleTickerProviderStateMixin {
  late List<_IntroMessage> _messages;
  int _currentIndex = 0;
  int _currentCharIndex = 0;
  String _displayedText = '';
  Timer? _typewriterTimer;
  Timer? _bootTimer;
  Timer? _zoomTimer;
  bool _isTypewriterFinished = false;
  bool _onCompleteCalled = false;
  bool _isBooting = true;
  List<String> _bootText = [];
  int _bootLineIndex = 0;
  double _neuronalZoom = 15.0; // Start with extreme zoom (Idea 6)

  late AnimationController _glitchController;

  @override
  void initState() {
    super.initState();
    _messages = _getMessagesForArc();
    _glitchController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
    
    _startBootSequence();

    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    // Iniciar música del arco con fade-in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audio = Provider.of<AudioProvider>(context, listen: false);
      audio.playArcMusic(widget.arcId);
    });
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _bootTimer?.cancel();
    _zoomTimer?.cancel();
    _glitchController.dispose();
    // NO detenemos el audio aquí — el juego continua escuchando el mismo tema
    super.dispose();
  }

  List<_IntroMessage> _getMessagesForArc() {
    switch (widget.arcId) {
      case 'arc_0_inicio':
        return [
          _IntroMessage('ESTÁS EN COMA.', isSmall: false),
          _IntroMessage('Esto no es un sueño.', isSmall: true),
          _IntroMessage('EL JUICIO HA COMENZADO.', isSmall: false),
        ];
      case 'arc_1_envidia_lujuria':
        return [
          _IntroMessage('DOS CARAS.', isSmall: false),
          _IntroMessage('Solo una es tuya.', isSmall: true),
          _IntroMessage('¿CUÁL ES EL TUYO?', isSmall: false),
        ];
      case 'arc_2_consumo_codicia':
        return [
          _IntroMessage('CAJAS VACÍAS.', isSmall: false),
          _IntroMessage('Promesas rotas dentro.', isSmall: true),
          _IntroMessage('EL VACÍO NO SE LLENA.', isSmall: false),
        ];
      case 'arc_3_soberbia_pereza':
        return [
          _IntroMessage('LAS LUCES SE APAGARON.', isSmall: false),
          _IntroMessage('Los aplausos ya no existen.', isSmall: true),
          _IntroMessage('EL SHOW HA TERMINADO.', isSmall: false),
        ];
      case 'arc_4_ira':
        return [
          _IntroMessage('ALGUIEN LLAMA.', isSmall: false),
          _IntroMessage('Ya no puede esperar más.', isSmall: true),
          _IntroMessage('ERA TU HERMANO.', isSmall: false),
        ];
      default:
        return [
          _IntroMessage('ACCEDIENDO.', isSmall: false),
          _IntroMessage('Tu memoria está siendo leída.', isSmall: true),
          _IntroMessage('RECONSTRUCCIÓN EN CURSO.', isSmall: false),
        ];
    }
  }

  void _startBootSequence() {
    final fullBootLines = [
      '>> INITIALIZING WitnessOS v.4.0.2...',
      '>> MEMORY_NODE_ACCESS: GRANTED',
      '>> SCANNING NEURONAL_PATHWAYS...',
      '>> CHECKING PARITY_ERRORS... [FAILED]',
      '>> AUTO_CORRECTING... [OK]',
      '>> LOADING_CONSCIOUSNESS... 100%',
      '>> SUBJECT_ALEX_CONNECTED.',
    ];

    _bootTimer = Timer.periodic(const Duration(milliseconds: 150), (timer) {
      if (_bootLineIndex < fullBootLines.length) {
        setState(() {
          _bootText.add(fullBootLines[_bootLineIndex]);
          _bootLineIndex++;
        });
        SoundManager().playBlip();
      } else {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            setState(() => _isBooting = false);
            _startTypewriter();
          }
        });
      }
    });

    // Start Neuronal Zoom Out (Idea 6)
    _zoomTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (_neuronalZoom > 1.0) {
        setState(() {
          _neuronalZoom -= 0.15;
          if (_neuronalZoom < 1.0) _neuronalZoom = 1.0;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _startTypewriter() {
    _displayedText = '';
    _currentCharIndex = 0;
    _isTypewriterFinished = false;
    _typewriterTimer?.cancel();

    final text = _messages[_currentIndex].text;

    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_currentCharIndex < text.length) {
        setState(() {
          _currentCharIndex++;
          _displayedText = text.substring(0, _currentCharIndex);
        });
        if (_currentCharIndex % 3 == 0) {
          HapticFeedback.lightImpact();
          SoundManager().playBlip();
        }
      } else {
        timer.cancel();
        setState(() => _isTypewriterFinished = true);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted && _isTypewriterFinished) _nextMessage();
        });
      }
    });
  }

  void _nextMessage() {
    if (_currentIndex < _messages.length - 1) {
      setState(() {
        _currentIndex++;
        _startTypewriter();
      });
    } else {
      if (!_onCompleteCalled) {
        _onCompleteCalled = true;
        Future.delayed(const Duration(seconds: 2), widget.onComplete);
      }
    }
  }

  void _onTap() {
    if (!_isTypewriterFinished) {
      // Skip typewriter: mostrar texto completo
      _typewriterTimer?.cancel();
      setState(() {
        _displayedText = _messages[_currentIndex].text;
        _isTypewriterFinished = true;
      });
    } else {
      _nextMessage();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final msg = _messages[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _onTap,
        child: Stack(
          children: [
            // Neuronal Zoom Background Effect (Idea 6)
            Transform.scale(
              scale: _neuronalZoom,
              child: Opacity(
                opacity: _isBooting ? 0.3 : 1.0,
                child: Stack(
                  children: [
                    Positioned.fill(child: CustomPaint(painter: _NoisePainter())),
                    // Hex Code Stream on the side (Idea 8)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      width: size.width * 0.25,
                      child: _buildHexStream(),
                    ),
                  ],
                ),
              ),
            ),

            if (_isBooting)
              _buildBootScreen(size)
            else ...[
              // Latido de Conciencia
              Center(
                child: AnimatedBuilder(
                  animation: _glitchController,
                  builder: (context, child) {
                    final scale = 1.0 + (_glitchController.value * 0.15);
                    final opacity = 0.05 + (_glitchController.value * 0.05);
                    return Container(
                      width: 350 * scale,
                      height: 350 * scale,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(opacity),
                            blurRadius: 100,
                            spreadRadius: 50,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Texto con Vibración (Idea 7)
              _buildVibratingText(msg),

              // Indicador de avance
              if (_isTypewriterFinished && _currentIndex < _messages.length - 1)
                Positioned(
                  bottom: 60,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    opacity: 1.0,
                    duration: const Duration(milliseconds: 400),
                    child: Column(
                      children: [
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'toca para continuar',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.shareTechMono(
                            fontSize: 10,
                            color: Colors.white.withOpacity(0.3),
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Contador
              Positioned(
                top: 50,
                right: 30,
                child: Text(
                  '${_currentIndex + 1} / ${_messages.length}',
                  style: GoogleFonts.shareTechMono(
                    fontSize: 10,
                    color: Colors.white.withOpacity(0.2),
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],

            // REC Overlay (Idea 5)
            _buildRecOverlay(),

            // Scanlines
            Positioned.fill(
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.15,
                  child: CustomPaint(
                    painter: ScanlinePainter(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBootScreen(Size size) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(40),
        width: size.width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _bootText.map((line) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              line,
              style: GoogleFonts.shareTechMono(
                color: Colors.greenAccent,
                fontSize: 12,
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  Widget _buildRecOverlay() {
    return Positioned(
      top: 40,
      left: 30,
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _glitchController,
            builder: (context, child) {
              return Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _glitchController.value > 0.5 ? Colors.red : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            'REC',
            style: GoogleFonts.shareTechMono(
              color: Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHexStream() {
    return AnimatedBuilder(
      animation: _glitchController,
      builder: (context, child) {
        return Opacity(
          opacity: 0.1,
          child: Column(
            children: List.generate(40, (index) => Text(
              '0x${math.Random().nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0')}',
              style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 8),
            )),
          ),
        );
      },
    );
  }

  Widget _buildVibratingText(_IntroMessage msg) {
    return AnimatedBuilder(
      animation: _glitchController,
      builder: (context, child) {
        final randomOffset = Offset(
          (math.Random().nextDouble() - 0.5) * 2.0,
          (math.Random().nextDouble() - 0.5) * 2.0,
        );

        return Center(
          child: Transform.translate(
            offset: randomOffset,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Text(
                _displayedText,
                textAlign: TextAlign.center,
                style: msg.isSmall
                    ? GoogleFonts.shareTechMono(
                        fontSize: 20,
                        color: Colors.white.withOpacity(0.5),
                        height: 1.5,
                        letterSpacing: 2,
                      )
                    : GoogleFonts.shareTechMono(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        height: 1.3,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _IntroMessage {
  final String text;
  final bool isSmall;
  const _IntroMessage(this.text, {this.isSmall = false});
}

class _NoisePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Fondo negro
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF060606),
    );

    // Ruido muy sutil
    final rand = math.Random();
    final noisePaint = Paint()..color = Colors.white.withOpacity(0.008);
    for (int i = 0; i < 80; i++) {
      canvas.drawCircle(
        Offset(rand.nextDouble() * size.width, rand.nextDouble() * size.height),
        rand.nextDouble() * 1.5,
        noisePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 0.5;

    for (double i = 0; i < size.height; i += 4) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
