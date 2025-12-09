import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/appointment_provider.dart';

class AppointmentsScreen extends ConsumerWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointmentsAsync = ref.watch(appointmentProviderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis citas'),
      ),
      body: appointmentsAsync.when(
        data: (appointments) {
          if (appointments.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.calendar_today, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No tienes citas agendadas'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Agendar cita'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Cita #${appointment.id.substring(0, 8)}',
                            style: Theme.of(context).textTheme.titleSmall,
                          ),
                          _StatusBadge(status: appointment.estado),
                        ],
                      ),
                      const SizedBox(height: 8),
                          Text(
                            'Fecha: ${appointment.fechaInicio.day}/${appointment.fechaInicio.month}/${appointment.fechaInicio.year}',
                          ),
                          Text('Servicio: ${appointment.servicio}'),
                          Text('Peluquero: ${appointment.peluquero}'),
                      const SizedBox(height: 4),
                      Text('Hora: ${appointment.fechaInicio.hour}:${appointment.fechaInicio.minute.toString().padLeft(2, '0')}'),
                      const SizedBox(height: 12),
                      if (appointment.estado == 'confirmada')
                        ElevatedButton.icon(
                          onPressed: () {
                            _showCancelDialog(context, ref, appointment.id);
                          },
                          icon: const Icon(Icons.close),
                          label: const Text('Cancelar cita'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/home'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva cita'),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color color;
    final String label;

    switch (status) {
      case 'confirmada':
        color = Colors.green;
        label = 'Confirmada';
        break;
      case 'cancelada':
        color = Colors.red;
        label = 'Cancelada';
        break;
      case 'completada':
        color = Colors.blue;
        label = 'Completada';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

void _showCancelDialog(BuildContext context, WidgetRef ref, String citaId) {
  final motivoController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Cancelar cita'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('¿Estás seguro de que deseas cancelar esta cita?'),
          const SizedBox(height: 16),
          TextField(
            controller: motivoController,
            decoration: const InputDecoration(
              labelText: 'Motivo de cancelación',
              hintText: 'Opcional',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('No'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            
            try {
              final motivo = motivoController.text.trim().isEmpty
                  ? 'Sin motivo especificado'
                  : motivoController.text.trim();
              
              await ref
                  .read(cancelAppointmentNotifierProvider.notifier)
                  .cancelAppointment(citaId, motivo);
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cita cancelada exitosamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al cancelar la cita: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
          child: const Text('Sí, cancelar'),
        ),
      ],
    ),
  );
}
