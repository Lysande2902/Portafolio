import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Overlay de efectos visuales para crear tensión e incomodidad
/// Se intensifica cuando la cordura baja o el enemigo está cerca
class TensionEffectsOverlay extends StatefulWidget {
  final double sanity; // 0.0 - 1.0
  final bool enemyNearby; // Si el enemigo está cerca
  
  const TensionEffectsOverlay({
    super.key,
    required this.sanity,
    this.enemyNearby = false,
  });

  @override
  State<TensionEffectsOverlay> createState() => _TensionEffectsOverlayState();
}

class _TensionEffectsOverlayState extends State<TensionEffectsOverlay>
    with TickerProviderStateMixin {
  late AnimationController _glitchController;
  late AnimationController _vignetteController;
  late AnimationController _scanlineController;
  
  @override
  void initState() {
    super.initState();
    
    // Glitch effect - más rápido con baja cordura
    _glitchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..repeat(reverse: true);
    
    // Vignette pulse - late más rápido con baja cordura
    _vignetteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    // Scanlines - movimiento constante
    _scanlineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }
  
  @override
  void dispose() {
    _glitchController.dispose();
    _vignetteController.dispose();
    _scanlineController.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(TensionEffectsOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Ajustar velocidad de efectos según cordura
    if (widget.sanity != oldWidget.sanity) {
      _updateEffectSpeed();
    }
  }
  
  void _updateEffectSpeed() {
    // Más rápido cuando la cordura es baja
    final speed = 1.0 + (1.0 - widget.sanity) * 2.0; // 1x a 3x speed
    
    _glitchController.duration = Duration(milliseconds: (150 / speed).round());
    _vignetteController.duration = Duration(milliseconds: (1500 / speed).round());
  }
  
  @override
  Widget build(BuildContext context) {
    // Calcular intensidad de efectos
    final lowSanity = widget.sanity < 0.5;
    final criticalSanity = widget.sanity < 0.3;
    final intensity = 1.0 - widget.sanity; // 0.0 = alta cordura, 1.0 = baja cordura
    
    return IgnorePointer(
      child: Stack(
        children: [
          // Vignette oscuro (más intenso con baja cordura)
          _buildVignette(intensity),
          
          // Glitch effect (solo con baja cordura)
          if (lowSanity) _buildGlitchEffect(intensity),
          
          // Scanlines (más visibles con baja cordura)
          if (lowSanity) _buildScanlines(intensity),
          
          // Distorsión RGB (solo con cordura crítica)
          if (criticalSanity) _buildRGBDistortion(intensity),
          
          // Parpadeo de pantalla (solo con cordura crítica o enemigo cerca)
          if (criticalSanity || widget.enemyNearby) _buildScreenFlicker(intensity),
          
          // Borde rojo pulsante (cuando enemigo está cerca)
          if (widget.enemyNearby) _buildDangerBorder(),
        ],
      ),
    );
  }
  
  /// Vignette oscuro en los bordes
  Widget _buildVignette(double intensity) {
    return AnimatedBuilder(
      animation: _vignetteController,
      builder: (context, child) {
        final pulse = _vignetteController.value * 0.1; // Pulso sutil
        final vignetteIntensity = (0.3 + intensity * 0.5 + pulse).clamp(0.0, 0.9);
        
        return Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 1.0,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(vignetteIntensity),
              ],
              stops: const [0.3, 1.0],
            ),
          ),
        );
      },
    );
  }
  
  /// Efecto de glitch/distorsión
  Widget _buildGlitchEffect(double intensity) {
    return AnimatedBuilder(
      animation: _glitchController,
      builder: (context, child) {
        // Glitch aleatorio
        final random = math.Random(_glitchController.value.hashCode);
        final shouldGlitch = random.nextDouble() < intensity * 0.3; // 30% chance con baja cordura
        
        if (!shouldGlitch) return const SizedBox.shrink();
        
        final offset = random.nextDouble() * 10 * intensity;
        
        return Transform.translate(
          offset: Offset(offset, 0),
          child: Container(
            color: Colors.white.withOpacity(0.05 * intensity),
          ),
        );
      },
    );
  }
  
  /// Líneas de escaneo (efecto CRT)
  Widget _buildScanlines(double intensity) {
    return AnimatedBuilder(
      animation: _scanlineController,
      builder: (context, child) {
        return CustomPaint(
          painter: _ScanlinePainter(
            progress: _scanlineController.value,
            intensity: intensity * 0.3,
          ),
          child: Container(),
        );
      },
    );
  }
  
  /// Distorsión RGB (aberración cromática)
  Widget _buildRGBDistortion(double intensity) {
    return AnimatedBuilder(
      animation: _glitchController,
      builder: (context, child) {
        final random = math.Random(_glitchController.value.hashCode);
        final shouldDistort = random.nextDouble() < 0.5;
        
        if (!shouldDistort) return const SizedBox.shrink();
        
        return Stack(
          children: [
            // Canal rojo
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(-2 * intensity, 0),
                child: Container(
                  color: Colors.red.withOpacity(0.1 * intensity),
                ),
              ),
            ),
            // Canal azul
            Positioned.fill(
              child: Transform.translate(
                offset: Offset(2 * intensity, 0),
                child: Container(
                  color: Colors.blue.withOpacity(0.1 * intensity),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// Parpadeo de pantalla
  Widget _buildScreenFlicker(double intensity) {
    return AnimatedBuilder(
      animation: _glitchController,
      builder: (context, child) {
        final random = math.Random(_glitchController.value.hashCode);
        final shouldFlicker = random.nextDouble() < intensity * 0.2;
        
        if (!shouldFlicker) return const SizedBox.shrink();
        
        return Container(
          color: Colors.black.withOpacity(0.3 * intensity),
        );
      },
    );
  }
  
  /// Borde rojo pulsante cuando el enemigo está cerca
  Widget _buildDangerBorder() {
    return AnimatedBuilder(
      animation: _vignetteController,
      builder: (context, child) {
        final pulse = (_vignetteController.value * 0.5 + 0.5); // 0.5 - 1.0
        
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.red.withOpacity(0.4 * pulse),
              width: 4 * pulse,
            ),
          ),
        );
      },
    );
  }
}

/// Painter para líneas de escaneo
class _ScanlinePainter extends CustomPainter {
  final double progress;
  final double intensity;
  
  _ScanlinePainter({
    required this.progress,
    required this.intensity,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(intensity)
      ..strokeWidth = 1.0;
    
    // Dibujar líneas horizontales
    for (double y = 0; y < size.height; y += 4) {
      final offset = (progress * size.height) % size.height;
      final lineY = (y + offset) % size.height;
      canvas.drawLine(
        Offset(0, lineY),
        Offset(size.width, lineY),
        paint,
      );
    }
  }
  
  @override
  bool shouldRepaint(_ScanlinePainter oldDelegate) {
    return progress != oldDelegate.progress || intensity != oldDelegate.intensity;
  }
}
