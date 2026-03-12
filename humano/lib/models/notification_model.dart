/// Modelo para las notificaciones del sistema WITNESS.ME
class WitnessNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final int arcTrigger; // Qué arco desbloquea esta notificación (0 = inicio, 1-5 = arcos)
  final NotificationTone tone; // Tono de la notificación (cambia según progreso)
  
  WitnessNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.arcTrigger,
    this.tone = NotificationTone.neutral,
  });
  
  WitnessNotification copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    int? arcTrigger,
    NotificationTone? tone,
  }) {
    return WitnessNotification(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      arcTrigger: arcTrigger ?? this.arcTrigger,
      tone: tone ?? this.tone,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'arcTrigger': arcTrigger,
      'tone': tone.toString(),
    };
  }
  
  factory WitnessNotification.fromJson(Map<String, dynamic> json) {
    return WitnessNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      arcTrigger: json['arcTrigger'] ?? 0,
      tone: NotificationTone.values.firstWhere(
        (e) => e.toString() == json['tone'],
        orElse: () => NotificationTone.neutral,
      ),
    );
  }
}

/// Tono/intensidad de las notificaciones
enum NotificationTone {
  neutral,    // Inicio - notificaciones normales
  curious,    // Arco 1-2 - empiezan a ser extrañas
  unsettling, // Arco 3-4 - perturbadoras
  horrifying, // Arco 5 - revelan la verdad
}
