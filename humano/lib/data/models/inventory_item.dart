import 'package:flutter/material.dart';
import 'store_item.dart';

/// Modelo para items en el inventario del usuario
class InventoryItem {
  /// ID único del item
  final String id;
  
  /// Nombre del item
  final String name;
  
  /// Descripción del item
  final String description;
  
  /// Tipo de item
  final StoreItemType type;
  
  /// Ruta del icono/sprite
  final String iconPath;
  
  /// Si el item está equipado actualmente
  final bool isEquipped;
  
  /// Cantidad disponible (para consumibles)
  final int quantity;
  
  /// Información de dónde se usa el item
  final String usageInfo;
  
  /// Fecha de adquisición
  final DateTime acquiredDate;
  
  /// Si el item es premium
  final bool isPremium;
  
  /// Categoría del item (para consumibles: defensive, stealth, offensive)
  final String? category;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.iconPath,
    this.isEquipped = false,
    this.quantity = 1,
    required this.usageInfo,
    required this.acquiredDate,
    this.isPremium = false,
    this.category,
  });

  /// Obtiene el texto de uso según el tipo de item
  String getUsageText() {
    switch (type) {
      case StoreItemType.skin:
        if (id.startsWith('player_')) {
          return 'Se usa en: Todos los arcos';
        } else if (id.startsWith('sin_')) {
          // Determinar el arco según el ID
          if (id.contains('gluttony')) {
            return 'Se usa en: Modo multijugador - Arco Gula';
          } else if (id.contains('greed')) {
            return 'Se usa en: Modo multijugador - Arco Avaricia';
          } else if (id.contains('envy')) {
            return 'Se usa en: Modo multijugador - Arco Envidia';
          } else if (id.contains('sloth')) {
            return 'Se usa en: Modo multijugador - Arco Pereza';
          } else if (id.contains('lust')) {
            return 'Se usa en: Modo multijugador - Arco Lujuria';
          } else if (id.contains('pride')) {
            return 'Se usa en: Modo multijugador - Arco Soberbia';
          } else if (id.contains('wrath')) {
            return 'Se usa en: Modo multijugador - Arco Ira';
          }
          return 'Se usa en: Modo multijugador';
        }
        return usageInfo;
        
      case StoreItemType.consumable:
        return 'Se usa en: Durante el gameplay';
        
      case StoreItemType.battlePass:
        return 'Activo durante toda la temporada';
        
      case StoreItemType.bundle:
        return 'Contiene múltiples items';
        
      case StoreItemType.theme:
        return 'Cambia la estética del sistema';
        
      case StoreItemType.protocol:
        return 'Mejora pasiva de red';
        
      case StoreItemType.narrative:
        return 'Archivo confidencial recuperado';
    }
  }

  /// Obtiene el icono apropiado según el tipo de item
  IconData getUsageIcon() {
    switch (type) {
      case StoreItemType.skin:
        if (id.startsWith('player_')) {
          return Icons.person;
        } else {
          return Icons.group;
        }
        
      case StoreItemType.consumable:
        if (category == 'defensive') {
          return Icons.shield;
        } else if (category == 'stealth') {
          return Icons.visibility_off;
        } else if (category == 'offensive') {
          return Icons.flash_on;
        }
        return Icons.inventory_2;
        
      case StoreItemType.battlePass:
        return Icons.military_tech;
        
      case StoreItemType.bundle:
        return Icons.card_giftcard;
        
      case StoreItemType.theme:
        return Icons.palette;
        
      case StoreItemType.protocol:
        return Icons.security;
        
      case StoreItemType.narrative:
        return Icons.library_books;
    }
  }

  /// Verifica si el item puede ser equipado
  bool canBeEquipped() {
    return type == StoreItemType.skin || type == StoreItemType.theme;
  }

  /// Crea una copia del item con campos actualizados
  InventoryItem copyWith({
    String? id,
    String? name,
    String? description,
    StoreItemType? type,
    String? iconPath,
    bool? isEquipped,
    int? quantity,
    String? usageInfo,
    DateTime? acquiredDate,
    bool? isPremium,
    String? category,
  }) {
    return InventoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      iconPath: iconPath ?? this.iconPath,
      isEquipped: isEquipped ?? this.isEquipped,
      quantity: quantity ?? this.quantity,
      usageInfo: usageInfo ?? this.usageInfo,
      acquiredDate: acquiredDate ?? this.acquiredDate,
      isPremium: isPremium ?? this.isPremium,
      category: category ?? this.category,
    );
  }

  /// Convierte el modelo a Map para Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString(),
      'iconPath': iconPath,
      'isEquipped': isEquipped,
      'quantity': quantity,
      'usageInfo': usageInfo,
      'acquiredDate': acquiredDate.toIso8601String(),
      'isPremium': isPremium,
      'category': category,
    };
  }

  /// Crea un modelo desde un Map de Firebase
  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      type: _parseStoreItemType(map['type'] as String),
      iconPath: map['iconPath'] as String,
      isEquipped: map['isEquipped'] as bool? ?? false,
      quantity: map['quantity'] as int? ?? 1,
      usageInfo: map['usageInfo'] as String,
      acquiredDate: DateTime.parse(map['acquiredDate'] as String),
      isPremium: map['isPremium'] as bool? ?? false,
      category: map['category'] as String?,
    );
  }

  /// Parsea el tipo de item desde string
  static StoreItemType _parseStoreItemType(String typeString) {
    switch (typeString) {
      case 'StoreItemType.consumable':
        return StoreItemType.consumable;
      case 'StoreItemType.skin':
        return StoreItemType.skin;
      case 'StoreItemType.bundle':
        return StoreItemType.bundle;
      case 'StoreItemType.battlePass':
        return StoreItemType.battlePass;
      case 'StoreItemType.theme':
        return StoreItemType.theme;
      case 'StoreItemType.protocol':
        return StoreItemType.protocol;
      case 'StoreItemType.narrative':
        return StoreItemType.narrative;
      default:
        // Handle short names too just in case
        if (typeString.contains('.')) {
          final part = typeString.split('.').last;
          return StoreItemType.values.firstWhere(
            (e) => e.name == part,
            orElse: () => StoreItemType.consumable,
          );
        }
        return StoreItemType.values.firstWhere(
            (e) => e.name == typeString,
            orElse: () => StoreItemType.consumable,
          );
    }
  }

  @override
  String toString() {
    return 'InventoryItem(id: $id, name: $name, type: $type, quantity: $quantity, isEquipped: $isEquipped)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is InventoryItem &&
      other.id == id &&
      other.name == name &&
      other.type == type &&
      other.isEquipped == isEquipped &&
      other.quantity == quantity;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      type.hashCode ^
      isEquipped.hashCode ^
      quantity.hashCode;
  }
}
