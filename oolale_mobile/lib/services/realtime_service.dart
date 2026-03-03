import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for managing Supabase Realtime connections
/// Handles message streaming, typing indicators, read receipts, presence status, and auto-reconnection
class RealtimeService {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;
  RealtimeChannel? _presenceChannel;
  StreamController<Map<String, dynamic>>? _messageController;
  StreamController<TypingEvent>? _typingController;
  StreamController<RealtimeConnectionState>? _connectionController;
  StreamController<PresenceEvent>? _presenceController;
  
  // Reconnection management
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _reconnectDelay = Duration(seconds: 3);
  
  // Connection state
  bool _isConnected = false;
  String? _currentUserId;
  String? _currentOtherUserId;
  Function(Map<String, dynamic>)? _currentOnMessage;

  RealtimeService(this._supabase) {
    _connectionController = StreamController<RealtimeConnectionState>.broadcast();
  }

  /// Get connection state stream
  Stream<RealtimeConnectionState> get connectionState => _connectionController!.stream;

  /// Check if currently connected
  bool get isConnected => _isConnected;

  /// Subscribe to a conversation channel for real-time messages
  /// [userId] - Current user's ID
  /// [otherUserId] - Other participant's ID
  /// [onMessage] - Callback when new message arrives
  Future<void> subscribeToConversation(
    String userId,
    String otherUserId,
    Function(Map<String, dynamic>) onMessage,
  ) async {
    // Store connection parameters for reconnection
    _currentUserId = userId;
    _currentOtherUserId = otherUserId;
    _currentOnMessage = onMessage;
    
    await _connect();
  }

  /// Internal connection method
  Future<void> _connect() async {
    if (_currentUserId == null || _currentOtherUserId == null || _currentOnMessage == null) {
      return;
    }

    // Create unique channel name for this conversation
    final channelName = _getChannelName(_currentUserId!, _currentOtherUserId!);

    // Unsubscribe from previous channel if exists
    await _unsubscribeInternal();

    // Update connection state
    _updateConnectionState(RealtimeConnectionState.connecting);

    // Create message stream controller if needed
    _messageController ??= StreamController<Map<String, dynamic>>.broadcast();
    _messageController!.stream.listen(_currentOnMessage!);

    try {
      // Subscribe to messages table changes
      _channel = _supabase.channel(channelName)
          .onPostgresChanges(
            event: PostgresChangeEvent.insert,
            schema: 'public',
            table: 'conversaciones',
            callback: (payload) {
              final newMessage = payload.newRecord;
              _messageController?.add({'event': 'insert', 'data': newMessage});
            },
          )
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'conversaciones',
            callback: (payload) {
              final updatedMessage = payload.newRecord;
              _messageController?.add({'event': 'update', 'data': updatedMessage});
            },
          )
          .subscribe((status, error) {
            if (status == RealtimeSubscribeStatus.subscribed) {
              debugPrint('✅ Subscribed to conversation: $channelName');
              _isConnected = true;
              _reconnectAttempts = 0;
              _updateConnectionState(RealtimeConnectionState.connected);
            } else if (status == RealtimeSubscribeStatus.closed) {
              debugPrint('⚠️ Connection closed');
              _isConnected = false;
              _updateConnectionState(RealtimeConnectionState.disconnected);
              _scheduleReconnect();
            } else if (error != null) {
              debugPrint('❌ Subscription error: $error');
              _isConnected = false;
              _updateConnectionState(RealtimeConnectionState.error);
              _scheduleReconnect();
            }
          });
    } catch (e) {
      debugPrint('❌ Error connecting: $e');
      _isConnected = false;
      _updateConnectionState(RealtimeConnectionState.error);
      _scheduleReconnect();
    }
  }

  /// Schedule automatic reconnection
  void _scheduleReconnect() {
    // Cancel existing timer
    _reconnectTimer?.cancel();
    
    // Check if we've exceeded max attempts
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('❌ Max reconnection attempts reached');
      _updateConnectionState(RealtimeConnectionState.failed);
      return;
    }
    
    _reconnectAttempts++;
    final delay = _reconnectDelay * _reconnectAttempts;
    
    debugPrint('🔄 Scheduling reconnection attempt $_reconnectAttempts in ${delay.inSeconds}s');
    
    _reconnectTimer = Timer(delay, () {
      debugPrint('🔄 Attempting reconnection...');
      _connect();
    });
  }

  /// Manually trigger reconnection
  Future<void> reconnect() async {
    _reconnectAttempts = 0;
    await _connect();
  }

  /// Update connection state and notify listeners
  void _updateConnectionState(RealtimeConnectionState state) {
    if (_connectionController != null && !_connectionController!.isClosed) {
      _connectionController?.add(state);
    }
  }

  /// Broadcast typing indicator to the recipient
  /// [conversationId] - Unique conversation identifier
  /// [isTyping] - Whether user is currently typing
  Future<void> sendTypingIndicator(String conversationId, bool isTyping) async {
    if (_channel == null || !_isConnected) return;

    try {
      await _channel!.sendBroadcastMessage(
        event: 'typing',
        payload: {
          'conversation_id': conversationId,
          'is_typing': isTyping,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      debugPrint('❌ Error sending typing indicator: $e');
    }
  }

  /// Listen for typing indicators from other user
  /// [conversationId] - Unique conversation identifier
  /// Returns stream of typing events
  Stream<TypingEvent> listenTypingIndicators(String conversationId) {
    _typingController = StreamController<TypingEvent>.broadcast();

    _channel?.onBroadcast(
      event: 'typing',
      callback: (payload) {
        if (payload['conversation_id'] == conversationId) {
          _typingController?.add(TypingEvent(
            conversationId: payload['conversation_id'] as String,
            isTyping: payload['is_typing'] as bool,
            timestamp: DateTime.parse(payload['timestamp'] as String),
          ));
        }
      },
    );

    return _typingController!.stream;
  }

  /// Mark message as read
  /// [messageId] - ID of the message to mark as read
  Future<void> markMessageAsRead(String messageId) async {
    try {
      await _supabase.from('conversaciones').update({
        'leido': true,
        'read_at': DateTime.now().toIso8601String(),
      }).eq('id', messageId);
    } catch (e) {
      debugPrint('❌ Error marking message as read: $e');
    }
  }

  /// Mark all messages in a conversation as read
  /// [userId] - Current user's ID
  /// [otherUserId] - Other participant's ID
  Future<void> markAllMessagesAsRead(String userId, String otherUserId) async {
    try {
      await _supabase
          .from('conversaciones')
          .update({
            'leido': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('destinatario_id', userId)
          .eq('remitente_id', otherUserId)
          .eq('leido', false);
    } catch (e) {
      debugPrint('❌ Error marking all messages as read: $e');
    }
  }

  /// Internal unsubscribe without clearing connection parameters
  Future<void> _unsubscribeInternal() async {
    if (_channel != null) {
      await _supabase.removeChannel(_channel!);
      _channel = null;
    }
  }

  /// Unsubscribe from current channel and clean up resources
  Future<void> unsubscribe() async {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _reconnectAttempts = 0;
    
    await _unsubscribeInternal();

    await _messageController?.close();
    _messageController = null;

    await _typingController?.close();
    _typingController = null;
    
    _currentUserId = null;
    _currentOtherUserId = null;
    _currentOnMessage = null;
    _isConnected = false;
    
    _updateConnectionState(RealtimeConnectionState.disconnected);
  }

  /// Generate unique channel name for conversation
  String _getChannelName(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return 'conversation:${ids[0]}:${ids[1]}';
  }

  /// Dispose of all resources
  void dispose() {
    _reconnectTimer?.cancel();
    unsubscribe();
    _connectionController?.close();
    _presenceController?.close();
  }

  /// Update user online status
  /// [userId] - User ID to update status for
  /// [isOnline] - Whether user is online or offline
  Future<void> updateOnlineStatus(String userId, bool isOnline) async {
    try {
      await _supabase.from('perfiles').update({
        'en_linea': isOnline,
        'ultima_conexion': DateTime.now().toIso8601String(),
      }).eq('id', userId); // Cambiado de 'user_id' a 'id'
      
      debugPrint('✅ Estado actualizado: ${isOnline ? "En línea" : "Desconectado"}');
    } catch (e) {
      debugPrint('❌ Error actualizando estado: $e');
    }
  }

  /// Subscribe to presence updates for a specific user
  /// [userId] - User ID to track presence for
  /// Returns stream of presence events
  Stream<PresenceEvent> listenPresence(String userId) {
    _presenceController = StreamController<PresenceEvent>.broadcast();

    // Subscribe to profile changes for this user
    _presenceChannel = _supabase
        .channel('presence:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'perfiles',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'id', // Cambiado de 'user_id' a 'id'
            value: userId,
          ),
          callback: (payload) {
            final record = payload.newRecord;
            if (record != null) {
              final isOnline = record['en_linea'] as bool? ?? false;
              final lastSeen = record['ultima_conexion'] as String?;
              
              _presenceController?.add(PresenceEvent(
                userId: userId,
                isOnline: isOnline,
                lastSeen: lastSeen != null ? () {
                  String normalized = lastSeen.replaceFirst(' ', 'T');
                  if (!normalized.contains('Z') && !normalized.contains('+') && !normalized.substring(10).contains('-')) {
                    normalized = '${normalized}Z';
                  }
                  return DateTime.parse(normalized).toLocal();
                }() : null,
              ));
            }
          },
        )
        .subscribe();

    return _presenceController!.stream;
  }

  /// Unsubscribe from presence updates
  Future<void> unsubscribePresence() async {
    if (_presenceChannel != null) {
      await _supabase.removeChannel(_presenceChannel!);
      _presenceChannel = null;
    }
    await _presenceController?.close();
    _presenceController = null;
  }
}

/// Presence event data class
class PresenceEvent {
  final String userId;
  final bool isOnline;
  final DateTime? lastSeen;

  PresenceEvent({
    required this.userId,
    required this.isOnline,
    this.lastSeen,
  });
}

/// Connection state enum
enum RealtimeConnectionState {
  disconnected,
  connecting,
  connected,
  error,
  failed,
}

/// Typing event data class
class TypingEvent {
  final String conversationId;
  final bool isTyping;
  final DateTime timestamp;

  TypingEvent({
    required this.conversationId,
    required this.isTyping,
    required this.timestamp,
  });
}
