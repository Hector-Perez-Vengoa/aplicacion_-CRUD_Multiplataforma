import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../features/auth/application/auth_provider.dart';
import '../application/hairstylist_appointments_provider.dart';

class HairstylistHomeScreen extends ConsumerWidget {
  const HairstylistHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final appointmentsAsync = ref.watch(hairstylistAppointmentsProviderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Peluquería - Peluquero'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
              context.go('/login');
            },
          )
        ],
      ),
      body: authState.isAuthenticated
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido ${authState.usuario?.nombre ?? 'Peluquero'}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Gestiona tus citas y horarios',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                  const SizedBox(height: 24),

                  // Estadísticas rápidas
                  _QuickStatsSection(appointmentsAsync: appointmentsAsync),
                  
                  const SizedBox(height: 24),

                  // Citas del día
                  Text(
                    'Citas de hoy',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  
                  appointmentsAsync.when(
                    data: (appointments) {
                      final today = DateTime.now();
                      final todayAppointments = appointments.where((apt) {
                        return apt.fechaInicio.year == today.year &&
                            apt.fechaInicio.month == today.month &&
                            apt.fechaInicio.day == today.day;
                      }).toList();

                      if (todayAppointments.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 48,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No hay citas para hoy',
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: todayAppointments.length,
                        itemBuilder: (context, index) {
                          final appointment = todayAppointments[index];
                          return _AppointmentCard(appointment: appointment);
                        },
                      );
                    },
                    loading: () => const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                    error: (error, _) => Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'Error al cargar citas: $error',
                          style: TextStyle(color: Colors.red[700]),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.go('/hairstylist/agenda'),
                          icon: const Icon(Icons.calendar_month),
                          label: const Text('Ver agenda completa'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const Center(child: Text('No autorizado')),
    );
  }
}

class _QuickStatsSection extends StatelessWidget {
  final AsyncValue appointmentsAsync;

  const _QuickStatsSection({required this.appointmentsAsync});

  @override
  Widget build(BuildContext context) {
    return appointmentsAsync.when(
      data: (appointments) {
        final today = DateTime.now();
        final todayAppointments = appointments.where((apt) {
          return apt.fechaInicio.year == today.year &&
              apt.fechaInicio.month == today.month &&
              apt.fechaInicio.day == today.day;
        }).toList();

        final confirmedToday = todayAppointments
            .where((apt) => apt.estado == 'confirmada')
            .length;

        final totalThisWeek = appointments.where((apt) {
          final diff = apt.fechaInicio.difference(today).inDays;
          return diff >= 0 && diff < 7;
        }).length;

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'Hoy',
                value: todayAppointments.length.toString(),
                icon: Icons.today,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Confirmadas',
                value: confirmedToday.toString(),
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'Esta semana',
                value: totalThisWeek.toString(),
                icon: Icons.calendar_view_week,
                color: Colors.orange,
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox(),
      error: (error, stackTrace) => const SizedBox(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final dynamic appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(appointment.estado),
          child: Icon(
            _getStatusIcon(appointment.estado),
            color: Colors.white,
          ),
        ),
        title: Text(
          'Cita #${appointment.id.substring(0, 8)}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Hora: ${appointment.fechaInicio.hour}:${appointment.fechaInicio.minute.toString().padLeft(2, '0')}',
            ),
            Text('Estado: ${_getStatusLabel(appointment.estado)}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, size: 16),
          onPressed: () {
            // TODO: Navegar a detalles de la cita
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmada':
        return Colors.green;
      case 'cancelada':
        return Colors.red;
      case 'completada':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'confirmada':
        return Icons.check;
      case 'cancelada':
        return Icons.close;
      case 'completada':
        return Icons.done_all;
      default:
        return Icons.help;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'confirmada':
        return 'Confirmada';
      case 'cancelada':
        return 'Cancelada';
      case 'completada':
        return 'Completada';
      default:
        return status;
    }
  }
}
