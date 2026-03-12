import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mind_hack_puzzle.dart';

class AudioSpectrumPuzzle extends MindHackPuzzle {
  final List<SoundWave> waves = [];
  bool isSolved = false;
  int truthsCaptured = 0;
  final int targetTruths = 3;
  double time = 0.0;
  
  static const Color egoColor = Color(0xFFD4AF37); // Dorado (Ego/Aplausos)
  static const Color truthColor = Color(0xFF00F0FF); // Cian (Verdad)

  AudioSpectrumPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  }) {
    _generateWaves();
  }

  @override
  String get title => "FILTRADO DE EXPECTRO";

  @override
  String get instruction => "TOCA LAS ONDAS CIAN PARA AISLAR LA VERDAD";

  void _generateWaves() {
    waves.clear();
    final rand = math.Random();
    // 5 Ego waves and some Truth waves that appear periodically
    for (int i = 0; i < 5; i++) {
        waves.add(SoundWave(
            id: "EGO_NOISE_${i + 1}",
            amplitude: 0.6 + rand.nextDouble() * 0.4,
            frequency: 1.5 + rand.nextDouble() * 2.0,
            isTruth: false,
            phase: rand.nextDouble() * math.pi * 2,
        ));
    }
    
    // Initial truth waves
    for (int i = 0; i < 2; i++) {
        _spawnTruthWave();
    }
  }

  void _spawnTruthWave() {
    final rand = math.Random();
    waves.add(SoundWave(
        id: "TRUTH_PULSE",
        amplitude: 0.8 + rand.nextDouble() * 0.2,
        frequency: 4.0 + rand.nextDouble() * 2.0,
        isTruth: true,
        phase: rand.nextDouble() * math.pi * 2,
    ));
  }

  @override
  void reset() {
    truthsCaptured = 0;
    _generateWaves();
    isSolved = false;
  }

  @override
  void update(double dt) {
    if (isSolved) return;
    super.update(dt);
    time += dt;

    // Movement and logic for waves
    for (var wave in waves) {
        wave.offset += dt * 50;
        if (wave.offset > gameRef.size.x + 100) {
            wave.offset = -100;
            if (wave.isTruth && !wave.isCaptured) {
                // If we missed a truth, maybe some penalty? 
                // For now just respawn to keep it active
            }
            wave.isCaptured = false;
        }
    }
  }

  @override
  void render(Canvas canvas) {
    final center = gameRef.size / 2;

    _drawText(canvas, "AISLAMIENTO DE ECO: ESTUDIO ECHO", Offset(center.x, 60), fontSize: 16, color: Colors.white, bold: true);
    _drawText(canvas, "FILTRA EL RUIDO DEL EGO PARA ESCUCHAR EL LATIDO REAL", Offset(center.x, 85), fontSize: 10, color: Colors.blueGrey);

    // Audio Visualizer Background
    final visualizerRect = Rect.fromCenter(center: center.toOffset().translate(0, 30), width: gameRef.size.x * 0.9, height: 300);
    canvas.drawRect(visualizerRect, Paint()..color = const Color(0xFF0D1117).withOpacity(0.8));
    
    // Draw Grid
    _drawSpectrumGrid(canvas, visualizerRect);

    // Draw Waves
    for (var wave in waves) {
        _drawWave(canvas, wave, visualizerRect);
    }

    // Progress
    _drawProgressBar(canvas, Offset(center.x, visualizerRect.bottom + 40), truthsCaptured / targetTruths);

    // Eliminamos el bloque de victoria intermedio para evitar estancamiento visual
  }

  void _drawSpectrumGrid(Canvas canvas, Rect rect) {
    final paint = Paint()..color = Colors.white10..strokeWidth = 1;
    for (double x = rect.left; x <= rect.right; x += rect.width / 10) {
        canvas.drawLine(Offset(x, rect.top), Offset(x, rect.bottom), paint);
    }
    for (double y = rect.top; y <= rect.bottom; y += rect.height / 6) {
        canvas.drawLine(Offset(rect.left, y), Offset(rect.right, y), paint);
    }
    // Zero line
    canvas.drawLine(Offset(rect.left, rect.center.dy), Offset(rect.right, rect.center.dy), 
        Paint()..color = Colors.white24..strokeWidth = 2);
  }

  void _drawWave(Canvas canvas, SoundWave wave, Rect rect) {
    if (wave.isCaptured) return;

    final paint = Paint()
      ..color = wave.isTruth ? truthColor : egoColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = wave.isTruth ? 3.0 : 1.0;

    final path = Path();
    bool first = true;
    
    for (double x = rect.left; x <= rect.right; x += 5) {
        final localX = (x - rect.left) / rect.width;
        // Pulse effect (heartbeat metaphor)
        final pulse = wave.isTruth ? (0.8 + 0.5 * math.pow(math.sin(time * 3), 4)) : 1.0;
        
        final y = rect.center.dy + math.sin(localX * wave.frequency * 10 + time * 2 + wave.phase) * (rect.height / 3) * wave.amplitude * pulse;
        
        if (first) {
            path.moveTo(x, y);
            first = false;
        } else {
            path.lineTo(x, y);
        }
    }
    
    // Add "Ghost" glow to Truth wave
    if (wave.isTruth) {
        canvas.drawPath(path, Paint()..color = truthColor.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 8.0);
    }
    
    canvas.drawPath(path, paint);
    
    // If it's the peak and it's truth, show a hint
    if (wave.isTruth) {
        final peakX = rect.left + (math.sin(time) * 0.5 + 0.5) * rect.width;
        // Note: peaks are hard to track with simple sine, but we just need a touch area
    }
  }

  void _drawProgressBar(Canvas canvas, Offset pos, double progress) {
    final width = 200.0;
    final rect = Rect.fromCenter(center: pos, width: width, height: 10);
    canvas.drawRect(rect, Paint()..color = Colors.white10);
    canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, width * progress, 10), Paint()..color = truthColor);
    _drawText(canvas, "CORRELACIÓN BIOLÓGICA: ${(progress * 100).toInt()}%", Offset(pos.dx, pos.dy + 25), fontSize: 10, color: truthColor);
  }

  void _drawText(Canvas canvas, String text, Offset pos, {double fontSize = 12, Color color = Colors.white, bool bold = false}) {
    final span = TextSpan(
      text: text,
      style: GoogleFonts.shareTechMono(
        color: color,
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        letterSpacing: 1.5,
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
    
    // In this revised version, we look for Truth waves. 
    // Since waves move/oscillate, the player just needs to tap the visualizer when a cian wave is dominant.
    bool captured = false;
    for (var wave in waves) {
        if (wave.isTruth && !wave.isCaptured) {
            // Check if the tap is anywhere in the visualizer when truth pulses
            final visualizerRect = Rect.fromCenter(center: (gameRef.size / 2).toOffset().translate(0, 30), width: gameRef.size.x * 0.9, height: 300);
            if (visualizerRect.contains(tapPos)) {
                // If they tap near the truth wave vertical range
                wave.isCaptured = true;
                truthsCaptured++;
                captured = true;
                
                if (truthsCaptured >= targetTruths) {
                    isSolved = true;
                    Future.delayed(const Duration(milliseconds: 600), () => onComplete());
                }
                break;
            }
        }
    }
    
    if (!captured) {
        // Penalty for tapping the ego noise?
        // onFail(); // Maybe too punishing, just ignore for now
    }
  }
}

class SoundWave {
  final String id;
  final double amplitude;
  final double frequency;
  final bool isTruth;
  final double phase;
  double offset = 0.0;
  bool isCaptured = false;

  SoundWave({required this.id, required this.amplitude, required this.frequency, required this.isTruth, required this.phase});
}
