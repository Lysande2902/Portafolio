import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../mind_hack_puzzle.dart';

class UnboxingPuzzle extends MindHackPuzzle {
  final List<DataPackage> packages = [];
  final List<String> emotions = ["YO", "FE", "LUZ", "FIN", "SOL", "MAR", "ECO", "BIO", "VER"];
  
  int openedCount = 0;
  final int targetCount = 6;
  double spawnTimer = 0.0;
  double time = 0.0;
  bool isSolved = false;
  
  // Terminal Colors
  static const Color primaryColor = Color(0xFF00FF41); 
  static const Color accentColor = Color(0xFF00F0FF);  
  static const Color alertColor = Color(0xFFFF3131);   

  UnboxingPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "UNBOXING";

  @override
  String get instruction => "CAPTURA LOS IMPULSOS TOCANDO LOS PAQUETES ANTES DE QUE SE ESCAPEN";

  @override
  void reset() {
    packages.clear();
    openedCount = 0;
    spawnTimer = 0.0;
    isSolved = false;
  }

  @override
  void update(double dt) {
    if (isSolved) return;
    
    super.update(dt);
    time += dt;
    spawnTimer += dt;
    
    // Controlled spawning logic
    if (spawnTimer > 1.2 && packages.length < 5) {
      _spawnPackage();
      spawnTimer = 0.0;
    }

    // Move packages horizontally and remove expired
    for (int i = packages.length - 1; i >= 0; i--) {
      final p = packages[i];
      p.pos = Offset(p.pos.dx + (p.speed * dt), p.pos.dy);
      
      // If package leaves screen without being opened
      if ((p.speed > 0 && p.pos.dx > gameRef.size.x + 50) || 
          (p.speed < 0 && p.pos.dx < -50)) {
        if (!p.isOpened) {
          onFail(); // Punish missing a package
        }
        packages.removeAt(i);
      }
    }
  }

  void _spawnPackage() {
    final rand = math.Random();
    final size = gameRef.size;
    final isLeft = rand.nextBool();
    final x = isLeft ? -40.0 : size.x + 40.0;
    // Spawn between 30% and 80% of screen height
    final y = size.y * 0.3 + rand.nextDouble() * (size.y * 0.5);
    final speed = (80.0 + rand.nextDouble() * 80.0) * (isLeft ? 1 : -1); 
    
    packages.add(DataPackage(
      id: emotions[rand.nextInt(emotions.length)],
      pos: Offset(x, y),
      speed: speed,
      color: rand.nextDouble() > 0.8 ? alertColor : accentColor,
    ));
  }

  @override
  void render(Canvas canvas) {
    final size = gameRef.size;
    final center = size / 2;
    
    // 1. HEADER
    _drawText(canvas, "ESTABILIZACIÓN_DE_IMPULSOS", Offset(center.x, size.y * 0.08), 
        fontSize: 14, color: Colors.white, bold: true);
    
    // 2. PROGRESS
    final progress = openedCount / targetCount;
    _drawText(canvas, "IMPULSOS_CAPTURADOS: ${(progress * 100).toInt()}%", Offset(center.x, size.y * 0.12), 
        fontSize: 10, color: accentColor);

    // 3. PACKAGES
    for (final package in packages) {
      _drawTechnicalPackage(canvas, package);
    }

    // Eliminamos el bloque isSolved para evitar estancamiento visual
  }

  void _drawTechnicalPackage(Canvas canvas, DataPackage p) {
    final rect = Rect.fromCenter(center: p.pos, width: 70, height: 40); // Slightly smaller visual box
    final paint = Paint()
      ..color = p.color.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
      
    canvas.drawRect(rect, paint);
    _drawText(canvas, p.id, p.pos, fontSize: 14, color: p.color, bold: true);
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
    debugPrint('🖱️ [TAP] Unboxing Tap at: $tapPos');
    
    for (int i = 0; i < packages.length; i++) {
      final p = packages[i];
      final rect = Rect.fromCenter(center: p.pos, width: 100, height: 70); // Slightly larger tap area
      
      if (rect.contains(tapPos) && !p.isOpened) {
        p.isOpened = true;
        openedCount++;
        
        // Visual feedback
        packages.removeAt(i);
        
        if (openedCount >= targetCount) {
          isSolved = true;
          Future.delayed(const Duration(milliseconds: 600), () {
            onComplete();
          });
        }
        return;
      }
    }
  }
}

class DataPackage {
  final String id;
  Offset pos;
  final double speed;
  final Color color;
  bool isOpened = false;

  DataPackage({required this.id, required this.pos, required this.speed, required this.color});
}
