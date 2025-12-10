import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/floating_notification.dart';
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
      backgroundColor: const Color(0xFF0E0E10),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withValues(alpha: 0.95),
                Colors.black.withValues(alpha: 0.85),
              ],
            ),
            border: Border(
              bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
            ),
          ),
          child: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.edit_calendar, color: Color(0xFFD4AF37)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Editar Cita',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFF0E0E10),
        child: servicesAsync.when(
          data: (services) {
            return hairstylistsAsync.when(
              data: (hairstylists) {
                return Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Info de la cita actual
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.08),
                                  Colors.white.withValues(alpha: 0.04),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.4),
                                  blurRadius: 14,
                                  offset: const Offset(0, 8),
                                ),
                              ],
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
                                        color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                                      ),
                                      child: const Icon(
                                        Icons.info_outline,
                                        size: 20,
                                        color: Color(0xFFD4AF37),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Cita Actual',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 16,
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
                                color: const Color(0xFF1A1A1E),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
                              ),
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedServicioId,
                                dropdownColor: const Color(0xFF1A1A1E),
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xFF1A1A1E),
                                  border: InputBorder.none,
                                  prefixIcon: Icon(
                                    Icons.content_cut,
                                    color: Color(0xFFD4AF37),
                                  ),
                                  hintText: 'Selecciona un servicio',
                                  hintStyle: TextStyle(color: Colors.white60),
                                ),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                items: services.map((servicio) {
                                  return DropdownMenuItem(
                                    value: servicio.id,
                                    child: Text('${servicio.nombre} - \$${servicio.precio}', style: const TextStyle(color: Colors.white)),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedServicioId = value;
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
                                color: const Color(0xFF1A1A1E),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
                              ),
                              child: DropdownButtonFormField<String>(
                                initialValue: _selectedPeluqueroId,
                                dropdownColor: const Color(0xFF1A1A1E),
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xFF1A1A1E),
                                  border: InputBorder.none,
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Color(0xFFD4AF37),
                                  ),
                                  hintText: 'Selecciona un peluquero',
                                  hintStyle: TextStyle(color: Colors.white60),
                                ),
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                items: hairstylists.map((peluquero) {
                                  return DropdownMenuItem(
                                    value: peluquero.id,
                                    child: Text(peluquero.nombre, style: const TextStyle(color: Colors.white)),
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
                                        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
                                        borderRadius: BorderRadius.circular(14),
                                        color: const Color(0xFF1A1A1E),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.calendar_today,
                                            color: Color(0xFFD4AF37),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _formatDate(_selectedDate),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
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
                                        border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
                                        borderRadius: BorderRadius.circular(14),
                                        color: const Color(0xFF1A1A1E),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.access_time,
                                            color: Color(0xFFD4AF37),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              _formatTime(_selectedTime),
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
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
                                border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.4)),
                                color: const Color(0xFF1A1A1E),
                              ),
                              child: TextField(
                                controller: _notesController,
                                maxLines: 3,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  filled: true,
                                  fillColor: Color(0xFF1A1A1E),
                                  hintText: 'Agrega notas adicionales...',
                                  hintStyle: TextStyle(color: Colors.white60),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Botón de actualizar
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : _updateAppointment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD4AF37),
                                foregroundColor: Colors.black,
                                elevation: 8,
                                shadowColor: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                      ),
                                    )
                                  : const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline,
                                          color: Colors.black,
                                          size: 22,
                                        ),
                                        SizedBox(width: 10),
                                        Text(
                                          'ACTUALIZAR CITA',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.black,
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
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFFD4AF37),
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
                color: Colors.white,
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
              color: const Color(0xFFD4AF37),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
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
