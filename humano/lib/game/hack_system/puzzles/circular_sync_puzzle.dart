import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../mind_hack_puzzle.dart';

class CircularSyncPuzzle extends MindHackPuzzle {
  double rotation = 0.0;
  double targetRotation = 0.0;
  double speed = 2.0;
  
  int successCount = 0;
  final int targetSuccess = 3;
  
  bool isSolved = false;
  bool isError = false;
  final int difficulty;

  CircularSyncPuzzle({required super.onComplete, required super.onFail, this.difficulty = 0}) {
    _generateTarget();
  }

  @override
  String get title => "SINCRONIZACIÓN CIRCULAR";

  @override
  String get instruction => "TOCA CUANDO EL PUNTERO ESTÉ SOBRE EL NODO AZUL";

  void _generateTarget() {
    final rand = math.Random();
    targetRotation = rand.nextDouble() * math.pi * 2;
    // Escalar velocidad con dificultad
    double baseSpeed = 1.5 + (difficulty * 0.5);
    speed = baseSpeed + rand.nextDouble() * 2.0;
    if (rand.nextBool()) speed *= -1;
  }

  @override
  void reset() {
    successCount = 0;
    _generateTarget();
    isSolved = false;
  }

  @override
  void update(double dt) {
    if (isSolved) return;
    super.update(dt);
    
    rotation += speed * dt;
    if (rotation > math.pi * 2) rotation -= math.pi * 2;
    if (rotation < 0) rotation += math.pi * 2;
  }

  @override
  void render(Canvas canvas) {
    final size = gameRef.size;
    final center = size / 2;
    final radius = math.min(size.x, size.y) * 0.3;

    // 1. HEADER
    _drawText(canvas, "SINCRONIZACIÓN_DE_CONCIENCIA", Offset(center.x, size.y * 0.10), 
        fontSize: 16, color: Colors.white, bold: true);

    // 2. OUTER RING (Target)
    final targetPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10;
    canvas.drawCircle(center.toOffset(), radius, targetPaint);

    // Target Segment
    final segmentPaint = Paint()
      ..color = const Color(0xFF00F0FF).withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12;
    canvas.drawArc(
      Rect.fromCircle(center: center.toOffset(), radius: radius),
      targetRotation - 0.2,
      0.4,
      false,
      segmentPaint,
    );

    // 3. INNER RING (Player Pointer)
    final pointerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    
    final pointerX = center.x + math.cos(rotation) * radius;
    final pointerY = center.y + math.sin(rotation) * radius;
    canvas.drawCircle(Offset(pointerX, pointerY), 8, pointerPaint);
    
    // Line to center
    canvas.drawLine(center.toOffset(), Offset(pointerX, pointerY), Paint()..color = Colors.white12);

    // 4. PROGRESS
    _drawText(canvas, "RESONANCIA: $successCount/$targetSuccess", Offset(center.x, center.y + radius + 40), 
        fontSize: 12, color: const Color(0xFF00F0FF));

    _drawText(canvas, "PULSAR EN EL NODO AZUL", Offset(center.x, size.y * 0.85), 
        fontSize: 10, color: Colors.white24);

    if (isSolved) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), Paint()..color = Colors.black.withOpacity(0.8));
      _drawText(canvas, "ESTADO_ESTABLECIDO", center.toOffset(), fontSize: 24, color: const Color(0xFF39FF14), bold: true);
    }
  }

  void _drawText(Canvas canvas, String text, Offset pos, {double fontSize = 12, Color color = Colors.white, bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: fontSize, fontFamily: 'Courier', fontWeight: bold ? FontWeight.bold : FontWeight.normal),
      ),
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isSolved) return;
    
    // Check if rotation is close to targetRotation
    double diff = (rotation - targetRotation).abs();
    // Handle wrap around
    if (diff > math.pi) diff = (math.pi * 2) - diff;

    // Dificultad escalada: tolerancia más pequeña
    final tolerance = (0.45 - (difficulty * 0.05)).clamp(0.20, 0.45);

    if (diff < tolerance) {
      successCount++;
      if (successCount >= targetSuccess) {
        isSolved = true;
        Future.delayed(const Duration(milliseconds: 600), () => onComplete());
      } else {
        _generateTarget();
      }
    } else {
      // Small penalty? Or just fail?
      onFail();
      _generateTarget(); // Change target anyway to keep it dynamic
    }
  }
}
