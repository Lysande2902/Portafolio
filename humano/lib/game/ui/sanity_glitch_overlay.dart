import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class SanityGlitchOverlay extends StatefulWidget {
  final ValueNotifier<double> sanityNotifier;

  const SanityGlitchOverlay({super.key, required this.sanityNotifier});

  @override
  State<SanityGlitchOverlay> createState() => _SanityGlitchOverlayState();
}

class _SanityGlitchOverlayState extends State<SanityGlitchOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final Random _random = Random();
  
  // Glitch properties
  double _glitchIntensity = 0.0;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100), // Fast update for noise
    )..repeat();
    
    widget.sanityNotifier.addListener(_updateIntensity);
  }
  
  void _updateIntensity() {
    // Calculate intensity based on sanity (inverse)
    // 1.0 sanity = 0.0 intensity
    // 0.0 sanity = 1.0 intensity
    // Only start showing effects below 0.8 sanity
    final sanity = widget.sanityNotifier.value;
    if (sanity > 0.8) {
      _glitchIntensity = 0.0;
    } else {
      // Map 0.8 -> 0.0 to 0.0 -> 1.0
      _glitchIntensity = (0.8 - sanity) / 0.8;
    }
    
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.sanityNotifier.removeListener(_updateIntensity);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_glitchIntensity <= 0.01) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return IgnorePointer(
          child: CustomPaint(
            painter: _GlitchEffectPainter(
              intensity: _glitchIntensity,
              random: _random,
              time: _controller.value,
            ),
            child: Container(),
          ),
        );
      },
    );
  }
}

class _GlitchEffectPainter extends CustomPainter {
  final double intensity;
  final Random random;
  final double time;

  _GlitchEffectPainter({
    required this.intensity,
    required this.random,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Static Noise (Grain)
    if (intensity > 0.2) {
      final paint = Paint()
        ..color = Colors.white.withOpacity(intensity * 0.15)
        ..style = PaintingStyle.fill;
        
      for (int i = 0; i < (size.width * size.height * 0.001 * intensity); i++) {
        final x = random.nextDouble() * size.width;
        final y = random.nextDouble() * size.height;
        final w = random.nextDouble() * 2 + 1;
        
        canvas.drawRect(Rect.fromLTWH(x, y, w, w), paint);
      }
    }
    
    // 2. Color Channel Shift (Chromatic Aberration simulation)
    // We simulate this by drawing random colored rectangles
    if (intensity > 0.4 && random.nextDouble() < intensity * 0.5) {
      final shiftPaint = Paint()
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.screen; // Additive blending
        
      // Red shift
      shiftPaint.color = Colors.red.withOpacity(intensity * 0.3);
      double h = random.nextDouble() * 50 + 10;
      double y = random.nextDouble() * size.height;
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, h), shiftPaint);
      
      // Blue shift
      shiftPaint.color = Colors.blue.withOpacity(intensity * 0.3);
      canvas.drawRect(Rect.fromLTWH(0, y + 5, size.width, h), shiftPaint);
    }
    
    // 3. Horizontal Glitch Lines (Scanlines)
    if (intensity > 0.1) {
      final linePaint = Paint()
        ..color = Colors.black.withOpacity(intensity * 0.2)
        ..style = PaintingStyle.fill;
        
      int lineCount = (intensity * 20).toInt();
      for (int i = 0; i < lineCount; i++) {
        double y = random.nextDouble() * size.height;
        double h = random.nextDouble() * 5 + 1;
        canvas.drawRect(Rect.fromLTWH(0, y, size.width, h), linePaint);
      }
    }
    
    // 4. Heavy Glitch Blocks (Severe sanity loss)
    if (intensity > 0.7 && random.nextDouble() < 0.3) {
      final blockPaint = Paint()
        ..color = Colors.white.withOpacity(random.nextDouble() * 0.5)
        ..style = PaintingStyle.fill
        ..blendMode = BlendMode.difference; // Invert colors
        
      double w = random.nextDouble() * 200 + 50;
      double h = random.nextDouble() * 200 + 50;
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height;
      
      canvas.drawRect(Rect.fromLTWH(x, y, w, h), blockPaint);
    }
    
    // 5. Vignette Pulse (Heartbeat effect)
    if (intensity > 0.5) {
      // Pulse speed increases with intensity
      double pulse = sin(time * pi * 2 * (1 + intensity * 2)) * 0.5 + 0.5;
      
      final vignettePaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(size.width / 2, size.height / 2),
          size.width * 0.8,
          [
            Colors.transparent,
            Colors.black.withOpacity(intensity * 0.8 * pulse),
          ],
          [0.2, 1.0],
        );
        
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignettePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _GlitchEffectPainter oldDelegate) {
    return true; // Always repaint for noise animation
  }
}
