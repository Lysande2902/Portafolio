import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../mind_hack_puzzle.dart';

class GlitchTapperPuzzle extends MindHackPuzzle {
  final List<String> targetCodes = ["INIT", "EXEC", "ROOT", "SYNK", "GATE"];
  final List<GlitchTarget> activeTargets = [];
  
  int score = 0;
  final int targetScore = 8;
  double spawnTimer = 0.0;
  bool isSolved = false;

  GlitchTapperPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "PURGA DE NODOS";

  @override
  String get instruction => "TOCA LAS ANOMALÍAS ANTES DE QUE DESAPAREZCAN PARA DEPURAR EL SISTEMA";

  @override
  void reset() {
    activeTargets.clear();
    score = 0;
    spawnTimer = 0.0;
    isSolved = false;
  }

  @override
  void update(double dt) {
    if (isSolved) return;
    
    super.update(dt);
    spawnTimer += dt;
    
    if (spawnTimer > 1.0) {
      _spawnTarget();
      spawnTimer = 0.0;
    }

    // Update targets and remove expired
    for (int i = activeTargets.length - 1; i >= 0; i--) {
      activeTargets[i].life -= dt;
      if (activeTargets[i].life <= 0) {
        activeTargets.removeAt(i);
        onFail(); // Mistake if not tapped? Maybe too harsh.
      }
    }
  }

  void _spawnTarget() {
    final rand = math.Random();
    final size = gameRef.size;
    final code = targetCodes[rand.nextInt(targetCodes.length)];
    // Constrain spawning to safe central area
    final x = size.x * 0.15 + rand.nextDouble() * (size.x * 0.7);
    final y = size.y * 0.35 + rand.nextDouble() * (size.y * 0.45);
    
    activeTargets.add(GlitchTarget(
      code: code,
      pos: Offset(x, y),
      life: 2.0 + rand.nextDouble() * 1.5,
    ));
  }

  @override
  void render(Canvas canvas) {
    final size = gameRef.size;
    final center = size / 2;
    
    // 1. HEADER
    _drawText(canvas, "DEBUG_ACTIVE // PURGE_NODES", Offset(center.x, size.y * 0.08), 
        fontSize: 14, color: Colors.white, bold: true);
    
    // 2. PROGRESS
    final progress = score / targetScore;
    _drawText(canvas, "CLEANING: ${(progress * 100).toInt()}%", Offset(center.x, size.y * 0.12), 
        fontSize: 10, color: const Color(0xFF39FF14));

    // 3. TARGETS
    for (final target in activeTargets) {
      _drawTarget(canvas, target);
    }

    // Eliminamos el bloque isSolved para evitar estancamiento visual
  }

  void _drawTarget(Canvas canvas, GlitchTarget target) {
    final opacity = (target.life / 2.0).clamp(0.0, 1.0);
    final paint = Paint()
      ..color = const Color(0xFF39FF14).withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(target.pos, 30, paint);
    _drawText(canvas, target.code, target.pos, fontSize: 13, color: Colors.white.withOpacity(opacity));
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

  @override
  void onTapDown(TapDownEvent event) {
    if (isSolved) return;
    
    final tapPos = event.localPosition.toOffset();
    debugPrint('🖱️ [TAP] GlitchTapper Tap at: $tapPos');
    
    for (int i = 0; i < activeTargets.length; i++) {
        final rect = Rect.fromCenter(center: activeTargets[i].pos, width: 80, height: 40);
        if (rect.contains(tapPos)) {
            activeTargets.removeAt(i);
            score++;
            if (score >= targetScore) {
                isSolved = true;
                Future.delayed(const Duration(milliseconds: 500), () {
                    onComplete();
                });
            }
            return;
        }
    }
  }
}

class GlitchTarget {
  final String code;
  final Offset pos;
  double life;

  GlitchTarget({required this.code, required this.pos, required this.life});
}
