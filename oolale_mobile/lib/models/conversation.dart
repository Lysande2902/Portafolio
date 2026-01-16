class Conversation {
  final int interlocutorId;
  final String interlocutorName;
  final String? interlocutorPhoto;
  final String lastMessage; // 'ultimo_mensaje'
  final DateTime lastDate; // 'ultima_fecha'
  final int unreadCount; // 'mensajes_no_leidos'

  Conversation({
    required this.interlocutorId,
    required this.interlocutorName,
    this.interlocutorPhoto,
    required this.lastMessage,
    required this.lastDate,
    required this.unreadCount,
  });

  factory Conversation.fromJson(Map<String, dynamic> json) {
    return Conversation(
      interlocutorId: json['interlocutor_id'] ?? 0,
      interlocutorName: json['interlocutor_nombre'] ?? 'Usuario',
      interlocutorPhoto: json['interlocutor_foto'],
      lastMessage: json['ultimo_mensaje'] ?? '',
      lastDate: DateTime.tryParse(json['ultima_fecha'] ?? '') ?? DateTime.now(),
      unreadCount: int.tryParse(json['mensajes_no_leidos'].toString()) ?? 0,
    );
  }
}
