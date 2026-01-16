class User {
  final int id;
  final String email;
  final String name;
  final String? role;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id_usuario'] ?? 0,
      email: json['correo_electronico'] ?? '',
      name: json['nombre_completo'] ?? 'Usuario',
      role: json['rol'],
    );
  }
}
