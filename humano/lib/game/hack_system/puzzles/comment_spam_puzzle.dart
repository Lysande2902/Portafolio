import 'dart:async' as async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
import 'package:humano/game/hack_system/mind_hack_puzzle.dart';

class CommentSpamPuzzle extends MindHackPuzzle {
  int _round = 0;
  final int _targetRounds = 3;
  late TextComponent _statusText;
  late TextComponent _counterText;
  final List<SpamComponent> _activeSpam = [];
  bool _isFinished = false;

  CommentSpamPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "DEPURACIÓN DE COMENTARIOS";

  @override
  String get instruction => "ELIMINA EL RUIDO SOCIAL REPRIMIENDO LOS MENSAJES NEGATIVOS";

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final screenSize = gameRef.size;

    _statusText = TextComponent(
      text: '[1] SPAM TÓXICO',
      position: Vector2(screenSize.x / 2, screenSize.y * 0.12),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFF00F0FF), fontSize: 18),
      ),
    );
    add(_statusText);

    _counterText = TextComponent(
      text: 'LIMPIEZA: 0/$_targetRounds',
      position: Vector2(screenSize.x / 2, screenSize.y * 0.17),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 16),
      ),
    );
    add(_counterText);

    _startRound();
  }

  void _startRound() {
    if (_round >= _targetRounds) {
      _isFinished = true;
      Future.delayed(const Duration(milliseconds: 500), () => onComplete());
      return;
    }

    _activeSpam.clear();
    final count = 6 + (_round * 3); // Aumentada la dificultad: más spam por ronda
    final random = Random();
    
    for (int i = 0; i < count; i++) {
      final spam = SpamComponent(
        onTap: (s) => _handleSpamTap(s),
        position: Vector2(
          80 + random.nextDouble() * (gameRef.size.x - 160),
          180 + random.nextDouble() * (gameRef.size.y - 350),
        ),
      );
      _activeSpam.add(spam);
      add(spam);
    }
  }

  void _handleSpamTap(SpamComponent spam) {
    if (_isFinished) return;
    
    spam.removeFromParent();
    _activeSpam.remove(spam);

    if (_activeSpam.isEmpty) {
      _round++;
      _counterText.text = 'LIMPIEZA: $_round/$_targetRounds';
      _startRound();
    }
  }

  @override
  void reset() {
    _round = 0;
    _isFinished = false;
    _activeSpam.forEach((s) => s.removeFromParent());
    _activeSpam.clear();
    _counterText.text = 'LIMPIEZA: 0/$_targetRounds';
    _startRound();
  }
}

class SpamComponent extends PositionComponent with TapCallbacks, HasGameRef<BaseArcGame> {
  final Function(SpamComponent) onTap;
  late Vector2 _velocity;
  static final List<String> _comments = [
    'ERES BASURA', 'NADIE TE QUIERE', 'DAME LIKE O MUERE', 'FALSO', 'ESTAFADOR', 
    'HORRIBLE', 'PATÉTICO', 'COPIA BARATA', 'CANCELADO', 'INÚTIL'
  ];

  SpamComponent({required this.onTap, required Vector2 position}) 
    : super(position: position, size: Vector2(160, 45), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final random = Random();
    final msg = _comments[random.nextInt(_comments.length)];
    
    // Movimiento aleatorio lento (Deriva)
    _velocity = Vector2(random.nextDouble() * 20 - 10, random.nextDouble() * 20 - 10);

    // Fondo estilo burbuja de chat "corrupta"
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..shader = LinearGradient(
          colors: [Colors.red.withOpacity(0.3), Colors.black.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromLTWH(0, 0, size.x, size.y)),
    )..add(RectangleComponent(
        size: size,
        paint: Paint()
          ..color = Colors.redAccent.withOpacity(0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
    )));

    add(TextComponent(
      text: msg,
      position: size / 2,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(
          color: Colors.white, 
          fontSize: 13, 
          fontWeight: FontWeight.bold,
          shadows: [const Shadow(color: Colors.red, blurRadius: 4)]
        ),
      ),
    ));

    // Animación de entrada
    scale = Vector2.zero();
    add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.3, curve: Curves.bounceOut)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Aplicar deriva
    position += _velocity * dt;
    
    // Rebote simple en bordes
    if (position.x < 50 || position.x > gameRef.size.x - 50) _velocity.x *= -1;
    if (position.y < 150 || position.y > gameRef.size.y - 150) _velocity.y *= -1;
  }

  @override
  void onTapDown(TapDownEvent event) {
    // Animación de salida rápida
    add(ScaleEffect.to(
      Vector2.all(1.2), 
      EffectController(duration: 0.1, reverseDuration: 0.1),
    )..onComplete = () => onTap(this));

  }
}
