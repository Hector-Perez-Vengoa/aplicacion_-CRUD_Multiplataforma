import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona peluquero y servicio')),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay cambios para guardar')),
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cita actualizada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar cita: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Cita'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (GoRouter.of(context).canPop()) {
              context.pop();
            } else {
              context.go('/home');
            }
          },
        ),
      ),
      body: servicesAsync.when(
        data: (services) {
          return hairstylistsAsync.when(
            data: (hairstylists) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info de la cita actual
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Cita Actual',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text('Estado: ${widget.cita.estado}'),
                          Text('Fecha original: ${_formatDateTime(widget.cita.fechaInicio)}'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Selección de servicio
                    const Text(
                      'Servicio',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedServicioId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
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
                    const SizedBox(height: 16),

                    // Selección de peluquero
                    const Text(
                      'Peluquero',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      key: ValueKey(_selectedServicioId), // Reconstruir cuando cambie el servicio
                      initialValue: _selectedPeluqueroId,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
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
                    const SizedBox(height: 16),

                    // Selección de fecha
                    const Text(
                      'Fecha',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 12),
                            Text(_formatDate(_selectedDate)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Selección de hora
                    const Text(
                      'Hora',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _selectTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey[100],
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time),
                            const SizedBox(width: 12),
                            Text(_formatTime(_selectedTime)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Notas
                    const Text(
                      'Notas (opcional)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Agrega notas adicionales...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Botón de actualizar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateAppointment,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Actualizar Cita',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
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
