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
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('https://images.unsplash.com/photo-1524504388940-b1c1722653e1?auto=format&fit=crop&w=1200&q=80'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.85),
                Colors.black.withValues(alpha: 0.95),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 520),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white.withValues(alpha: 0.12),
                            ),
                            icon: const Icon(Icons.arrow_back, color: Colors.white),
                            onPressed: () => context.go('/login'),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Crear cuenta',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.45),
                              blurRadius: 20,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.vpn_key, color: Color(0xFFD4AF37)),
                                  SizedBox(width: 8),
                                  Text(
                                    'Información de acceso',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 19,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),

                              if (_errorMessage != null)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.red.withValues(alpha: 0.35)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Icon(Icons.error_outline, color: Colors.redAccent),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: const TextStyle(color: Colors.white, fontSize: 13),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              Text(
                                'Tipo de cuenta',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.85),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SegmentedButton<String>(
                                style: SegmentedButton.styleFrom(
                                  backgroundColor: Colors.white.withValues(alpha: 0.06),
                                  foregroundColor: Colors.white,
                                  selectedBackgroundColor: const Color(0xFFD4AF37),
                                  selectedForegroundColor: Colors.black,
                                  side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
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
                              const SizedBox(height: 16),

                              if (_selectedRole == 'peluquero')
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Servicios especializados',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.8),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Consumer(
                                        builder: (context, ref, child) {
                                          final servicesAsync = ref.watch(publicServiceProviderProvider);
                                          return servicesAsync.when(
                                            data: (services) {
                                              if (services.isEmpty) {
                                                return const Text('No hay servicios disponibles', style: TextStyle(color: Colors.white70));
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
                                                          labelStyle: const TextStyle(color: Colors.white),
                                                          backgroundColor: Colors.white.withValues(alpha: 0.1),
                                                          selectedColor: const Color(0xFFD4AF37),
                                                          checkmarkColor: Colors.black,
                                                        ))
                                                    .toList(),
                                              );
                                            },
                                            loading: () => const CircularProgressIndicator(color: Color(0xFFD4AF37)),
                                            error: (error, _) => Text('Error: $error', style: const TextStyle(color: Colors.redAccent)),
                                          );
                                        },
                                      ),
                                      if (_selectedServices.isEmpty && _selectedRole == 'peluquero')
                                        Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            'Debes seleccionar al menos un servicio',
                                            style: TextStyle(
                                              color: Colors.redAccent.withValues(alpha: 0.8),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),

                              _DarkInput(
                                controller: _nombreController,
                                label: 'Nombre completo',
                                icon: Icons.person_outline,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Por favor ingresa tu nombre';
                                  }
                                  return null;
                                },
                                enabled: !authState.isLoading,
                              ),
                              const SizedBox(height: 14),
                              _DarkInput(
                                controller: _emailController,
                                label: 'Correo electrónico',
                                hint: 'usuario@example.com',
                                icon: Icons.email_outlined,
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
                              const SizedBox(height: 14),
                              _DarkInput(
                                controller: _telefonoController,
                                label: 'Teléfono',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value?.isEmpty ?? true) {
                                    return 'Por favor ingresa tu teléfono';
                                  }
                                  return null;
                                },
                                enabled: !authState.isLoading,
                              ),
                              const SizedBox(height: 14),
                              _DarkInput(
                                controller: _passwordController,
                                label: 'Contraseña',
                                icon: Icons.lock_outline,
                                obscure: true,
                                toggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                                obscured: _obscurePassword,
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
                              const SizedBox(height: 14),
                              _DarkInput(
                                controller: _confirmPasswordController,
                                label: 'Confirmar contraseña',
                                icon: Icons.lock_reset_outlined,
                                obscure: true,
                                toggleObscure: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                                obscured: _obscureConfirmPassword,
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
                              const SizedBox(height: 22),

                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: ElevatedButton(
                                  onPressed: authState.isLoading ? null : _handleRegister,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFD4AF37),
                                    foregroundColor: Colors.black,
                                    elevation: 6,
                                    shadowColor: const Color(0xFFD4AF37).withValues(alpha: 0.45),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: authState.isLoading
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.black),
                                        )
                                      : const Text(
                                          'Crear cuenta',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '¿Ya tienes cuenta?',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                                  ),
                                  TextButton(
                                    onPressed: () => context.go('/login'),
                                    child: const Text(
                                      'Inicia sesión',
                                      style: TextStyle(
                                        color: Colors.white,
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
        ),
      ),
    );
  }
}

class _DarkInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscure;
  final bool obscured;
  final VoidCallback? toggleObscure;
  final String? Function(String?)? validator;
  final bool enabled;

  const _DarkInput({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.obscure = false,
    this.obscured = false,
    this.toggleObscure,
    this.validator,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      obscureText: obscure ? obscured : false,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.75)),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.45)),
        prefixIcon: Icon(icon, color: Colors.white70),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(
                  obscured ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white70,
                ),
                onPressed: toggleObscure,
              )
            : null,
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFD4AF37), width: 1.5),
        ),
      ),
      validator: validator,
      enabled: enabled,
    );
  }
}

