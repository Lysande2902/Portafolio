class PortfolioMedia {
  final int id;
  final String profileId;
  final String titulo;
  final String tipo; // 'video', 'audio', 'imagen'
  final String url;
  final String? thumbnailUrl;
  final int vistas;
  final int descargas;
  final String visibilidad; // 'publico', 'privado'
  final DateTime createdAt;

  PortfolioMedia({
    required this.id,
    required this.profileId,
    required this.titulo,
    required this.tipo,
    required this.url,
    this.thumbnailUrl,
    required this.vistas,
    required this.descargas,
    required this.visibilidad,
    required this.createdAt,
  });

  factory PortfolioMedia.fromJson(Map<String, dynamic> json) {
    return PortfolioMedia(
      id: json['id'] as int,
      profileId: json['profile_id'] as String,
      titulo: json['titulo'] as String? ?? 'Sin título',
      tipo: json['tipo'] as String? ?? 'otro',
      url: json['url_recurso'] as String? ?? json['url'] as String? ?? '',
      thumbnailUrl: json['thumbnail_url'] as String?,
      vistas: json['vistas'] as int? ?? 0,
      descargas: json['descargas'] as int? ?? 0,
      visibilidad: json['visibilidad'] as String? ?? 'publico',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profile_id': profileId,
      'titulo': titulo,
      'tipo': tipo,
      'url_recurso': url,
      'thumbnail_url': thumbnailUrl,
      'vistas': vistas,
      'descargas': descargas,
      'visibilidad': visibilidad,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
