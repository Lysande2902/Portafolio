import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Manages player preferences for content warnings and disclaimers
class DisclaimerPreferenceManager {
  static const String _keyDemoEndingSkipped = 'demo_ending_skipped';
  static const String _keyLastDecisionTime = 'demo_ending_decision_time';
  
  /// Check if player has chosen to skip the demo ending
  /// Returns false if storage fails (safe fallback to showing content)
  Future<bool> hasSkippedDemoEnding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyDemoEndingSkipped) ?? false;
    } catch (e) {
      debugPrint('⚠️ [DISCLAIMER] Storage read failed: $e');
      return false; // Default to showing disclaimer
    }
  }
  
  /// Save player's decision about demo ending
  /// @param skipped: true if player chose to skip, false if they chose to continue
  Future<void> setDemoEndingSkipped(bool skipped) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      await prefs.setBool(_keyDemoEndingSkipped, skipped);
      await prefs.setInt(_keyLastDecisionTime, timestamp);
      
      debugPrint('✅ [DISCLAIMER] Preference saved: skipped=$skipped');
    } catch (e) {
      debugPrint('⚠️ [DISCLAIMER] Storage write failed: $e');
      // Don't throw - graceful degradation
    }
  }
  
  /// Reset disclaimer preference (for settings/data reset)
  Future<void> resetPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.remove(_keyDemoEndingSkipped);
      await prefs.remove(_keyLastDecisionTime);
      
      debugPrint('✅ [DISCLAIMER] Preference reset');
    } catch (e) {
      debugPrint('⚠️ [DISCLAIMER] Failed to reset preference: $e');
      // Don't throw - graceful degradation
    }
  }
  
  /// Get the timestamp of when the player made their decision
  /// Returns null if no decision has been made or if storage fails
  Future<DateTime?> getLastDecisionTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(_keyLastDecisionTime);
      
      if (timestamp == null) return null;
      
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    } catch (e) {
      debugPrint('⚠️ [DISCLAIMER] Failed to get decision time: $e');
      return null;
    }
  }
}
