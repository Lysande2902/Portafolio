import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';

/// TrueEndingScreen — Se activa al coleccionar los 15 fragmentos completos.
/// Es Victor hablando directamente. Sin filtros. El cierre definitivo.
class TrueEndingScreen extends StatefulWidget {
  const TrueEndingScreen({super.key});

  @override
  State<TrueEndingScreen> createState() => _TrueEndingScreenState();
}

class _TrueEndingScreenState extends State<TrueEndingScreen>
    with SingleTickerProviderStateMixin {
  late AudioPlayer _staticPlayer;
  late AnimationController _glitchController;
  int _currentPhase = 0;
  Timer? _phaseTimer;
  final Random _random = Random();

  // Voz de Víctor. Sin cólera. Peor: con calma.
  final List<_EndingBeat> _beats = [
    _EndingBeat(text: 'Ya lo leíste todo.', pauseMs: 3200),
    _EndingBeat(text: '', pauseMs: 1000),
    _EndingBeat(text: 'Los expedientes.', pauseMs: 2500),
    _EndingBeat(text: 'Los documentos.', pauseMs: 2500),
    _EndingBeat(text: 'Las 15 llamadas.', pauseMs: 3500, strong: true),
    _EndingBeat(text: '', pauseMs: 800),
    _EndingBeat(text: '¿Entiendes lo que eso significa?', pauseMs: 3500),
    _EndingBeat(text: '', pauseMs: 800),
    _EndingBeat(text: 'Que estabas ahí.', pauseMs: 3000),
    _EndingBeat(text: 'Que el teléfono sonó.', pauseMs: 3000),
    _EndingBeat(text: 'Que elegiste no contestar.', pauseMs: 4000, strong: true),
    _EndingBeat(text: '', pauseMs: 1500),
    _EndingBeat(text: 'No te pido que te odíes.', pauseMs: 3200),
    _EndingBeat(text: 'Eso sería fácil.', pauseMs: 2800),
    _EndingBeat(text: '', pauseMs: 1000),
    _EndingBeat(text: 'Te pido algo más difícil:', pauseMs: 3500),
    _EndingBeat(text: '', pauseMs: 800),
    _EndingBeat(text: 'Que no lo olvides.', pauseMs: 4500, strong: true),
    _EndingBeat(text: '', pauseMs: 2000),
    _EndingBeat(text: 'Cuando salgas de aquí,', pauseMs: 2800),
    _EndingBeat(text: 'cuando despiertes,', pauseMs: 2500),
    _EndingBeat(text: 'llama a alguien que te quiere de verdad.', pauseMs: 4500, strong: true),
    _EndingBeat(text: '', pauseMs: 1500),
    _EndingBeat(text: 'Antes de encender la cámara.', pauseMs: 4000),
    _EndingBeat(text: '', pauseMs: 2500),
    _EndingBeat(text: '— Víctor', pauseMs: 5000, isSignature: true),
  ];

  @override
  void initState() {
    super.initState();
    _initAudio();
    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    )..repeat(reverse: true);
    _startSequence();
  }

  void _initAudio() async {
    _staticPlayer = AudioPlayer();
    try {
      await _staticPlayer.setAsset('assets/audio/static.mp3');
      await _staticPlayer.setLoopMode(LoopMode.one);
      await _staticPlayer.setVolume(0.18); // Muy sutil — no es un horror show
      await _staticPlayer.play();
    } catch (e) {
      debugPrint('Audio static error: $e');
    }
  }

  void _startSequence() {
    _advanceBeat();
  }

  void _advanceBeat() {
    if (!mounted || _currentPhase >= _beats.length) {
      if (mounted) setState(() {}); // Mostrar botón final
      return;
    }

    final beat = _beats[_currentPhase];
    if (beat.strong) HapticFeedback.heavyImpact();

    Future.delayed(Duration(milliseconds: beat.pauseMs), () {
      if (!mounted) return;
      setState(() => _currentPhase++);
      _advanceBeat();
    });
  }

  @override
  void dispose() {
    _staticPlayer.dispose();
    _glitchController.dispose();
    _phaseTimer?.cancel();
    super.dispose();
  }

  bool get _isFinished => _currentPhase >= _beats.length;
  _EndingBeat? get _current =>
      _currentPhase < _beats.length ? _beats[_currentPhase] : null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Estática muy tenue de fondo
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glitchController,
              builder: (context, child) {
                return CustomPaint(
                  painter: StaticNoisePainter(
                    intensity: 0.08 + (_glitchController.value * 0.05),
                    seed: _random.nextInt(10000),
                  ),
                );
              },
            ),
          ),

          // El texto de Víctor — centrado, tranquilo, definitivo
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: AnimatedBuilder(
                animation: _glitchController,
                builder: (context, child) {
                  if (_current == null && !_isFinished) {
                    return const SizedBox.shrink();
                  }

                  final beat = _current;
                  if (beat == null) return const SizedBox.shrink();

                  final isGlitch = beat.strong && _random.nextDouble() > 0.88;
                  final glitchOffset = isGlitch ? (_random.nextDouble() * 6 - 3) : 0.0;

                  if (beat.text.isEmpty) return const SizedBox.shrink();

                  return Transform.translate(
                    offset: Offset(glitchOffset, 0),
                    child: Text(
                      beat.text,
                      textAlign: TextAlign.center,
                      style: beat.isSignature
                          ? GoogleFonts.ebGaramond(
                              fontSize: 28,
                              color: const Color(0xFF9E1A1A),
                              fontStyle: FontStyle.italic,
                              letterSpacing: 3,
                            )
                          : GoogleFonts.shareTechMono(
                              fontSize: beat.strong ? 22 : 17,
                              color: beat.strong
                                  ? Colors.white.withOpacity(0.95)
                                  : Colors.white.withOpacity(0.65),
                              fontWeight: beat.strong
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              letterSpacing: 1.5,
                              height: 1.6,
                              shadows: beat.strong
                                  ? [
                                      Shadow(
                                        color: const Color(0xFF9E1A1A).withOpacity(0.6),
                                        blurRadius: 20,
                                      ),
                                    ]
                                  : null,
                            ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Botón de salida — solo al final, muy discreto
          if (_isFinished)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: 1.0,
                  duration: const Duration(milliseconds: 2000),
                  child: TextButton(
                    onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
                    child: Text(
                      'CERRAR EL EXPEDIENTE',
                      style: GoogleFonts.shareTechMono(
                        color: Colors.white24,
                        fontSize: 11,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // "REC" parpadeando — siempre grabando
          Positioned(
            top: 30,
            right: 30,
            child: AnimatedBuilder(
              animation: _glitchController,
              builder: (context, _) {
                final visible = _random.nextDouble() > 0.3;
                return Opacity(
                  opacity: visible ? 0.5 : 0.15,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: Color(0xFF9E1A1A),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'REC',
                        style: GoogleFonts.shareTechMono(
                          color: const Color(0xFF9E1A1A),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EndingBeat {
  final String text;
  final int pauseMs;
  final bool strong;
  final bool isSignature;

  const _EndingBeat({
    required this.text,
    required this.pauseMs,
    this.strong = false,
    this.isSignature = false,
  });
}

/// Estática muy sutil — no es un jump scare, es un murmullo
class StaticNoisePainter extends CustomPainter {
  final double intensity;
  final int seed;

  StaticNoisePainter({required this.intensity, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);
    final paint = Paint();

    for (int i = 0; i < (size.width * size.height * intensity / 200).toInt(); i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final b = random.nextDouble();

      paint.color = Color.fromRGBO(
        (b * 255).toInt(),
        (b * 255).toInt(),
        (b * 255).toInt(),
        0.18,
      );
      canvas.drawCircle(Offset(x, y), 0.8, paint);
    }
  }

  @override
  bool shouldRepaint(StaticNoisePainter old) => true;
}
