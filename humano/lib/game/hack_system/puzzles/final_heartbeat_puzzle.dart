import 'dart:async' as async;
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
import 'package:humano/game/hack_system/mind_hack_puzzle.dart';

class FinalHeartbeatPuzzle extends MindHackPuzzle {
  late TextComponent _statusText;
  late TextComponent _instructionText;
  late ECGLineComponent _ecgLine;
  int _beatsSynced = 0;
  final int _targetBeats = 10;
  bool _isFinished = false;

  FinalHeartbeatPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "LATIDO FINAL";

  @override
  String get instruction => "SINCRO CON EL PULSO TOCANDO LA PANTALLA CUANDO EL PICO PASE POR EL SENSOR CENTRAL";

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _statusText = TextComponent(
      text: '[5] LATIDO FINAL',
      position: Vector2(size.x / 2, size.y * 0.12),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFF00F0FF), fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
    add(_statusText);

    _instructionText = TextComponent(
      text: 'SINCRO CON EL PULSO',
      position: Vector2(size.x / 2, size.y * 0.17),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 12),
      ),
    );
    add(_instructionText);

    _ecgLine = ECGLineComponent(position: Vector2(size.x / 2, size.y * 0.5));
    add(_ecgLine);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isFinished) return;
    
    _instructionText.text = 'LATIDOS: $_beatsSynced/$_targetBeats';
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_isFinished) return;

    // Verificar si el "pulso" está en el área de acierto
    if (_ecgLine.isInHitZone) {
      _beatsSynced++;
      // Efecto visual de destello azul
      add(RectangleComponent(
        size: size,
        paint: Paint()..color = const Color(0xFF00F0FF).withOpacity(0.1),
      )..add(OpacityEffect.fadeOut(EffectController(duration: 0.2, reverseDuration: 0.1), onComplete: () => children.last.removeFromParent())));

      if (_beatsSynced >= _targetBeats) {
        _isFinished = true;
        _instructionText.text = 'SISTEMA ESTABLE';
        Future.delayed(const Duration(milliseconds: 1000), () => onComplete());
      }
    } else {
      // Fallo de ritmo (feedback dramático)
      gameRef.camera.viewfinder.add(
        MoveEffect.by(
          Vector2(3, 0), 
          EffectController(duration: 0.05, reverseDuration: 0.05, repeatCount: 2),
        )
      );
    }
  }

  @override
  void reset() {
    _beatsSynced = 0;
    _isFinished = false;
  }
}

class ECGLineComponent extends PositionComponent {
  double _xPos = 0;
  final double _speed = 250;
  bool isInHitZone = false;
  final double _hitZoneX = 150; // Donde está el "sensor"
  final double _hitZoneWidth = 40;

  ECGLineComponent({required super.position}) : super(anchor: Anchor.center, size: Vector2(300, 150));

  @override
  void update(double dt) {
    super.update(dt);
    _xPos += _speed * dt;
    if (_xPos > size.x) _xPos = 0;

    // El pulso está en la zona de acierto cuando el pico del ECG está cerca del sensor
    // Para simplificar, el "pico" se genera cada ciclo en una posición fija visualmente
    // Pero aquí detectamos si la _xPos del escaneo está sobre el sensor
    isInHitZone = (_xPos > _hitZoneX - _hitZoneWidth / 2 && _xPos < _hitZoneX + _hitZoneWidth / 2);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF00F0FF).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Dibujar línea de fondo
    canvas.drawLine(const Offset(0, 75), Offset(size.x, 75), paint);

    // Dibujar el sensor (Zona de impacto)
    final sensorPaint = Paint()
      ..color = isInHitZone ? const Color(0xFF00F0FF) : Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawRect(Rect.fromCenter(center: const Offset(150, 75), width: 40, height: 100), sensorPaint);

    // Dibujar el pulso actual
    final pulsePaint = Paint()
      ..color = const Color(0xFF00F0FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    
    final path = Path();
    path.moveTo(_xPos, 75);
    // Simular el complejo QRS (el pico del latido) cuando pasa por el sensor
    if (isInHitZone) {
      path.lineTo(_xPos - 5, 75);
      path.lineTo(_xPos, 20);
      path.lineTo(_xPos + 5, 130);
      path.lineTo(_xPos + 10, 75);
    } else {
      path.lineTo(_xPos + 10, 75);
    }
    canvas.drawPath(path, pulsePaint);
  }
}
