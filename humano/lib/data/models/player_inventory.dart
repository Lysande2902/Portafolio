class PlayerInventory {
  final int coins;
  final Set<String> ownedItems;
  final bool hasBattlePass;
  final int battlePassLevel;
  final List<int> claimedBattlePassRewards;
  final DateTime? battlePassExpiryDate;
  
  // Equipment system
  final String? equippedPlayerSkin;
  final String? equippedTheme;
  final String? equippedMusic; // musicId
  final Map<String, String?> equippedSinSkins; // arcId -> skinId
  final Map<String, int> consumableQuantities; // itemId -> quantity

  const PlayerInventory({
    required this.coins,
    required this.ownedItems,
    required this.hasBattlePass,
    required this.battlePassLevel,
    this.claimedBattlePassRewards = const [],
    this.battlePassExpiryDate,
    this.equippedPlayerSkin,
    this.equippedTheme,
    this.equippedMusic,
    this.equippedSinSkins = const {},
    this.consumableQuantities = const {},
  });

  factory PlayerInventory.empty() {
    return const PlayerInventory(
      coins: 0, // Starting coins (users earn coins by playing)
      ownedItems: {
        'music_reflections', // FREE
        'music_excess',      // FREE
      },
      hasBattlePass: false,
      battlePassLevel: 0,
      claimedBattlePassRewards: [],
      battlePassExpiryDate: null,
      equippedPlayerSkin: 'skin_anonymous', // Default skin
      equippedTheme: 'default', // Default theme
      equippedMusic: 'music_reflections', // Default music
      equippedSinSkins: {},
      consumableQuantities: {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'coins': coins,
      'ownedItems': ownedItems.toList(),
      'hasBattlePass': hasBattlePass,
      'battlePassLevel': battlePassLevel,
      'claimedBattlePassRewards': claimedBattlePassRewards,
      'battlePassExpiryDate': battlePassExpiryDate?.toIso8601String(),
      'equippedPlayerSkin': equippedPlayerSkin,
      'equippedTheme': equippedTheme,
      'equippedMusic': equippedMusic,
      'equippedSinSkins': equippedSinSkins,
      'consumableQuantities': consumableQuantities,
    };
  }

  factory PlayerInventory.fromJson(Map<String, dynamic> json) {
    return PlayerInventory(
      coins: json['coins'] as int? ?? 0,
      ownedItems: Set<String>.from(json['ownedItems'] as List? ?? []),
      hasBattlePass: json['hasBattlePass'] as bool? ?? false,
      battlePassLevel: json['battlePassLevel'] as int? ?? 0,
      claimedBattlePassRewards: List<int>.from(json['claimedBattlePassRewards'] as List? ?? []),
      battlePassExpiryDate: json['battlePassExpiryDate'] != null ? DateTime.parse(json['battlePassExpiryDate'] as String) : null,
      equippedPlayerSkin: json['equippedPlayerSkin'] as String? ?? 'skin_anonymous',
      equippedTheme: json['equippedTheme'] as String? ?? 'default',
      equippedMusic: json['equippedMusic'] as String? ?? 'music_reflections',
      equippedSinSkins: Map<String, String?>.from(json['equippedSinSkins'] as Map? ?? {}),
      consumableQuantities: Map<String, int>.from(json['consumableQuantities'] as Map? ?? {}),
    );
  }

  PlayerInventory copyWith({
    int? coins,
    Set<String>? ownedItems,
    bool? hasBattlePass,
    int? battlePassLevel,
    List<int>? claimedBattlePassRewards,
    DateTime? battlePassExpiryDate,
    String? equippedPlayerSkin,
    String? equippedTheme,
    String? equippedMusic,
    Map<String, String?>? equippedSinSkins,
    Map<String, int>? consumableQuantities,
  }) {
    return PlayerInventory(
      coins: coins ?? this.coins,
      ownedItems: ownedItems ?? this.ownedItems,
      hasBattlePass: hasBattlePass ?? this.hasBattlePass,
      battlePassLevel: battlePassLevel ?? this.battlePassLevel,
      claimedBattlePassRewards: claimedBattlePassRewards ?? this.claimedBattlePassRewards,
      battlePassExpiryDate: battlePassExpiryDate ?? this.battlePassExpiryDate,
      equippedPlayerSkin: equippedPlayerSkin ?? this.equippedPlayerSkin,
      equippedTheme: equippedTheme ?? this.equippedTheme,
      equippedMusic: equippedMusic ?? this.equippedMusic,
      equippedSinSkins: equippedSinSkins ?? this.equippedSinSkins,
      consumableQuantities: consumableQuantities ?? this.consumableQuantities,
    );
  }

  bool ownsItem(String itemId) {
    // Items básicos gratuitos por defecto
    const freeItems = {
      'skin_anonymous', 
      'default', 
      'music_reflections', 
      'music_excess'
    };
    if (freeItems.contains(itemId)) return true;
    
    return ownedItems.contains(itemId);
  }

  bool canAfford(int price) {
    return coins >= price;
  }
  
  /// Check if a skin is currently equipped
  bool isSkinEquipped(String skinId) {
    // Check if it's a player skin
    if (skinId.startsWith('skin_') && !skinId.contains('gluttony') && !skinId.contains('greed') && !skinId.contains('envy')) {
      return equippedPlayerSkin == skinId;
    }
    // Check if it's an enemy skin
    else if (skinId.contains('gluttony') || skinId.contains('greed') || skinId.contains('envy')) {
      return equippedSinSkins.values.contains(skinId);
    }
    return false;
  }
  
  /// Get quantity of a consumable item
  int getConsumableQuantity(String itemId) {
    return consumableQuantities[itemId] ?? 0;
  }
}
