import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/application/auth_provider.dart';
import '../../../domain/models/peluquero.dart';

final hairstylistProviderProvider = FutureProvider.family<List<Peluquero>, String?>((ref, serviceId) async {
  final dioClient = ref.watch(dioClientProvider);
  
  try {
    if (serviceId == null || serviceId.isEmpty) {
      return [];
    }
    
    final response = await dioClient.get('/client/hairstylists', queryParameters: {'serviceId': serviceId});
    
    // Extraer lista de peluqueros de la respuesta
    List<dynamic> data = [];
    if (response.data is List) {
      data = response.data;
    } else if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      data = map['peluqueros'] ?? map['data'] ?? [];
    }
    
    return data.map((json) => Peluquero.fromJson(json as Map<String, dynamic>)).toList();
  } catch (e) {
    throw Exception('Error al obtener peluqueros: $e');
  }
});
