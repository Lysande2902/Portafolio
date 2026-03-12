class BattlePassData {
  final bool isActive; // Si el pase está activo (comprado)
  final int level; // Nivel actual (0-20)
  final List<int> claimedRewards; // Lista de niveles ya reclamados
  final DateTime? purchaseDate;
  final DateTime? expiryDate;

  const BattlePassData({
    this.isActive = false,
    this.level = 0,
    this.claimedRewards = const [],
    this.purchaseDate,
    this.expiryDate,
  });

  factory BattlePassData.empty() {
    return const BattlePassData();
  }

  Map<String, dynamic> toJson() {
    return {
      'isActive': isActive,
      'level': level,
      'claimedRewards': claimedRewards,
      'purchaseDate': purchaseDate?.toIso8601String(),
      'expiryDate': expiryDate?.toIso8601String(),
    };
  }

  factory BattlePassData.fromJson(Map<String, dynamic> json) {
    return BattlePassData(
      isActive: json['isActive'] as bool? ?? false,
      level: json['level'] as int? ?? 0,
      claimedRewards: List<int>.from(json['claimedRewards'] as List? ?? []),
      purchaseDate: json['purchaseDate'] != null ? DateTime.parse(json['purchaseDate'] as String) : null,
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate'] as String) : null,
    );
  }

  BattlePassData copyWith({
    bool? isActive,
    int? level,
    List<int>? claimedRewards,
    DateTime? purchaseDate,
    DateTime? expiryDate,
  }) {
    return BattlePassData(
      isActive: isActive ?? this.isActive,
      level: level ?? this.level,
      claimedRewards: claimedRewards ?? this.claimedRewards,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  bool isLevelClaimed(int level) {
    return claimedRewards.contains(level);
  }

  bool canClaimLevel(int levelToCheck) {
    return isActive && level >= levelToCheck && !isLevelClaimed(levelToCheck);
  }

  bool get isExpired {
    if (expiryDate == null) return false;
    return DateTime.now().isAfter(expiryDate!);
  }
}
