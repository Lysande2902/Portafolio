import 'dart:async' as async;
import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:humano/game/core/base/base_arc_game.dart';
import 'package:humano/game/hack_system/mind_hack_puzzle.dart';

class VoiceNotePuzzle extends MindHackPuzzle with DragCallbacks {
  late TextComponent _statusText;
  late TextComponent _instructionText;
  late TextComponent _syncText;
  late WaveformComponent _waveform;
  
  double _scrubberPos = 0.0; // 0.0 to 1.0 (Horizontal position)
  double _sweetSpot = 0.5; // The secret position where the voice is clear
  double _driftDir = 1.0;
  double _stability = 0.0;
  bool _isFinished = false;

  VoiceNotePuzzle({
    required super.onComplete,
    required super.onFail,
    int? difficulty,
  });

  @override
  String get title => "RECUPERACIÓN DE AUDIO";

  @override
  String get instruction => "ARRASTRA EL MARCADOR ROJO PARA SINTONIZAR LA FRECUENCIA HASTA QUE LA ONDA SEA ESTABLE";

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _statusText = TextComponent(
      text: '[4] NOTA DE VOZ: 9 SEG',
      position: Vector2(size.x / 2, size.y * 0.12),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFFFF3131), fontSize: 18),
      ),
    );
    add(_statusText);

    _instructionText = TextComponent(
      text: 'ENCUENTRA LA FRECUENCIA DE VÍCTOR',
      position: Vector2(size.x / 2, size.y * 0.17),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: Colors.white54, fontSize: 12),
      ),
    );
    add(_instructionText);

    _waveform = WaveformComponent(position: Vector2(size.x / 2, size.y * 0.45));
    add(_waveform);

    _syncText = TextComponent(
      text: 'SYNC: 0%',
      position: Vector2(size.x / 2, size.y * 0.6),
      anchor: Anchor.center,
      textRenderer: TextPaint(
        style: GoogleFonts.shareTechMono(color: const Color(0xFF00F0FF), fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
    add(_syncText);

    // Track de sintonización (Visual)
    add(RectangleComponent(
      position: Vector2(size.x / 2, size.y * 0.8),
      size: Vector2(size.x * 0.8, 4),
      anchor: Anchor.center,
      paint: Paint()..color = Colors.white24,
    ));

    // El marcador (Scrubber)
    add(ScrubberIndicator(position: Vector2(size.x / 2, size.y * 0.8)));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_isFinished) return;

    // El punto dulce "deriva" lentamente para obligar al jugador a corregir
    _sweetSpot += _driftDir * 0.1 * dt;
    if (_sweetSpot > 0.9) _driftDir = -1.0;
    if (_sweetSpot < 0.1) _driftDir = 1.0;

    // Calcular distancia entre el scrubber y el sweet spot
    double dist = (_scrubberPos - _sweetSpot).abs();
    bool inRange = dist < 0.06;

    if (inRange) {
      _stability += dt * 0.4; // Progreso
      _waveform.isStable = true;
      _syncText.text = 'SYNC: ${(_stability * 100).toInt()}%';
      _syncText.scale = Vector2.all(1.0 + math.sin(_stability * 20) * 0.1);
    } else {
      _stability = (_stability - dt * 0.1).clamp(0.0, 1.0); // Pierde progreso si se aleja mucho
      _waveform.isStable = false;
      _syncText.text = 'BUSCANDO FRECUENCIA...';
      _syncText.scale = Vector2.all(1.0);
    }

    _waveform.noiseLevel = (dist * 3.0).clamp(0.0, 1.0);

    if (_stability >= 1.0) {
      _isFinished = true;
      _syncText.text = 'AUDIO RESTAURADO';
      _syncText.add(ColorEffect(Colors.white, EffectController(duration: 0.2, repeatCount: 3, reverseDuration: 0.2)));
      Future.delayed(const Duration(milliseconds: 1200), () => onComplete());
    }
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (_isFinished) return;
    // Mover el scrubber basado en el arrastre horizontal
    _scrubberPos += event.localDelta.x / (size.x * 0.8);
    _scrubberPos = _scrubberPos.clamp(0.0, 1.0);
  }

  @override
  void reset() {
    _stability = 0;
    _scrubberPos = 0.5;
    _isFinished = false;
  }
}

class ScrubberIndicator extends PositionComponent with HasGameRef<BaseArcGame> {
  ScrubberIndicator({required super.position}) : super(anchor: Anchor.center, size: Vector2(20, 60));

  @override
  void render(Canvas canvas) {
    final parentPuzzle = parent as VoiceNotePuzzle;
    final visualPosX = (parentPuzzle._scrubberPos - 0.5) * (gameRef.size.x * 0.8);
    
    final paint = Paint()..color = const Color(0xFFFF3131);
    final rect = Rect.fromCenter(center: Offset(visualPosX, 0), width: 10, height: 40);
    canvas.drawRect(rect, paint);
    
    // Aura de neón
    canvas.drawRect(rect.inflate(4), paint..color = paint.color.withOpacity(0.2)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
  }
}

class WaveformComponent extends PositionComponent {
  bool isStable = false;
  double noiseLevel = 1.0;
  double _time = 0;

  WaveformComponent({required super.position}) : super(anchor: Anchor.center, size: Vector2(300, 100));

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = isStable ? const Color(0xFF00F0FF) : const Color(0xFFFF3131).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final path = Path();
    path.moveTo(0, size.y / 2);
    
    for (double x = 0; x < size.x; x += 2) {
      double y = math.sin(x * 0.08 + _time * 15) * 25;
      if (!isStable) {
        y += (math.Random().nextDouble() - 0.5) * 60 * noiseLevel;
      } else {
        // Un poco de "vida" a la onda estable
        y += math.cos(x * 0.04 + _time * 8) * 10;
      }
      path.lineTo(x, size.y / 2 + y);
    }
    
    canvas.drawPath(path, paint);
  }
}
