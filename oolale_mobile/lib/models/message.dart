class Message {
  final int id;
  final int senderId;
  final int receiverId;
  final String content;
  final DateTime sentAt;
  final bool isRead;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.sentAt,
    this.isRead = false,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? 0,
      senderId: json['id_remitente'] ?? 0,
      receiverId: json['id_destinatario'] ?? 0,
      content: json['contenido'] ?? json['mensaje'] ?? '',
      sentAt: DateTime.parse(json['fecha_envio'] ?? DateTime.now().toIso8601String()),
      isRead: json['leido'] == 1 || json['leido'] == true,
    );
  }
}
