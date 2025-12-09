import '../../../../domain/models/usuario.dart';

class AuthResponse {
  final String? token;
  final Usuario? usuario;
  final String? redirectUrl;
  final bool requiresApproval;

  AuthResponse({
    this.token,
    this.usuario,
    this.redirectUrl,
    this.requiresApproval = false,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Verificar si es una respuesta de registro pendiente de aprobación
    final requiresApproval = json['requiresApproval'] as bool? ?? false;
    
    if (requiresApproval) {
      // Para registro de peluquero pendiente
      final rawUser = json['user'] ?? json['data']?['user'];
      if (rawUser is! Map<String, dynamic>) {
        throw 'La respuesta no contiene usuario válido';
      }

      final normalizedUser = _normalizeUser(rawUser);

      return AuthResponse(
        token: null,
        usuario: Usuario.fromJson(normalizedUser),
        redirectUrl: null,
        requiresApproval: true,
      );
    }

    // Backend may return token at different levels
    final token = json['token'] ?? json['data']?['token'];
    if (token == null) {
      throw 'La respuesta no contiene token';
    }

    // Backend may return `usuario` or `user`; ensure it's a map before casting.
    final rawUser = json['usuario'] ?? 
                    json['user'] ?? 
                    json['data']?['usuario'] ?? 
                    json['data']?['user'];
    
    if (rawUser is! Map<String, dynamic>) {
      throw 'La respuesta no contiene usuario válido';
    }

    // Normalizar el usuario para asegurar compatibilidad
    final normalizedUser = _normalizeUser(rawUser);

    return AuthResponse(
      token: token.toString(),
      usuario: Usuario.fromJson(normalizedUser),
      redirectUrl: json['redirectUrl'] as String? ?? json['data']?['redirectUrl'] as String?,
      requiresApproval: false,
    );
  }

  /// Normaliza la estructura del usuario para manejar diferentes formatos
  static Map<String, dynamic> _normalizeUser(Map<String, dynamic> user) {
    return {
      'id': user['id'] ?? user['_id'],
      '_id': user['id'] ?? user['_id'],
      'nombre': user['nombre'] ?? user['name'],
      'name': user['nombre'] ?? user['name'],
      'email': user['email'] ?? user['email'],
      'telefono': user['telefono'] ?? user['phone'] ?? '',
      'phone': user['telefono'] ?? user['phone'] ?? '',
      'rol': user['rol'] ?? user['role'],
      'role': user['rol'] ?? user['role'],
      'activo': user['activo'] ?? user['active'] ?? true,
      'active': user['activo'] ?? user['active'] ?? true,
      'createdAt': user['createdAt'],
      'updatedAt': user['updatedAt'],
    };
  }

  Map<String, dynamic> toJson() => {
        'token': token,
        'usuario': usuario?.toJson(),
        'redirectUrl': redirectUrl,
        'requiresApproval': requiresApproval,
      };
}
