import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/auth/application/auth_provider.dart';
import '../../../core/widgets/floating_notification.dart';

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
  double _dragStartX = 0;

  void _handleHorizontalDrag(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
  }

  void _handleHorizontalDragEnd(DragEndDetails details) {
    const int swipeThreshold = 50;
    double dragDistance = details.globalPosition.dx - _dragStartX;

    if (dragDistance.abs() > swipeThreshold) {
      if (dragDistance > 0) {
        // Deslizar hacia la derecha - ir a la pantalla anterior
        if (_selectedIndex > 0) {
          _navigateToTab(context, _selectedIndex - 1);
        }
      } else {
        // Deslizar hacia la izquierda - ir a la pantalla siguiente
        if (_selectedIndex < 2) {
          _navigateToTab(context, _selectedIndex + 1);
        }
      }
    }
  }

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
            backgroundColor: const Color(0xFF0E0E10),
            appBar: PreferredSize(
              preferredSize: const Size.fromHeight(78),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.95),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
                          ),
                          child: const Icon(Icons.content_cut, color: Color(0xFFD4AF37)),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'Barbería Noir',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                letterSpacing: 0.4,
                              ),
                            ),
                            Text(
                              'Cortes de autor • Agenda precisa',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: () {
                            ref.read(authNotifierProvider.notifier).logout();
                            context.go('/login');
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            body: GestureDetector(
              onHorizontalDragStart: _handleHorizontalDrag,
              onHorizontalDragEnd: _handleHorizontalDragEnd,
              child: ColoredBox(
                color: const Color(0xFF0E0E10),
                child: authState.isAuthenticated
                    ? widget.child
                    : const Center(child: Text('No autorizado')),
              ),
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withValues(alpha: 0.9),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.45),
                    blurRadius: 14,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(
                        icon: Icons.home_outlined,
                        activeIcon: Icons.home_rounded,
                        label: 'Inicio',
                        index: 0,
                      ),
                      _buildNavItem(
                        icon: Icons.cut_outlined,
                        activeIcon: Icons.cut,
                        label: 'Servicios',
                        index: 1,
                      ),
                      _buildNavItem(
                        icon: Icons.calendar_today_outlined,
                        activeIcon: Icons.event_available,
                        label: 'Citas',
                        index: 2,
                      ),
                    ],
                  ),
                ),
              ),
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

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _navigateToTab(context, index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive
                ? const Color(0xFFD4AF37)
                : Colors.white.withValues(alpha: 0.6),
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive
                  ? const Color(0xFFD4AF37)
                  : Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
