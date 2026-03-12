import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Efectos visuales de habilidades del Algoritmo
/// Se muestran en la pantalla del Sujeto cuando es atacado
class AlgorithmEffectsOverlay extends StatefulWidget {
  final String effectType; // 'ping', 'glitch', 'lag'
  final Duration duration;

  const AlgorithmEffectsOverlay({
    super.key,
    required this.effectType,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<AlgorithmEffectsOverlay> createState() => _AlgorithmEffectsOverlayState();
}

class _AlgorithmEffectsOverlayState extends State<AlgorithmEffectsOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Timer _dismissTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _controller.forward();

    _dismissTimer = Timer(widget.duration, () {
      Navigator.of(context, rootNavigator: true).pop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _dismissTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            if (widget.effectType == 'ping')
              _buildPingEffect()
            else if (widget.effectType == 'glitch')
              _buildGlitchEffect()
            else if (widget.effectType == 'lag')
              _buildLagEffect(),
          ],
        );
      },
    );
  }

  /// SONDA: Vibración + Pulso visual suave
  Widget _buildPingEffect() {
    return Positioned.fill(
      child: CustomPaint(
        painter: PingEffectPainter(progress: _controller.value),
      ),
    );
  }

  /// GLITCH: Aberración cromática + Scanlines + Distorsión
  Widget _buildGlitchEffect() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Aberración cromática (Red/Cyan shift)
          Positioned.fill(
            child: CustomPaint(
              painter: ChromaticAberrationPainter(
                progress: _controller.value,
                offset: 3 * _controller.value,
              ),
            ),
          ),
          // Scanlines
          Positioned.fill(
            child: CustomPaint(
              painter: ScanlinesEffectPainter(progress: _controller.value),
            ),
          ),
          // Overlay oscuro
          Container(
            color: Colors.red.withOpacity(0.1 * (1 - _controller.value)),
          ),
        ],
      ),
    );
  }

  /// LAG: Congelamiento + Overlay + Icono reloj arena
  Widget _buildLagEffect() {
    return Positioned.fill(
      child: Stack(
        children: [
          // Overlay oscuro
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          // Reloj de arena + "LAG" text
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Transform.rotate(
                  angle: (_controller.value * 4 * math.pi) % (2 * math.pi),
                  child: const Text(
                    '⏸️',
                    style: TextStyle(fontSize: 60),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'LAG',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${((_controller.value) * 1500).toStringAsFixed(0)}ms',
                  style: TextStyle(
                    color: Colors.yellow,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Painter para efecto SONDA (ping)
class PingEffectPainter extends CustomPainter {
  final double progress;

  PingEffectPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    // Múltiples ondas
    for (int i = 0; i < 3; i++) {
      final delay = i * 0.33;
      final waveProgress = (progress - delay).clamp(0.0, 1.0);
      
      if (waveProgress > 0) {
        final radius = size.width * waveProgress;
        final opacity = (1 - waveProgress).clamp(0.0, 1.0);

        final paint = Paint()
          ..color = Colors.red.withOpacity(opacity * 0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        canvas.drawCircle(center, radius, paint);
      }
    }

    // Punto central
    final centerPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, centerPaint);
  }

  @override
  bool shouldRepaint(PingEffectPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Painter para aberración cromática (GLITCH)
class ChromaticAberrationPainter extends CustomPainter {
  final double progress;
  final double offset;

  ChromaticAberrationPainter({
    required this.progress,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Red shift
    final redPaint = Paint()
      ..color = Colors.red.withOpacity(0.3 * progress)
      ..blendMode = BlendMode.colorDodge;

    // Cyan shift
    final cyanPaint = Paint()
      ..color = Colors.cyan.withOpacity(0.3 * progress)
      ..blendMode = BlendMode.colorDodge;

    // Dibujar líneas de aberración
    for (int i = 0; i < size.height.toInt(); i += 10) {
      if (i % 20 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(0, i.toDouble(), size.width, 5),
          redPaint,
        );
        canvas.drawRect(
          Rect.fromLTWH(offset, i.toDouble(), size.width - offset, 5),
          cyanPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ChromaticAberrationPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.offset != offset;
  }
}

/// Painter para scanlines (GLITCH)
class ScanlinesEffectPainter extends CustomPainter {
  final double progress;

  ScanlinesEffectPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.green.withOpacity(0.1)
      ..strokeWidth = 1;

    for (double i = 0; i < size.height; i += 2) {
      if ((i + progress * 100) % 4 < 2) {
        canvas.drawLine(
          Offset(0, i),
          Offset(size.width, i),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(ScanlinesEffectPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Widget para congelar input durante LAG
class InputFreezerOverlay extends StatefulWidget {
  final Duration freezeDuration;

  const InputFreezerOverlay({
    super.key,
    this.freezeDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<InputFreezerOverlay> createState() => _InputFreezerOverlayState();
}

class _InputFreezerOverlayState extends State<InputFreezerOverlay> {
  late Timer _unfreezeTimer;
  bool _isFrozen = true;

  @override
  void initState() {
    super.initState();
    _unfreezeTimer = Timer(widget.freezeDuration, () {
      if (mounted) {
        setState(() => _isFrozen = false);
        Navigator.of(context, rootNavigator: true).pop();
      }
    });
  }

  @override
  void dispose() {
    _unfreezeTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _isFrozen,
      child: IgnorePointer(
        ignoring: _isFrozen,
        child: Container(),
      ),
    );
  }
}
