class RegisterRequest {
  final String nombre;
  final String email;
  final String telefono;
  final String password;
  final String rol;
  final List<String>? serviciosEspecializados;

  RegisterRequest({
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.password,
    required this.rol,
    this.serviciosEspecializados,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) =>
      RegisterRequest(
        nombre: json['nombre'] as String,
        email: json['email'] as String,
        telefono: json['telefono'] as String,
        password: json['contrasena'] as String? ?? json['password'] as String,
        rol: json['rol'] as String,
        serviciosEspecializados:
            (json['servicios_especializados'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList(),
      );

  Map<String, dynamic> toJson() => {
        'nombre': nombre,
        'email': email,
        'telefono': telefono,
        'contrasena': password,
        'rol': rol,
        'serviciosEspecializados': serviciosEspecializados,
      };
}
