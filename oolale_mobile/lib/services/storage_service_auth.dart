import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageServiceAuth {
  static const _storage = FlutterSecureStorage();
  
  // Keys
  static const String _rememberMeKey = 'remember_me';
  static const String _emailKey = 'saved_email';
  static const String _sessionKey = 'session_token';

  // Remember Me
  static Future<void> setRememberMe(bool value) async {
    await _storage.write(key: _rememberMeKey, value: value.toString());
  }

  static Future<bool> getRememberMe() async {
    final value = await _storage.read(key: _rememberMeKey);
    return value == 'true';
  }

  // Email
  static Future<void> saveEmail(String email) async {
    await _storage.write(key: _emailKey, value: email);
  }

  static Future<String?> getSavedEmail() async {
    return await _storage.read(key: _emailKey);
  }

  static Future<void> clearEmail() async {
    await _storage.delete(key: _emailKey);
  }

  // Session Token (for persistent login)
  static Future<void> saveSessionToken(String token) async {
    await _storage.write(key: _sessionKey, value: token);
  }

  static Future<String?> getSessionToken() async {
    return await _storage.read(key: _sessionKey);
  }

  static Future<void> clearSessionToken() async {
    await _storage.delete(key: _sessionKey);
  }

  // Clear all
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
