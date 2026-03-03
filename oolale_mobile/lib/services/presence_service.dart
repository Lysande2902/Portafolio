import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing user presence (online/offline status)
class PresenceService {
  static final _supabase = Supabase.instance.client;
  static String? _currentUserId;

  /// Initialize presence service for current user
  static Future<void> initialize() async {
    try {
      _currentUserId = _supabase.auth.currentUser?.id;
      if (_currentUserId == null) {
        debugPrint('⚠️ No hay usuario autenticado para inicializar presencia');
        return;
      }

      // Marcar como en línea al iniciar
      await setOnline();
      
      debugPrint('✅ PresenceService inicializado para usuario: $_currentUserId');
    } catch (e) {
      debugPrint('❌ Error inicializando PresenceService: $e');
    }
  }

  /// Set user status to online
  static Future<void> setOnline() async {
    try {
      final userId = _currentUserId ?? _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('perfiles').update({
        'en_linea': true,
        'ultima_conexion': DateTime.now().toIso8601String(),
      }).eq('id', userId); // Cambiado de 'user_id' a 'id'

      debugPrint('✅ Usuario marcado como EN LÍNEA');
    } catch (e) {
      // Si las columnas no existen, solo registrar el error sin fallar
      debugPrint('⚠️ Error marcando usuario como en línea (ejecuta FIX_SUPABASE_SIMPLE.sql): $e');
    }
  }

  /// Set user status to offline
  static Future<void> setOffline() async {
    try {
      final userId = _currentUserId ?? _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('perfiles').update({
        'en_linea': false,
        'ultima_conexion': DateTime.now().toIso8601String(),
      }).eq('id', userId); // Cambiado de 'user_id' a 'id'

      debugPrint('✅ Usuario marcado como DESCONECTADO');
    } catch (e) {
      // Si las columnas no existen, solo registrar el error sin fallar
      debugPrint('⚠️ Error marcando usuario como desconectado (ejecuta FIX_SUPABASE_SIMPLE.sql): $e');
    }
  }

  /// Clean up when user logs out
  static Future<void> dispose() async {
    await setOffline();
    _currentUserId = null;
    debugPrint('✅ PresenceService limpiado');
  }
}
