import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Widget para efectos visuales de ataques del Algoritmo
class AlgorithmAttackEffects extends StatefulWidget {
  final String? currentAttack;
  final VoidCallback? onAttackComplete;

  const AlgorithmAttackEffects({
    super.key,
    this.currentAttack,
    this.onAttackComplete,
  });

  @override
  State<AlgorithmAttackEffects> createState() => _AlgorithmAttackEffectsState();
}

class _AlgorithmAttackEffectsState extends State<AlgorithmAttackEffects>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String? _previousAttack;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void didUpdateWidget(AlgorithmAttackEffects oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Detectar nuevo ataque
    if (widget.currentAttack != null && widget.currentAttack != _previousAttack) {
      _previousAttack = widget.currentAttack;
      _triggerAttackEffect(widget.currentAttack!);
    }
  }

  void _triggerAttackEffect(String attackType) async {
    _controller.forward(from: 0.0);

    switch (attackType) {
      case 'ping':
        // Vibración suave
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 300, amplitude: 128);
        }
        break;

      case 'glitch':
        // Vibración intermitente
        if (await Vibration.hasVibrator() ?? false) {
          for (int i = 0; i < 3; i++) {
            await Future.delayed(const Duration(milliseconds: 100));
            Vibration.vibrate(duration: 50, amplitude: 255);
          }
        }
        break;

      case 'lag':
        // Vibración fuerte y sostenida
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 500, amplitude: 255);
        }
        // Congelar input brevemente
        HapticFeedback.heavyImpact();
        break;
    }

    // Notificar cuando termine el efecto
    await Future.delayed(const Duration(milliseconds: 1500));
    widget.onAttackComplete?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentAttack == null) {
      return const SizedBox.shrink();
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        switch (widget.currentAttack) {
          case 'ping':
            return _buildPingEffect();
          case 'glitch':
            return _buildGlitchEffect();
          case 'lag':
            return _buildLagEffect();
          default:
            return const SizedBox.shrink();
        }
      },
    );
  }

  /// Efecto de PING - Ondas de vibración
  Widget _buildPingEffect() {
    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: PingEffectPainter(_controller.value),
        ),
      ),
    );
  }

  /// Efecto de GLITCH - Distorsión visual
  Widget _buildGlitchEffect() {
    final glitchOffset = (_controller.value * 20) * ((_controller.value * 10).floor() % 2 == 0 ? 1 : -1);
    
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // Chromatic aberration
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(glitchOffset, 0),
                child: Container(
                  color: Colors.red.withOpacity(0.1 * _controller.value),
                ),
              ),
            ),
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(-glitchOffset, 0),
                child: Container(
                  color: Colors.cyan.withOpacity(0.1 * _controller.value),
                ),
              ),
            ),
            // Scanlines
            Positioned.fill(
              child: CustomPaint(
                painter: ScanlinesPainter(_controller.value),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Efecto de LAG - Congelamiento visual
  Widget _buildLagEffect() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.black.withOpacity(0.3 * (1 - _controller.value)),
          child: Center(
            child: Opacity(
              opacity: 1 - _controller.value,
              child: Icon(
                Icons.hourglass_empty,
                size: 80,
                color: Colors.red.withOpacity(0.8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Painter para efecto de PING
class PingEffectPainter extends CustomPainter {
  final double progress;

  PingEffectPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width * 0.8;

    for (int i = 0; i < 3; i++) {
      final waveProgress = (progress + (i * 0.3)) % 1.0;
      final radius = maxRadius * waveProgress;
      final opacity = (1 - waveProgress) * 0.3;

      final paint = Paint()
        ..color = Colors.red.withOpacity(opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant PingEffectPainter oldDelegate) => true;
}

/// Painter para líneas de escaneo
class ScanlinesPainter extends CustomPainter {
  final double progress;

  ScanlinesPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1.0;

    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ScanlinesPainter oldDelegate) => false;
}
