class Arc {
  final String id;
  final int number;
  final String title;
  final String subtitle;
  final String description;
  final String thumbnailPath;
  final bool isUnlockedByDefault;
  final List<String> unlockRequirements;

  const Arc({
    required this.id,
    required this.number,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.thumbnailPath,
    required this.isUnlockedByDefault,
    required this.unlockRequirements,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'number': number,
      'title': title,
      'subtitle': subtitle,
      'description': description,
      'thumbnailPath': thumbnailPath,
      'isUnlockedByDefault': isUnlockedByDefault,
      'unlockRequirements': unlockRequirements,
    };
  }

  factory Arc.fromJson(Map<String, dynamic> json) {
    return Arc(
      id: json['id'] as String,
      number: json['number'] as int,
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      description: json['description'] as String,
      thumbnailPath: json['thumbnailPath'] as String,
      isUnlockedByDefault: json['isUnlockedByDefault'] as bool,
      unlockRequirements: List<String>.from(json['unlockRequirements'] as List),
    );
  }
}
