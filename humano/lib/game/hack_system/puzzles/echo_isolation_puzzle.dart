import 'dart:async' as async;
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
import 'package:humano/game/hack_system/mind_hack_puzzle.dart';

class EchoIsolationPuzzle extends MindHackPuzzle with DragCallbacks {
  late TextComponent _statusText;
  late TextComponent _counterText;
  late ShieldComponent _shield;
  double _spawnTimer = 0;
  final double _spawnInterval = 1.5;
  int _blockedCount = 0;
  final int _targetBlocked = 8;
  bool _isFinished = false;

  EchoIsolationPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "AISLAMIENTO DE ECO";

  @override
  String get instruction => "ARRASTRA PARA ROTAR EL ESCUDO Y BLOQUEAR LOS ECOS QUE ATACAN AL NÚCLEO";

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _statusText = TextComponent(
      text: '[2] AISLAMIENTO DE ECO',
      position: Vector2(size.x / 2, size.y * 0.12),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFF00F0FF), fontSize: 18),
      ),
    );
    add(_statusText);

    _counterText = TextComponent(
      text: 'ECOS BLOQUEADOS: 0/$_targetBlocked',
      position: Vector2(size.x / 2, size.y * 0.17),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 14),
      ),
    );
    add(_counterText);

    // El núcleo que protegemos
    add(CircleComponent(
      radius: 30,
      position: size / 2,
      anchor: Anchor.center,
      paint: Paint()..color = const Color(0xFF00F0FF).withOpacity(0.2),
    )..add(CircleComponent(
        radius: 10,
        position: Vector2(30, 30),
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0xFF00F0FF),
    )));

    // El escudo
    _shield = ShieldComponent(position: size / 2);
    add(_shield);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isFinished) return;

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnEcho();
    }
  }

  void _spawnEcho() {
    final angle = math.Random().nextDouble() * 2 * math.pi;
    add(EchoWaveComponent(
      angle: angle,
      target: size / 2,
      onHitShield: () {
        _blockedCount++;
        _counterText.text = 'ECOS BLOQUEADOS: $_blockedCount/$_targetBlocked';
        if (_blockedCount >= _targetBlocked) {
          _isFinished = true;
          onComplete();
        }
      },
      onHitCore: () => onFail(),
      currentShieldAngle: () => _shield.angle,
    ));
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    // Rotar escudo
    _shield.angle += event.localDelta.x * 0.01;
  }

  @override
  void reset() {
    _blockedCount = 0;
    _isFinished = false;
    children.whereType<EchoWaveComponent>().forEach((e) => e.removeFromParent());
  }
}

class ShieldComponent extends PositionComponent {
  ShieldComponent({required super.position}) : super(anchor: Anchor.center, size: Vector2.all(160));

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFF00F0FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    
    // Dibujar un arco de 90 grados como escudo
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.x, size.y),
      -math.pi / 4, // 45 grados antes del centro
      math.pi / 2,  // 90 grados de ancho
      false,
      paint,
    );
  }
}

class EchoWaveComponent extends PositionComponent {
  final double angle;
  final Vector2 target;
  final VoidCallback onHitShield;
  final VoidCallback onHitCore;
  final double Function() currentShieldAngle;
  double _distance = 300;
  final double _speed = 120;

  EchoWaveComponent({
    required this.angle,
    required this.target,
    required this.onHitShield,
    required this.onHitCore,
    required this.currentShieldAngle,
  }) : super(anchor: Anchor.center, size: Vector2.all(40));

  @override
  void update(double dt) {
    super.update(dt);
    _distance -= _speed * dt;

    // Actualizar posición basado en ángulo y distancia
    position = target + Vector2(math.cos(angle) * _distance, math.sin(angle) * _distance);

    if (_distance <= 80 && _distance > 70) {
      // Verificar si el escudo está en la posición correcta
      final sAngle = currentShieldAngle();
      // Normalizar ángulos para comparación
      double diff = (angle - sAngle) % (2 * math.pi);
      if (diff > math.pi) diff -= 2 * math.pi;
      
      if (diff.abs() < math.pi / 4) { // El escudo cubre 45 grados a cada lado
        onHitShield();
        removeFromParent();
      }
    } else if (_distance <= 30) {
      onHitCore();
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Dibujar una onda (arco invertido)
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.x, size.y),
      angle + math.pi - 0.5,
      1.0,
      false,
      paint,
    );
  }
}
