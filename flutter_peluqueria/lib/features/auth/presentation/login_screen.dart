import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/loading_widget.dart';
import '../application/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => _errorMessage = null);
      
      final authResponse = await ref.read(authNotifierProvider.notifier).login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // Navegar según redirect del backend o, en su defecto, por rol
      if (mounted) {
        final redirect = authResponse.redirectUrl;
        String finalRoute = '/home'; // Ruta por defecto

        if (redirect != null && redirect.isNotEmpty) {
          // Mapear rutas del backend a rutas de Flutter
          finalRoute = _mapBackendRouteToFlutter(redirect);
        } else {
          // Usar el rol si no hay redirect
          final role = await ref.read(authRepositoryProvider).getStoredRole();
          if (mounted) {
            if (role == 'cliente') {
              finalRoute = '/home';
            } else if (role == 'peluquero') {
              finalRoute = '/hairstylist';
            } else if (role == 'admin') {
              finalRoute = '/admin';
            }
          }
        }

        if (mounted) {
          context.go(finalRoute);
        }
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    }
  }

  String _mapBackendRouteToFlutter(String backendRoute) {
    // Mapear rutas del backend a rutas de Flutter
    final routeMap = {
      '/cliente/dashboard': '/home',
      '/cliente/citas': '/appointments',
      '/peluquero/dashboard': '/hairstylist',
      '/peluquero/agenda': '/hairstylist/agenda',
      '/admin/dashboard': '/admin',
      '/admin/servicios': '/admin/services',
      '/admin/peluqueros': '/admin/hairstylists',
    };

    // Si la ruta exacta existe en el mapeo, usarla
    if (routeMap.containsKey(backendRoute)) {
      return routeMap[backendRoute]!;
    }

    // Si comienza con /cliente, enviar a home
    if (backendRoute.startsWith('/cliente')) {
      return '/home';
    }

    // Si comienza con /peluquero, enviar a hairstylist
    if (backendRoute.startsWith('/peluquero')) {
      return '/hairstylist';
    }

    // Si comienza con /admin, enviar a admin
    if (backendRoute.startsWith('/admin')) {
      return '/admin';
    }

    // Por defecto, ir a home
    return '/home';
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    if (authState.isLoading) {
      return Scaffold(
        body: LoadingWidget(message: 'Iniciando sesión...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar sesión'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                const SizedBox(height: 24),
                Icon(
                  Icons.person_outline,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 32),

                // Error message
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),

                // Email field
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    hintText: 'usuario@example.com',
                    prefixIcon: const Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor ingresa tu correo';
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
                      return 'Ingresa un correo válido';
                    }
                    return null;
                  },
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Por favor ingresa tu contraseña';
                    }
                    if (value!.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                  enabled: !authState.isLoading,
                ),
                const SizedBox(height: 24),

                // Login button
                ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleLogin,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: authState.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text(
                            'Iniciar sesión',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Register link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿No tienes cuenta? '),
                    TextButton(
                      onPressed: () => context.go('/register'),
                      child: const Text('Registrarse'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    const Expanded(child: Divider()),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'O continúa con',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const Expanded(child: Divider()),
                  ],
                ),
                const SizedBox(height: 16),

                // Google login button (placeholder)
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: Implementar Google OAuth
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Google OAuth próximamente')),
                    );
                  },
                  icon: const Icon(Icons.mail_outline),
                  label: const Text('Google'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
