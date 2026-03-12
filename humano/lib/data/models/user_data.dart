import 'package:cloud_firestore/cloud_firestore.dart';
import 'arc_progress.dart';
import 'player_inventory.dart';
import 'game_settings.dart';
import 'user_stats.dart';

/// Modelo que encapsula todos los datos de un usuario
class UserData {
  final String userId;
  final Map<String, ArcProgress> arcProgress;
  final PlayerInventory inventory;
  final GameSettings settings;
  final UserStats stats;
  final DateTime lastUpdated;
  final String? unlockedEnding; // 'spectator' or 'accomplice'

  const UserData({
    required this.userId,
    required this.arcProgress,
    required this.inventory,
    required this.settings,
    required this.stats,
    required this.lastUpdated,
    this.unlockedEnding,
  });

  /// Crea un UserData inicial para un nuevo usuario
  factory UserData.initial(String userId) {
    return UserData(
      userId: userId,
      arcProgress: {},
      inventory: PlayerInventory.empty(),
      settings: GameSettings.defaults,
      stats: UserStats.empty(userId),
      lastUpdated: DateTime.now(),
      unlockedEnding: null,
    );
  }

  /// Crea un UserData desde un documento de Firestore
  factory UserData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    
    if (data == null) {
      throw Exception('Document data is null');
    }

    // Get userId from data or fallback to document ID
    final userId = (data['userId'] as String?) ?? doc.id;

    // Parse arcProgress map
    final arcProgressData = data['arcProgress'] as Map<String, dynamic>? ?? {};
    final arcProgressMap = <String, ArcProgress>{};
    arcProgressData.forEach((key, value) {
      arcProgressMap[key] = ArcProgress.fromJson(value as Map<String, dynamic>);
    });

    return UserData(
      userId: userId,
      arcProgress: arcProgressMap,
      inventory: PlayerInventory.fromJson(
        data['inventory'] as Map<String, dynamic>? ?? {},
      ),
      settings: GameSettings.fromJson(
        data['settings'] as Map<String, dynamic>? ?? {},
      ),
      stats: UserStats.fromJson(
        data['stats'] as Map<String, dynamic>? ?? {'userId': userId},
      ),
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      unlockedEnding: data['unlockedEnding'] as String?,
    );
  }

  /// Convierte el UserData a un mapa para Firestore
  Map<String, dynamic> toFirestore() {
    // Convert arcProgress map to JSON
    final arcProgressJson = <String, dynamic>{};
    arcProgress.forEach((key, value) {
      arcProgressJson[key] = value.toJson();
    });

    return {
      'userId': userId,
      'arcProgress': arcProgressJson,
      'inventory': inventory.toJson(),
      'settings': settings.toJson(),
      'stats': stats.toJson(),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'unlockedEnding': unlockedEnding,
    };
  }

  /// Crea una copia del UserData con campos actualizados
  UserData copyWith({
    String? userId,
    Map<String, ArcProgress>? arcProgress,
    PlayerInventory? inventory,
    GameSettings? settings,
    UserStats? stats,
    DateTime? lastUpdated,
    String? unlockedEnding,
  }) {
    return UserData(
      userId: userId ?? this.userId,
      arcProgress: arcProgress ?? this.arcProgress,
      inventory: inventory ?? this.inventory,
      settings: settings ?? this.settings,
      stats: stats ?? this.stats,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      unlockedEnding: unlockedEnding ?? this.unlockedEnding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserData &&
        other.userId == userId &&
        _mapsEqual(other.arcProgress, arcProgress) &&
        other.inventory == inventory &&
        other.settings == settings &&
        other.stats == stats;
  }

  @override
  int get hashCode {
    return userId.hashCode ^
        arcProgress.hashCode ^
        inventory.hashCode ^
        settings.hashCode ^
        stats.hashCode;
  }

  /// Helper para comparar mapas de ArcProgress
  bool _mapsEqual(Map<String, ArcProgress> map1, Map<String, ArcProgress> map2) {
    if (map1.length != map2.length) return false;
    for (var key in map1.keys) {
      if (!map2.containsKey(key)) return false;
      if (map1[key] != map2[key]) return false;
    }
    return true;
  }
}
