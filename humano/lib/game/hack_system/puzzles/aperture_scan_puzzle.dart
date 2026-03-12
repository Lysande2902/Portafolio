import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mind_hack_puzzle.dart';

class ApertureScanPuzzle extends MindHackPuzzle {
  double currentFocus = 0.2;
  final double targetFocus = 0.8;
  double exposure = 0.0;
  double time = 0.0;
  bool isSolved = false;
  
  static const Color primaryColor = Color(0xFFE5E5E5); // SOBERBIA - Blanco puro
  static const Color dangerColor = Color(0xFFFFCC00);

  ApertureScanPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "ESCANEO DE PERCEPCIÓN";

  @override
  String get instruction => "AJUSTA LA LENTE PARA ENFOCAR LA VERDAD";

  @override
  void reset() {
    currentFocus = 0.2;
    exposure = 0.0;
    isSolved = false;
  }

  @override
  void update(double dt) {
    if (isSolved) return;
    super.update(dt);
    time += dt;

    double focusError = (currentFocus - targetFocus).abs();
    
    // If we are close to the focus, build up exposure (revelation)
    if (focusError < 0.05) {
      exposure += dt * 0.4;
      if (exposure >= 1.0) {
        isSolved = true;
        Future.delayed(const Duration(milliseconds: 800), () => onComplete());
      }
    } else {
      // If we are way off, or passed the focus, we handle differently
      // Over-focus causes glare
      if (currentFocus > targetFocus + 0.1) {
          exposure = (exposure + dt * 0.2).clamp(0.0, 0.6); // Glare overhead
      } else {
          exposure = (exposure - dt * 2.0).clamp(0.0, 1.0);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final center = gameRef.size / 2;
    
    // UI Header
    _drawText(canvas, "ESCANEO DE PERCEPCIÓN: FOCO DE VERDAD", Offset(center.x, 60), fontSize: 16, color: Colors.white, bold: true);
    _drawText(canvas, "AJUSTA LA LENTE PARA REVELAR LA IDENTIDAD REAL", Offset(center.x, 85), fontSize: 10, color: Colors.blueGrey);

    // Camera Viewport
    final viewSize = 280.0;
    final viewRect = Rect.fromCenter(center: center.toOffset().translate(0, -20), width: viewSize, height: viewSize);
    
    // Viewport Background (Scanlines effect)
    canvas.drawRect(viewRect, Paint()..color = const Color(0xFF030303));
    
    // Draw procedural face silhouette
    _drawProceduralFace(canvas, viewRect, currentFocus);

    // Lens Overlays (Focus markers)
    _drawLensMarkers(canvas, viewRect);

    // Exposure Overlay (Blinding Pride / Glitch)
    if (exposure > 0.05) {
        canvas.drawRect(viewRect, Paint()..color = Colors.white.withOpacity(exposure * 0.95));
        
        // Glitch lines when exposure is high
        if (exposure > 0.7) {
            final rand = math.Random();
            for (int i = 0; i < 5; i++) {
                final y = viewRect.top + rand.nextDouble() * viewSize;
                canvas.drawLine(Offset(viewRect.left, y), Offset(viewRect.right, y), 
                    Paint()..color = Colors.cyan.withOpacity(0.5)..strokeWidth = 2);
            }
        }
    }

    // Slider UI
    _drawFocusSlider(canvas, Offset(center.x, center.y + 160), currentFocus);
    
    // Eliminamos el bloque de victoria intermedio para evitar estancamiento visual
  }

  void _drawProceduralFace(Canvas canvas, Rect rect, double focus) {
    final center = rect.center;
    final blur = (targetFocus - focus).abs() * 30.0;
    final opacity = (1.0 - (blur / 30.0)).clamp(0.1, 1.0);
    
    final paint = Paint()
      ..color = primaryColor.withOpacity(opacity)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    // Draw a "broken" face made of vector lines
    // Head
    for (int i = 0; i < 3; i++) {
        final jitter = (math.sin(time * 5 + i) * blur * 0.5);
        canvas.drawCircle(center.translate(jitter, -40), 40 + (i * 2), paint);
        
        // Eyes (Material Icons or simple shapes)
        canvas.drawCircle(center.translate(-20 + jitter, -50), 5, paint);
        canvas.drawCircle(center.translate(20 + jitter, -50), 5, paint);
        
        // Mouth
        canvas.drawArc(
          Rect.fromCenter(center: center.translate(jitter, -20), width: 30, height: 20),
          0, math.pi, false, paint
        );
    }
    
    if (blur < 2.0) {
        _drawText(canvas, "MATCH://REAL_IDENTITY", center.translate(0, -90), fontSize: 9, color: const Color(0xFF00FF41));
    }
  }

  void _drawLensMarkers(Canvas canvas, Rect rect) {
    final paint = Paint()..color = Colors.white24..style = PaintingStyle.stroke..strokeWidth = 1.0;
    final cornerSize = 20.0;
    
    // Corners
    canvas.drawLine(rect.topLeft, rect.topLeft + Offset(cornerSize, 0), paint);
    canvas.drawLine(rect.topLeft, rect.topLeft + Offset(0, cornerSize), paint);
    
    canvas.drawLine(rect.topRight, rect.topRight + Offset(-cornerSize, 0), paint);
    canvas.drawLine(rect.topRight, rect.topRight + Offset(0, cornerSize), paint);
    
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + Offset(cornerSize, 0), paint);
    canvas.drawLine(rect.bottomLeft, rect.bottomLeft + Offset(0, -cornerSize), paint);
    
    canvas.drawLine(rect.bottomRight, rect.bottomRight + Offset(-cornerSize, 0), paint);
    canvas.drawLine(rect.bottomRight, rect.bottomRight + Offset(0, -cornerSize), paint);
    
    // Center crosshair
    canvas.drawLine(rect.center - Offset(10, 0), rect.center + Offset(10, 0), paint);
    canvas.drawLine(rect.center - Offset(0, 10), rect.center + Offset(0, 10), paint);
  }

  void _drawFocusSlider(Canvas canvas, Offset pos, double value) {
    final width = 240.0;
    final rect = Rect.fromCenter(center: pos, width: width, height: 50);
    
    _drawText(canvas, "CONTROL DE APERTURA (F-STOP)", Offset(pos.dx, pos.dy - 40), fontSize: 9, color: Colors.blueGrey);

    // Track
    canvas.drawRect(Rect.fromLTWH(rect.left, pos.dy - 1, width, 2), Paint()..color = Colors.white24);
    
    // Graduation marks
    for (int i = 0; i <= 10; i++) {
        final x = rect.left + (i / 10 * width);
        canvas.drawLine(Offset(x, pos.dy - 5), Offset(x, pos.dy + 5), Paint()..color = Colors.white54);
    }

    // Handle
    final handleX = rect.left + (value * width);
    final handlePaint = Paint()..color = primaryColor;
    if ( (value - targetFocus).abs() < 0.05 ) {
        handlePaint.color = const Color(0xFF00FF41);
    }
    
    canvas.drawRect(Rect.fromCenter(center: Offset(handleX, pos.dy), width: 12, height: 30), handlePaint);
    canvas.drawRect(Rect.fromCenter(center: Offset(handleX, pos.dy), width: 14, height: 32), 
        Paint()..color = handlePaint.color.withOpacity(0.3)..style = PaintingStyle.stroke);
    
    _drawText(canvas, "APERTURA: f/${((1.0 - value) * 22).toStringAsFixed(1)}", Offset(pos.dx, pos.dy + 40), fontSize: 10, color: primaryColor);
  }

  void _drawText(Canvas canvas, String text, Offset pos, {double fontSize = 12, Color color = Colors.white, bool bold = false}) {
    final span = TextSpan(
      text: text,
      style: GoogleFonts.shareTechMono(
        color: color,
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        letterSpacing: 1.2,
      ),
    );
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isSolved) return;
    _updateFocus(event.localPosition.x);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (isSolved) return;
    _updateFocus(event.canvasEndPosition.x);
  }

  void _updateFocus(double localX) {
    final center = gameRef.size.x / 2;
    currentFocus = ((localX - (center - 120)) / 240).clamp(0.0, 1.0);
  }
}
