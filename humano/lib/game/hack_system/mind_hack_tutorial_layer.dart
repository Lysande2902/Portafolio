import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/game/core/base/base_arc_game.dart';

class MindHackTutorialLayer extends PositionComponent with HasGameRef<BaseArcGame>, TapCallbacks {
  final String title;
  final String instruction;
  final bool showUIHints;
  final VoidCallback onDismiss;

  MindHackTutorialLayer({
    required this.title,
    required this.instruction,
    this.showUIHints = false,
    required this.onDismiss,
  });

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = gameRef.size;
    priority = 100; // Always on top
  }

  @override
  void render(Canvas canvas) {
    // Semi-transparent background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = Colors.black.withOpacity(0.9)
    );

    final center = size / 2;

    // Title
    _drawText(canvas, title, Offset(center.x, size.y * 0.28), 
        fontSize: 22, color: const Color(0xFF00F0FF), bold: true, maxWidth: size.x * 0.85);

    // Instruction
    _drawText(canvas, instruction, Offset(center.x, size.y * 0.38), 
        fontSize: 14, color: Colors.white70, maxWidth: size.x * 0.75);

    // --- GUÍA DE INTERFAZ (Pointing out UI) ---
    // SOLO se muestra en el primer minijuego
    if (showUIHints) {
      final statusY = size.y * 0.55;
      final statusBoxWidth = size.x * 0.8;
      final statusBoxHeight = 100.0;
      
      // Status Box Border (Slight terminal feel)
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset(center.x, statusY), width: statusBoxWidth, height: statusBoxHeight), 
          const Radius.circular(2)
        ),
        Paint()..color = const Color(0xFF00F0FF).withOpacity(0.04)..style = PaintingStyle.fill
      );

      _drawUIIndicator(canvas, "ESTABILIDAD", "ESQUINA INFERIOR IZQUIERDA [SW]", Offset(center.x, statusY - 30));
      _drawUIIndicator(canvas, "SINCRONIZACIÓN", "BARRA DE PROGRESO INFERIOR", Offset(center.x, statusY));
      _drawUIIndicator(canvas, "PROTOCOLOS", "ESQUINA INFERIOR DERECHA [SE]", Offset(center.x, statusY + 30));
    }

    // Prompt to touch
    final pulse = (math.sin(gameRef.elapsedTime * 6) + 1) / 2;
    _drawText(canvas, "TOCA PARA INICIAR PROTOCOLO", Offset(center.x, showUIHints ? size.y * 0.75 : size.y * 0.55), 
        fontSize: 16, color: const Color(0xFF39FF14).withOpacity(0.5 + 0.5 * pulse), bold: true, maxWidth: size.x * 0.85);

    // Decorative lines
    _drawText(canvas, "[ ANALIZANDO NÚCLEO... ]", Offset(center.x, size.y * 0.15), 
        fontSize: 10, color: Colors.white10, letterSpacing: 2);
  }

  void _drawUIIndicator(Canvas canvas, String label, String location, Offset pos) {
    _drawText(canvas, "$label -> ", pos - Offset(60, 0), fontSize: 10, color: Colors.white38, textAlign: TextAlign.right);
    _drawText(canvas, location, pos + Offset(60, 0), fontSize: 10, color: const Color(0xFF00F0FF), bold: true, textAlign: TextAlign.left, maxWidth: 150);
  }

  void _drawText(Canvas canvas, String text, Offset pos, {double fontSize = 12, Color color = Colors.white, bool bold = false, double? maxWidth, double letterSpacing = 0, TextAlign textAlign = TextAlign.center}) {
    final span = TextSpan(
      text: text,
      style: GoogleFonts.shareTechMono(
        color: color,
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        letterSpacing: letterSpacing,
      ),
    );
    final tp = TextPainter(
      text: span, 
      textDirection: TextDirection.ltr,
      textAlign: textAlign,
    );
    
    if (maxWidth != null) {
      tp.layout(maxWidth: maxWidth);
    } else {
      tp.layout();
    }
    
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  void onTapDown(TapDownEvent event) {
    onDismiss();
    removeFromParent();
  }
}
