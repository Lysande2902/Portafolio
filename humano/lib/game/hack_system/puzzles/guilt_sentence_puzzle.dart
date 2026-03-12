import 'dart:async' as async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
import 'package:humano/game/hack_system/mind_hack_puzzle.dart';

class GuiltSentencePuzzle extends MindHackPuzzle {
  late TextComponent _statusText;
  late TextComponent _counterText;
  int _accepted = 0;
  final int _targetAccepted = 6;
  double _spawnTimer = 0;
  final double _spawnInterval = 2.0;
  bool _isFinished = false;

  final List<String> _sentences = [
    'YO LO MATÉ', 
    'FUE MI CULPA', 
    'LLEGUÉ TARDE', 
    'LO IGNORÉ', 
    'PREFERÍ LA FAMA', 
    'FALLÉ COMO HERMANO'
  ];

  GuiltSentencePuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "SENTENCIA DE CULPA";

  @override
  String get instruction => "ACEPTA LA RESPONSABILIDAD TOCANDO LAS PALABRAS QUE CAEN";

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _statusText = TextComponent(
      text: '[4] SENTENCIA DE CULPA',
      position: Vector2(size.x / 2, size.y * 0.12),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFFFF3131), fontSize: 18),
      ),
    );
    add(_statusText);

    _counterText = TextComponent(
      text: 'ACEPTACIÓN: 0/$_targetAccepted',
      position: Vector2(size.x / 2, size.y * 0.17),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 14),
      ),
    );
    add(_counterText);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isFinished) return;

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval && _accepted + children.whereType<GuiltWord>().length < _targetAccepted) {
      _spawnTimer = 0;
      _spawnSentence();
    }
  }

  void _spawnSentence() {
    final random = Random();
    add(GuiltWord(
      text: _sentences[_accepted % _sentences.length],
      onAccepted: () {
        _accepted++;
        _counterText.text = 'ACEPTACIÓN: $_accepted/$_targetAccepted';
        if (_accepted >= _targetAccepted) {
          _isFinished = true;
          onComplete();
        }
      },
      position: Vector2(
        50 + random.nextDouble() * (size.x - 100),
        -50,
      ),
    ));
  }

  @override
  void reset() {
    _accepted = 0;
    _isFinished = false;
    children.whereType<GuiltWord>().forEach((w) => w.removeFromParent());
  }
}

class GuiltWord extends PositionComponent with TapCallbacks {
  final String text;
  final VoidCallback onAccepted;
  double _speed = 100;

  GuiltWord({
    required this.text,
    required this.onAccepted,
    required Vector2 position,
  }) : super(position: position, anchor: Anchor.center, size: Vector2(250, 50));

  @override
  Future<void> onLoad() async {
    add(TextComponent(
      text: text,
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(
          color: Colors.white, 
          fontSize: 22, 
          fontWeight: FontWeight.bold,
          shadows: [const Shadow(color: Colors.red, blurRadius: 10)],
        ),
      ),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += _speed * dt;

    if (position.y > 800) {
      // Si el jugador no la toca, la palabra se "pierde", pero este puzzle requiere tocarlas para aceptarlas
      removeFromParent();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    // A diferencia de otros, aquí tocar es "aceptar"
    add(ScaleEffect.to(Vector2.all(1.5), EffectController(duration: 0.1, reverseDuration: 0.2))..onComplete = () {
      onAccepted();
      removeFromParent();
    });
  }
}
