class Usuario {
  final String id;
  final String nombre;
  final String email;
  final String telefono;
  final String rol;
  final bool activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Usuario({
    required this.id,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.rol,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    final idValue = json['id'] ?? json['_id'];
    if (idValue == null) throw 'Usuario sin id';

    final nombre = json['nombre'] ?? json['name'];
    if (nombre == null) throw 'Usuario sin nombre';

    final email = json['email'];
    if (email == null) throw 'Usuario sin email';

    final telefono = json['telefono'] ?? json['phone'] ?? '';

    final rol = json['rol'] ?? json['role'];
    if (rol == null) throw 'Usuario sin rol';

    return Usuario(
      id: idValue.toString(),
      nombre: nombre.toString(),
      email: email.toString(),
      telefono: telefono.toString(),
      rol: rol.toString(),
      activo: json['activo'] as bool? ?? json['active'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'email': email,
        'telefono': telefono,
        'rol': rol,
        'activo': activo,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
