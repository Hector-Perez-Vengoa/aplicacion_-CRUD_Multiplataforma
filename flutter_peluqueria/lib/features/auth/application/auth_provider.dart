import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../data/clients/dio_client.dart';
import '../../../../data/clients/secure_storage_service.dart';
import '../data/repositories/auth_repository.dart';
import '../domain/models/auth_response.dart';
import '../data/dtos/login_request.dart';
import '../data/dtos/register_request.dart';
import '../../../../domain/models/usuario.dart';

/// Provider del servicio de almacenamiento seguro
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

/// Provider del cliente Dio
final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient();
});

/// Provider del repositorio de autenticación
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dioClient = ref.watch(dioClientProvider);
  final storageService = ref.watch(secureStorageServiceProvider);
  return AuthRepository(
    dioClient: dioClient,
    storageService: storageService,
  );
});

/// Estado de autenticación
class AuthState {
  final Usuario? usuario;
  final bool isLoading;
  final String? error;
  final bool requiresApproval; // Para peluqueros pendientes de aprobación

  AuthState({
    this.usuario,
    this.isLoading = false,
    this.error,
    this.requiresApproval = false,
  });

  bool get isAuthenticated => usuario != null && !requiresApproval;

  AuthState copyWith({
    Usuario? usuario,
    bool? isLoading,
    String? error,
    bool? requiresApproval,
  }) {
    return AuthState(
      usuario: usuario ?? this.usuario,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      requiresApproval: requiresApproval ?? this.requiresApproval,
    );
  }
}

/// Notifier de autenticación
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _authRepository;

  @override
  AuthState build() {
    _authRepository = ref.watch(authRepositoryProvider);
    _checkAuthStatus();
    return AuthState();
  }

  /// Verificar estado de autenticación al iniciar
  Future<void> _checkAuthStatus() async {
    final hasSession = await _authRepository.hasActiveSession();
    if (hasSession) {
      try {
        final usuario = await _authRepository.getCurrentUser();
        state = state.copyWith(usuario: usuario);
      } catch (e) {
        await logout();
      }
    }
  }

  /// Login
  Future<AuthResponse> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authRepository.login(
        LoginRequest(email: email, password: password),
      );
      state = state.copyWith(
        usuario: response.usuario,
        isLoading: false,
      );
      return response;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Registro
  Future<AuthResponse> register(RegisterRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _authRepository.register(request);
      
      // Si requiere aprobación (peluquero pendiente), no establecer usuario en autenticado
      if (response.requiresApproval) {
        state = state.copyWith(
          usuario: response.usuario,
          isLoading: false,
          requiresApproval: true,
        );
      } else {
        state = state.copyWith(
          usuario: response.usuario,
          isLoading: false,
        );
      }
      return response;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Logout
  Future<void> logout() async {
    await _authRepository.logout();
    state = AuthState();
  }

  /// Refrescar usuario actual
  Future<void> refreshUser() async {
    try {
      final usuario = await _authRepository.getCurrentUser();
      state = state.copyWith(usuario: usuario);
    } catch (e) {
      // Si falla, mantener estado actual
    }
  }
}

/// Provider del notifier de autenticación
final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});

/// Provider del usuario autenticado
final authUserProvider = Provider<Usuario?>((ref) {
  return ref.watch(authNotifierProvider).usuario;
});

/// Provider para verificar si está autenticado
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authNotifierProvider).isAuthenticated;
});

/// Provider para el rol del usuario
final userRoleProvider = Provider<String?>((ref) {
  return ref.watch(authNotifierProvider).usuario?.rol;
});
