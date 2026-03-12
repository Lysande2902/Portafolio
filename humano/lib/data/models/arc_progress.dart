enum ArcStatus {
  notStarted,
  inProgress,
  completed;

  String toJson() => name;

  static ArcStatus fromJson(String json) {
    return ArcStatus.values.firstWhere(
      (status) => status.name == json,
      orElse: () => ArcStatus.notStarted,
    );
  }
}

class ArcProgress {
  final String arcId;
  final ArcStatus status;
  final double progressPercent;
  final DateTime? lastPlayed;
  final int attemptsCount;
  final List<String> evidencesCollected;

  const ArcProgress({
    required this.arcId,
    required this.status,
    required this.progressPercent,
    this.lastPlayed,
    required this.attemptsCount,
    required this.evidencesCollected,
  });

  factory ArcProgress.initial(String arcId) {
    return ArcProgress(
      arcId: arcId,
      status: ArcStatus.notStarted,
      progressPercent: 0.0,
      lastPlayed: null,
      attemptsCount: 0,
      evidencesCollected: [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arcId': arcId,
      'status': status.toJson(),
      'progressPercent': progressPercent,
      'lastPlayed': lastPlayed?.toIso8601String(),
      'attemptsCount': attemptsCount,
      'evidencesCollected': evidencesCollected,
    };
  }

  factory ArcProgress.fromJson(Map<String, dynamic> json) {
    return ArcProgress(
      arcId: json['arcId'] as String,
      status: ArcStatus.fromJson(json['status'] as String),
      progressPercent: (json['progressPercent'] as num).toDouble(),
      lastPlayed: json['lastPlayed'] != null
          ? DateTime.parse(json['lastPlayed'] as String)
          : null,
      attemptsCount: json['attemptsCount'] as int,
      evidencesCollected: List<String>.from(json['evidencesCollected'] as List),
    );
  }

  ArcProgress copyWith({
    String? arcId,
    ArcStatus? status,
    double? progressPercent,
    DateTime? lastPlayed,
    int? attemptsCount,
    List<String>? evidencesCollected,
  }) {
    return ArcProgress(
      arcId: arcId ?? this.arcId,
      status: status ?? this.status,
      progressPercent: progressPercent ?? this.progressPercent,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      attemptsCount: attemptsCount ?? this.attemptsCount,
      evidencesCollected: evidencesCollected ?? this.evidencesCollected,
    );
  }
  
  // Getter alias for compatibility
  double get completionPercentage => progressPercent;
}
