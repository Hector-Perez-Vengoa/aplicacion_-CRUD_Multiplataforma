import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/application/auth_provider.dart';
import '../../../domain/models/cita.dart';

final appointmentProviderProvider = FutureProvider<List<Cita>>((ref) async {
  final dioClient = ref.watch(dioClientProvider);
  
  try {
    final response = await dioClient.get('/client/appointments');
    // Backend retorna { citas, total }
    final List<dynamic> data = response.data is List
        ? response.data
        : response.data['citas'] ?? response.data['data'] ?? [];
    return data.map((json) => Cita.fromJson(json as Map<String, dynamic>)).toList();
  } catch (e) {
    throw Exception('Error al obtener citas: $e');
  }
});

class CreateAppointmentRequest {
  final String peluqueroId;
  final String servicioId;
  final DateTime fechaHoraInicio;
  final String? notasCliente;

  CreateAppointmentRequest({
    required this.peluqueroId,
    required this.servicioId,
    required this.fechaHoraInicio,
    this.notasCliente,
  });

  Map<String, dynamic> toJson() => {
    'peluqueroId': peluqueroId,
    'servicioId': servicioId,
    'fechaHoraInicio': fechaHoraInicio.toIso8601String(),
    if (notasCliente != null && notasCliente!.isNotEmpty) 'notasCliente': notasCliente,
  };
}

final createAppointmentProvider = FutureProvider.family<Cita, CreateAppointmentRequest>((ref, request) async {
  final dioClient = ref.watch(dioClientProvider);
  
  try {
    final response = await dioClient.post('/client/appointments', data: request.toJson());

    // El backend retorna { message, cita } en la clave 'cita'
    final raw = response.data is Map<String, dynamic> ? response.data['cita'] ?? response.data['data'] ?? response.data : response.data;
    return Cita.fromJson(raw as Map<String, dynamic>);
  } catch (e) {
    throw Exception('Error al crear cita: $e');
  }
});

/// Request para cancelar una cita
class CancelAppointmentRequest {
  final String citaId;
  final String motivo;

  CancelAppointmentRequest({
    required this.citaId,
    required this.motivo,
  });

  Map<String, dynamic> toJson() => {
    'motivo': motivo,
  };
}

/// Provider para cancelar una cita
final cancelAppointmentProvider = FutureProvider.family<void, CancelAppointmentRequest>((ref, request) async {
  final dioClient = ref.watch(dioClientProvider);
  
  try {
    await dioClient.patch('/client/appointments/${request.citaId}/cancel', data: request.toJson());
    // Invalidar el provider de citas para refrescar la lista
    ref.invalidate(appointmentProviderProvider);
  } catch (e) {
    throw Exception('Error al cancelar cita: $e');
  }
});

/// Notifier para manejar el estado de cancelación
class CancelAppointmentNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> cancelAppointment(String citaId, String motivo) async {
    state = const AsyncValue.loading();
    
    try {
      final dioClient = ref.read(dioClientProvider);
      await dioClient.patch('/client/appointments/$citaId/cancel', data: {'motivo': motivo});
      
      // Refrescar la lista de citas
      ref.invalidate(appointmentProviderProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

final cancelAppointmentNotifierProvider = NotifierProvider<CancelAppointmentNotifier, AsyncValue<void>>(() {
  return CancelAppointmentNotifier();
});

/// Request para actualizar una cita
class UpdateAppointmentRequest {
  final String citaId;
  final String? peluqueroId;
  final String? servicioId;
  final DateTime? fechaHoraInicio;
  final String? notasCliente;

  UpdateAppointmentRequest({
    required this.citaId,
    this.peluqueroId,
    this.servicioId,
    this.fechaHoraInicio,
    this.notasCliente,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (peluqueroId != null) data['peluqueroId'] = peluqueroId;
    if (servicioId != null) data['servicioId'] = servicioId;
    if (fechaHoraInicio != null) data['fechaHoraInicio'] = fechaHoraInicio!.toIso8601String();
    if (notasCliente != null) data['notasCliente'] = notasCliente;
    return data;
  }
}

/// Notifier para manejar el estado de actualización de citas
class UpdateAppointmentNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> updateAppointment(UpdateAppointmentRequest request) async {
    state = const AsyncValue.loading();
    
    try {
      final dioClient = ref.read(dioClientProvider);
      await dioClient.patch('/client/appointments/${request.citaId}', data: request.toJson());
      
      // Refrescar la lista de citas
      ref.invalidate(appointmentProviderProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

final updateAppointmentNotifierProvider = NotifierProvider<UpdateAppointmentNotifier, AsyncValue<void>>(() {
  return UpdateAppointmentNotifier();
});

/// Notifier para manejar la eliminación de citas
class DeleteAppointmentNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncValue.data(null);

  Future<void> deleteAppointment(String citaId) async {
    state = const AsyncValue.loading();
    
    try {
      final dioClient = ref.read(dioClientProvider);
      await dioClient.delete('/client/appointments/$citaId');
      
      // Refrescar la lista de citas
      ref.invalidate(appointmentProviderProvider);
      
      state = const AsyncValue.data(null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      rethrow;
    }
  }
}

final deleteAppointmentNotifierProvider = NotifierProvider<DeleteAppointmentNotifier, AsyncValue<void>>(() {
  return DeleteAppointmentNotifier();
});
