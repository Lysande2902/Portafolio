import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:humano/game/core/base/base_arc_game.dart';

/// Base component for individual mind-hacking puzzles
abstract class MindHackPuzzle extends PositionComponent with HasGameRef<BaseArcGame>, TapCallbacks {
  final VoidCallback onComplete;
  final VoidCallback onFail;

  MindHackPuzzle({
    required this.onComplete,
    required this.onFail,
  });

  /// The title of the puzzle for the tutorial
  String get title;
  
  /// The instructions for the puzzle
  String get instruction;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Pre-set size so subclasses can use it for layout in their own onLoad
    size = gameRef.size;
  }

  @override
  void onMount() {
    super.onMount();
    size = gameRef.size; // Initial size
    position = Vector2.zero(); // Align with topLeft
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size; // Stay full screen
  }

  @override
  void onTapDown(TapDownEvent event) {
    debugPrint('🧩 [PUZZLE_TAP] ${runtimeType} received tap at ${event.localPosition}');
    super.onTapDown(event);
  }

  void reset();
}
