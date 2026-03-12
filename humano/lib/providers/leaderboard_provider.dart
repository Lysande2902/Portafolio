import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/leaderboard_entry.dart';

/// Provider para gestionar el leaderboard global
class LeaderboardProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<LeaderboardEntry> _topPlayers = [];
  LeaderboardEntry? _currentUserEntry;
  int? _currentUserRank;
  bool _isLoading = false;
  String? _error;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<LeaderboardEntry> get topPlayers => List.unmodifiable(_topPlayers);
  LeaderboardEntry? get currentUserEntry => _currentUserEntry;
  int? get currentUserRank => _currentUserRank;

  /// Carga el top 100 del leaderboard
  Future<void> loadLeaderboard({int limit = 100}) async {
    print('🏅 [LeaderboardProvider] Cargando leaderboard...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('leaderboard')
          .orderBy('totalScore', descending: true)
          .limit(limit)
          .get();

      _topPlayers = snapshot.docs
          .map((doc) => LeaderboardEntry.fromFirestore(
                doc.data(),
                doc.id,
              ))
          .toList();

      // Cargar posición del usuario actual
      await _loadCurrentUserRank();

      print('✅ Leaderboard cargado: ${_topPlayers.length} jugadores');
    } catch (e) {
      print('❌ Error cargando leaderboard: $e');
      _error = 'Error cargando clasificación';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga la posición del usuario actual
  Future<void> _loadCurrentUserRank() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Obtener datos del usuario
      final userDoc = await _firestore
          .collection('leaderboard')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        _currentUserEntry = LeaderboardEntry.fromFirestore(
          userDoc.data()!,
          user.uid,
        );

        // Calcular ranking
        final userScore = _currentUserEntry!.totalScore;
        final higherScoresCount = await _firestore
            .collection('leaderboard')
            .where('totalScore', isGreaterThan: userScore)
            .count()
            .get();

        _currentUserRank = higherScoresCount.count! + 1;
        
        print('   Usuario actual: Rank #$_currentUserRank (${_currentUserEntry!.totalScore} pts)');
      }
    } catch (e) {
      print('⚠️ Error cargando ranking del usuario: $e');
    }
  }

  /// Actualiza la entrada del usuario en el leaderboard
  Future<void> updateUserEntry({
    required String username,
    required int totalFragments,
    required int arcsCompleted,
    required int totalCoins,
    required int achievementsUnlocked,
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      print('⚠️ Usuario no autenticado');
      return;
    }

    print('📊 [LeaderboardProvider] Actualizando entrada del usuario...');

    try {
      final entry = LeaderboardEntry(
        userId: user.uid,
        username: username,
        totalFragments: totalFragments,
        arcsCompleted: arcsCompleted,
        totalCoins: totalCoins,
        achievementsUnlocked: achievementsUnlocked,
        lastUpdated: DateTime.now(),
      );

      // Calcular y guardar el puntaje total
      final data = entry.toFirestore();
      data['totalScore'] = entry.totalScore;

      await _firestore
          .collection('leaderboard')
          .doc(user.uid)
          .set(data, SetOptions(merge: true));

      print('✅ Entrada actualizada: ${entry.totalScore} puntos');

      // Recargar leaderboard
      await loadLeaderboard();
    } catch (e) {
      print('❌ Error actualizando leaderboard: $e');
      _error = 'Error actualizando clasificación';
      notifyListeners();
    }
  }

  /// Obtiene la posición de un usuario específico
  Future<int?> getUserRank(String userId) async {
    try {
      final userDoc = await _firestore
          .collection('leaderboard')
          .doc(userId)
          .get();

      if (!userDoc.exists) return null;

      final userData = userDoc.data()!;
      final userScore = userData['totalScore'] ?? 0;

      final higherScoresCount = await _firestore
          .collection('leaderboard')
          .where('totalScore', isGreaterThan: userScore)
          .count()
          .get();

      return higherScoresCount.count! + 1;
    } catch (e) {
      print('❌ Error obteniendo ranking: $e');
      return null;
    }
  }

  /// Limpia los datos del leaderboard
  void clearData() {
    _topPlayers.clear();
    _currentUserEntry = null;
    _currentUserRank = null;
    _error = null;
    notifyListeners();
  }
}
