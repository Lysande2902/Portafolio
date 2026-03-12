import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages the persistence state of tutorials
/// Tracks which tutorials have been completed by the player
class TutorialStateManager {
  // Storage keys
  static const String _keyFirstTimeTutorial = 'has_seen_tutorial';
  static const String _keyArcTutorialPrefix = 'has_seen_arc_tutorial_';
  static const String _keyTimestampPrefix = 'tutorial_completion_timestamp_';
  
  /// Check if first-time tutorial has been completed
  /// Returns false if storage fails (safe fallback to show tutorial)
  Future<bool> hasCompletedFirstTimeTutorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyFirstTimeTutorial) ?? false;
    } catch (e) {
      debugPrint('⚠️ [TUTORIAL] Storage read failed for first-time tutorial: $e');
      return false; // Default to showing tutorial
    }
  }
  
  /// Mark first-time tutorial as completed
  /// Saves completion state and timestamp immediately
  Future<void> completeFirstTimeTutorial() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      await prefs.setBool(_keyFirstTimeTutorial, true);
      await prefs.setInt('${_keyTimestampPrefix}first_time', timestamp);
      
      debugPrint('✅ [TUTORIAL] First-time tutorial marked as completed');
    } catch (e) {
      debugPrint('⚠️ [TUTORIAL] Storage write failed for first-time tutorial: $e');
      // Don't throw - graceful degradation
    }
  }
  
  /// Check if arc-specific tutorial has been completed
  /// Returns false if storage fails (safe fallback to show tutorial)
  Future<bool> hasCompletedArcTutorial(String arcId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyArcTutorialPrefix$arcId';
      return prefs.getBool(key) ?? false;
    } catch (e) {
      debugPrint('⚠️ [TUTORIAL] Storage read failed for arc tutorial $arcId: $e');
      return false; // Default to showing tutorial
    }
  }
  
  /// Mark arc-specific tutorial as completed
  /// Saves completion state and timestamp immediately
  Future<void> completeArcTutorial(String arcId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final key = '$_keyArcTutorialPrefix$arcId';
      
      await prefs.setBool(key, true);
      await prefs.setInt('$_keyTimestampPrefix$arcId', timestamp);
      
      debugPrint('✅ [TUTORIAL] Arc tutorial $arcId marked as completed');
    } catch (e) {
      debugPrint('⚠️ [TUTORIAL] Storage write failed for arc tutorial $arcId: $e');
      // Don't throw - graceful degradation
    }
  }
  
  /// Reset all tutorial states (for testing/debugging)
  /// Clears all tutorial completion flags and timestamps
  Future<void> resetAllTutorials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Remove first-time tutorial
      await prefs.remove(_keyFirstTimeTutorial);
      await prefs.remove('${_keyTimestampPrefix}first_time');
      
      // Remove all arc tutorials
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_keyArcTutorialPrefix) || 
            key.startsWith(_keyTimestampPrefix)) {
          await prefs.remove(key);
        }
      }
      
      debugPrint('✅ [TUTORIAL] All tutorial states reset');
    } catch (e) {
      debugPrint('⚠️ [TUTORIAL] Failed to reset tutorial states: $e');
      // Don't throw - graceful degradation
    }
  }
  
  /// Get completion timestamp for a tutorial
  /// Returns null if not completed or if storage fails
  Future<DateTime?> getTutorialCompletionTime(String tutorialId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_keyTimestampPrefix$tutorialId';
      final timestamp = prefs.getInt(key);
      
      if (timestamp == null) return null;
      
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      debugPrint('⚠️ [TUTORIAL] Failed to get completion time for $tutorialId: $e');
      return null;
    }
  }
  
  /// Get all completed tutorial IDs
  /// Useful for debugging and analytics
  Future<List<String>> getCompletedTutorials() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final completed = <String>[];
      
      // Check first-time tutorial
      if (prefs.getBool(_keyFirstTimeTutorial) ?? false) {
        completed.add('first_time');
      }
      
      // Check arc tutorials
      final keys = prefs.getKeys();
      for (final key in keys) {
        if (key.startsWith(_keyArcTutorialPrefix)) {
          if (prefs.getBool(key) ?? false) {
            final arcId = key.substring(_keyArcTutorialPrefix.length);
            completed.add(arcId);
          }
        }
      }
      
      return completed;
    } catch (e) {
      debugPrint('⚠️ [TUTORIAL] Failed to get completed tutorials: $e');
      return [];
    }
  }
}
