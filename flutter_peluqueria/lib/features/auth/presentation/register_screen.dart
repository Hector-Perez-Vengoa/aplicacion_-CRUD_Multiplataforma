import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/loading_widget.dart';
import '../application/auth_provider.dart';
import '../data/dtos/register_request.dart';
import '../../client/application/service_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nombreController = TextEditingController();
  final _emailController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String _selectedRole = 'cliente'; // 'cliente' o 'peluquero'
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  List<String> _selectedServices = []; // Servicios seleccionados para peluquero

  @override
  void dispose() {
    _nombreController.dispose();
    _emailController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    // Validar que si es peluquero, tenga servicios seleccionados
    if (_selectedRole == 'peluquero' && _selectedServices.isEmpty) {
      setState(() => _errorMessage = 'Debes seleccionar al menos un servicio especializado');
      return;
    }

    try {
      setState(() => _errorMessage = null);

      final request = RegisterRequest(
        nombre: _nombreController.text.trim(),
        email: _emailController.text.trim(),
        telefono: _telefonoController.text.trim(),
        password: _passwordController.text,
        rol: _selectedRole,
        serviciosEspecializados: _selectedRole == 'peluquero' ? _selectedServices : null,
      );

      final authResponse =
          await ref.read(authNotifierProvider.notifier).register(request);

      // Navegar según el resultado del registro
      if (mounted) {
        // Si requiere aprobación, mostrar pantalla de pendiente
        if (authResponse.requiresApproval) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tu solicitud fue enviada. Un administrador revisará tu perfil.'),
              duration: Duration(seconds: 3),
            ),
          );
          context.go('/login');
          return;
        }

        final redirect = authResponse.redirectUrl;
        String finalRoute = '/home'; // Ruta por defecto

        if (redirect != null && redirect.isNotEmpty) {
          // Mapear rutas del backend a rutas de Flutter
          finalRoute = _mapBackendRouteToFlutter(redirect);
        } else {
          // Usar el rol seleccionado
          if (_selectedRole == 'cliente') {
            finalRoute = '/home';
          } else if (_selectedRole == 'peluquero') {
            finalRoute = '/hairstylist';
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
        body: LoadingWidget(message: 'Registrando cuenta...'),
      );
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -60,
              left: -30,
              child: _AccentCircle(color: Colors.white.withValues(alpha: 0.08), size: 190),
            ),
            Positioned(
              bottom: -70,
              right: -10,
              child: _AccentCircle(color: Colors.black.withValues(alpha: 0.08), size: 230),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white.withValues(alpha: 0.15),
                              ),
                              icon: const Icon(Icons.arrow_back, color: Colors.white),
                              onPressed: () => context.go('/login'),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Registro premium',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.15),
                                      blurRadius: 16,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.content_cut,
                                  size: 32,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Crea tu cuenta',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Reservas fáciles, agenda visible y perfil de estilista elegante.',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.white.withValues(alpha: 0.8),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 24,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Datos de acceso',
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Elige tu rol y completa la información para empezar a reservar o atender clientes.',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                                ),
                                const SizedBox(height: 20),

                                if (_errorMessage != null)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Container(
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                                        border: Border.all(
                                          color: Theme.of(context).colorScheme.error.withValues(alpha: 0.6),
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Theme.of(context).colorScheme.error,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              _errorMessage!,
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.error,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tipo de cuenta',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 12),
                                      SegmentedButton<String>(
                                        style: SegmentedButton.styleFrom(
                                          selectedBackgroundColor: Theme.of(context).colorScheme.secondary,
                                          selectedForegroundColor: Theme.of(context).colorScheme.primary,
                                        ),
                                        segments: const [
                                          ButtonSegment(
                                            value: 'cliente',
                                            label: Text('Cliente'),
                                            icon: Icon(Icons.person),
                                          ),
                                          ButtonSegment(
                                            value: 'peluquero',
                                            label: Text('Peluquero'),
                                            icon: Icon(Icons.content_cut),
                                          ),
                                        ],
                                        selected: {_selectedRole},
                                        onSelectionChanged: (Set<String> newSelection) {
                                          setState(() {
                                            _selectedRole = newSelection.first;
                                            _selectedServices = [];
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),

                                if (_selectedRole == 'peluquero')
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Servicios especializados',
                                          style: Theme.of(context).textTheme.labelLarge,
                                        ),
                                        const SizedBox(height: 8),
                                        Consumer(
                                          builder: (context, ref, child) {
                                            final servicesAsync = ref.watch(publicServiceProviderProvider);
                                            return servicesAsync.when(
                                              data: (services) {
                                                if (services.isEmpty) {
                                                  return const Text('No hay servicios disponibles');
                                                }
                                                return Wrap(
                                                  spacing: 8,
                                                  runSpacing: 8,
                                                  children: services
                                                      .map((service) => FilterChip(
                                                            label: Text(service.nombre),
                                                            selected: _selectedServices.contains(service.id),
                                                            onSelected: (selected) {
                                                              setState(() {
                                                                if (selected) {
                                                                  _selectedServices.add(service.id);
                                                                } else {
                                                                  _selectedServices.remove(service.id);
                                                                }
                                                              });
                                                            },
                                                          ))
                                                      .toList(),
                                                );
                                              },
                                              loading: () => const CircularProgressIndicator(),
                                              error: (error, _) => Text('Error: $error'),
                                            );
                                          },
                                        ),
                                        if (_selectedServices.isEmpty && _selectedRole == 'peluquero')
                                          Padding(
                                            padding: const EdgeInsets.only(top: 8),
                                            child: Text(
                                              'Debes seleccionar al menos un servicio',
                                              style: TextStyle(
                                                color: Theme.of(context).colorScheme.error,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),

                                TextFormField(
                                  controller: _nombreController,
                                  decoration: const InputDecoration(
                                    labelText: 'Nombre completo',
                                    prefixIcon: Icon(Icons.person_outline),
                                  ),
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Por favor ingresa tu nombre';
                                    }
                                    return null;
                                  },
                                  enabled: !authState.isLoading,
                                ),
                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _emailController,
                                  decoration: const InputDecoration(
                                    labelText: 'Correo electrónico',
                                    hintText: 'usuario@example.com',
                                    prefixIcon: Icon(Icons.email_outlined),
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

                                TextFormField(
                                  controller: _telefonoController,
                                  decoration: const InputDecoration(
                                    labelText: 'Teléfono',
                                    prefixIcon: Icon(Icons.phone_outlined),
                                  ),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Por favor ingresa tu teléfono';
                                    }
                                    return null;
                                  },
                                  enabled: !authState.isLoading,
                                ),
                                const SizedBox(height: 16),

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
                                      return 'Por favor ingresa una contraseña';
                                    }
                                    if (value!.length < 8) {
                                      return 'La contraseña debe tener al menos 8 caracteres';
                                    }
                                    if (!value.contains(RegExp(r'[A-Z]'))) {
                                      return 'Debe contener al menos una mayúscula';
                                    }
                                    if (!value.contains(RegExp(r'[a-z]'))) {
                                      return 'Debe contener al menos una minúscula';
                                    }
                                    if (!value.contains(RegExp(r'[0-9]'))) {
                                      return 'Debe contener al menos un número';
                                    }
                                    return null;
                                  },
                                  enabled: !authState.isLoading,
                                ),
                                const SizedBox(height: 16),

                                TextFormField(
                                  controller: _confirmPasswordController,
                                  decoration: InputDecoration(
                                    labelText: 'Confirmar contraseña',
                                    hintText: '••••••••',
                                    prefixIcon: const Icon(Icons.lock_outlined),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                                      },
                                    ),
                                  ),
                                  obscureText: _obscureConfirmPassword,
                                  validator: (value) {
                                    if (value?.isEmpty ?? true) {
                                      return 'Por favor confirma tu contraseña';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Las contraseñas no coinciden';
                                    }
                                    return null;
                                  },
                                  enabled: !authState.isLoading,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.verified_user_outlined, size: 18, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Protegemos tus datos y validamos perfiles de peluquero.',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: authState.isLoading ? null : _handleRegister,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).colorScheme.secondary,
                                      foregroundColor: Theme.of(context).colorScheme.primary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    child: authState.isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : const Text(
                                            'Crear cuenta',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 16),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '¿Ya tienes cuenta?',
                                      style: TextStyle(color: Colors.grey[700]),
                                    ),
                                    TextButton(
                                      onPressed: () => context.go('/login'),
                                      child: Text(
                                        'Inicia sesión',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccentCircle extends StatelessWidget {
  final Color color;
  final double size;

  const _AccentCircle({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
