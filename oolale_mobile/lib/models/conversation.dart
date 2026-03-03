class Conversation {
  final String interlocutorId; // UUID
  final String interlocutorName;
  final String? interlocutorPhoto;
  final String lastMessage; 
  final DateTime lastDate; 
  int unreadCount; 

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
      interlocutorId: json['interlocutor_id']?.toString() ?? '',
      interlocutorName: json['interlocutor_nombre'] ?? 'Artista',
      interlocutorPhoto: json['interlocutor_foto'],
      lastMessage: json['contenido'] ?? json['ultimo_mensaje'] ?? '',
      lastDate: DateTime.tryParse(json['ultima_fecha'] ?? json['fecha_envio'] ?? '') ?? DateTime.now(),
      unreadCount: int.tryParse(json['mensajes_no_leidos']?.toString() ?? '0') ?? 0,
    );
  }
}
