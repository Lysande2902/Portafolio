class User {
  final String id;
  final String email;
  final String name;
  final bool isAdmin;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.isAdmin = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id_usuario']?.toString() ?? json['id']?.toString() ?? '',
      email: json['correo_electronico'] ?? json['email'] ?? '',
      name: json['nombre_completo'] ?? json['full_name'] ?? 'Usuario',
      isAdmin: json['es_admin'] ?? false,
    );
  }
}
