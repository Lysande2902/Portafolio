class Evento {
  final int id;
  final String titulo;
  final String descripcion;
  final DateTime fechaHora;
  final String ubicacion;
  final String tipo;
  final int organizadorId;
  final String? organizadorNombre;

  Evento({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaHora,
    required this.ubicacion,
    required this.tipo,
    required this.organizadorId,
    this.organizadorNombre,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id_evento'] ?? 0,
      titulo: json['titulo'] ?? 'Sin título',
      descripcion: json['descripcion'] ?? '',
      fechaHora: json['fecha_hora'] != null 
          ? DateTime.parse(json['fecha_hora']) 
          : DateTime.now(),
      ubicacion: json['ubicacion'] ?? 'Por definir',
      tipo: json['tipo_evento'] ?? 'jam',
      organizadorId: json['id_organizador'] ?? 0,
      organizadorNombre: json['nombre_organizador'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'fecha_hora': fechaHora.toIso8601String(),
      'ubicacion': ubicacion,
      'tipo_evento': tipo,
    };
  }
}
