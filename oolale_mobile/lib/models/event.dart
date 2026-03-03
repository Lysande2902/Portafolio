class Evento {
  final int id;
  final String titulo;
  final String descripcion;
  final DateTime fecha;
  final String hora;
  final String ubicacion;
  final String tipo;
  final String organizadorId; // UUID
  final String? flyerUrl;
  final String? estatus;

  Evento({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fecha,
    required this.hora,
    required this.ubicacion,
    required this.tipo,
    required this.organizadorId,
    this.flyerUrl,
    this.estatus,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'] ?? 0,
      titulo: json['titulo_bolo'] ?? 'Sin título',
      descripcion: json['resumen_setlist'] ?? '',
      fecha: json['fecha_gig'] != null 
          ? DateTime.parse(json['fecha_gig']) 
          : DateTime.now(),
      hora: json['hora_soundcheck'] ?? '00:00',
      ubicacion: json['lugar_nombre'] ?? 'Por definir',
      tipo: json['tipo'] ?? 'otro',
      organizadorId: json['organizador_id']?.toString() ?? '',
      flyerUrl: json['flyer_url'],
      estatus: json['estatus_bolo'] ?? 'programado',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo_bolo': titulo,
      'resumen_setlist': descripcion,
      'tipo': tipo,
      'fecha_gig': fecha.toIso8601String().split('T')[0],
      'hora_soundcheck': hora,
      'lugar_nombre': ubicacion,
      'organizador_id': organizadorId,
    };
  }
}
