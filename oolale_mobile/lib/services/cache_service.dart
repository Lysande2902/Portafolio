import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Service for caching data locally using SharedPreferences
/// Helps reduce API calls and improve app performance
class CacheService {
  static const String _profilePrefix = 'profile_';
  static const String _eventsPrefix = 'events_';
  static const String _conversationsPrefix = 'conversations_';
  static const String _discoveryPrefix = 'discovery_';
  static const Duration _defaultExpiry = Duration(minutes: 15);

  /// Save profile data to cache
  static Future<void> cacheProfile(String userId, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await prefs.setString('$_profilePrefix$userId', jsonEncode(cacheData));
      debugPrint('✅ Profile cached for user: $userId');
    } catch (e) {
      debugPrint('❌ Error caching profile: $e');
    }
  }

  /// Get cached profile data
  static Future<Map<String, dynamic>?> getCachedProfile(String userId, {Duration? expiry}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('$_profilePrefix$userId');
      if (cached == null) return null;

      final cacheData = jsonDecode(cached);
      final timestamp = cacheData['timestamp'] as int;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      final maxAge = (expiry ?? _defaultExpiry).inMilliseconds;

      if (age > maxAge) {
        debugPrint('⏰ Cache expired for profile: $userId');
        return null;
      }

      debugPrint('✅ Profile loaded from cache: $userId');
      return cacheData['data'] as Map<String, dynamic>;
    } catch (e) {
      debugPrint('❌ Error getting cached profile: $e');
      return null;
    }
  }

  /// Save events list to cache
  static Future<void> cacheEvents(String userId, List<Map<String, dynamic>> events) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'data': events,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await prefs.setString('$_eventsPrefix$userId', jsonEncode(cacheData));
      debugPrint('✅ Events cached for user: $userId (${events.length} events)');
    } catch (e) {
      debugPrint('❌ Error caching events: $e');
    }
  }

  /// Get cached events list
  static Future<List<Map<String, dynamic>>?> getCachedEvents(String userId, {Duration? expiry}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('$_eventsPrefix$userId');
      if (cached == null) return null;

      final cacheData = jsonDecode(cached);
      final timestamp = cacheData['timestamp'] as int;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      final maxAge = (expiry ?? _defaultExpiry).inMilliseconds;

      if (age > maxAge) {
        debugPrint('⏰ Cache expired for events: $userId');
        return null;
      }

      final data = (cacheData['data'] as List).cast<Map<String, dynamic>>();
      debugPrint('✅ Events loaded from cache: $userId (${data.length} events)');
      return data;
    } catch (e) {
      debugPrint('❌ Error getting cached events: $e');
      return null;
    }
  }

  /// Save conversations list to cache
  static Future<void> cacheConversations(String userId, List<Map<String, dynamic>> conversations) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'data': conversations,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      await prefs.setString('$_conversationsPrefix$userId', jsonEncode(cacheData));
      debugPrint('✅ Conversations cached for user: $userId (${conversations.length} conversations)');
    } catch (e) {
      debugPrint('❌ Error caching conversations: $e');
    }
  }

  /// Get cached conversations list
  static Future<List<Map<String, dynamic>>?> getCachedConversations(String userId, {Duration? expiry}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cached = prefs.getString('$_conversationsPrefix$userId');
      if (cached == null) return null;

      final cacheData = jsonDecode(cached);
      final timestamp = cacheData['timestamp'] as int;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      final maxAge = (expiry ?? _defaultExpiry).inMilliseconds;

      if (age > maxAge) {
        debugPrint('⏰ Cache expired for conversations: $userId');
        return null;
      }

      final data = (cacheData['data'] as List).cast<Map<String, dynamic>>();
      debugPrint('✅ Conversations loaded from cache: $userId (${data.length} conversations)');
      return data;
    } catch (e) {
      debugPrint('❌ Error getting cached conversations: $e');
      return null;
    }
  }

  /// Save discovery results to cache
  static Future<void> cacheDiscovery(String query, List<Map<String, dynamic>> results) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'data': results,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      final key = '$_discoveryPrefix${query.isEmpty ? 'all' : query}';
      await prefs.setString(key, jsonEncode(cacheData));
      debugPrint('✅ Discovery cached for query: "$query" (${results.length} results)');
    } catch (e) {
      debugPrint('❌ Error caching discovery: $e');
    }
  }

  /// Get cached discovery results
  static Future<List<Map<String, dynamic>>?> getCachedDiscovery(String query, {Duration? expiry}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = '$_discoveryPrefix${query.isEmpty ? 'all' : query}';
      final cached = prefs.getString(key);
      if (cached == null) return null;

      final cacheData = jsonDecode(cached);
      final timestamp = cacheData['timestamp'] as int;
      final age = DateTime.now().millisecondsSinceEpoch - timestamp;
      final maxAge = (expiry ?? _defaultExpiry).inMilliseconds;

      if (age > maxAge) {
        debugPrint('⏰ Cache expired for discovery: "$query"');
        return null;
      }

      final data = (cacheData['data'] as List).cast<Map<String, dynamic>>();
      debugPrint('✅ Discovery loaded from cache: "$query" (${data.length} results)');
      return data;
    } catch (e) {
      debugPrint('❌ Error getting cached discovery: $e');
      return null;
    }
  }

  /// Clear all cache
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      final cacheKeys = keys.where((key) => 
        key.startsWith(_profilePrefix) ||
        key.startsWith(_eventsPrefix) ||
        key.startsWith(_conversationsPrefix) ||
        key.startsWith(_discoveryPrefix)
      );
      
      for (final key in cacheKeys) {
        await prefs.remove(key);
      }
      
      debugPrint('✅ All cache cleared (${cacheKeys.length} entries)');
    } catch (e) {
      debugPrint('❌ Error clearing cache: $e');
    }
  }

  /// Clear cache for specific user
  static Future<void> clearUserCache(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_profilePrefix$userId');
      await prefs.remove('$_eventsPrefix$userId');
      await prefs.remove('$_conversationsPrefix$userId');
      debugPrint('✅ Cache cleared for user: $userId');
    } catch (e) {
      debugPrint('❌ Error clearing user cache: $e');
    }
  }

  /// Get cache size (approximate)
  static Future<int> getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      int totalSize = 0;
      
      for (final key in keys) {
        if (key.startsWith(_profilePrefix) ||
            key.startsWith(_eventsPrefix) ||
            key.startsWith(_conversationsPrefix) ||
            key.startsWith(_discoveryPrefix)) {
          final value = prefs.getString(key);
          if (value != null) {
            totalSize += value.length;
          }
        }
      }
      
      return totalSize;
    } catch (e) {
      debugPrint('❌ Error getting cache size: $e');
      return 0;
    }
  }

  /// Get cache statistics
  static Future<Map<String, int>> getCacheStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      int profiles = 0;
      int events = 0;
      int conversations = 0;
      int discovery = 0;
      
      for (final key in keys) {
        if (key.startsWith(_profilePrefix)) profiles++;
        else if (key.startsWith(_eventsPrefix)) events++;
        else if (key.startsWith(_conversationsPrefix)) conversations++;
        else if (key.startsWith(_discoveryPrefix)) discovery++;
      }
      
      return {
        'profiles': profiles,
        'events': events,
        'conversations': conversations,
        'discovery': discovery,
        'total': profiles + events + conversations + discovery,
      };
    } catch (e) {
      debugPrint('❌ Error getting cache stats: $e');
      return {};
    }
  }
}
