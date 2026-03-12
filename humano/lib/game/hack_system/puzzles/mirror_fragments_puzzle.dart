import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mind_hack_puzzle.dart';

/// MirrorFragmentsPuzzle — Acto 3 del Arco 4: "El Espejo de Sangre".
/// Conecta fragmentos de las 6 víctimas anteriores para revelar que
/// todas eran facetas de Alex. Al unirlas, el espejo muestra su verdadero rostro.
class MirrorFragmentsPuzzle extends MindHackPuzzle {

  static const List<String> _victimLabels = [
    'LUCÍA', 'ADRIANA', 'MATEO', 'VALERIA', 'CARLOS', 'MIGUEL',
  ];
  static const List<Color> _victimColors = [
    Color(0xFF8B5CF6), // Envidia
    Color(0xFFEC4899), // Lujuria
    Color(0xFFF97316), // Consumo
    Color(0xFFEAB308), // Avaricia
    Color(0xFFF43F5E), // Soberbia
    Color(0xFF6366F1), // Pereza
  ];

  final List<FragmentNode> _nodes = [];
  final List<Connection> _connections = [];
  int _connectedCount = 0;
  final int _targetConnections = 5;

  bool isSolved = false;
  double animTime = 0.0;
  double revealProgress = 0.0;
  FragmentNode? _selectedNode;
  bool _nodesInitialized = false;

  MirrorFragmentsPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "FRAGMENTOS DE ESPEJO";

  @override
  String get instruction => "CONECTA LOS FRAGMENTOS TOCANDO DOS NODOS PARA RESTABLECER EL VÍNCULO";

  void _buildNodes(Vector2 size) {
    if (_nodesInitialized) return;
    _nodesInitialized = true;
    final center = size / 2;
    final radius = size.x * 0.33;
    for (int i = 0; i < 6; i++) {
      final angle = (i / 6) * math.pi * 2 - math.pi / 2;
      _nodes.add(FragmentNode(
        label: _victimLabels[i],
        color: _victimColors[i],
        pos: Offset(
          center.x + math.cos(angle) * radius,
          center.y + math.sin(angle) * radius + 20,
        ),
        index: i,
      ));
    }
  }

  @override
  void reset() {
    _nodes.clear();
    _connections.clear();
    _connectedCount = 0;
    _selectedNode = null;
    isSolved = false;
    revealProgress = 0.0;
    _nodesInitialized = false;
  }

  @override
  void update(double dt) {
    if (isSolved) {
      revealProgress = (revealProgress + dt * 0.55).clamp(0.0, 1.0);
      return;
    }
    super.update(dt);
    animTime += dt;
  }

  @override
  void render(Canvas canvas) {
    final size = gameRef.size;
    final center = size / 2;

    _buildNodes(size);

    // Red pulsing background — the fire around Victor's room
    final pulse = 0.08 + 0.07 * math.sin(animTime * 2.5);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = const Color(0xFFCC0000).withOpacity(pulse));

    if (isSolved) {
      // Simplificado para evitar estancamiento visual (Como el Arco 0)
      return;
    }

    // Header
    _drawText(canvas, 'ESPEJO DE SANGRE',
        Offset(center.x, 55), fontSize: 20, color: Colors.white, bold: true);
    _drawText(canvas, 'UNE LOS FRAGMENTOS — MIRA LO QUE ESCONDISTE',
        Offset(center.x, 80), fontSize: 9, color: const Color(0xFFFF5555));

    // Draw connection lines first (below nodes)
    for (final conn in _connections) {
      final grad = Paint()
        ..shader = LinearGradient(
          colors: [conn.from.color, conn.to.color],
        ).createShader(Rect.fromPoints(conn.from.pos, conn.to.pos))
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;
      canvas.drawLine(conn.from.pos, conn.to.pos, grad);
    }

    // Nodes
    for (final node in _nodes) {
      _drawNode(canvas, node);
    }

    // Counter
    _drawText(canvas, 'VÍNCULOS: $_connectedCount / $_targetConnections',
        Offset(center.x, size.y - 75), fontSize: 12, color: Colors.white60);
    _drawText(canvas, 'TOCA DOS FRAGMENTOS PARA CONECTARLOS',
        Offset(center.x, size.y - 48), fontSize: 8, color: Colors.white30);
  }

  void _drawNode(Canvas canvas, FragmentNode node) {
    final isSelected = _selectedNode == node;
    const baseR = 29.0;
    final r = isSelected ? baseR + 4 : baseR;

    // Glow bloom
    canvas.drawCircle(node.pos, r + 6,
        Paint()..color = node.color.withOpacity(0.25)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));

    // Fill
    canvas.drawCircle(node.pos, r,
        Paint()..color = node.color.withOpacity(node.isConnected ? 0.55 : 0.25));

    // Border
    canvas.drawCircle(node.pos, r,
        Paint()
          ..color = isSelected ? Colors.white : node.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 2.5 : 1.5);

    // Selection pulse ring
    if (isSelected) {
      final pR = r + 8 + math.sin(animTime * 12) * 3;
      canvas.drawCircle(node.pos, pR,
          Paint()..color = Colors.white.withOpacity(0.45)..style = PaintingStyle.stroke..strokeWidth = 1.0);
    }

    _drawText(canvas, node.label, node.pos,
        fontSize: 8, color: node.isConnected ? Colors.white : Colors.white70, bold: node.isConnected);
  }

  void _drawReveal(Canvas canvas, Vector2 size, Vector2 center) {
    // Blackout
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y),
        Paint()..color = Colors.black.withOpacity((revealProgress * 0.9).clamp(0.0, 0.9)));

    // The mirror growing
    final mirrorR = revealProgress * size.x * 0.38;
    canvas.drawCircle(center.toOffset(), mirrorR,
        Paint()
          ..color = const Color(0xFFAA0000).withOpacity(0.35 * revealProgress)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24));
    canvas.drawCircle(center.toOffset(), mirrorR,
        Paint()..color = Colors.white.withOpacity(0.7 * revealProgress)..style = PaintingStyle.stroke..strokeWidth = 2.0);

    // Main revelation line
    if (revealProgress > 0.35) {
      final op = ((revealProgress - 0.35) / 0.65).clamp(0.0, 1.0);
      _drawText(canvas, 'TODOS ERAN TÚ, ALEX.',
          center.toOffset().translate(0, -mirrorR * 0.3),
          fontSize: 22, color: Colors.white.withOpacity(op), bold: true);
    }

    // Secondary cinematic lines
    if (revealProgress > 0.6) {
      final op = ((revealProgress - 0.6) / 0.4).clamp(0.0, 1.0);
      _drawText(canvas, '"PERO ÉL ERA REAL. TU HERMANO."',
          center.toOffset().translate(0, mirrorR * 0.35),
          fontSize: 12, color: const Color(0xFFFF5555).withOpacity(op));
    }

    if (revealProgress > 0.85) {
      final op = ((revealProgress - 0.85) / 0.15).clamp(0.0, 1.0);
      _drawText(canvas, '"MÍRALO A LOS OJOS Y ELIGE."',
          center.toOffset().translate(0, mirrorR * 0.55),
          fontSize: 11, color: Colors.white38.withOpacity(op));
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
    if (isSolved) return;
    final tap = event.localPosition.toOffset();

    for (final node in _nodes) {
      if ((tap - node.pos).distance <= 36) {
        if (_selectedNode == null) {
          _selectedNode = node;
        } else if (_selectedNode == node) {
          _selectedNode = null;
        } else {
          final alreadyConnected = _connections.any(
            (c) => (c.from == _selectedNode && c.to == node) ||
                   (c.from == node && c.to == _selectedNode),
          );
          if (!alreadyConnected) {
            _connections.add(Connection(from: _selectedNode!, to: node));
            _selectedNode!.isConnected = true;
            node.isConnected = true;
            _connectedCount++;

            if (_connectedCount >= _targetConnections) {
              isSolved = true;
              Future.delayed(const Duration(milliseconds: 500), () => onComplete());
            }
          }
          _selectedNode = null;
        }
        return;
      }
    }
    _selectedNode = null;
  }
}

class FragmentNode {
  final String label;
  final Color color;
  final Offset pos;
  final int index;
  bool isConnected;

  FragmentNode({
    required this.label,
    required this.color,
    required this.pos,
    required this.index,
    this.isConnected = false,
  });
}

class Connection {
  final FragmentNode from;
  final FragmentNode to;
  Connection({required this.from, required this.to});
}
