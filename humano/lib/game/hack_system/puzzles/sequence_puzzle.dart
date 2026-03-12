import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import '../mind_hack_puzzle.dart';

/// SequencePuzzle - Reconstruct a fragmented memory phrase.
/// The user sees the target phrase at the top and must select the words in order.
class SequencePuzzle extends MindHackPuzzle {
  // Phrases focused on surveillance and loss of control (realistic/uncomfortable)
  final List<List<String>> phrases = [
    ["SÉ", "QUE", "ME", "VES"],
    ["ÉL", "ME", "VE", "MAL"],
    ["NO", "HAY", "MÁS", "YO"],
    ["MI", "ID", "ES", "MAL"],
    ["SIN", "ÉL", "NO", "SÉ"],
    ["ESTOY", "SOLO", "EN", "EL", "RUIDO"],
    ["NO", "QUEDA", "NADA", "DE", "MÍ"],
    ["TODO", "LO", "QUE", "VES", "ES", "MENTIRA"],
    ["VÍCTOR", "ME", "VE", "DESDE", "EL", "FUEGO"],
  ];
  
  // Distractor words to fill the grid
  final List<String> distractors = [
    "VES", "MAL", "ID", "FIN", "ÉL", "SI", "NO", "QUE", "YO", "MI", "YA", "SOLO", "VER", "LUZ", "FIN"
  ];

  List<String> targetSequence = [];
  List<String> playerBuffer = [];
  List<String> gridOptions = [];
  
  int currentStep = 0;
  bool isSolved = false;
  
  // Visual feedback
  String? lastSelectedWord;

  // Tooltips for Magnolia
  final List<String> tooltips = [
    "> MAGNOLIA: Su pulso cae. Concéntrate, Alex. Ordénalo.",
    "> MAGNOLIA: No dejes que los pensamientos intrusivos ganen.",
    "> MAGNOLIA: Respira. No pierdas fragmentos vitales.",
    "> MAGNOLIA: El sistema detecta anomalías. Rápido.",
  ];
  String? currentTooltip;
  double tooltipTimer = 0.0;
  double feedbackTimer = 0.0;
  bool _lastSelectionWasError = false;
  final int difficulty;

  SequencePuzzle({required super.onComplete, required super.onFail, this.difficulty = 0}) {
    _initPuzzle();
  }

  @override
  String get title => "RECONSTRUCCIÓN DE MEMORIA";

  @override
  String get instruction => "ORDENA LAS PALABRAS EN EL ORDEN CORRECTO";

  void _initPuzzle() {
    final rand = math.Random();
    
    // 1. Dificultad escalada: longitud de frase
    // Fase 1-2: 4 palabras, Fase 3-4: 5 palabras, Fase 5+: 6 palabras
    int wordCount = 4;
    if (difficulty >= 2) wordCount = 5;
    if (difficulty >= 4) wordCount = 6;

    final suitablePhrases = phrases.where((p) => p.length >= wordCount).toList();
    final basePhrase = suitablePhrases[rand.nextInt(suitablePhrases.length)];
    targetSequence = basePhrase.take(wordCount).toList();
    
    // 2. Setup player state
    playerBuffer = List.filled(wordCount, "");
    currentStep = 0;
    isSolved = false;
    
    // 3. Setup Option Grid (8-12 items total)
    // Más distractores en dificultades altas
    int totalOptions = (difficulty >= 3) ? 12 : 8;
    
    gridOptions = List.from(targetSequence);
    final filler = List.from(distractors);
    filler.shuffle(rand);
    
    for (var word in filler) {
      if (gridOptions.length >= totalOptions) break;
      if (!gridOptions.contains(word)) {
        gridOptions.add(word);
      }
    }
    
    // Shuffle the grid
    gridOptions.shuffle(rand);
  }

  @override
  void reset() {
    // Only reset progress, don't change words to avoid player confusion
    playerBuffer = List.filled(targetSequence.length, "");
    currentStep = 0;
    isSolved = false;
    // Don't reset feedbackTimer to allow the error flash to display
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (feedbackTimer > 0) feedbackTimer -= dt;
    
    // Updates tooltip
    if (tooltipTimer > 0) {
      tooltipTimer -= dt;
    } else {
      // Pick a random new tooltip every ~5 seconds
      final rand = math.Random();
      if (rand.nextDouble() > 0.5) {
        currentTooltip = tooltips[rand.nextInt(tooltips.length)];
        tooltipTimer = 5.0 + rand.nextDouble() * 5.0; // Show for 5-10 seconds
      } else {
        currentTooltip = null;
        tooltipTimer = 3.0 + rand.nextDouble() * 3.0; // Hide for 3-6 seconds
      }
    }
  }

  @override
  void render(Canvas canvas) {
    final size = gameRef.size;
    final center = size / 2;

    // --- 1. HEADER ---
    _drawText(canvas, "RECONSTRUCCIÓN DE MEMORIA", Offset(center.x, size.y * 0.08), 
        fontSize: 16, color: const Color(0xFF00F0FF), bold: true);
    
    _drawText(canvas, "IDENTIFICA LA SECUENCIA CORRECTA", Offset(center.x, size.y * 0.11), 
        fontSize: 10, color: Colors.white38);

    // --- 2. TARGET CLUE AREA (At the top) ---
    // User needs to see WHAT they are looking for
    _drawClueArea(canvas, size, center);

    // --- 3. PLAYER INPUT AREA (The slots being filled) ---
    _drawPlayerBuffer(canvas, size, center);

    // --- 4. INTERACTIVE GRID (The buttons) ---
    _drawSelectionGrid(canvas, size, center);
    
    // --- 5. MAGNOLIA TOOLTIP ---
    if (currentTooltip != null && !isSolved) {
      _drawText(canvas, currentTooltip!, Offset(center.x, size.y * 0.88), 
          fontSize: 10, color: const Color(0xFFE57373), bold: false); // Soft red/pink for Magnolia's voice
    }

    // --- 6. VICTORY OVERLAY ---
    if (isSolved) {
      canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), Paint()..color = Colors.black.withOpacity(0.85));
      _drawText(canvas, "FRAGMENTO_ESTABILIZADO", center.toOffset(), fontSize: 24, color: const Color(0xFF39FF14), bold: true);
    }
  }

  void _drawClueArea(Canvas canvas, Vector2 size, Vector2 center) {
    final y = size.y * 0.22;
    final spacing = size.x * 0.22;
    
    // Header for the clue section
    _drawText(canvas, "[ REFERENCIA_FRAGMENTADA ]", Offset(center.x, y - 35), fontSize: 9, color: Colors.white12);

    for (int i = 0; i < targetSequence.length; i++) {
        final pos = Offset(center.x - spacing * 1.5 + i * spacing, y);
        // We show the target words clearly but in a "ghost" style
        _drawWordBox(canvas, targetSequence[i], pos, width: spacing * 0.8, color: Colors.white12, textColor: Colors.white24);
    }
  }

  void _drawPlayerBuffer(Canvas canvas, Vector2 size, Vector2 center) {
    final y = size.y * 0.45;
    final int count = targetSequence.length;
    final spacing = size.x * (0.8 / count); // Adjust spacing based on word count

    for (int i = 0; i < count; i++) {
        final content = playerBuffer[i];
        final isActive = i == currentStep;
        final isFilled = content.isNotEmpty;
        
        Color boxColor = Colors.white10;
        if (isActive) boxColor = const Color(0xFF00F0FF);
        if (isFilled) boxColor = const Color(0xFF39FF14);

        final pos = Offset(center.x - spacing * (count - 1) * 0.5 + i * spacing, y);
        _drawWordBox(canvas, isFilled ? content : "??", pos, 
            width: spacing * 0.85, 
            color: boxColor, 
            textColor: isFilled ? Colors.white : boxColor.withOpacity(0.5),
            isBorderOnly: !isFilled);
    }
  }

  void _drawSelectionGrid(Canvas canvas, Vector2 size, Vector2 center) {
    final startY = size.y * 0.68;
    final btnWidth = size.x * 0.22;
    final btnHeight = size.y * 0.08;
    final spacingX = btnWidth * 1.1;
    final spacingY = btnHeight * 1.2;

    final int totalWords = gridOptions.length;
    final int cols = (totalWords > 8) ? 4 : 4; 
    
    for (int i = 0; i < totalWords; i++) {
      final col = i % cols;
      final row = i ~/ cols;
      final pos = Offset(center.x - spacingX * (cols - 1) * 0.5 + col * spacingX, startY + row * spacingY);
      
      final word = gridOptions[i];
      final isHighlighted = lastSelectedWord == word && feedbackTimer > 0;
      final isError = isHighlighted && _lastSelectionWasError;
      
      _drawButton(canvas, word, pos, btnWidth, btnHeight, isHighlighted, isError);
    }
  }

  void _drawWordBox(Canvas canvas, String text, Offset pos, {required double width, required Color color, required Color textColor, bool isBorderOnly = false}) {
    final height = 40.0;
    final rect = Rect.fromCenter(center: pos, width: width, height: height);
    
    final paint = Paint()
      ..color = color
      ..style = isBorderOnly ? PaintingStyle.stroke : PaintingStyle.fill
      ..strokeWidth = 1.0;
    
    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(2)), paint);
    _drawText(canvas, text, pos, fontSize: 13, color: textColor, bold: true);
  }

  void _drawButton(Canvas canvas, String label, Offset pos, double width, double height, bool highlight, bool isError) {
    final rect = Rect.fromCenter(center: pos, width: width, height: height);
    
    Color baseColor;
    if (highlight) {
      baseColor = isError ? const Color(0xFFFF0000) : const Color(0xFF39FF14); // Red if error, Green if correct component
    } else {
      baseColor = const Color(0xFF00F0FF); // Default Cyan
    }
    
    // Background fill
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)), 
      Paint()..color = baseColor.withOpacity(highlight ? 0.3 : 0.05)
    );
    
    // Border
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(3)), 
      Paint()..color = baseColor.withOpacity(highlight ? 0.8 : 0.3)..style = PaintingStyle.stroke..strokeWidth = 1.5
    );
    
    _drawText(canvas, label, pos, fontSize: 14, color: highlight ? Colors.white : baseColor);
  }

  void _drawText(Canvas canvas, String text, Offset pos, {double fontSize = 12, Color color = Colors.white, bool bold = false}) {
    final span = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontFamily: 'Courier',
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
      ),
    );
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, pos - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (isSolved) return;
    
    final tapPos = event.localPosition.toOffset();
    final size = gameRef.size;
    final center = size / 2;
    final startY = size.y * 0.68;
    final btnWidth = size.x * 0.22;
    final btnHeight = size.y * 0.08;
    final spacingX = btnWidth * 1.1;
    final spacingY = btnHeight * 1.2;

    final int totalWords = gridOptions.length;
    final int cols = (totalWords > 8) ? 4 : 4;

    for (int i = 0; i < totalWords; i++) {
        final col = i % cols;
        final row = i ~/ cols;
        final pos = Offset(center.x - spacingX * (cols - 1) * 0.5 + col * spacingX, startY + row * spacingY);
        
        // Large hitbox covering the button areas
        final rect = Rect.fromCenter(center: pos, width: spacingX, height: spacingY);
        
        if (rect.contains(tapPos)) {
            _onWordSelected(gridOptions[i]);
            return;
        }
    }
  }

  void _onWordSelected(String word) {
    lastSelectedWord = word;
    feedbackTimer = 0.5; // Visual flash holds a bit longer to see the red/green

    if (word == targetSequence[currentStep]) {
        _lastSelectionWasError = false;
        playerBuffer[currentStep] = word;
        currentStep++;
        
        if (currentStep >= targetSequence.length) {
            isSolved = true;
            Future.delayed(const Duration(milliseconds: 500), () => onComplete());
        }
    } else {
        // FAIL: Set error flag to true for red text box highlight before mind_hack updates
        _lastSelectionWasError = true;
        // CLEAR BUFFER
        onFail();
        reset(); 
    }
  }
}
