import 'package:dio/dio.dart';
import '../../../../data/clients/dio_client.dart';
import '../../../../data/clients/secure_storage_service.dart';
import '../../../../domain/models/usuario.dart';
import '../dtos/login_request.dart';
import '../dtos/register_request.dart';
import '../../domain/models/auth_response.dart';

/// Repositorio de autenticación
class AuthRepository {
  final DioClient _dioClient;
  final SecureStorageService _storageService;

  AuthRepository({
    required DioClient dioClient,
    required SecureStorageService storageService,
  })  : _dioClient = dioClient,
        _storageService = storageService;

  /// Login con email y contraseña
  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dioClient.post(
        '/auth/login',
        data: request.toJson(),
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw 'Respuesta de login inválida';
      }

      final authResponse = AuthResponse.fromJson(data);

      // Guardar token y rol si existen (para login y registro de cliente)
      if (authResponse.token != null && authResponse.usuario != null) {
        await _storageService.saveToken(authResponse.token!);
        await _storageService.saveUserRole(authResponse.usuario!.rol);
        _dioClient.updateToken(authResponse.token!);
      }

      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      // Capturar errores de parsing u otros errores
      throw 'Error al procesar la respuesta: ${e.toString()}';
    }
  }

  /// Registro de nuevo usuario
  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dioClient.post(
        '/auth/register',
        data: request.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Guardar token y rol si existen (para registro de cliente)
      if (authResponse.token != null && authResponse.usuario != null) {
        await _storageService.saveToken(authResponse.token!);
        await _storageService.saveUserRole(authResponse.usuario!.rol);
        _dioClient.updateToken(authResponse.token!);
      }

      return authResponse;
    } on DioException catch (e) {
      throw _handleError(e);
    } catch (e) {
      // Capturar errores de parsing u otros errores
      throw 'Error al procesar la respuesta: ${e.toString()}';
    }
  }

  /// Obtener información del usuario actual
  Future<Usuario> getCurrentUser() async {
    try {
      final response = await _dioClient.get('/auth/me');
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw 'Respuesta de usuario inválida';
      }

      final rawUser = data['usuario'] ?? data['user'];
      if (rawUser == null) {
        throw 'La respuesta del servidor no contiene usuario';
      }
      return Usuario.fromJson(rawUser);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _dioClient.post('/auth/logout');
    } catch (_) {
      // Ignorar errores del servidor en logout
    } finally {
      // Limpiar almacenamiento local
      await _storageService.clearAll();
      _dioClient.updateToken(null);
    }
  }

  /// Verificar si hay sesión activa
  Future<bool> hasActiveSession() async {
    final token = await _storageService.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Obtener token almacenado
  Future<String?> getStoredToken() async {
    return await _storageService.getToken();
  }

  /// Obtener rol almacenado
  Future<String?> getStoredRole() async {
    return await _storageService.getUserRole();
  }

  /// Manejo de errores
  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'] as String;
      }
      return 'Error: ${error.response!.statusCode}';
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Tiempo de espera agotado. Verifica tu conexión.';
    } else if (error.type == DioExceptionType.connectionError) {
      return 'Error de conexión. Verifica tu internet.';
    }
    return 'Error desconocido. Intenta de nuevo.';
  }
}
