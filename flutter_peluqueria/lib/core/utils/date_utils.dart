import 'package:intl/intl.dart';

/// Utilidades para manejo de fechas
class AppDateUtils {
  AppDateUtils._();

  /// Formato de fecha ISO 8601
  static String toIso8601(DateTime date) => date.toUtc().toIso8601String();

  /// Parse de fecha ISO 8601
  static DateTime fromIso8601(String dateString) => DateTime.parse(dateString).toLocal();

  /// Formato de fecha legible (ej: "7 dic. 2025")
  static String formatDate(DateTime date, {String locale = 'es'}) {
    return DateFormat.yMMMd(locale).format(date);
  }

  /// Formato de hora (ej: "14:30")
  static String formatTime(DateTime date) {
    return DateFormat.Hm().format(date);
  }

  /// Formato de fecha y hora (ej: "7 dic. 2025 14:30")
  static String formatDateTime(DateTime date, {String locale = 'es'}) {
    return '${formatDate(date, locale: locale)} ${formatTime(date)}';
  }

  /// Verificar si una fecha es hoy
  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  /// Verificar si una fecha es mañana
  static bool isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && date.month == tomorrow.month && date.day == tomorrow.day;
  }

  /// Diferencia en horas entre dos fechas
  static int hoursDifference(DateTime start, DateTime end) {
    return end.difference(start).inHours;
  }
}
