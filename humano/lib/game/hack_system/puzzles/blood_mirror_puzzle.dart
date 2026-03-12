import 'dart:async' as async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
import 'package:humano/game/hack_system/mind_hack_puzzle.dart';

class BloodMirrorPuzzle extends MindHackPuzzle {
  late TextComponent _statusText;
  int _cracksFixed = 0;
  final int _targetCracks = 15;
  bool _isFinished = false;

  BloodMirrorPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "ESPEJO DE SANGRE";

  @override
  String get instruction => "RECONSTRUYE EL REFLEJO FRACTURADO TAPPING LAS GRIETAS";

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _statusText = TextComponent(
      text: '[3] ESPEJO DE SANGRE',
      position: Vector2(size.x / 2, size.y * 0.12),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFFFF3131), fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
    add(_statusText);

    _spawnInitialCracks();
  }

  void _spawnInitialCracks() {
    for (int i = 0; i < 5; i++) {
      _addCrack();
    }
  }

  void _addCrack() {
    if (_isFinished) return;
    final random = Random();
    add(MirrorCrack(
      position: Vector2(
        80 + random.nextDouble() * (size.x - 160),
        size.y * 0.3 + random.nextDouble() * (size.y * 0.5),
      ),
      onFixed: () {
        _cracksFixed++;
        
        // Sacudida de pantalla más violenta
        gameRef.camera.viewfinder.add(
          MoveEffect.by(
            Vector2(8, 4), 
            EffectController(duration: 0.05, reverseDuration: 0.05, repeatCount: 4),
          )
        );
        
        if (_cracksFixed >= _targetCracks) {
          _isFinished = true;
          onComplete();
        } else {
          // Aparecen nuevas grietas agresivamente
          if (children.whereType<MirrorCrack>().length < 4) {
             _addCrack();
             if (random.nextBool()) _addCrack();
          }
        }
      },
    ));
  }

  @override
  void reset() {
    _cracksFixed = 0;
    _isFinished = false;
    children.whereType<MirrorCrack>().forEach((c) => c.removeFromParent());
    _spawnInitialCracks();
  }
}

class MirrorCrack extends PositionComponent with TapCallbacks {
  final VoidCallback onFixed;
  final List<List<Offset>> _shardLines = [];

  MirrorCrack({
    required Vector2 position,
    required this.onFixed,
  }) : super(position: position, anchor: Anchor.center, size: Vector2.all(120)) {
    // Generar líneas de fractura aleatorias más orgánicas
    final random = Random();
    for (int i = 0; i < 8; i++) {
      final List<Offset> line = [
        Offset(size.x / 2, size.y / 2), // Centro
        Offset(random.nextDouble() * size.x, random.nextDouble() * size.y),
      ];
      _shardLines.add(line);
    }
  }

  @override
  void render(Canvas canvas) {
    // Dibujo del cristal roto
    final paint = Paint()
      ..color = const Color(0xFFFF4D4D).withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // Líneas principales
    for (final line in _shardLines) {
      canvas.drawLine(line[0], line[1], paint);
    }

    // Efecto de manchas de sangre (puntos)
    final bloodPaint = Paint()..color = const Color(0xFF8B0000).withOpacity(0.6);
    final random = Random(1234); // Seed para que no parpadeen
    for (int i = 0; i < 10; i++) {
      canvas.drawCircle(
        Offset(random.nextDouble() * size.x, random.nextDouble() * size.y),
        random.nextDouble() * 4,
        bloodPaint
      );
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Flash de impacto
    add(ColorEffect(Colors.white, EffectController(duration: 0.1, reverseDuration: 0.1), opacityTo: 0.5));
    
    add(ScaleEffect.to(Vector2.all(1.8), EffectController(duration: 0.1))..onComplete = () {
      add(ScaleEffect.to(Vector2.zero(), EffectController(duration: 0.1))..onComplete = () {
        onFixed();
        removeFromParent();
      });
    });
  }
}
