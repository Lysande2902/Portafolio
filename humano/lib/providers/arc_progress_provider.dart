import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/models/arc.dart';
import '../data/models/arc_progress.dart';
import '../data/providers/arc_data_provider.dart';

class ArcProgressProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ArcDataProvider _arcDataProvider = ArcDataProvider();
  
  Map<String, ArcProgress> _progressMap = {};
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;
  
  Map<String, ArcProgress> get progressMap => _progressMap;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load progress for a specific user from Firestore and cache locally
  Future<void> loadProgress(String userId) async {
    if (_currentUserId == userId && _progressMap.isNotEmpty) {
      // Already loaded for this user
      return;
    }

    _currentUserId = userId;
    _isLoading = true;
    _error = null;
    Future.microtask(() => notifyListeners());

    try {
      // Try to load from local cache first
      await _loadFromCache(userId);
      
      // Then fetch from Firestore
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('arcProgress')
          .get();

      for (var doc in snapshot.docs) {
        try {
          final progress = ArcProgress.fromJson(doc.data());
          _progressMap[doc.id] = progress;
        } catch (e) {
          debugPrint('Error parsing arc progress for ${doc.id}: $e');
        }
      }

      // Save to cache
      await _saveToCache(userId);
      
      _isLoading = false;
      Future.microtask(() => notifyListeners());
    } catch (e) {
      _error = 'Error al cargar progreso: $e';
      _isLoading = false;
      _isLoading = false;
      Future.microtask(() => notifyListeners());
      debugPrint('Error loading progress: $e');
    }
  }

  /// Update progress for a specific arc
  Future<void> updateProgress(String arcId, ArcProgress progress) async {
    if (_currentUserId == null) {
      debugPrint('No user ID set, cannot update progress');
      return;
    }

    try {
      // Update in Firestore
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .collection('arcProgress')
          .doc(arcId)
          .set(progress.toJson());

      // Update local map
      _progressMap[arcId] = progress;
      
      // Update cache
      await _saveToCache(_currentUserId!);
      
      notifyListeners();
    } catch (e) {
      _error = 'Error al guardar progreso: $e';
      notifyListeners();
      debugPrint('Error updating progress: $e');
    }
  }

  /// Get progress for a specific arc
  ArcProgress? getProgress(String arcId) {
    return _progressMap[arcId];
  }

  /// Check if an arc is unlocked based on requirements
  bool isArcUnlocked(Arc arc) {
    // If unlocked by default, return true
    if (arc.isUnlockedByDefault) {
      return true;
    }

    // Check if all required arcs are completed
    for (String requiredArcId in arc.unlockRequirements) {
      final progress = _progressMap[requiredArcId];
      if (progress == null || progress.status != ArcStatus.completed) {
        return false;
      }
    }

    return true;
  }

  /// Get progress percentage for a specific arc
  double getProgressPercent(String arcId) {
    final progress = _progressMap[arcId];
    return progress?.progressPercent ?? 0.0;
  }

  /// Get status for a specific arc
  ArcStatus getStatus(String arcId) {
    final progress = _progressMap[arcId];
    return progress?.status ?? ArcStatus.notStarted;
  }

  /// Start a new arc
  Future<void> startArc(String arcId) async {
    final currentProgress = _progressMap[arcId];
    final newProgress = ArcProgress(
      arcId: arcId,
      status: ArcStatus.inProgress,
      progressPercent: 0.0,
      lastPlayed: DateTime.now(),
      attemptsCount: (currentProgress?.attemptsCount ?? 0) + 1,
      evidencesCollected: currentProgress?.evidencesCollected ?? [],
    );

    await updateProgress(arcId, newProgress);
  }

  /// Complete an arc
  Future<void> completeArc(String arcId, List<String> evidencesCollected) async {
    final currentProgress = _progressMap[arcId];
    final newProgress = ArcProgress(
      arcId: arcId,
      status: ArcStatus.completed,
      progressPercent: 1.0,
      lastPlayed: DateTime.now(),
      attemptsCount: currentProgress?.attemptsCount ?? 1,
      evidencesCollected: evidencesCollected,
    );

    await updateProgress(arcId, newProgress);
  }

  /// Load progress from local cache
  Future<void> _loadFromCache(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'arc_progress_$userId';
      final cachedData = prefs.getString(cacheKey);
      
      if (cachedData != null) {
        final Map<String, dynamic> decoded = json.decode(cachedData);
        _progressMap = decoded.map(
          (key, value) => MapEntry(key, ArcProgress.fromJson(value)),
        );
      }
    } catch (e) {
      debugPrint('Error loading from cache: $e');
    }
  }

  /// Save progress to local cache
  Future<void> _saveToCache(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = 'arc_progress_$userId';
      final encoded = json.encode(
        _progressMap.map((key, value) => MapEntry(key, value.toJson())),
      );
      await prefs.setString(cacheKey, encoded);
    } catch (e) {
      debugPrint('Error saving to cache: $e');
    }
  }

  /// Clear all progress (for testing or logout)
  void clearProgress() {
    _progressMap.clear();
    _currentUserId = null;
    _error = null;
    notifyListeners();
  }
}
