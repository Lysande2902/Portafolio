class UserStats {
  final String userId;
  final int totalPlayTimeMinutes;
  final DateTime accountCreatedAt;
  final int arcsCompleted;
  final int totalAttempts;

  const UserStats({
    required this.userId,
    required this.totalPlayTimeMinutes,
    required this.accountCreatedAt,
    required this.arcsCompleted,
    required this.totalAttempts,
  });

  factory UserStats.empty(String userId) {
    return UserStats(
      userId: userId,
      totalPlayTimeMinutes: 0,
      accountCreatedAt: DateTime.now(),
      arcsCompleted: 0,
      totalAttempts: 0,
    );
  }

  String get formattedPlayTime {
    final hours = totalPlayTimeMinutes ~/ 60;
    final minutes = totalPlayTimeMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'totalPlayTimeMinutes': totalPlayTimeMinutes,
      'accountCreatedAt': accountCreatedAt.toIso8601String(),
      'arcsCompleted': arcsCompleted,
      'totalAttempts': totalAttempts,
    };
  }

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      userId: json['userId'] as String,
      totalPlayTimeMinutes: json['totalPlayTimeMinutes'] as int? ?? 0,
      accountCreatedAt: json['accountCreatedAt'] != null
          ? DateTime.parse(json['accountCreatedAt'] as String)
          : DateTime.now(),
      arcsCompleted: json['arcsCompleted'] as int? ?? 0,
      totalAttempts: json['totalAttempts'] as int? ?? 0,
    );
  }

  UserStats copyWith({
    String? userId,
    int? totalPlayTimeMinutes,
    DateTime? accountCreatedAt,
    int? arcsCompleted,
    int? totalAttempts,
  }) {
    return UserStats(
      userId: userId ?? this.userId,
      totalPlayTimeMinutes: totalPlayTimeMinutes ?? this.totalPlayTimeMinutes,
      accountCreatedAt: accountCreatedAt ?? this.accountCreatedAt,
      arcsCompleted: arcsCompleted ?? this.arcsCompleted,
      totalAttempts: totalAttempts ?? this.totalAttempts,
    );
  }
}
