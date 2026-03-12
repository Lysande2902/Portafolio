import 'dart:async' as async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
import 'package:humano/game/hack_system/mind_hack_puzzle.dart';

class EgoSyntaxPuzzle extends MindHackPuzzle {
  final List<String> _egoWords = ['YO', 'MI', 'ME', 'EGO', 'FAMA', 'LIKES', 'VIEWS', 'TODO YO'];
  final List<String> _truthWords = ['VÍCTOR', 'MAMÁ', 'MAGNOLIA', 'LO SIENTO', 'PERDÓN', 'VERDAD', 'HERMANO'];
  
  int _truthsFound = 0;
  final int _targetTruths = 5;
  late TextComponent _statusText;
  late TextComponent _counterText;
  double _spawnTimer = 0;
  final double _spawnInterval = 0.9;
  bool _isFinished = false;

  EgoSyntaxPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "SINTAXIS DE EGO";

  @override
  String get instruction => "TOCA LAS PALABRAS QUE REPRESENTAN LA VERDAD (CIAN) Y EVITA LAS QUE ALIMENTAN EL EGO (GRIS)";

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _statusText = TextComponent(
      text: '[3] SINTAXIS DE EGO',
      position: Vector2(size.x / 2, size.y * 0.12),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFF00F0FF), fontSize: 18),
      ),
    );
    add(_statusText);

    _counterText = TextComponent(
      text: 'CONEXIONES: 0/$_targetTruths',
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
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnWord();
    }
  }

  void _spawnWord() {
    final isTruth = Random().nextDouble() < 0.3; // 30% chance of truth
    final text = isTruth 
      ? _truthWords[Random().nextInt(_truthWords.length)]
      : _egoWords[Random().nextInt(_egoWords.length)];

    add(SyntaxWordComponent(
      text: text,
      isTruth: isTruth,
      onTapTruth: () {
        _truthsFound++;
        _counterText.text = 'CONEXIONES: $_truthsFound/$_targetTruths';
        if (_truthsFound >= _targetTruths) {
          _isFinished = true;
          onComplete();
        }
      },
      onTapEgo: () => onFail(),
      position: Vector2(
        50 + Random().nextDouble() * (size.x - 100),
        size.y * 0.3 + Random().nextDouble() * (size.y * 0.5),
      ),
    ));
  }

  @override
  void reset() {
    _truthsFound = 0;
    _isFinished = false;
    children.whereType<SyntaxWordComponent>().forEach((w) => w.removeFromParent());
  }
}

class SyntaxWordComponent extends PositionComponent with TapCallbacks {
  final String text;
  final bool isTruth;
  final VoidCallback onTapTruth;
  final VoidCallback onTapEgo;
  late Vector2 _velocity;

  SyntaxWordComponent({
    required this.text,
    required this.isTruth,
    required this.onTapTruth,
    required this.onTapEgo,
    required Vector2 position,
  }) : super(position: position, anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    final color = isTruth ? const Color(0xFF00F0FF) : Colors.white.withOpacity(0.3);
    final random = Random();
    
    _velocity = Vector2(random.nextDouble() * 60 - 30, random.nextDouble() * 40 - 20);

    add(TextComponent(
      text: text,
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(
          color: color, 
          fontSize: isTruth ? 24 : 16, 
          fontWeight: isTruth ? FontWeight.bold : FontWeight.normal,
          shadows: isTruth ? [const Shadow(color: Color(0xFF00F0FF), blurRadius: 10)] : [],
        ),
      ),
    ));

    // Desaparecer después de 2 segundos
    add(ScaleEffect.to(
      Vector2.all(1.2), 
      EffectController(duration: 2.0),
    )..onComplete = () => removeFromParent());
    
    add(OpacityEffect.fadeOut(
      EffectController(duration: 2.0),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += _velocity * dt;
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isTruth) {
      onTapTruth();
      removeFromParent();
    } else {
      onTapEgo();
    }
  }
}
