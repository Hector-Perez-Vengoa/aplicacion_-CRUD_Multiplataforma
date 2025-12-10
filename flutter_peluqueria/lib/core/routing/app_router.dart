import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/client/presentation/client_home_screen.dart';
import '../../features/client/presentation/home_screen.dart';
import '../../features/client/presentation/book_appointment_screen.dart';
import '../../features/client/presentation/appointments_screen.dart';
import '../../features/client/presentation/services_screen.dart';
import '../../features/client/presentation/edit_appointment_screen.dart';
import '../../features/hairstylist/presentation/hairstylist_home_screen.dart';
import '../../domain/models/peluquero.dart';
import '../../domain/models/cita.dart';

/// Rutas de la aplicación
class AppRoutes {
  AppRoutes._();

  // Rutas públicas
  static const String login = '/login';
  static const String register = '/register';
  static const String oauthCallback = '/oauth-callback';

  // Rutas cliente
  static const String clientHome = '/home';
  static const String services = '/services';
  static const String appointments = '/appointments';
  static const String profile = '/profile';

  // Rutas peluquero
  static const String hairstylistHome = '/hairstylist';
  static const String agenda = '/hairstylist/agenda';

  // Rutas admin
  static const String adminHome = '/admin';
  static const String adminServices = '/admin/services';
  static const String adminHairstylists = '/admin/hairstylists';
}

/// Configuración del router de la aplicación
class AppRouter {
  AppRouter._();

  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.login,
    routes: [
      // Rutas públicas
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.oauthCallback,
        builder: (context, state) => const Placeholder(), // TODO: OAuthCallbackScreen
      ),

      // Rutas cliente con Shell (barra de navegación)
      ShellRoute(
        pageBuilder: (context, state, child) {
          return NoTransitionPage(
            child: ClientHomeScreen(child: child),
          );
        },
        routes: [
          GoRoute(
            path: AppRoutes.clientHome,
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: HomeScreen(),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.services,
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: ServicesScreen(),
              );
            },
          ),
          GoRoute(
            path: AppRoutes.appointments,
            pageBuilder: (context, state) {
              return const NoTransitionPage(
                child: AppointmentsScreen(),
              );
            },
          ),
        ],
      ),

      // Rutas de booking y edición (fuera del shell)
      GoRoute(
        path: '/appointments/new',
        builder: (context, state) {
          final hairstylist = state.extra as Peluquero?;
          return BookAppointmentScreen(initialHairstylist: hairstylist);
        },
      ),
      GoRoute(
        path: '/appointments/edit/:id',
        builder: (context, state) {
          final cita = state.extra as Cita;
          return EditAppointmentScreen(cita: cita);
        },
      ),

      // Rutas peluquero
      GoRoute(
        path: AppRoutes.hairstylistHome,
        builder: (context, state) => const HairstylistHomeScreen(),
      ),

      // Rutas admin
      GoRoute(
        path: AppRoutes.adminHome,
        builder: (context, state) => const Placeholder(), // TODO: AdminHomeScreen
      ),

      // Rutas de redirección del backend (mapeo dinámico)
      GoRoute(
        path: '/cliente/:path(.*)',
        redirect: (context, state) {
          final path = state.pathParameters['path'] ?? '';
          if (path.contains('dashboard')) return '/home';
          if (path.contains('citas')) return '/appointments';
          return '/home';
        },
      ),
      GoRoute(
        path: '/peluquero/:path(.*)',
        redirect: (context, state) {
          final path = state.pathParameters['path'] ?? '';
          if (path.contains('agenda')) return '/hairstylist/agenda';
          return '/hairstylist';
        },
      ),
      GoRoute(
        path: '/admin/:path(.*)',
        redirect: (context, state) {
          final path = state.pathParameters['path'] ?? '';
          if (path.contains('servicios')) return '/admin/services';
          if (path.contains('peluqueros')) return '/admin/hairstylists';
          return '/admin';
        },
      ),
    ],
    errorBuilder: (context, state) => const Scaffold(
      body: Center(child: Text('Página no encontrada')),
    ),
  );
}
