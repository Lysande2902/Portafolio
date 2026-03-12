import 'dart:async' as async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
import 'package:humano/game/hack_system/mind_hack_puzzle.dart';

class OverexposurePuzzle extends MindHackPuzzle with DragCallbacks {
  double _exposureLevel = 0.0; // 0.0 to 1.0 (Full white)
  final double _exposureSpeed = 0.15;
  late TextComponent _statusText;
  late TextComponent _warningText;
  late RectangleComponent _whiteOverlay;
  bool _isFinished = false;
  double _timeCleaned = 0;
  final double _targetCleanTime = 8.0;

  OverexposurePuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "SOBREEXPOSICIÓN";

  @override
  String get instruction => "LIMPIA LA PANTALLA ARRASTRANDO EL DEDO PARA REDUCIR EL BRILLO Y VER LA VERDAD";

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _statusText = TextComponent(
      text: '[1] FILTRO DE SOBREEXPOSICIÓN',
      position: Vector2(size.x / 2, size.y * 0.12),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFF00F0FF), fontSize: 18),
      ),
    );
    add(_statusText);

    _warningText = TextComponent(
      text: 'LIMPIA LA CEGUERA DEL EGO',
      position: Vector2(size.x / 2, size.y * 0.17),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.white.withOpacity(0.5), fontSize: 12),
      ),
    );
    add(_warningText);

    // El filtro blanco que se opaca
    _whiteOverlay = RectangleComponent(
      size: size,
      paint: Paint()..color = Colors.white.withOpacity(0),
    );
    add(_whiteOverlay);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isFinished) return;

    // La exposición aumenta sola
    _exposureLevel += _exposureSpeed * dt;
    
    // Si llegas al máximo de exposición, fallas
    if (_exposureLevel >= 1.0) {
      _isFinished = true;
      onFail();
      return;
    }

    _whiteOverlay.paint.color = Colors.white.withOpacity(_exposureLevel.clamp(0, 0.95));

    // Si el jugador mantiene la exposición baja, progresa
    if (_exposureLevel < 0.3) {
      _timeCleaned += dt;
      final progress = (_timeCleaned / _targetCleanTime).clamp(0, 1.0);
      _warningText.text = 'DEPURANDO LUZ: ${(progress * 100).toInt()}%';
      
      if (_timeCleaned >= _targetCleanTime) {
        _isFinished = true;
        _warningText.text = 'VISIÓN RESTAURADA';
        Future.delayed(const Duration(milliseconds: 1000), () => onComplete());
      }
    } else {
      _warningText.text = '¡DÉMASIADA LUZ! LIMPIA LA PANTALLA';
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_isFinished) return;
    
    // Reducción de exposición al arrastrar (Limpiar)
    // El movimiento reduce la exposición más rápido de lo que sube
    _exposureLevel -= (event.localDelta.length / 500);
    if (_exposureLevel < 0) _exposureLevel = 0;
  }

  @override
  void reset() {
    _exposureLevel = 0;
    _timeCleaned = 0;
    _isFinished = false;
  }
}
