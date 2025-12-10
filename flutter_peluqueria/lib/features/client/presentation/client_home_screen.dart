import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/auth/application/auth_provider.dart';
import '../../../core/widgets/floating_notification.dart';
import '../../../core/widgets/premium_app_bar.dart';

class ClientHomeScreen extends StatefulWidget {
  final Widget child;

  const ClientHomeScreen({
    super.key,
    required this.child,
  });

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final authState = ref.watch(authNotifierProvider);

        // Determinar el índice según la ruta actual
        _updateSelectedIndex(context);

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            showFloatingNotification(
              context,
              message: 'Usa el botón de logout para salir',
              icon: Icons.logout,
              duration: const Duration(seconds: 2),
            );
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: PremiumAppBarWithIcon(
              title: 'Barbería Premium',
              icon: Icons.content_cut,
              showBack: GoRouter.of(context).canPop(),
              onBackPressed: () => GoRouter.of(context).pop(),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  onPressed: () {
                    ref.read(authNotifierProvider.notifier).logout();
                    context.go('/login');
                  },
                )
              ],
            ),
            body: authState.isAuthenticated
                ? widget.child
                : const Center(child: Text('No autorizado')),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                _navigateToTab(context, index);
              },
              selectedItemColor: Theme.of(context).colorScheme.secondary,
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Inicio',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.cut),
                  label: 'Servicios',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'Citas',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _updateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.contains('/home')) {
      _selectedIndex = 0;
    } else if (location.contains('/services')) {
      _selectedIndex = 1;
    } else if (location.contains('/appointments')) {
      _selectedIndex = 2;
    }
  }

  void _navigateToTab(BuildContext context, int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/services');
        break;
      case 2:
        context.go('/appointments');
        break;
    }
  }
}
