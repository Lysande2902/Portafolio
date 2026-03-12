import 'dart:async' as async;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/game/hack_system/mind_hack_puzzle.dart';

class VanityFilterPuzzle extends MindHackPuzzle {
  final int _targetRounds = 5;
  int _currentRound = 0;
  int? _anomalyIndex;
  final List<FilterTile> _tiles = [];
  late TextComponent _statusText;
  late TextComponent _counterText;

  VanityFilterPuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty, // Añadido para estandarizar con Arco 0
  });

  @override
  String get title => "FILTRO DE VANIDAD";

  @override
  String get instruction => "ENCUENTRA LA ANOMALÍA TOCANDO EL ICONO QUE ES DIFERENTE O PARPADEA";

  @override
  Future<void> onLoad() async {
    debugPrint('📦 [LOAD] VanityFilterPuzzle (Fase 1) - Iniciando onLoad');
    await super.onLoad();

    _statusText = TextComponent(
      text: '[3] FOTO VERDADERA',
      position: Vector2(gameRef.size.x / 2, gameRef.size.y * 0.12),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFF00F0FF), fontSize: 18),
      ),
    );
    add(_statusText);

    _counterText = TextComponent(
      text: 'FASE: 0/$_targetRounds',

      position: Vector2(gameRef.size.x / 2, gameRef.size.y * 0.17),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 16),
      ),
    );
    add(_counterText);

    _setupGrid();
    _startRound();
  }

  void _setupGrid() {
    final gridPadding = 40.0;
    // Use gameRef.size to ensure we have the actual screen dimensions
    final screenSize = gameRef.size;
    final gridSize = min(screenSize.x, screenSize.y) - (gridPadding * 2);
    final tileSize = gridSize / 4;

    for (int i = 0; i < 16; i++) {
      final row = i ~/ 4;
      final col = i % 4;
      final tile = FilterTile(
        index: i,
        size: Vector2.all(tileSize - 10),
        position: Vector2(
          (screenSize.x - gridSize) / 2 + col * tileSize,
          (screenSize.y - gridSize) / 2 + row * tileSize - 20,
        ),
        onTap: _handleTileTap,
      );
      _tiles.add(tile);
      add(tile);
    }
  }

  void _startRound() {
    if (_currentRound >= _targetRounds) {
      debugPrint('✨ [PUZZLE] VanityFilterPuzzle target reached. Calling onComplete()');
      _isFinished = true;
      Future.delayed(const Duration(milliseconds: 600), () => onComplete());
      return;
    }


    final random = Random();
    _anomalyIndex = random.nextInt(16);
    
    // Reset all tiles
    final baseIcon = _getRandomIcon(random);
    final anomalyIcon = _getRandomIcon(random, exclude: baseIcon);

    for (int i = 0; i < _tiles.length; i++) {
       _tiles[i].setup(i == _anomalyIndex ? anomalyIcon : baseIcon, i == _anomalyIndex);
    }
  }

  IconData _getRandomIcon(Random r, {IconData? exclude}) {
    final icons = [
      Icons.face,
      Icons.camera_alt,
      Icons.auto_awesome,
      Icons.visibility,
      Icons.diamond,
      Icons.theater_comedy,
      Icons.phone_android,
      Icons.favorite,
    ];
    IconData icon;
    do {
      icon = icons[r.nextInt(icons.length)];
    } while (icon == exclude);
    return icon;
  }

  bool _isFinished = false;

  void _handleTileTap(int index) {
    if (_isFinished) return;

    if (index == _anomalyIndex) {
      if (_currentRound + 1 >= _targetRounds) {
        _isFinished = true;
      }
      _currentRound++;
      _counterText.text = 'FASE: $_currentRound/$_targetRounds';
      _startRound();
    } else {
      onFail();
    }
  }

  @override
  void reset() {
    _currentRound = 0;
    _counterText.text = 'FASE: 0/$_targetRounds';
    _startRound();
  }
}

class FilterTile extends PositionComponent with TapCallbacks {
  final int index;
  final Function(int) onTap;
  late TextComponent _iconText;
  bool isAnomaly = false;

  FilterTile({
    required this.index,
    required Vector2 size,
    required Vector2 position,
    required this.onTap,
  }) : super(size: size, position: position);

  @override
  Future<void> onLoad() async {
    add(RectangleComponent(
      size: size,
      paint: Paint()
        ..color = Colors.white.withOpacity(0.05)
        ..style = PaintingStyle.fill,
    ));

    _iconText = TextComponent(
      text: '',
      anchor: Anchor.center,
      position: size / 2,
      textRenderer: TextPaint(
        style: TextStyle(
          fontSize: 32,
          fontFamily: 'MaterialIcons',
          color: Colors.white.withOpacity(0.9),
        ),
      ),
    );
    add(_iconText);
  }

  void setup(IconData icon, bool anomaly) {
    _iconText.text = String.fromCharCode(icon.codePoint);
    isAnomaly = anomaly;
    
    // Clear previous effects and reset opacity
    _iconText.removeAll(_iconText.children.whereType<OpacityEffect>());
    _iconText.add(OpacityEffect.to(1.0, EffectController(duration: 0)));

    if (isAnomaly) {
      _iconText.add(OpacityEffect.to(
        0.3,
        EffectController(duration: 0.2, reverseDuration: 0.2, infinite: true),
      ));
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    onTap(index);
  }
}
