class Message {
  final String id;
  final String senderId; // UUID
  final String receiverId; // UUID
  final String content;
  final DateTime sentAt;
  final bool isRead;
  final DateTime? deliveredAt;
  final DateTime? readAt;
  final String? mediaUrl;
  final String? mediaType; // 'image', 'audio', null
  final String? explicitStatus; // 'pending', 'sent', 'delivered', 'read'

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.sentAt,
    this.isRead = false,
    this.deliveredAt,
    this.readAt,
    this.mediaUrl,
    this.mediaType,
    this.explicitStatus,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id']?.toString() ?? '',
      senderId: json['remitente_id']?.toString() ?? '',
      receiverId: json['destinatario_id']?.toString() ?? '',
      content: json['contenido'] ?? '',
      sentAt: () {
        final dateStr = json['created_at']?.toString();
        if (dateStr == null) return DateTime.now();
        
        // Supabase/Postgres suelen guardar en UTC.
        // Si no tiene 'Z', '+' ni un '-' después de la fecha (índice 10), le añadimos 'Z' para tratarlo como UTC.
        String normalized = dateStr.replaceFirst(' ', 'T');
        if (!normalized.contains('Z') && !normalized.contains('+') && !normalized.substring(10).contains('-')) {
          normalized = '${normalized}Z';
        }
        return DateTime.parse(normalized).toLocal();
      }(),
      isRead: json['leido'] == 1 || json['leido'] == true,
      deliveredAt: json['delivered_at'] != null 
          ? DateTime.parse(json['delivered_at']) 
          : null,
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at']) 
          : null,
      mediaUrl: json['media_url'],
      mediaType: json['media_type'],
      explicitStatus: json['status'],
    );
  }

  /// Get message status: 'pending', 'sent', 'delivered', or 'read'
  String get status {
    if (explicitStatus != null) return explicitStatus!;
    if (readAt != null) return 'read';
    if (deliveredAt != null) return 'delivered';
    return 'sent';
  }
}
