import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mind_hack_puzzle.dart';

/// ExpiationSyntaxPuzzle — Acto 2 del Arco 4.
/// Alex debe escribir verdades dolorosas eligiendo la palabra correcta para
/// completar frases relacionadas con Víctor. El sistema rechaza las mentiras.
class ExpiationSyntaxPuzzle extends MindHackPuzzle {
  final List<Confession> confessions = [
    Confession(
      prompt: 'LO DEJÉ MORIR PORQUE...',
      options: ['GRABA', 'ESTABA EN VIVO', 'DORMÍA'],
      correct: 'ESTABA EN VIVO',
    ),
    Confession(
      prompt: 'VÍCTOR LLAMÓ...',
      options: ['UNA VEZ', 'NUNCA', '15 VECES'],
      correct: '15 VECES',
    ),
    Confession(
      prompt: 'YO ESTABA...',
      options: ['EN CASA', 'EN VIVO', 'DURMIENDO'],
      correct: 'EN VIVO',
    ),
    Confession(
      prompt: 'LAS LLAMADAS PERDIDAS...',
      options: ['LAS VÍ', 'LAS IGNORÉ', 'ERAN SPAM'],
      correct: 'LAS IGNORÉ',
    ),
    Confession(
      prompt: 'LO QUE NECESITO DECIR ES...',
      options: ['LO SIENTO', 'TENÍA TRABAJO', 'FUE SU CULPA'],
      correct: 'LO SIENTO',
    ),
  ];

  int _currentIndex = 0;
  bool isSolved = false;
  double animTime = 0.0;
  String? _feedbackText;
  bool _feedbackIsCorrect = false;
  double _feedbackTimer = 0.0;
  double _bgFlashTimer = 0.0;
  bool _bgFlash = false;
  final int difficulty;

  ExpiationSyntaxPuzzle({required super.onComplete, required super.onFail, this.difficulty = 0});

  @override
  String get title => "SINTAXIS DE EXPIACIÓN";

  @override
  String get instruction => "ESCRIBE LA VERDAD SELECCIONANDO LA OPCIÓN QUE COMPLETA CADA CONFESIÓN";

  @override
  void reset() {
    _currentIndex = 0;
    isSolved = false;
    _feedbackText = null;
  }

  @override
  void update(double dt) {
    super.update(dt);
    animTime += dt;

    if (_feedbackTimer > 0) {
      _feedbackTimer -= dt;
      if (_feedbackTimer <= 0) {
        _feedbackText = null;
      }
    }

    // Red flash on wrong answer
    if (_bgFlash) {
      _bgFlashTimer += dt;
      if (_bgFlashTimer > 0.3) {
        _bgFlash = false;
        _bgFlashTimer = 0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final size = gameRef.size;
    final center = size / 2;

    // Panic red-flash background
    if (_bgFlash) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y),
          Paint()..color = const Color(0xFFFF0000).withOpacity(0.25));
    }

    // Header
    _drawText(canvas, 'SINTAXIS DE EXPIACIÓN',
        Offset(center.x, size.y * 0.09), fontSize: 18, color: Colors.white, bold: true);
    _drawText(canvas, 'ESCRIBE LA VERDAD. EL SISTEMA RECHAZA LAS MENTIRAS.',
        Offset(center.x, size.y * 0.14), fontSize: 9, color: const Color(0xFFFF4444));

    // Victor silhouette / face ghost (ASCII style)
    _drawVictorFace(canvas, size, center);

    // Progress
    final progress = _currentIndex / confessions.length;
    _drawProgressBar(canvas, Offset(center.x, size.y * 0.27), progress);

    if (_currentIndex < confessions.length) {
      final conf = confessions[_currentIndex];

      // Prompt (glitching)
      _drawPrompt(canvas, size, center, conf.prompt);

      // Choices
      _drawChoices(canvas, size, center, conf.options);
    }

    // Feedback text
    if (_feedbackText != null) {
      final col = _feedbackIsCorrect ? const Color(0xFF00FF41) : const Color(0xFFFF2200);
      _drawText(canvas, _feedbackText!,
          Offset(center.x, size.y * 0.56), fontSize: 13, color: col, bold: true);
    }

    if (isSolved) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y),
          Paint()..color = Colors.black.withOpacity(0.88));
      _drawText(canvas, 'CONCIENCIA_EXPUESTA',
          center.toOffset().translate(0, -20), fontSize: 22, color: const Color(0xFF00FF41), bold: true);
      _drawText(canvas, '"LO SIENTO, VÍCTOR."',
          center.toOffset().translate(0, 15), fontSize: 14, color: Colors.white54);
    }
  }

  // --- Victor ghost: ASCII face drawn as broken lines ---
  void _drawVictorFace(Canvas canvas, Vector2 size, Vector2 center) {
    final glitch = math.sin(animTime * 8) * 3.0;
    final basePaint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Simple circle head
    canvas.drawCircle(Offset(center.x + glitch, size.y * 0.38), 38, basePaint);
    // Eyes
    canvas.drawCircle(Offset(center.x - 12 + glitch, size.y * 0.36), 4, basePaint);
    canvas.drawCircle(Offset(center.x + 12 + glitch, size.y * 0.36), 4, basePaint);
    // Mouth (sad arc)
    canvas.drawArc(
      Rect.fromCenter(center: Offset(center.x + glitch, size.y * 0.41), width: 22, height: 14),
      0, math.pi, false, basePaint,
    );
  }

  void _drawProgressBar(Canvas canvas, Offset pos, double progress) {
    const w = 200.0;
    canvas.drawRect(Rect.fromCenter(center: pos, width: w, height: 5),
        Paint()..color = Colors.white12);
    canvas.drawRect(
        Rect.fromLTWH(pos.dx - w / 2, pos.dy - 2.5, w * progress, 5),
        Paint()..color = const Color(0xFFFF4444));
    _drawText(canvas, 'VERDADES: $_currentIndex / ${confessions.length}',
        Offset(pos.dx, pos.dy + 16), fontSize: 8, color: Colors.white38);
  }

  void _drawPrompt(Canvas canvas, Vector2 size, Vector2 center, String prompt) {
    final y = size.y * 0.44;
    final glitch = math.sin(animTime * 15) * 2.0;

    // Frame
    canvas.drawRect(
      Rect.fromCenter(center: Offset(center.x, y), width: size.x * 0.88, height: 52),
      Paint()..color = Colors.white.withOpacity(0.08)..style = PaintingStyle.stroke,
    );

    // Shadow / chromatic abberation
    _drawText(canvas, prompt, Offset(center.x + glitch + 2, y + 1),
        fontSize: 16, color: const Color(0xFFFF0000).withOpacity(0.4), bold: true);
    _drawText(canvas, prompt, Offset(center.x + glitch, y),
        fontSize: 16, color: const Color(0xFF00FF41), bold: true);
  }

  void _drawChoices(Canvas canvas, Vector2 size, Vector2 center, List<String> opts) {
    final startY = size.y * 0.62;
    const btnH = 40.0;
    const btnW = 240.0;
    const gap = 50.0;

    for (int i = 0; i < opts.length; i++) {
      final pos = Offset(center.x, startY + i * gap);
      final rect = Rect.fromCenter(center: pos, width: btnW, height: btnH);

      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          Paint()..color = Colors.white.withOpacity(0.04));
      canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          Paint()..color = Colors.white30..style = PaintingStyle.stroke..strokeWidth = 1.0);

      _drawText(canvas, opts[i], pos, fontSize: 12, color: Colors.white70);
    }
  }

  void _drawText(Canvas canvas, String text, Offset pos,
      {double fontSize = 12, Color color = Colors.white, bool bold = false}) {
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
    if (isSolved || _feedbackTimer > 0) return;

    final tap = event.localPosition.toOffset();
    final size = gameRef.size;
    final center = size / 2;
    final startY = size.y * 0.62;
    const btnH = 40.0;
    const btnW = 240.0;
    const gap = 50.0;

    final conf = confessions[_currentIndex];

    for (int i = 0; i < conf.options.length; i++) {
      final pos = Offset(center.x, startY + i * gap);
      final rect = Rect.fromCenter(center: pos, width: btnW, height: btnH + 5);

      if (rect.contains(tap)) {
        _onOptionSelected(conf.options[i], conf.correct);
        return;
      }
    }
  }

  void _onOptionSelected(String chosen, String correct) {
    if (chosen == correct) {
      _feedbackText = '✓ VERDAD ACEPTADA';
      _feedbackIsCorrect = true;
      _feedbackTimer = 0.5;
      _currentIndex++;
      if (_currentIndex >= confessions.length) {
        isSolved = true;
        Future.delayed(const Duration(milliseconds: 700), () => onComplete());
      }
    } else {
      _feedbackText = '✗ MENTIRA DETECTADA — SISTEMA RECHAZADO';
      _feedbackIsCorrect = false;
      _feedbackTimer = 0.8;
      _bgFlash = true;
      _bgFlashTimer = 0.0;
      onFail();
    }
  }
}

class Confession {
  final String prompt;
  final List<String> options;
  final String correct;

  const Confession({required this.prompt, required this.options, required this.correct});
}
