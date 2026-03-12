import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../mind_hack_puzzle.dart';

class DeadTaskPuzzle extends MindHackPuzzle {
  final List<ZombieProcess> processes = [];
  int killedCount = 0;
  final int targetKilled = 10;
  double spawnTimer = 0.0;
  double totalLoad = 0.0;
  bool isSolved = false;
  
  static const Color primaryColor = Color(0xFF6E5494); // PEREZA - Púrpura/Zombie
  static const Color alertColor = Color(0xFFFF3131);
  static const Color accentColor = Color(0xFF00F0FF);

  DeadTaskPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "GESTOR DE TAREAS";

  @override
  String get instruction => "FINALIZA LOS PROCESOS ZOMBIE TOCÁNDOLOS ANTES DE QUE SE SATURE EL SISTEMA";

  @override
  void reset() {
    processes.clear();
    killedCount = 0;
    totalLoad = 0.0;
    spawnTimer = 0.0;
    isSolved = false;
  }

  @override
  void update(double dt) {
    if (isSolved) return;
    super.update(dt);
    
    spawnTimer += dt;
    if (spawnTimer > 0.7 && processes.length < 12) {
      _spawnProcess();
      spawnTimer = 0.0;
    }

    totalLoad = 0.0;
    for (int i = processes.length - 1; i >= 0; i--) {
      final p = processes[i];
      p.cpuLoad += dt * (0.1 + (killedCount * 0.01)); // Gets harder
      totalLoad += p.cpuLoad;
      
      if (p.cpuLoad > 1.0) {
         // Process fully saturated the kernel
         onFail();
         processes.clear();
         return;
      }
    }
  }

  void _spawnProcess() {
    final rand = math.Random();
    final names = ["GRIND_CULTURE.EXE", "VALIDACION_FALSA.SVC", "EGO_FILTER.DLL", "FAKE_METRICS.LOG", "Burnout_Thread"];
    processes.add(ZombieProcess(
      name: names[rand.nextInt(names.length)],
      pos: Offset(60 + rand.nextDouble() * (gameRef.size.x - 120), 180 + rand.nextDouble() * (gameRef.size.y - 350)),
    ));
  }

  @override
  void render(Canvas canvas) {
    final center = gameRef.size / 2;
    
    // UI Header
    _drawText(canvas, "GESTOR DE TAREAS: PSIQUE_OS", Offset(center.x, 60), fontSize: 16, color: Colors.white, bold: true);
    _drawText(canvas, "DEPURA LOS PROCESOS ZOMBIE QUE CONSUMEN TU ALMA", Offset(center.x, 85), fontSize: 10, color: Colors.blueGrey);

    // Global Load Meter
    final loadRatio = (totalLoad / 8.0).clamp(0.0, 1.0);
    _drawGlobalMeter(canvas, Offset(center.x, 130), loadRatio);

    // Grid background
    final gridPaint = Paint()..color = Colors.white.withOpacity(0.02)..style = PaintingStyle.stroke;
    for (int i = 0; i < 10; i++) {
        canvas.drawLine(Offset(0, 150 + i * 50), Offset(gameRef.size.x, 150 + i * 50), gridPaint);
    }

    // Processes
    for (final p in processes) {
      _drawProcess(canvas, p);
    }

    // Counter
    _drawText(canvas, "HILOS ELIMINADOS: $killedCount / $targetKilled", Offset(center.x, gameRef.size.y - 80), 
        fontSize: 12, color: accentColor);

    // Eliminamos el bloque de victoria intermedio para evitar estancamiento visual
  }

  void _drawGlobalMeter(Canvas canvas, Offset pos, double ratio) {
    final width = 280.0;
    final h = 12.0;
    final rect = Rect.fromCenter(center: pos, width: width, height: h);
    
    canvas.drawRect(rect, Paint()..color = Colors.white10);
    canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, width * ratio, h), 
        Paint()..color = Color.lerp(accentColor, alertColor, ratio)!);
    
    _drawText(canvas, "CARGA DEL NÚCLEO: ${(ratio * 100).toInt()}%", Offset(pos.dx, pos.dy + 22), 
        fontSize: 10, color: Color.lerp(accentColor, alertColor, ratio)!);
  }

  void _drawProcess(Canvas canvas, ZombieProcess p) {
    final rect = Rect.fromCenter(center: p.pos, width: 110, height: 50);
    final color = Color.lerp(primaryColor, alertColor, p.cpuLoad)!;
    
    // Terminal style window
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), Paint()..color = const Color(0xFF050505));
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(3)), 
        Paint()..color = color.withOpacity(0.4)..style = PaintingStyle.stroke..strokeWidth = 1.0);

    // Title bar
    canvas.drawRect(Rect.fromLTWH(rect.left, rect.top, rect.width, 14), Paint()..color = color.withOpacity(0.2));
    
    _drawText(canvas, p.name, Offset(p.pos.dx, p.pos.dy - 12), fontSize: 8, color: Colors.white, bold: true);
    
    // CPU Load bar inside
    final barW = rect.width - 20;
    canvas.drawRect(Rect.fromLTWH(rect.left + 10, rect.bottom - 12, barW, 4), Paint()..color = Colors.white10);
    canvas.drawRect(Rect.fromLTWH(rect.left + 10, rect.bottom - 12, barW * p.cpuLoad, 4), Paint()..color = color);

    // PID
    _drawText(canvas, "PID:${p.hashCode.toString().substring(0,4)}", Offset(p.pos.dx, p.pos.dy + 5), fontSize: 7, color: Colors.white38);
  }

  void _drawText(Canvas canvas, String text, Offset pos, {double fontSize = 12, Color color = Colors.white, bool bold = false}) {
    final span = TextSpan(
      text: text,
      style: GoogleFonts.shareTechMono(
        color: color,
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        letterSpacing: 1.1,
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
    
    for (int i = processes.length - 1; i >= 0; i--) {
        final p = processes[i];
        final rect = Rect.fromCenter(center: p.pos, width: 120, height: 60);
        
        if (rect.contains(tapPos)) {
            processes.removeAt(i);
            killedCount++;
            
            if (killedCount >= targetKilled) {
                isSolved = true;
                Future.delayed(const Duration(milliseconds: 600), () => onComplete());
            }
            return;
        }
    }
  }
}

class ZombieProcess {
  final String name;
  final Offset pos;
  double cpuLoad = 0.0;

  ZombieProcess({required this.name, required this.pos});
}
