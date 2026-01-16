class Perfil {
  final int id;
  final int userId;
  final String nombreArtistico;
  final String bio;
  final String? avatarUrl;
  final String ubicacion;
  final String nivelExperiencia;

  Perfil({
    required this.id,
    required this.userId,
    required this.nombreArtistico,
    required this.bio,
    this.avatarUrl,
    required this.ubicacion,
    required this.nivelExperiencia,
  });

  factory Perfil.fromJson(Map<String, dynamic> json) {
    return Perfil(
      id: json['id_perfil'] ?? 0,
      userId: json['id_usuario'] ?? 0,
      nombreArtistico: json['nombre_artistico'] ?? '',
      bio: json['descripcion_breve'] ?? '', // Mapped from backend column
      avatarUrl: json['foto_url'],
      ubicacion: json['ubicacion'] ?? 'No especificada',
      nivelExperiencia: json['experiencia'] ?? 'intermedio',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre_artistico': nombreArtistico,
      'descripcion_breve': bio,
      'ubicacion': ubicacion,
      'experiencia': nivelExperiencia,
    };
  }
}
