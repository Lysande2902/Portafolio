import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../mind_hack_puzzle.dart';

class BinaryShiftPuzzle extends MindHackPuzzle {
  int targetValue = 0;
  int currentValue = 0;
  int bits = 4; // 4-bit binary puzzle
  
  bool isSolved = false;
  final int difficulty;

  BinaryShiftPuzzle({required super.onComplete, required super.onFail, this.difficulty = 0}) {
    // Escalar bits con dificultad
    if (difficulty >= 2) bits = 5;
    if (difficulty >= 4) bits = 6;
    _generateTarget();
  }

  @override
  String get title => "CAMBIO BINARIO";

  @override
  String get instruction => "ALINEA LOS BITS CON EL PATRÓN OBJETIVO";

  void _generateTarget() {
    final rand = math.Random();
    targetValue = rand.nextInt(math.pow(2, bits).toInt());
    // Ensure current is different
    currentValue = rand.nextInt(math.pow(2, bits).toInt());
    if (currentValue == targetValue) {
      currentValue = (currentValue + 1) % math.pow(2, bits).toInt();
    }
  }

  @override
  void reset() {
    _generateTarget();
    isSolved = false;
  }

  @override
  void render(Canvas canvas) {
    final size = gameRef.size;
    final center = size / 2;

    // 1. HEADER
    _drawText(canvas, "RECONSTRUCCIÓN_DE_MEMORIA", Offset(center.x, size.y * 0.10), 
        fontSize: 16, color: Colors.white, bold: true);

    // 2. TARGET DISPLAY
    _drawText(canvas, "OBJETIVO: ${targetValue.toRadixString(2).padLeft(bits, '0')}", 
        Offset(center.x, size.y * 0.20), fontSize: 14, color: Colors.white54);

    // 3. CURRENT BITS
    final String binStr = currentValue.toRadixString(2).padLeft(bits, '0');
    final double bitBoxSize = 60.0;
    final double spacing = 15.0;
    final double totalW = (bitBoxSize * bits) + (spacing * (bits - 1));
    final double startX = center.x - (totalW / 2) + (bitBoxSize / 2);

    for (int i = 0; i < bits; i++) {
        final pos = Offset(startX + i * (bitBoxSize + spacing), size.y * 0.40);
        _drawBitBox(canvas, binStr[i], pos, bitBoxSize);
    }

    _drawText(canvas, "PULSO: $currentValue", Offset(center.x, size.y * 0.50), 
        fontSize: 18, color: const Color(0xFF00F0FF), bold: true);

    // 4. CONTROLS
    _drawControls(canvas, center);

    if (isSolved) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), Paint()..color = Colors.black.withOpacity(0.8));
      _drawText(canvas, "MEMORIA_RECUPERADA", center.toOffset(), fontSize: 24, color: const Color(0xFF39FF14), bold: true);
    }
  }

  void _drawBitBox(Canvas canvas, String bit, Offset pos, double size) {
    final rect = Rect.fromCenter(center: pos, width: size, height: size);
    final paint = Paint()
      ..color = bit == '1' ? const Color(0xFF00F0FF) : Colors.white12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
      
    canvas.drawRect(rect, paint);
    
    if (bit == '1') {
        canvas.drawRect(rect.deflate(5), Paint()..color = const Color(0xFF00F0FF).withOpacity(0.1));
    }

    _drawText(canvas, bit, pos, fontSize: 24, color: bit == '1' ? const Color(0xFF00F0FF) : Colors.white24, bold: true);
  }

  void _drawControls(Canvas canvas, Vector2 center) {
    final size = gameRef.size;
    final startY = size.y * 0.70;
    final btnW = 110.0;
    final btnH = 50.0;

    _drawButton(canvas, "DESPLAZAR_IZQ", Offset(center.x - 65, startY), Size(btnW, btnH));
    _drawButton(canvas, "DESPLAZAR_DER", Offset(center.x + 65, startY), Size(btnW, btnH));
    _drawButton(canvas, "INVERTIR", Offset(center.x, startY + 70), Size(btnW, btnH));
  }

  void _drawButton(Canvas canvas, String label, Offset pos, Size size) {
    final rect = Rect.fromCenter(center: pos, width: size.width, height: size.height);
    canvas.drawRect(rect, Paint()..color = Colors.white10..style = PaintingStyle.fill);
    canvas.drawRect(rect, Paint()..color = Colors.white24..style = PaintingStyle.stroke);
    _drawText(canvas, label, pos, fontSize: 14, color: Colors.white);
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
    
    final pos = event.localPosition;
    final size = gameRef.size;
    final center = size / 2;
    final startY = size.y * 0.70;
    final btnW = 110.0;
    final btnH = 50.0;

    // L_SHIFT
    if (Rect.fromCenter(center: Offset(center.x - 65, startY), width: btnW, height: btnH).contains(pos.toOffset())) {
      _shiftLeft();
    }
    // R_SHIFT
    else if (Rect.fromCenter(center: Offset(center.x + 65, startY), width: btnW, height: btnH).contains(pos.toOffset())) {
      _shiftRight();
    }
    // NOT
    else if (Rect.fromCenter(center: Offset(center.x, startY + 70), width: btnW, height: btnH).contains(pos.toOffset())) {
      _not();
    }

    _checkWin();
  }

  void _shiftLeft() {
    currentValue = (currentValue << 1) % math.pow(2, bits).toInt();
  }

  void _shiftRight() {
    currentValue = (currentValue >> 1);
  }

  void _not() {
    // Bitwise NOT masked to the current bit count
    int mask = (1 << bits) - 1;
    currentValue = (~currentValue) & mask;
  }

  void _checkWin() {
    if (currentValue == targetValue) {
      isSolved = true;
      Future.delayed(const Duration(milliseconds: 600), () => onComplete());
    }
  }
}
