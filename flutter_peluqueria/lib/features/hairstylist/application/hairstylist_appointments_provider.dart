import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/application/auth_provider.dart';
import '../../../domain/models/cita.dart';

/// Provider para obtener las citas asignadas al peluquero autenticado
final hairstylistAppointmentsProviderProvider = FutureProvider<List<Cita>>((ref) async {
  final dioClient = ref.watch(dioClientProvider);
  
  try {
    // Endpoint para citas del peluquero
    final response = await dioClient.get('/hairstylist/agenda');
    final List<dynamic> data = response.data is List ? response.data : response.data['data'] ?? [];
    return data.map((json) => Cita.fromJson(json as Map<String, dynamic>)).toList();
  } catch (e) {
    throw Exception('Error al obtener citas del peluquero: $e');
  }
});

/// Provider para refrescar las citas
final refreshHairstylistAppointmentsProvider = Provider<void Function()>((ref) {
  return () => ref.invalidate(hairstylistAppointmentsProviderProvider);
});
