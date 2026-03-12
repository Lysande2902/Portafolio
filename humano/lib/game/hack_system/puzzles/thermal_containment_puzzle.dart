import 'dart:async' as async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
import 'package:humano/game/hack_system/mind_hack_puzzle.dart';

class ThermalContainmentPuzzle extends MindHackPuzzle {
  late TextComponent _statusText;
  late TextComponent _warningText;
  double _spawnTimer = 0;
  final double _spawnInterval = 0.6; // Más rápido
  int _extinguished = 0;
  final int _targetExtinguished = 15; // De 8 a 15
  bool _isFinished = false;


  ThermalContainmentPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "CONTENCIÓN TÉRMICA";

  @override
  String get instruction => "EXTINGUE EL INCENDIO TOCANDO LOS ICONOS DE FUEGO REPETIDAMENTE ANTES DE QUE EXPLOTEN";

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _statusText = TextComponent(
      text: '[1] CONTENCIÓN TÉRMICA',
      position: Vector2(size.x / 2, size.y * 0.12),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFFFF3131), fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
    add(_statusText);

    _warningText = TextComponent(
      text: 'EXTINGUE EL INCENDIO DEL SISTEMA',
      position: Vector2(size.x / 2, size.y * 0.17),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.white70, fontSize: 12),
      ),
    );
    add(_warningText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isFinished) return;

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval && children.whereType<FireNode>().length < 7) {
      _spawnTimer = 0;
      _spawnFire();
    }

  }

  void _spawnFire() {
    final random = Random();
    add(FireNode(
      position: Vector2(
        100 + random.nextDouble() * (size.x - 200),
        size.y * 0.3 + random.nextDouble() * (size.y * 0.5),
      ),
      onExtinguished: () {
        _extinguished++;
        if (_extinguished >= _targetExtinguished) {
          _isFinished = true;
          onComplete();
        }
      },
      onExplode: () => onFail(),
    ));
  }

  @override
  void reset() {
    _extinguished = 0;
    _isFinished = false;
    children.whereType<FireNode>().forEach((f) => f.removeFromParent());
  }
}

class FireNode extends PositionComponent with TapCallbacks {
  final VoidCallback onExtinguished;
  final VoidCallback onExplode;
  double _heat = 0.2; // 0.0 to 1.0
  final double _heatSpeed = 0.7; // Casi el doble de rápido

  late CircleComponent _glow;

  FireNode({
    required Vector2 position,
    required this.onExtinguished,
    required this.onExplode,
  }) : super(position: position, anchor: Anchor.center, size: Vector2.all(80));

  @override
  Future<void> onLoad() async {
    _glow = CircleComponent(
      radius: size.x / 2,
      paint: Paint()..color = Colors.orange.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
    );
    add(_glow);

    add(TextComponent(
      text: String.fromCharCode(Icons.local_fire_department.codePoint),
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 40,
          fontFamily: 'MaterialIcons',
          color: Colors.orange,
        ),
      ),
    ));
    
    scale = Vector2.zero();
    add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.3)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    _heat += _heatSpeed * dt;
    
    // El color se vuelve más rojo y el tamaño aumenta
    _glow.paint.color = Color.lerp(Colors.orange, Colors.red, _heat)!.withOpacity(0.5);
    scale = Vector2.all(1.0 + _heat * 0.5);

    if (_heat >= 1.0) {
      onExplode();
      removeFromParent();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Al tocarlo, "enfriamos" el nodo
    _heat -= 0.3;
    if (_heat <= 0) {
      onExtinguished();
      removeFromParent();
    } else {
      // Feedback de enfriamiento
      add(ColorEffect(Colors.cyan, EffectController(duration: 0.1, reverseDuration: 0.1)));
    }
  }
}
