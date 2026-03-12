import 'package:cloud_firestore/cloud_firestore.dart';

/// Modelo de entrada en el leaderboard
class LeaderboardEntry {
  final String userId;
  final String username;
  final int totalFragments;
  final int arcsCompleted;
  final int totalCoins;
  final int achievementsUnlocked;
  final DateTime lastUpdated;

  LeaderboardEntry({
    required this.userId,
    required this.username,
    required this.totalFragments,
    required this.arcsCompleted,
    required this.totalCoins,
    required this.achievementsUnlocked,
    required this.lastUpdated,
  });

  /// Crea desde Firestore
  factory LeaderboardEntry.fromFirestore(Map<String, dynamic> data, String userId) {
    return LeaderboardEntry(
      userId: userId,
      username: data['username'] ?? 'Jugador',
      totalFragments: data['totalFragments'] ?? 0,
      arcsCompleted: data['arcsCompleted'] ?? 0,
      totalCoins: data['totalCoins'] ?? 0,
      achievementsUnlocked: data['achievementsUnlocked'] ?? 0,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convierte a Map para Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'username': username,
      'totalFragments': totalFragments,
      'arcsCompleted': arcsCompleted,
      'totalCoins': totalCoins,
      'achievementsUnlocked': achievementsUnlocked,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  /// Calcula el puntaje total (para ranking)
  int get totalScore {
    return (totalFragments * 100) +
           (arcsCompleted * 500) +
           (achievementsUnlocked * 50) +
           (totalCoins ~/ 10);
  }
}
