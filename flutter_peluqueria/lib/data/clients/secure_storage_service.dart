import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/config/constants.dart';

/// Servicio de almacenamiento seguro para tokens y datos sensibles
class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Guardar token de autenticación
  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenStorageKey, value: token);
  }

  /// Obtener token de autenticación
  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenStorageKey);
  }

  /// Eliminar token de autenticación
  Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.tokenStorageKey);
  }

  /// Guardar rol del usuario
  Future<void> saveUserRole(String role) async {
    await _storage.write(key: AppConstants.userRoleStorageKey, value: role);
  }

  /// Obtener rol del usuario
  Future<String?> getUserRole() async {
    return await _storage.read(key: AppConstants.userRoleStorageKey);
  }

  /// Eliminar rol del usuario
  Future<void> deleteUserRole() async {
    await _storage.delete(key: AppConstants.userRoleStorageKey);
  }

  /// Limpiar todo el almacenamiento (logout completo)
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
