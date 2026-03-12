import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../mind_hack_puzzle.dart';

class SharpFracturePuzzle extends MindHackPuzzle with TapCallbacks {
  final List<MemoryShard> shards = [];
  bool isSolved = false;
  int connectedCount = 0;
  final int targetConnected = 6;
  
  // Tactical Colors
  static const Color bloodColor = Color(0xFFAA0000);
  static const Color fragmentColor = Color(0xFFC0C0C0);

  SharpFracturePuzzle({required super.onComplete, required super.onFail}) {
    _initShards();
  }

  @override
  String get title => "FRACTURA NEURONAL";

  @override
  String get instruction => "REÚNE LOS FRAGMENTOS ROTOS TOCÁNDOLOS PARA RECONSTRUIR LA MEMORIA";

  void _initShards() {
    shards.clear();
    final rand = math.Random();
    final center = Offset(gameRef.size.x / 2, gameRef.size.y / 2 + 50);
    
    for (int i = 0; i < targetConnected; i++) {
        shards.add(MemoryShard(
            id: "SHARD_$i",
            pos: Offset(50 + rand.nextDouble() * (gameRef.size.x - 100), 150 + rand.nextDouble() * (gameRef.size.y - 300)),
            targetPos: Offset(center.dx + math.cos(i * 2 * math.pi / targetConnected) * 80, 
                               center.dy + math.sin(i * 2 * math.pi / targetConnected) * 80)
        ));
    }
  }

  @override
  void reset() {
    _initShards();
    connectedCount = 0;
    isSolved = false;
  }

  @override
  void update(double dt) {
    if (isSolved) return;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    final center = gameRef.size / 2;
    
    _drawText(canvas, "ESPEJO DE SANGRE: FRACTURA NEURONAL", Offset(center.x, 80), fontSize: 18, color: Colors.white, bold: true);
    _drawText(canvas, "REÚNE LOS FRAGMENTOS ROTOS DE LA VERDAD DE VÍCTOR", Offset(center.x, 105), fontSize: 10, color: Colors.blueGrey);

    // Target Silhouette (Ghostly circle in the center)
    final circleRect = Rect.fromCenter(center: Offset(center.x, center.y + 50), width: 180, height: 180);
    canvas.drawOval(circleRect, Paint()..color = bloodColor.withOpacity(0.05));
    canvas.drawOval(circleRect, Paint()..color = bloodColor.withOpacity(0.2)..style = PaintingStyle.stroke..strokeWidth = 1);

    // Draw lines connecting connected shards
    final linePaint = Paint()..color = bloodColor.withOpacity(0.3)..strokeWidth = 2;
    for (int i = 0; i < shards.length; i++) {
        if (shards[i].isConnected) {
            canvas.drawLine(shards[i].pos, Offset(center.x, center.y + 50), linePaint);
        }
    }

    // Shards
    for (final shard in shards) {
      _drawShard(canvas, shard);
    }

    if (isSolved) {
      _drawGlitchText(canvas, "MEMORIA_SUTURADA", center.toOffset(), fontSize: 32, color: bloodColor);
    }
  }

  void _drawShard(Canvas canvas, MemoryShard s) {
    final color = s.isConnected ? bloodColor : fragmentColor;
    final size = 40.0;
    
    // Draw a sharp triangle (Shard)
    final path = Path();
    path.moveTo(s.pos.dx, s.pos.dy - size / 2);
    path.lineTo(s.pos.dx + size / 2, s.pos.dy + size / 2);
    path.lineTo(s.pos.dx - size / 2, s.pos.dy + size / 2);
    path.close();

    canvas.drawPath(path, Paint()..color = color.withOpacity(0.2));
    canvas.drawPath(path, Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2);

    _drawText(canvas, "0x${s.id.hashCode.toRadixString(16).substring(0,2)}", s.pos.translate(0, 10), fontSize: 8, color: color);
  }

  void _drawText(Canvas canvas, String text, Offset pos, {double fontSize = 12, Color color = Colors.white, bool bold = false}) {
    final span = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: 'Courier',
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        letterSpacing: 1.1,
      ),
    );
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  void _drawGlitchText(Canvas canvas, String text, Offset pos, {double fontSize = 12, Color color = Colors.white}) {
     _drawText(canvas, text, pos, fontSize: fontSize, color: color, bold: true);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isSolved) return;
    final tapPos = event.localPosition.toOffset();
    
    for (final s in shards) {
        if (!s.isConnected) {
            final dist = (s.pos - tapPos).distance;
            if (dist < 40) {
                s.isConnected = true;
                s.pos = s.targetPos; // Snap to target
                connectedCount++;
                if (connectedCount >= targetConnected) {
                    isSolved = true;
                    Future.delayed(const Duration(milliseconds: 800), () => onComplete());
                }
                return;
            }
        }
    }
  }
}

class MemoryShard {
  final String id;
  Offset pos;
  final Offset targetPos;
  bool isConnected = false;

  MemoryShard({required this.id, required this.pos, required this.targetPos});
}
