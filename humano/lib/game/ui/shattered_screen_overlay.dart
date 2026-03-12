import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Overlay de pantalla fracturada que se intensifica con cada fragmento recolectado
/// Representa la pérdida progresiva de cordura del jugador
/// OPTIMIZADO para mejor rendimiento
class ShatteredScreenOverlay extends StatefulWidget {
  final int evidenceCollected; // 0-5
  final int totalEvidence; // Normalmente 5

  const ShatteredScreenOverlay({
    super.key,
    required this.evidenceCollected,
    required this.totalEvidence,
  });

  @override
  State<ShatteredScreenOverlay> createState() => _ShatteredScreenOverlayState();
}

class _ShatteredScreenOverlayState extends State<ShatteredScreenOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousEvidence = 0;
  final List<CrackPoint> _crackPoints = [];

  @override
  void initState() {
    super.initState();
    _previousEvidence = widget.evidenceCollected;
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void didUpdateWidget(ShatteredScreenOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Si recolectamos un nuevo fragmento, animar la fractura
    if (widget.evidenceCollected > _previousEvidence) {
      _addNewCrack();
      _controller.forward(from: 0.0);
      _triggerVibration();
      _previousEvidence = widget.evidenceCollected;
    }
  }

  void _addNewCrack() {
    final random = math.Random();
    
    // Generar puntos lejos del centro (donde está el jugador)
    // Probabilidad alta de que sea en los bordes
    double x, y;
    
    if (random.nextBool()) {
      // Borde izquierdo o derecho
      x = random.nextBool() ? random.nextDouble() * 0.25 : 0.75 + random.nextDouble() * 0.25;
      y = random.nextDouble(); // Cualquier altura
    } else {
      // Borde superior o inferior
      x = random.nextDouble(); // Cualquier ancho
      y = random.nextBool() ? random.nextDouble() * 0.25 : 0.75 + random.nextDouble() * 0.25;
    }

    _crackPoints.add(CrackPoint(
      x: x,
      y: y,
      seed: random.nextInt(1000),
    ));
  }

  void _triggerVibration() {
    // Vibración corta al quebrar la pantalla
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.evidenceCollected == 0) {
      return const SizedBox.shrink();
    }

    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: ShatteredGlassPainter(
              crackPoints: _crackPoints,
              animationValue: _animation.value,
            ),
            size: Size.infinite,
          );
        },
      ),
    );
  }
}

class CrackPoint {
  final double x; // 0.0 - 1.0
  final double y; // 0.0 - 1.0
  final int seed;

  CrackPoint({required this.x, required this.y, required this.seed});
}

/// Painter que dibuja grietas de vidrio roto en la pantalla
class ShatteredGlassPainter extends CustomPainter {
  final List<CrackPoint> crackPoints;
  final double animationValue;

  ShatteredGlassPainter({
    required this.crackPoints,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (crackPoints.isEmpty) return;

    // Dibujar penumbra negra progresiva (aumenta con cada fragmento)
    // OPTIMIZADO: Solo si hay 6+ fragmentos para mejor rendimiento
    // MÁS OSCURA para ambiente tenebroso
    if (crackPoints.length >= 6) {
      final adjustedIntensity = 0.55 + (crackPoints.length - 5) * 0.08; // 0.55 a 0.95 (MÁS OSCURO)
      
      // Penumbra negra desde los bordes
      final darknessPaint = Paint()
        ..shader = RadialGradient(
          center: Alignment.center,
          radius: 0.75, // Radio más pequeño = más oscuridad
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(adjustedIntensity * 0.7), // Más intenso
            Colors.black.withOpacity(adjustedIntensity),
          ],
          stops: const [0.2, 0.6, 1.0], // Transición más rápida
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      
      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        darknessPaint,
      );
    }

    // OPTIMIZACIÓN CRÍTICA: Limitar a máximo 8 puntos de impacto visibles
    // Si hay más, solo mostrar los últimos 8
    final startIndex = crackPoints.length > 8 ? crackPoints.length - 8 : 0;
    
    // Dibujar cada punto de fractura (cristal roto)
    for (int i = startIndex; i < crackPoints.length; i++) {
      final point = crackPoints[i];
      final impactPoint = Offset(size.width * point.x, size.height * point.y);
      
      // Solo animar el último punto agregado
      final isLatest = i == crackPoints.length - 1;
      final anim = isLatest ? animationValue : 1.0;
      
      _drawCrackFromPoint(canvas, size, impactPoint, point.seed, anim);
    }
  }

  void _drawCrackFromPoint(Canvas canvas, Size size, Offset impact, int seed, double anim) {
    final random = math.Random(seed);
    
    // ULTRA OPTIMIZADO: Mínimas operaciones para máximo rendimiento
    // SUTIL: Cristal oscuro y delgado para no romper el ambiente
    
    // UNA SOLA CAPA - Oscuro y delgado
    final crackPaint = Paint()
      ..color = Colors.white.withOpacity(0.15) // MUY SUTIL (antes 0.7)
      ..strokeWidth = 1.0 // MUY DELGADO (antes 2.5)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // REDUCIDO: 4-5 grietas (antes 6-8) para mejor rendimiento
    final radialCrackCount = 4 + random.nextInt(2);
    
    for (int i = 0; i < radialCrackCount; i++) {
      final baseAngle = (math.pi * 2 / radialCrackCount) * i;
      final angleVariation = (random.nextDouble() - 0.5) * 0.5;
      final angle = baseAngle + angleVariation;
      
      final length = (150 + random.nextDouble() * 250) * anim;
      
      final path = Path();
      path.moveTo(impact.dx, impact.dy);
      
      // REDUCIDO: 4 segmentos (antes 6) para mejor rendimiento
      final segments = 4;
      
      for (int seg = 1; seg <= segments; seg++) {
        final segmentProgress = seg / segments;
        final segmentLength = length * segmentProgress;
        
        // Desviación suave
        final deviation = math.sin(segmentProgress * math.pi * 2) * 8.0 * (1.0 - segmentProgress * 0.3);
        
        final nextX = impact.dx + math.cos(angle) * segmentLength + math.cos(angle + math.pi/2) * deviation;
        final nextY = impact.dy + math.sin(angle) * segmentLength + math.sin(angle + math.pi/2) * deviation;
        
        path.lineTo(nextX, nextY);
      }
      
      // Dibujar con UNA SOLA capa
      canvas.drawPath(path, crackPaint);
      
      // Ramificaciones - MUY REDUCIDAS (30% probabilidad)
      if (random.nextDouble() > 0.7) {
        final branchStart = 0.5 + random.nextDouble() * 0.3;
        final branchX = impact.dx + math.cos(angle) * length * branchStart;
        final branchY = impact.dy + math.sin(angle) * length * branchStart;
        
        final branchAngle = angle + (random.nextBool() ? 1 : -1) * (0.6 + random.nextDouble() * 0.5);
        final branchLength = length * (0.2 + random.nextDouble() * 0.2);
        
        final branchPath = Path();
        branchPath.moveTo(branchX, branchY);
        
        // REDUCIDO: 2 segmentos (antes 3)
        final branchSegments = 2;
        for (int seg = 1; seg <= branchSegments; seg++) {
          final segProgress = seg / branchSegments;
          final segLength = branchLength * segProgress;
          final deviation = (random.nextDouble() - 0.5) * 4.0;
          
          branchPath.lineTo(
            branchX + math.cos(branchAngle) * segLength + math.cos(branchAngle + math.pi/2) * deviation,
            branchY + math.sin(branchAngle) * segLength + math.sin(branchAngle + math.pi/2) * deviation,
          );
        }
        
        canvas.drawPath(branchPath, crackPaint..strokeWidth = 0.8); // MUY DELGADO (antes 1.8)
      }
    }
    
    // Anillos de impacto - MUY REDUCIDOS (1-2 anillos)
    final concentricCount = 1 + random.nextInt(2);
    for (int i = 0; i < concentricCount; i++) {
      final radius = (50 + i * 40 + random.nextDouble() * 20) * anim;
      final startAngle = random.nextDouble() * math.pi * 2;
      final arcLength = math.pi * 0.6 + random.nextDouble() * math.pi * 0.6;
      
      final arcPath = Path();
      // REDUCIDO: 4 segmentos (antes 6)
      final arcSegments = 4;
      for (int j = 0; j <= arcSegments; j++) {
        final currentAngle = startAngle + (arcLength * (j / arcSegments));
        final r = radius + math.sin(j * math.pi / 2) * 6;
        
        final x = impact.dx + math.cos(currentAngle) * r;
        final y = impact.dy + math.sin(currentAngle) * r;
        
        if (j == 0) {
          arcPath.moveTo(x, y);
        } else {
          arcPath.lineTo(x, y);
        }
      }
      
      canvas.drawPath(arcPath, crackPaint..strokeWidth = 0.8); // MUY DELGADO (antes 1.5)
    }
    
    // ELIMINADOS: Fragmentos pequeños (causan lag)
    // Solo dejamos las grietas y anillos principales
  }

  @override
  bool shouldRepaint(ShatteredGlassPainter oldDelegate) {
    return oldDelegate.crackPoints.length != crackPoints.length ||
        oldDelegate.animationValue != animationValue;
  }
}
