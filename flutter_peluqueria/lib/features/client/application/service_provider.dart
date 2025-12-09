import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../features/auth/application/auth_provider.dart';
import '../../../domain/models/servicio.dart';
import '../../../core/config/environment.dart';

final serviceProviderProvider = FutureProvider<List<Servicio>>((ref) async {
  final dioClient = ref.watch(dioClientProvider);
  
  try {
    final response = await dioClient.get('/client/services');
    final List<dynamic> data = response.data is List ? response.data : response.data['servicios'] ?? response.data['data'] ?? [];
    return data.map((json) => Servicio.fromJson(json as Map<String, dynamic>)).toList();
  } catch (e) {
    throw Exception('Error al obtener servicios: $e');
  }
});

// Provider para servicios públicos (sin autenticación, usado en registro)
final publicServiceProviderProvider = FutureProvider<List<Servicio>>((ref) async {
  try {
    final dio = Dio(BaseOptions(
      baseUrl: Environment.apiBaseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ));
    
    final response = await dio.get('/auth/services');
    final List<dynamic> data = response.data is List ? response.data : response.data['servicios'] ?? response.data['data'] ?? [];
    return data.map((json) => Servicio.fromJson(json as Map<String, dynamic>)).toList();
  } catch (e) {
    throw Exception('Error al obtener servicios: $e');
  }
});
