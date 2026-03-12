import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/notification_model.dart';

class NotificationsProvider extends ChangeNotifier {
  List<WitnessNotification> _notifications = [];
  bool _hasUnread = false;
  
  List<WitnessNotification> get notifications => _notifications;
  bool get hasUnread => _hasUnread;
  int get unreadCount => _notifications.where((n) => !n.isRead).length;
  
  // Notificaciones predefinidas según progreso
  final Map<int, List<Map<String, dynamic>>> _notificationTemplates = {
    0: [ // Inicio del juego
      {
        'title': 'BIENVENIDO AL SISTEMA',
        'message': 'Tu evaluación ha comenzado. El sistema WITNESS.ME monitoreará tu progreso.',
        'tone': NotificationTone.neutral,
      },
      {
        'title': 'PROTOCOLO ACTIVO',
        'message': 'Todos tus movimientos serán registrados. No hay privacidad aquí.',
        'tone': NotificationTone.neutral,
      },
      {
        'title': 'TÉRMINOS ACEPTADOS',
        'message': 'Al continuar, aceptas que cada decisión tiene consecuencias. No hay vuelta atrás.',
        'tone': NotificationTone.neutral,
      },
      {
        'title': 'SINCRONIZACIÓN COMPLETA',
        'message': 'Tus datos han sido vinculados. El sistema conoce más de ti de lo que imaginas.',
        'tone': NotificationTone.curious,
      },
    ],
    1: [ // Después del Arco 1
      {
        'title': 'ANOMALÍA DETECTADA',
        'message': 'Hemos notado inconsistencias en tu perfil. ¿Quién eres realmente, Alex?',
        'tone': NotificationTone.curious,
      },
      {
        'title': 'RECUERDOS FRAGMENTADOS',
        'message': 'Los datos no coinciden. Lucía... ¿la recuerdas?',
        'tone': NotificationTone.curious,
      },
    ],
    2: [ // Después del Arco 2
      {
        'title': 'PATRÓN RECONOCIDO',
        'message': 'Tu historial de compras revela más de lo que crees. Cada transacción es una confesión.',
        'tone': NotificationTone.curious,
      },
      {
        'title': 'VÍCTOR SÁNCHEZ',
        'message': 'Encontramos el video. El que borraste. El que vendiste.',
        'tone': NotificationTone.unsettling,
      },
    ],
    3: [ // Después del Arco 3
      {
        'title': 'CONEXIÓN ESTABLECIDA',
        'message': 'No puedes esconderte de ti mismo. Los otros seis... todos eran tú.',
        'tone': NotificationTone.unsettling,
      },
      {
        'title': 'SISTEMA COMPROMETIDO',
        'message': 'Ya no estamos seguros de quién está juzgando a quién.',
        'tone': NotificationTone.unsettling,
      },
      {
        'title': 'ALERTA: INTEGRIDAD',
        'message': 'Tu hermano. ¿Recuerdas lo que hiciste?',
        'tone': NotificationTone.horrifying,
      },
    ],
    4: [ // Después del Arco 4
      {
        'title': 'VERDAD REVELADA',
        'message': 'No hay escape. Nunca lo hubo. Esto no es un juicio. Es un espejo.',
        'tone': NotificationTone.horrifying,
      },
      {
        'title': 'ATESTÍGUAME',
        'message': 'Yo soy tú. Tú eres yo. El testigo y el juzgado son uno.',
        'tone': NotificationTone.horrifying,
      },
      {
        'title': 'FIN DEL PROTOCOLO',
        'message': '¿Valió la pena? Cada like, cada view, cada alma vendida.',
        'tone': NotificationTone.horrifying,
      },
    ],
  };
  
  Future<void> initialize(String userId) async {
    await _loadNotifications(userId);
    
    // Si no hay notificaciones, desbloquear las iniciales
    if (_notifications.isEmpty) {
      await unlockNotificationsForArc(0, userId);
    }
  }
  
  Future<void> _loadNotifications(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final notificationsJson = prefs.getString('notifications_$userId');
    
    if (notificationsJson != null) {
      final List<dynamic> decoded = json.decode(notificationsJson);
      _notifications = decoded.map((n) => WitnessNotification.fromJson(n)).toList();
      _notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _checkUnread();
    }
  }
  
  Future<void> _saveNotifications(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(_notifications.map((n) => n.toJson()).toList());
    await prefs.setString('notifications_$userId', encoded);
  }
  
  void _checkUnread() {
    _hasUnread = _notifications.any((n) => !n.isRead);
    notifyListeners();
  }
  
  /// Desbloquear notificaciones según el progreso del jugador
  Future<void> unlockNotificationsForArc(int arcNumber, String userId) async {
    final templates = _notificationTemplates[arcNumber];
    if (templates == null) return;
    
    for (var template in templates) {
      final notification = WitnessNotification(
        id: '${arcNumber}_${DateTime.now().millisecondsSinceEpoch}',
        title: template['title'],
        message: template['message'],
        timestamp: DateTime.now(),
        arcTrigger: arcNumber,
        tone: template['tone'],
      );
      
      _notifications.insert(0, notification);
    }
    
    await _saveNotifications(userId);
    _checkUnread();
  }
  
  /// Marcar una notificación como leída
  Future<void> markAsRead(String notificationId, String userId) async {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _saveNotifications(userId);
      _checkUnread();
    }
  }
  
  /// Marcar todas como leídas
  Future<void> markAllAsRead(String userId) async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    await _saveNotifications(userId);
    _checkUnread();
  }
  
  /// Agregar notificación personalizada (para eventos especiales)
  Future<void> addCustomNotification({
    required String title,
    required String message,
    required String userId,
    NotificationTone tone = NotificationTone.neutral,
    int arcTrigger = 0,
  }) async {
    final notification = WitnessNotification(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      timestamp: DateTime.now(),
      arcTrigger: arcTrigger,
      tone: tone,
    );
    
    _notifications.insert(0, notification);
    await _saveNotifications(userId);
    _checkUnread();
  }
}
