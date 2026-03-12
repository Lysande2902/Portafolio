import 'dart:async' as async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
import 'package:humano/game/hack_system/mind_hack_puzzle.dart';

class MissedCallPuzzle extends MindHackPuzzle {
  late TextComponent _statusText;
  late TextComponent _counterText;
  int _answered = 0;
  final int _targetAnswered = 15;
  double _spawnTimer = 0;
  final double _spawnInterval = 0.7;
  bool _isFinished = false;

  final List<String> _messages = [
    '¿Alex?', '¿Dónde estás?', 'Por favor...', 'Contesta...', 'Es Vic...', 'Hay fuego...', 'Tengo miedo...', '¿Me oyes?', 'Ayuda...', '¿Por qué no...?', 'Mamá no sabe...', 'Hermano...', 'Te necesito...', 'No llegas...', 'Adiós.'
  ];

  MissedCallPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "LLAMADAS PERDIDAS";

  @override
  String get instruction => "CONTESTA LAS LLAMADAS DE VÍCTOR TOCANDO LOS ICONOS ROJOS";

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _statusText = TextComponent(
      text: '[15] LLAMADAS PERDIDAS - VÍCTOR',
      position: Vector2(size.x / 2, size.y * 0.35),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFFFF3131), fontSize: 18),
      ),
    );
    add(_statusText);
 
    _counterText = TextComponent(
      text: 'LLAMADAS: 0/$_targetAnswered',
      position: Vector2(size.x / 2, size.y * 0.40),
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
    if (_spawnTimer >= _spawnInterval && _answered + children.whereType<PhoneIcon>().length < _targetAnswered) {
      _spawnTimer = 0;
      _spawnCall();
    }
  }
 
  void _spawnCall() {
    final random = Random();
    add(PhoneIcon(
      message: _messages[(_answered + children.whereType<PhoneIcon>().length) % _messages.length],
      onAnswered: () {
        _answered++;
        _counterText.text = 'LLAMADAS: $_answered/$_targetAnswered';
        if (_answered >= _targetAnswered) {
          _isFinished = true;
          onComplete();
        }
      },
      position: Vector2(
        80 + random.nextDouble() * (size.x - 160),
        size.y * 0.45 + random.nextDouble() * (size.y * 0.4),
      ),
    ));
  }

  @override
  void reset() {
    _answered = 0;
    _isFinished = false;
    children.whereType<PhoneIcon>().forEach((p) => p.removeFromParent());
  }
}

class PhoneIcon extends PositionComponent with TapCallbacks {
  final String message;
  final VoidCallback onAnswered;
  bool _handled = false;

  PhoneIcon({
    required this.message,
    required this.onAnswered,
    required Vector2 position,
  }) : super(position: position, anchor: Anchor.center, size: Vector2.all(70));

  @override
  Future<void> onLoad() async {
    debugPrint('📞 [CALL] Loading PhoneIcon at $position');
    
    // Círculo técnico estilo neón (más fiable que los iconos de fuente)
    add(CircleComponent(
      radius: size.x / 2,
      paint: Paint()
        ..color = const Color(0xFFFF3131).withOpacity(0.2)
        ..style = PaintingStyle.fill,
    ));

    add(CircleComponent(
      radius: size.x / 2,
      paint: Paint()
        ..color = const Color(0xFFFF3131)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    )..add(OpacityEffect.fadeOut(
      EffectController(duration: 0.2, reverseDuration: 0.2, infinite: true),
    )));

    add(TextComponent(
      text: 'LLAMADA',
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    ));

    scale = Vector2.zero();
    add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.3)));
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_handled) return;
    _handled = true;

    // Mostrar el mensaje de Víctor al contestar
    // Usamos solo MoveEffect y quitamos OpacityEffect para evitar crasheos en TextComponent
    add(TextComponent(
      text: message,
      anchor: Anchor.center,
      position: Vector2(size.x / 2, -20),
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    )..add(MoveByEffect(Vector2(0, -60), EffectController(duration: 0.8)))
     ..add(ScaleEffect.to(Vector2.zero(), EffectController(duration: 0.8))));

    // Animación de desaparición del ícono
    add(ScaleEffect.to(Vector2.all(0.0), EffectController(duration: 0.15))
      ..onComplete = () {
        onAnswered();
        removeFromParent();
      });
  }
}
