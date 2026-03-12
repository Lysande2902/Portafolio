import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

class PuzzleFragment {
  final String id;
  final String evidenceId;
  final int fragmentNumber; // 1-5
  
  // Grid position (3x2 grid, 5 fragments)
  final int gridX; // 0-2 (columna)
  final int gridY; // 0-1 (fila)
  
  final vm.Vector2 correctPosition; // Correct position on the board
  final double correctRotation; // Correct rotation (0, 90, 180, 270)
  bool isCollected;
  DateTime? collectedAt;

  // Metadata
  final String arcId;
  final String narrativeSnippet; // Narrative text for this fragment

  PuzzleFragment({
    required this.id,
    required this.evidenceId,
    required this.fragmentNumber,
    required this.gridX,
    required this.gridY,
    required this.correctPosition,
    required this.correctRotation,
    this.isCollected = false,
    this.collectedAt,
    required this.arcId,
    required this.narrativeSnippet,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'evidenceId': evidenceId,
        'fragmentNumber': fragmentNumber,
        'gridX': gridX,
        'gridY': gridY,
        'correctPosition': {
          'x': correctPosition.x,
          'y': correctPosition.y,
        },
        'correctRotation': correctRotation,
        'isCollected': isCollected,
        'collectedAt': collectedAt?.toIso8601String(),
        'arcId': arcId,
        'narrativeSnippet': narrativeSnippet,
      };

  factory PuzzleFragment.fromJson(Map<String, dynamic> json) {
    return PuzzleFragment(
      id: json['id'] as String,
      evidenceId: json['evidenceId'] as String,
      fragmentNumber: json['fragmentNumber'] as int,
      gridX: json['gridX'] as int,
      gridY: json['gridY'] as int,
      correctPosition: vm.Vector2(
        json['correctPosition']['x'] as double,
        json['correctPosition']['y'] as double,
      ),
      correctRotation: json['correctRotation'] as double,
      isCollected: json['isCollected'] as bool? ?? false,
      collectedAt: json['collectedAt'] != null
          ? DateTime.parse(json['collectedAt'] as String)
          : null,
      arcId: json['arcId'] as String,
      narrativeSnippet: json['narrativeSnippet'] as String,
    );
  }

  PuzzleFragment copyWith({
    String? id,
    String? evidenceId,
    int? fragmentNumber,
    int? gridX,
    int? gridY,
    vm.Vector2? correctPosition,
    double? correctRotation,
    bool? isCollected,
    DateTime? collectedAt,
    String? arcId,
    String? narrativeSnippet,
  }) {
    return PuzzleFragment(
      id: id ?? this.id,
      evidenceId: evidenceId ?? this.evidenceId,
      fragmentNumber: fragmentNumber ?? this.fragmentNumber,
      gridX: gridX ?? this.gridX,
      gridY: gridY ?? this.gridY,
      correctPosition: correctPosition ?? this.correctPosition,
      correctRotation: correctRotation ?? this.correctRotation,
      isCollected: isCollected ?? this.isCollected,
      collectedAt: collectedAt ?? this.collectedAt,
      arcId: arcId ?? this.arcId,
      narrativeSnippet: narrativeSnippet ?? this.narrativeSnippet,
    );
  }
  
  // Helper para obtener el tamaño del fragmento en el grid
  // Grid 3x2: cada fragmento es 1/3 del ancho y 1/2 de la altura
  double get widthFactor => 1.0 / 3.0;
  double get heightFactor => 1.0 / 2.0;
  
  // Helper para obtener la alineación en la imagen completa
  Alignment get imageAlignment {
    // Convertir gridX (0-2) y gridY (0-1) a alineación (-1.0 a 1.0)
    // Para 3 columnas: 0->-1.0, 1->0.0, 2->1.0
    // Para 2 filas: 0->-1.0, 1->1.0
    final alignX = (gridX - 1.0); // 0->-1.0, 1->0.0, 2->1.0
    final alignY = (gridY * 2.0) - 1.0; // 0->-1.0, 1->1.0
    return Alignment(alignX, alignY);
  }
}
