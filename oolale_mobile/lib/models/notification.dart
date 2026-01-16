class Notificacion {
  final int id;
  final String titulo;
  final String mensaje;
  final String tipo;
  final bool leida;
  final DateTime fecha;

  Notificacion({
    required this.id,
    required this.titulo,
    required this.mensaje,
    required this.tipo,
    required this.leida,
    required this.fecha,
  });

  factory Notificacion.fromJson(Map<String, dynamic> json) {
    return Notificacion(
      id: json['id_notificacion'] ?? 0,
      titulo: json['titulo'] ?? 'Notificación',
      mensaje: json['mensaje'] ?? '',
      tipo: json['tipo'] ?? 'info',
      leida: (json['leida'] == 1 || json['leida'] == true),
      fecha: json['fecha_creacion'] != null 
          ? DateTime.parse(json['fecha_creacion']) 
          : DateTime.now(),
    );
  }
}
