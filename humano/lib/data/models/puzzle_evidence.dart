import 'puzzle_fragment.dart';

class PuzzleEvidence {
  final String id;
  final String arcId;
  final String title;
  final String narrativeDescription;
  final String completeImagePath;
  final List<PuzzleFragment> fragments; // 5 fragments
  bool isCompleted;
  DateTime? completedAt;
  int attemptCount;

  PuzzleEvidence({
    required this.id,
    required this.arcId,
    required this.title,
    required this.narrativeDescription,
    required this.completeImagePath,
    required this.fragments,
    this.isCompleted = false,
    this.completedAt,
    this.attemptCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'arcId': arcId,
        'title': title,
        'narrativeDescription': narrativeDescription,
        'completeImagePath': completeImagePath,
        'fragments': fragments.map((f) => f.toJson()).toList(),
        'isCompleted': isCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'attemptCount': attemptCount,
      };

  factory PuzzleEvidence.fromJson(Map<String, dynamic> json) {
    return PuzzleEvidence(
      id: json['id'] as String,
      arcId: json['arcId'] as String,
      title: json['title'] as String,
      narrativeDescription: json['narrativeDescription'] as String,
      completeImagePath: json['completeImagePath'] as String,
      fragments: (json['fragments'] as List)
          .map((f) => PuzzleFragment.fromJson(f as Map<String, dynamic>))
          .toList(),
      isCompleted: json['isCompleted'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      attemptCount: json['attemptCount'] as int? ?? 0,
    );
  }

  int get collectedFragmentCount =>
      fragments.where((f) => f.isCollected).length;

  bool get canAssemble => collectedFragmentCount == 5;

  PuzzleEvidence copyWith({
    String? id,
    String? arcId,
    String? title,
    String? narrativeDescription,
    String? completeImagePath,
    List<PuzzleFragment>? fragments,
    bool? isCompleted,
    DateTime? completedAt,
    int? attemptCount,
  }) {
    return PuzzleEvidence(
      id: id ?? this.id,
      arcId: arcId ?? this.arcId,
      title: title ?? this.title,
      narrativeDescription: narrativeDescription ?? this.narrativeDescription,
      completeImagePath: completeImagePath ?? this.completeImagePath,
      fragments: fragments ?? this.fragments,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      attemptCount: attemptCount ?? this.attemptCount,
    );
  }
}
