enum StoreItemType {
  consumable,
  theme,
  protocol,
  narrative,
  bundle,
  battlePass,
  skin,
  music;

  String get displayName {
    switch (this) {
      case StoreItemType.consumable:
        return 'Items';
      case StoreItemType.theme:
        return 'Hardware Visual';
      case StoreItemType.protocol:
        return 'Protocolos';
      case StoreItemType.narrative:
        return 'Contenido Extra';
      case StoreItemType.bundle:
        return 'Bundles';
      case StoreItemType.battlePass:
        return 'Battle Pass';
      case StoreItemType.skin:
        return 'Skin';
      case StoreItemType.music:
        return 'Música de Fondo';
    }
  }
}

class StoreItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final StoreItemType type;
  final String iconPath;
  final bool isPremium;
  final String? category;
  final String? rarity;
  
  // Lore content for narrative items
  final String? loreContent;
  final List<String>? loreImages;
  
  // Bundle contents
  final Map<String, int>? bundleItems; // itemId -> quantity
  final int? bundleCoins; // bonus coins included in bundle

  const StoreItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.type,
    required this.iconPath,
    this.isPremium = false,
    this.category,
    this.rarity,
    this.loreContent,
    this.loreImages,
    this.bundleItems,
    this.bundleCoins,
  });

  bool get isFree => price == 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'type': type.name,
      'iconPath': iconPath,
      'isPremium': isPremium,
      'loreContent': loreContent,
      'loreImages': loreImages,
      'bundleItems': bundleItems,
      'bundleCoins': bundleCoins,
    };
  }

  factory StoreItem.fromJson(Map<String, dynamic> json) {
    return StoreItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: json['price'] as int,
      type: StoreItemType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => StoreItemType.consumable,
      ),
      iconPath: json['iconPath'] as String,
      isPremium: json['isPremium'] as bool? ?? false,
      loreContent: json['loreContent'] as String?,
      loreImages: json['loreImages'] != null 
          ? List<String>.from(json['loreImages'] as List)
          : null,
      bundleItems: json['bundleItems'] != null 
          ? Map<String, int>.from(json['bundleItems'] as Map)
          : null,
      bundleCoins: json['bundleCoins'] as int?,
    );
  }
}
