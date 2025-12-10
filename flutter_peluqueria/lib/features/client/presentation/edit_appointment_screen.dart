import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/floating_notification.dart';
import '../../../core/widgets/premium_app_bar.dart';
import '../../../domain/models/cita.dart';
import '../application/appointment_provider.dart';
import '../application/service_provider.dart';
import '../application/hairstylist_provider.dart';

class EditAppointmentScreen extends ConsumerStatefulWidget {
  final Cita cita;

  const EditAppointmentScreen({super.key, required this.cita});

  @override
  ConsumerState<EditAppointmentScreen> createState() => _EditAppointmentScreenState();
}

class _EditAppointmentScreenState extends ConsumerState<EditAppointmentScreen> {
  late String? _selectedPeluqueroId;
  late String? _selectedServicioId;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicializar con los valores actuales de la cita
    _selectedPeluqueroId = widget.cita.peluqueroId is Map 
        ? (widget.cita.peluqueroId as Map)['_id'] 
        : widget.cita.peluqueroId.toString();
    
    _selectedServicioId = widget.cita.servicioId is Map 
        ? (widget.cita.servicioId as Map)['_id'] 
        : widget.cita.servicioId.toString();
    
    _selectedDate = widget.cita.fechaInicio;
    _selectedTime = TimeOfDay.fromDateTime(widget.cita.fechaInicio);
    _notesController.text = widget.cita.notasCliente ?? '';
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _updateAppointment() async {
    if (_selectedPeluqueroId == null || _selectedServicioId == null) {
      await showFloatingNotification(
        context,
        title: 'Falta información',
        message: 'Por favor selecciona peluquero y servicio',
        type: NotificationType.warning,
      );
      return;
    }

    final DateTime fechaHoraInicio = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    // Verificar si hay cambios
    final originalPeluqueroId = widget.cita.peluqueroId is Map 
        ? (widget.cita.peluqueroId as Map)['_id'] 
        : widget.cita.peluqueroId.toString();
    
    final originalServicioId = widget.cita.servicioId is Map 
        ? (widget.cita.servicioId as Map)['_id'] 
        : widget.cita.servicioId.toString();

    final hasChanges = _selectedPeluqueroId != originalPeluqueroId ||
        _selectedServicioId != originalServicioId ||
        !_isSameDateTime(fechaHoraInicio, widget.cita.fechaInicio) ||
        _notesController.text != (widget.cita.notasCliente ?? '');

    if (!hasChanges) {
      await showFloatingNotification(
        context,
        title: 'Sin cambios',
        message: 'No hay cambios para guardar',
        type: NotificationType.info,
      );
      return;
    }

    final request = UpdateAppointmentRequest(
      citaId: widget.cita.id,
      peluqueroId: _selectedPeluqueroId != originalPeluqueroId ? _selectedPeluqueroId : null,
      servicioId: _selectedServicioId != originalServicioId ? _selectedServicioId : null,
      fechaHoraInicio: !_isSameDateTime(fechaHoraInicio, widget.cita.fechaInicio) ? fechaHoraInicio : null,
      notasCliente: _notesController.text != (widget.cita.notasCliente ?? '') ? _notesController.text : null,
    );

    try {
      await ref.read(updateAppointmentNotifierProvider.notifier).updateAppointment(request);
      
      if (mounted) {
        await showFloatingNotification(
          context,
          title: 'Cita actualizada',
          message: 'Cita actualizada exitosamente',
          type: NotificationType.success,
          duration: const Duration(seconds: 3),
        );
        if (!mounted) return;
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error al actualizar cita';
        if (e is DioException) {
          final data = e.response?.data;
          if (data is Map && data['error'] is Map && data['error']['message'] is String) {
            errorMessage = data['error']['message'] as String;
          } else if (e.message != null) {
            errorMessage = e.message!;
          }
        } else {
          errorMessage = e.toString();
        }

        await showFloatingNotification(
          context,
          title: 'Error',
          message: errorMessage,
          type: NotificationType.error,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  bool _isSameDateTime(DateTime dt1, DateTime dt2) {
    return dt1.year == dt2.year &&
        dt1.month == dt2.month &&
        dt1.day == dt2.day &&
        dt1.hour == dt2.hour &&
        dt1.minute == dt2.minute;
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(serviceProviderProvider);
    // Cargar peluqueros basados en el servicio seleccionado
    final hairstylistsAsync = ref.watch(hairstylistProviderProvider(_selectedServicioId));
    final isLoading = ref.watch(updateAppointmentNotifierProvider).isLoading;

    return Scaffold(
      appBar: PremiumAppBarWithIcon(
        icon: Icons.edit_calendar,
        title: 'Editar Cita',
      ),
      body: servicesAsync.when(
        data: (services) {
          return hairstylistsAsync.when(
            data: (hairstylists) {
              return Stack(
                children: [
                  // Fondo decorativo
                  Container(
                    height: 180,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
                          Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Info de la cita actual - Premium container
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.12),
                                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.12),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                    ),
                                    child: Icon(
                                      Icons.info_outline,
                                      size: 20,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Cita Actual',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _InfoRow(label: 'Estado:', value: widget.cita.estado),
                              _InfoRow(
                                label: 'Fecha/Hora:',
                                value: _formatDateTime(widget.cita.fechaInicio),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Selección de servicio
                        _SectionCardEdit(
                          icon: Icons.content_cut,
                          title: 'Servicio',
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedServicioId,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.content_cut,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                hintText: 'Selecciona un servicio',
                              ),
                              items: services.map((servicio) {
                                return DropdownMenuItem(
                                  value: servicio.id,
                                  child: Text('${servicio.nombre} - \$${servicio.precio}'),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedServicioId = value;
                                  // Resetear peluquero cuando cambia el servicio
                                  _selectedPeluqueroId = null;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Selección de peluquero
                        _SectionCardEdit(
                          icon: Icons.person,
                          title: 'Peluquero',
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: DropdownButtonFormField<String>(
                              key: ValueKey(_selectedServicioId), // Reconstruir cuando cambie el servicio
                              value: _selectedPeluqueroId,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Theme.of(context).colorScheme.secondary,
                                ),
                                hintText: 'Selecciona un peluquero',
                              ),
                              items: hairstylists.map((peluquero) {
                                return DropdownMenuItem(
                                  value: peluquero.id,
                                  child: Text(peluquero.nombre),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedPeluqueroId = value;
                                });
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Selección de fecha y hora
                        Row(
                          children: [
                            Expanded(
                              child: _SectionCardEdit(
                                icon: Icons.calendar_today,
                                title: 'Fecha',
                                child: InkWell(
                                  onTap: _selectDate,
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(14),
                                      color: Colors.white.withValues(alpha: 0.6),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          color: Theme.of(context).colorScheme.secondary,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _formatDate(_selectedDate),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _SectionCardEdit(
                                icon: Icons.access_time,
                                title: 'Hora',
                                child: InkWell(
                                  onTap: _selectTime,
                                  child: Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.shade200),
                                      borderRadius: BorderRadius.circular(14),
                                      color: Colors.white.withValues(alpha: 0.6),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.access_time,
                                          color: Theme.of(context).colorScheme.secondary,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _formatTime(_selectedTime),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
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
                        const SizedBox(height: 16),

                        // Notas
                        _SectionCardEdit(
                          icon: Icons.note_alt_outlined,
                          title: 'Notas (opcional)',
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                            child: TextField(
                              controller: _notesController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Agrega notas adicionales...',
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Botón de actualizar premium
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _updateAppointment,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isLoading
                                ? SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).colorScheme.onSecondary,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle_outline,
                                        color: Theme.of(context).colorScheme.onSecondary,
                                        size: 22,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Actualizar Cita',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.onSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(DateTime dateTime) {
    return '${_formatDate(dateTime)} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

// Widget helper para mostrar información en la vista actual
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget para secciones en la pantalla de edición
class _SectionCardEdit extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCardEdit({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
