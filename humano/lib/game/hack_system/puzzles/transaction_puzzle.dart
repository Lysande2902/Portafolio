import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../mind_hack_puzzle.dart';

class TransactionPuzzle extends MindHackPuzzle {
  final List<TransactionRecord> records = [];
  double targetBalance = 0.0;
  double currentBalance = 0.0;
  
  int successfulOperations = 0;
  final int targetOperations = 5;
  double exposure = 0.0;
  double time = 0.0;
  bool isSolved = false;
  double timer = 0.0;
  final rand = math.Random();

  TransactionPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  }) {
    _generateLevel();
  }

  @override
  String get title => "ESTADO TRANSACCIONAL";

  @override
  String get instruction => "EQUILIBRA EL LEDGER DECIMAL TOCANDO LOS VALORES HASTA ALCANZAR EL OBJETIVO EXACTO";

  void _generateLevel() {
    final rand = math.Random();
    targetBalance = (rand.nextInt(5) + 1) * 100.0;
    currentBalance = 0.0;
    records.clear();
    _spawnRecord();
  }

  @override
  void reset() {
    _generateLevel();
    successfulOperations = 0;
    isSolved = false;
  }

  @override
  void update(double dt) {
    if (isSolved) return;
    
    super.update(dt);
    time += dt;

    // Pride metaphor: Too much focus/exposure burns the image
    if (timer > 1.5 && records.length < 4) {
      _spawnRecord();
      timer = 0.0;
    }

    // Scroll records and check for expiration
    for (int i = records.length - 1; i >= 0; i--) {
        records[i].pos = Offset(records[i].pos.dx, records[i].pos.dy + (80.0 * dt));
        if (records[i].pos.dy > gameRef.size.y + 100) {
            records.removeAt(i);
        }
    }
  }

  void _spawnRecord() {
    final rand = math.Random();
    final value = (rand.nextInt(4) + 1) * 50.0;
    final isDeposit = rand.nextBool();
    
    records.add(TransactionRecord(
      id: "REF_${rand.nextInt(9999).toString().padLeft(4, '0')}",
      value: isDeposit ? value : -value,
      pos: Offset(gameRef.size.x * 0.15 + rand.nextDouble() * (gameRef.size.x * 0.7), -50),
    ));
  }

  @override
  void render(Canvas canvas) {
    final center = gameRef.size / 2;
    
    // Background noise sidebars (Procedural)
    final noisePaint = Paint()..color = Colors.white.withOpacity(0.015);
    canvas.drawRect(Rect.fromLTWH(0, 0, 30, gameRef.size.y), noisePaint);
    canvas.drawRect(Rect.fromLTWH(gameRef.size.x - 30, 0, 30, gameRef.size.y), noisePaint);

    // Header Panel
    _drawText(canvas, "ESTADO TRANSACCIONAL: BUFFER_CORRUPTO", Offset(center.x, 60), fontSize: 18, color: Colors.white, bold: true);
    _drawText(canvas, "EQUILIBRA EL LEDGER DECIMAL PARA ESTABILIZAR EL NODO", Offset(center.x, 85), fontSize: 10, color: const Color(0xFFD4AF37).withOpacity(0.8));

    // Decorative Data Streams
    for (int i = 0; i < 3; i++) {
        final x = 15.0;
        final y = (timer * 100 + i * 150) % gameRef.size.y;
        _drawText(canvas, "0x${rand.nextInt(0xFF).toRadixString(16)}", Offset(x, y), fontSize: 8, color: Colors.white.withOpacity(0.1));
    }

    // Balance Display (Table Style)
    _drawTechnicalBalancePanel(canvas, Offset(center.x, 160));

    // Records (Floating Ledgers)
    for (final record in records) {
        _drawTechnicalRecord(canvas, record);
    }

    // Eliminamos el bloque isSolved para evitar estancamiento visual
  }

  void _drawTechnicalBalancePanel(Canvas canvas, Offset pos) {
    final width = 280.0;
    final height = 100.0;
    final rect = Rect.fromCenter(center: pos, width: width, height: height);
    
    // Double Border Box
    canvas.drawRect(rect, Paint()..color = const Color(0xFF0D1117).withOpacity(0.9));
    canvas.drawRect(rect.inflate(2), Paint()..color = const Color(0xFFD4AF37)..style = PaintingStyle.stroke..strokeWidth = 1);
    canvas.drawRect(rect, Paint()..color = const Color(0xFF30363D)..style = PaintingStyle.stroke);

    // Table Header
    canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, rect.width, 25), Paint()..color = const Color(0xFF161B22));
    _drawText(canvas, "NODE://LEDGER_SUMMARY", Offset(pos.dx, rect.top + 12), fontSize: 9, color: const Color(0xFFD4AF37));

    // Balance Values
    _drawText(canvas, "BAL: \$${currentBalance.toStringAsFixed(2)}", Offset(pos.dx, pos.dy + 8), fontSize: 22, color: Colors.white, bold: true);
    _drawText(canvas, "TARGET: \$${targetBalance.toStringAsFixed(2)}", Offset(pos.dx, pos.dy + 32), fontSize: 10, color: Colors.blueGrey);
    
    // Integrity Bar
    final barW = width - 60;
    final progress = (currentBalance / targetBalance).clamp(0.0, 1.0);
    final barRect = Rect.fromCenter(center: Offset(pos.dx, rect.bottom - 15), width: barW, height: 6);
    canvas.drawRect(barRect, Paint()..color = Colors.white.withOpacity(0.05));
    canvas.drawRect(Rect.fromLTWH(barRect.left, barRect.top, barW * progress, 6), Paint()..color = const Color(0xFFD4AF37));
  }

  void _drawTechnicalRecord(Canvas canvas, TransactionRecord r) {
    final isNegative = r.value < 0;
    final color = isNegative ? const Color(0xFFFF3131) : const Color(0xFF39FF14);
    final rect = Rect.fromLTWH(r.pos.dx, r.pos.dy, 130, 55);
    
    // Ledger Card Style
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), Paint()..color = const Color(0xFF161B22).withOpacity(0.8));
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), 
        Paint()..color = color.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 1);

    // Decorative Side Strip
    canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, 4, rect.height), Paint()..color = color);

    _drawText(canvas, "ID: ${r.id}", Offset(r.pos.dx + 65, r.pos.dy + 15), fontSize: 8, color: Colors.grey);
    _drawText(canvas, "${isNegative ? '' : '+'}${r.value.toInt()}.00", Offset(r.pos.dx + 65, r.pos.dy + 35), fontSize: 16, color: color, bold: true);
    
    // Status code
    _drawText(canvas, "ST_OK", Offset(r.pos.dx + 110, r.pos.dy + 15), fontSize: 7, color: color.withOpacity(0.5));
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

  void _drawGlitchText(Canvas canvas, String text, Offset pos, {double fontSize = 12, Color color = Colors.white}) {
     _drawText(canvas, text, pos, fontSize: fontSize, color: color, bold: true);
     if (math.Random().nextDouble() > 0.8) {
       _drawText(canvas, text, pos.translate(3, 0), fontSize: fontSize, color: Colors.blue.withOpacity(0.4));
     }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isSolved) return;
    
    final tapPos = event.localPosition.toOffset();
    
    for (int i = 0; i < records.length; i++) {
        final r = records[i];
        final rect = Rect.fromLTWH(r.pos.dx, r.pos.dy, 120, 50);
        
        if (rect.contains(tapPos)) {
            currentBalance += r.value;
            records.removeAt(i);
            
            if (currentBalance == targetBalance) {
                successfulOperations++;
                if (successfulOperations >= targetOperations) {
                    isSolved = true;
                    Future.delayed(const Duration(milliseconds: 600), () => onComplete());
                } else {
                    _generateLevel();
                }
            } else if (currentBalance > targetBalance) {
                onFail();
                _generateLevel();
            }
            return;
        }
    }
  }
}

class TransactionRecord {
  final String id;
  final double value;
  Offset pos;

  TransactionRecord({required this.id, required this.value, required this.pos});
}
