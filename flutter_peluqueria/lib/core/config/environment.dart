import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configuración de entorno de la aplicación
class Environment {
  /// URL base de la API
  static String get apiBaseUrl => dotenv.get('API_BASE_URL', fallback: 'http://localhost:5000/api');

  /// Google Client ID (si se usa OAuth)
  static String get googleClientId => dotenv.get('GOOGLE_CLIENT_ID', fallback: '');

  /// Inicializar variables de entorno
  static Future<void> init() async {
    await dotenv.load(fileName: '.env');
  }
}
