import 'dart:async' as async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
import 'package:humano/game/hack_system/mind_hack_puzzle.dart';

class ConveyorBeltPuzzle extends MindHackPuzzle {
  final int _targetSaves = 10;
  int _saves = 0;
  late TextComponent _statusText;
  late TextComponent _counterText;
  double _spawnTimer = 0;
  final double _spawnInterval = 1.2;
  bool _isFinished = false;

  ConveyorBeltPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "CINTA DE EXCESO";

  @override
  String get instruction => "ELIMINA EL LUJO (DORADO) Y DEJA PASAR LO ESENCIAL (BLANCO)";

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // HUD del Puzzle
    _statusText = TextComponent(
      text: '[1] CINTA DE EXCESO',
      position: Vector2(size.x / 2, size.y * 0.12),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFF00F0FF), fontSize: 18),
      ),
    );
    add(_statusText);

    _counterText = TextComponent(
      text: 'FILTRADO: 0/$_targetSaves',
      position: Vector2(size.x / 2, size.y * 0.17),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 16),
      ),
    );
    add(_counterText);

    // Dibujar la "Cinta" visualmente
    add(RectangleComponent(
      position: Vector2(0, size.y * 0.5),
      size: Vector2(size.x, 4),
      paint: Paint()..color = Colors.white.withOpacity(0.1),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isFinished) return;

    _spawnTimer += dt;
    if (_spawnTimer >= _spawnInterval) {
      _spawnTimer = 0;
      _spawnItem();
    }
  }

  void _spawnItem() {
    final isLuxury = Random().nextBool();
    final item = ConveyorItem(
      isLuxury: isLuxury,
      onDestroyed: (correct) {
        if (correct) {
          _updateScore();
        } else {
          onFail();
        }
      },
      onPassed: (missed) {
        if (missed) {
          onFail();
        } else {
          _updateScore();
        }
      },
    );
    add(item);
  }

  void _updateScore() {
    _saves++;
    _counterText.text = 'FILTRADO: $_saves/$_targetSaves';
    if (_saves >= _targetSaves) {
      _isFinished = true;
      Future.delayed(const Duration(milliseconds: 500), () => onComplete());
    }
  }

  @override
  void reset() {
    _saves = 0;
    _isFinished = false;
    children.whereType<ConveyorItem>().forEach((element) => element.removeFromParent());
    _counterText.text = 'FILTRADO: 0/$_targetSaves';
  }
}

class ConveyorItem extends PositionComponent with TapCallbacks, HasGameRef<BaseArcGame> {
  final bool isLuxury;
  final Function(bool) onDestroyed;
  final Function(bool) onPassed;
  double _speed = 180;
  bool _handled = false;

  ConveyorItem({
    required this.isLuxury,
    required this.onDestroyed,
    required this.onPassed,
  }) : super(size: Vector2.all(70), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    position = Vector2(-size.x, gameRef.size.y * 0.5);
    
    // Estética del Item
    final color = isLuxury ? const Color(0xFFFFD700) : Colors.white;
    
    if (isLuxury) {
      // Efecto de brillo para lujo
      add(CircleComponent(
        radius: 30,
        anchor: Anchor.center,
        position: size / 2,
        paint: Paint()..color = color.withOpacity(0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      ));
    }

    add(TextComponent(
      text: String.fromCharCode(isLuxury ? Icons.watch.codePoint : Icons.lunch_dining.codePoint),
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 32,
          fontFamily: 'MaterialIcons',
          color: color,
          shadows: isLuxury ? [Shadow(color: color, blurRadius: 10)] : [],
        ),
      ),
    ));

    // Nombre del item para ayudar al jugador
    add(TextComponent(
      text: isLuxury ? 'LUJO' : 'ESENCIAL',
      anchor: Anchor.center,
      position: Vector2(size.x / 2, -15),
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: color.withOpacity(0.7), fontSize: 10),
      ),
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.x += _speed * dt;

    if (position.x > gameRef.size.x + size.x && !_handled) {
      _handled = true;
      onPassed(isLuxury); // Si es lujo y pasa, es un fallo (true). Si es esencial y pasa, es acierto (false).
      removeFromParent();
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_handled) return;
    _handled = true;

    if (isLuxury) {
      // Acierto: destruiste el lujo
      // Usamos ScaleEffect porque OpacityEffect requiere que el componente implemente OpacityProvider
      add(ScaleEffect.to(
        Vector2.zero(), 
        EffectController(duration: 0.2),
      )..onComplete = () {
        onDestroyed(true);
        removeFromParent();
      });
    } else {
      // Error: destruiste algo esencial
      // En lugar de ColorEffect (que puede fallar), escalamos y notificamos fallo
      add(ScaleEffect.to(
        Vector2.all(0.5), 
        EffectController(duration: 0.1),
      )..onComplete = () {
        onDestroyed(false);
        removeFromParent();
      });
    }
  }
}
