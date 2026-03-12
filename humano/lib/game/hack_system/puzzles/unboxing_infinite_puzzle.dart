import 'dart:async' as async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
import 'package:humano/game/hack_system/mind_hack_puzzle.dart';

class UnboxingInfinitePuzzle extends MindHackPuzzle {
  late TextComponent _statusText;
  late TextComponent _counterText;
  int _totalDestroyed = 0;
  final int _requiredDestroyed = 15;
  bool _isFinished = false;

  UnboxingInfinitePuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "UNBOXING INFINITO";

  @override
  String get instruction => "ABRE LAS CAJAS TOCÁNDOLAS HASTA QUE NO QUEDE NADA MÁS QUE EL VACÍO";

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _statusText = TextComponent(
      text: '[3] UNBOXING INFINITO',
      position: Vector2(size.x / 2, size.y * 0.12),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFF00F0FF), fontSize: 18),
      ),
    );
    add(_statusText);

    _counterText = TextComponent(
      text: 'VACÍO: 0/$_requiredDestroyed',
      position: Vector2(size.x / 2, size.y * 0.17),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 16),
      ),
    );
    add(_counterText);

    _spawnRootBox();
  }

  void _spawnRootBox() {
    add(BoxComponent(
      position: size / 2,
      level: 0,
      onSplit: (newBoxes) {
        for (var box in newBoxes) {
          add(box);
        }
      },
      onDestroyed: () => _onBoxDestroyed(),
    ));
  }

  void _onBoxDestroyed() {
    if (_isFinished) return;
    _totalDestroyed++;
    _counterText.text = 'VACÍO: $_totalDestroyed/$_requiredDestroyed';

    if (_totalDestroyed >= _requiredDestroyed) {
      _isFinished = true;
      _counterText.text = 'TODO ESTÁ VACÍO';
      Future.delayed(const Duration(milliseconds: 1000), () => onComplete());
    } else {
      // Si no quedan cajas en pantalla, spawnear otra raíz
      Future.delayed(const Duration(milliseconds: 500), () {
        if (children.whereType<BoxComponent>().isEmpty && !_isFinished) {
          _spawnRootBox();
        }
      });
    }
  }

  @override
  void reset() {
    _totalDestroyed = 0;
    _isFinished = false;
    _counterText.text = 'VACÍO: 0/$_requiredDestroyed';
    children.whereType<BoxComponent>().forEach((b) => b.removeFromParent());
    _spawnRootBox();
  }
}

class BoxComponent extends PositionComponent with TapCallbacks {
  final int level;
  final Function(List<BoxComponent>) onSplit;
  final VoidCallback onDestroyed;
  bool _isSplit = false;

  BoxComponent({
    required Vector2 position,
    required this.level,
    required this.onSplit,
    required this.onDestroyed,
  }) : super(position: position, anchor: Anchor.center) {
    // Escalar tamaño según el nivel
    size = Vector2.all(120 / (level + 1));
  }

  @override
  Future<void> onLoad() async {
    final color = const Color(0xFF00F0FF).withOpacity(0.8 / (level + 1));
    
    // Cuadrado con estilo técnico
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 2,
    ));
    
    add(RectangleComponent(
      size: size * 0.8,
      position: size / 2,
      anchor: Anchor.center,
      paint: Paint()..color = color.withOpacity(0.1),
    ));

    // Cruz interior (cuerda de caja)
    add(RectangleComponent(
      size: Vector2(size.x, 1),
      position: Vector2(0, size.y / 2),
      paint: Paint()..color = color.withOpacity(0.3),
    ));
    add(RectangleComponent(
      size: Vector2(1, size.y),
      position: Vector2(size.x / 2, 0),
      paint: Paint()..color = color.withOpacity(0.3),
    ));

    // Animación de entrada
    scale = Vector2.zero();
    add(ScaleEffect.to(Vector2.all(1.0), EffectController(duration: 0.3, curve: Curves.easeOutBack)));
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (_isSplit) return;
    
    // Si el puzzle ya terminó, no procesar más clics
    if ((parent as UnboxingInfinitePuzzle)._isFinished) return;

    _isSplit = true;

    if (level < 2) {
      // Splitting (Divide la caja en 4)
      final List<BoxComponent> newBoxes = [];
      final offset = size.x / 2.5;
      
      final positions = [
        position + Vector2(-offset, -offset),
        position + Vector2(offset, -offset),
        position + Vector2(-offset, offset),
        position + Vector2(offset, offset),
      ];

      for (var pos in positions) {
        newBoxes.add(BoxComponent(
          position: pos,
          level: level + 1,
          onSplit: onSplit,
          onDestroyed: onDestroyed,
        ));
      }
      
      onSplit(newBoxes);
      removeFromParent();
    } else {
      // Final level destroy (Nivel 2 -> 16 cajas)
      // Usamos ScaleEffect para evitar el problema de OpacityProvider
      add(ScaleEffect.to(
        Vector2.zero(), 
        EffectController(duration: 0.2),
      )..onComplete = () {
        onDestroyed();
        removeFromParent();
      });
    }
  }
}
