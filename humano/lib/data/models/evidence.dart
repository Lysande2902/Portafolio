enum EvidenceType {
  screenshot,
  message,
  video,
  audio,
  document;

  String get displayName {
    switch (this) {
      case EvidenceType.screenshot:
        return 'Screenshots';
      case EvidenceType.message:
        return 'Mensajes';
      case EvidenceType.video:
        return 'Videos';
      case EvidenceType.audio:
        return 'Audio';
      case EvidenceType.document:
        return 'Documentos';
    }
  }

  String get icon {
    switch (this) {
      case EvidenceType.screenshot:
        return '📷';
      case EvidenceType.message:
        return '💬';
      case EvidenceType.video:
        return '🎥';
      case EvidenceType.audio:
        return '🔊';
      case EvidenceType.document:
        return '📄';
    }
  }
}

class Evidence {
  final String id;
  final String arcId;
  final EvidenceType type;
  final String title;
  final String description;
  final String contentPath;
  final String? thumbnailPath;
  final String unlockHint;
  bool isUnlocked;

  Evidence({
    required this.id,
    required this.arcId,
    required this.type,
    required this.title,
    required this.description,
    required this.contentPath,
    this.thumbnailPath,
    required this.unlockHint,
    this.isUnlocked = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'arcId': arcId,
      'type': type.name,
      'title': title,
      'description': description,
      'contentPath': contentPath,
      'thumbnailPath': thumbnailPath,
      'unlockHint': unlockHint,
      'isUnlocked': isUnlocked,
    };
  }

  factory Evidence.fromJson(Map<String, dynamic> json) {
    return Evidence(
      id: json['id'] as String,
      arcId: json['arcId'] as String,
      type: EvidenceType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => EvidenceType.screenshot,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      contentPath: json['contentPath'] as String,
      thumbnailPath: json['thumbnailPath'] as String?,
      unlockHint: json['unlockHint'] as String,
      isUnlocked: json['isUnlocked'] as bool? ?? false,
    );
  }

  Evidence copyWith({
    String? id,
    String? arcId,
    EvidenceType? type,
    String? title,
    String? description,
    String? contentPath,
    String? thumbnailPath,
    String? unlockHint,
    bool? isUnlocked,
  }) {
    return Evidence(
      id: id ?? this.id,
      arcId: arcId ?? this.arcId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      contentPath: contentPath ?? this.contentPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      unlockHint: unlockHint ?? this.unlockHint,
      isUnlocked: isUnlocked ?? this.isUnlocked,
    );
  }
}
