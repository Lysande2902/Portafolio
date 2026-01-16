class Connection {
  final int id;
  final int requesterId;
  final int receiverId;
  final String status; // pendiente, aceptada, rechazada
  final DateTime createdAt;
  final String? otherUserName; // Helper for UI
  final String? otherUserAvatar; // Helper for UI

  Connection({
    required this.id,
    required this.requesterId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    this.otherUserName,
    this.otherUserAvatar,
  });

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id_conexion'] ?? 0,
      requesterId: json['id_usuario_solicitante'] ?? 0,
      receiverId: json['id_usuario_receptor'] ?? 0,
      status: json['estado'] ?? 'pendiente',
      createdAt: json['fecha_creacion'] != null 
          ? DateTime.parse(json['fecha_creacion']) 
          : DateTime.now(),
      otherUserName: json['nombre_usuario_otro'],
      otherUserAvatar: json['foto_usuario_otro'],
    );
  }
}
