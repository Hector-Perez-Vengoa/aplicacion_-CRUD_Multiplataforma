/// Constantes de la aplicación
class AppConstants {
  AppConstants._();

  /// Timeout para peticiones HTTP (en segundos)
  static const int httpTimeout = 30;

  /// Nombre de la key para almacenar el token JWT
  static const String tokenStorageKey = 'auth_token';

  /// Nombre de la key para almacenar el rol del usuario
  static const String userRoleStorageKey = 'user_role';

  /// Regla de cancelación de citas (horas mínimas de anticipación)
  static const int cancellationMinHours = 24;

  /// Duración de slots de disponibilidad (minutos)
  static const int slotDurationMinutes = 15;
}
