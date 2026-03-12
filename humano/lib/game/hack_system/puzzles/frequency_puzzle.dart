import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../mind_hack_puzzle.dart';

class FrequencyPuzzle extends MindHackPuzzle {
  double targetFreq = 2.0;
  double targetAmp = 50.0;
  
  double currentFreq = 1.0;
  double currentAmp = 30.0;
  
  double time = 0.0;
  bool isSolved = false;
  final int difficulty;

  FrequencyPuzzle({required super.onComplete, required super.onFail, this.difficulty = 0}) {
    _randomizeTarget();
  }

  @override
  String get title => "SINTONÍA EMOCIONAL";

  @override
  String get instruction => "AJUSTA LA FRECUENCIA E INTENSIDAD PARA QUE COINCIDA CON LA ONDA ROJA";

  void _randomizeTarget() {
    final rand = math.Random();
    targetFreq = 1.5 + rand.nextDouble() * 3.0;
    targetAmp = 40.0 + rand.nextDouble() * 40.0;
    currentFreq = 1.0;
    currentAmp = 20.0;
  }

  @override
  void reset() {
    _randomizeTarget();
    isSolved = false;
  }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;
    
    // Check if matched
    if (!isSolved) {
      final freqDiff = (currentFreq - targetFreq).abs();
      final ampDiff = (currentAmp - targetAmp).abs();

      // Dificultad escalada: margen de error más pequeño
      final freqTolerance = (0.15 - (difficulty * 0.015)).clamp(0.04, 0.15);
      final ampTolerance = (8.0 - (difficulty * 0.5)).clamp(3.0, 8.0);
      
      if (freqDiff < freqTolerance && ampDiff < ampTolerance) {
        isSolved = true;
        Future.delayed(const Duration(milliseconds: 500), () {
          onComplete();
        });
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final size = gameRef.size;
    final center = size / 2;
    final graphWidth = size.x * 0.92;
    final graphHeight = size.y * 0.25;
    final graphRect = Rect.fromCenter(center: Offset(center.x, size.y * 0.28), width: graphWidth, height: graphHeight);

    // 1. MINIMAL GRAPH BOX
    canvas.drawRect(graphRect, Paint()..color = Colors.white10..style = PaintingStyle.stroke);
    
    // Internal Grid (Very faint)
    final gridPaint = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 0.5;
    for (double x = graphRect.left; x < graphRect.right; x += graphWidth / 10) {
      canvas.drawLine(Offset(x, graphRect.top), Offset(x, graphRect.bottom), gridPaint);
    }
    for (double y = graphRect.top; y < graphRect.bottom; y += graphHeight / 6) {
      canvas.drawLine(Offset(graphRect.left, y), Offset(graphRect.right, y), gridPaint);
    }

    // 2. OSCILLOSCOPE WAVES
    // Target Wave (Faint red)
    _drawOscilloscopeWave(canvas, graphRect, targetFreq, targetAmp, Colors.red.withOpacity(0.4), time, isGlitching: true);
    
    // Player Wave (Cyan)
    final waveColor = isSolved ? const Color(0xFF39FF14) : const Color(0xFF00F0FF);
    _drawOscilloscopeWave(canvas, graphRect, currentFreq, currentAmp, waveColor, time);

    // 3. UI LABELS
    _drawText(canvas, "SINTONÍA_EMOCIONAL", Offset(center.x, size.y * 0.08), 
        fontSize: 14, color: Colors.white, bold: true);
    
    _drawText(canvas, "ESTADO: ${isSolved ? 'ESTABLE' : 'INESTABLE'}", Offset(center.x, graphRect.bottom + 20), 
        fontSize: 10, color: isSolved ? const Color(0xFF39FF14) : Colors.redAccent);

    // 4. CONTROLS
    _drawControls(canvas, center);
    
    if (isSolved) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), Paint()..color = Colors.black.withOpacity(0.8));
      _drawText(canvas, "CONCIENCIA_SINTONIZADA", center.toOffset(), fontSize: 24, color: const Color(0xFF39FF14), bold: true);
    }
  }

  void _drawOscilloscopeWave(Canvas canvas, Rect rect, double freq, double amp, Color color, double t, {bool isGlitching = false}) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    for (double x = 0; x <= rect.width; x += 5) {
      final y = math.sin((x / rect.width) * freq * 2 * math.pi + t * 4) * amp;
      if (x == 0) path.moveTo(rect.left + x, rect.top + rect.height / 2 + y);
      else path.lineTo(rect.left + x, rect.top + rect.height / 2 + y);
    }
    canvas.drawPath(path, paint);
  }

  void _drawText(Canvas canvas, String text, Offset pos, {double fontSize = 12, Color color = Colors.white, bool bold = false}) {
    final span = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: 'Courier',
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
    );
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawControls(Canvas canvas, Vector2 center) {
    final size = gameRef.size;
    final startY = size.y * 0.70;
    
    final btnW = math.min(size.x * 0.20, 75.0);
    final btnH = 40.0;

    // Labels
    _drawText(canvas, "FRECUENCIA", Offset(center.x - size.x * 0.20, startY - 40), fontSize: 10, color: Colors.blueGrey);
    _drawText(canvas, "INTENSIDAD", Offset(center.x + size.x * 0.20, startY - 40), fontSize: 10, color: Colors.blueGrey);

    // Buttons
    _drawSimpleButton(canvas, "-", Offset(center.x - size.x * 0.30, startY), Size(btnW, btnH));
    _drawSimpleButton(canvas, "+", Offset(center.x - size.x * 0.10, startY), Size(btnW, btnH));
    
    _drawSimpleButton(canvas, "BAJA", Offset(center.x + size.x * 0.10, startY), Size(btnW, btnH));
    _drawSimpleButton(canvas, "ALTA", Offset(center.x + size.x * 0.30, startY), Size(btnW, btnH));

    final statsText = "F: ${currentFreq.toStringAsFixed(1)} | I: ${currentAmp.toInt()}";
    _drawText(canvas, statsText, Offset(center.x, startY + 60), fontSize: 13, color: const Color(0xFF00F0FF));
  }

  void _drawSimpleButton(Canvas canvas, String label, Offset pos, Size size) {
    final rect = Rect.fromCenter(center: pos, width: size.width, height: size.height);
    canvas.drawRect(rect, Paint()..color = Colors.white10..style = PaintingStyle.stroke);
    _drawText(canvas, label, pos, fontSize: 14, color: Colors.white, bold: true);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isSolved) return;
    
    debugPrint('🖱️ [TAP] FrequencyPuzzle Tap at: ${event.localPosition}');
    
    final size = gameRef.size;
    final center = size / 2;
    final tapX = event.localPosition.x;
    final tapY = event.localPosition.y;
    final startY = size.y * 0.70;
    final btnW = math.min(size.x * 0.20, 70.0);
    final btnH = 40.0;

    if ((tapY - startY).abs() < btnH / 2 + 10) {
      if ((tapX - (center.x - size.x * 0.30)).abs() < btnW / 2) {
        currentFreq = math.max(0.5, currentFreq - 0.2);
      } else if ((tapX - (center.x - size.x * 0.10)).abs() < btnW / 2) {
        currentFreq = math.min(8.0, currentFreq + 0.2);
      } else if ((tapX - (center.x + size.x * 0.10)).abs() < btnW / 2) {
        currentAmp = math.max(10.0, currentAmp - 5.0);
      } else if ((tapX - (center.x + size.x * 0.30)).abs() < btnW / 2) {
        currentAmp = math.min(90.0, currentAmp + 5.0);
      }
    }
  }
}
