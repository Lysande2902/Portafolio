import 'dart:async' as async;
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
import 'package:humano/game/hack_system/mind_hack_puzzle.dart';

class StaticClearPuzzle extends MindHackPuzzle {
  late TextComponent _statusText;
  late TextComponent _instructionText;
  int _taps = 0;
  final int _targetTaps = 20;
  bool _isFinished = false;
  late RectangleComponent _staticOverlay;

  StaticClearPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "CLARIDAD DIGITAL";

  @override
  String get instruction => "LIMPIA EL RUIDO DE LA SEÑAL TOCANDO REPETIDAMENTE LA PANTALLA";

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _statusText = TextComponent(
      text: '[3] CLARIDAD DIGITAL',
      position: Vector2(size.x / 2, size.y * 0.12),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFFFF3131), fontSize: 18),
      ),
    );
    add(_statusText);

    _instructionText = TextComponent(
      text: 'PULSA PARA LIMPIAR EL RUIDO',
      position: Vector2(size.x / 2, size.y * 0.17),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.white54, fontSize: 12),
      ),
    );
    add(_instructionText);

    // Un fondo de "ruido" que se irá aclarando
    _staticOverlay = RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFFFF3131).withOpacity(0.6),
    );
    add(_staticOverlay);

    // Añadir algunas partículas de estática
    for (int i = 0; i < 30; i++) {
      add(_StaticParticle(screenSize: size));
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_isFinished) return;

    _taps++;
    // Reducir la opacidad del ruido
    final progress = _taps / _targetTaps;
    _staticOverlay.paint.color = const Color(0xFFFF3131).withOpacity((0.6 - (progress * 0.6)).clamp(0, 0.6));
    
    // Feedback visual al tocar
    gameRef.camera.viewfinder.add(
      MoveEffect.by(Vector2(2, 2), EffectController(duration: 0.05, reverseDuration: 0.05))
    );

    if (_taps >= _targetTaps) {
      _isFinished = true;
      _instructionText.text = 'SEÑAL ENCONTRADA';
      _staticOverlay.paint.color = Colors.transparent;
      
      // Eliminar partículas inmediatamente para evitar errores de OpacityEffect
      children.whereType<_StaticParticle>().forEach((p) => p.removeFromParent());
      
      Future.delayed(const Duration(milliseconds: 1000), () => onComplete());
    }
  }

  @override
  void reset() {
    _taps = 0;
    _isFinished = false;
  }
}

class _StaticParticle extends PositionComponent {
  final Vector2 screenSize;
  _StaticParticle({required this.screenSize}) : super(anchor: Anchor.center);

  @override
  void onMount() {
    super.onMount();
    final random = math.Random();
    position = Vector2(random.nextDouble() * screenSize.x, random.nextDouble() * screenSize.y);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.white.withOpacity(math.Random().nextDouble() * 0.3);
    canvas.drawRect(Rect.fromLTWH(0, 0, 4, 4), paint);
  }

  @override
  void update(double dt) {
    if (math.Random().nextDouble() < 0.1) {
      position = Vector2(math.Random().nextDouble() * screenSize.x, math.Random().nextDouble() * screenSize.y);
    }
  }
}
