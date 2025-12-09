import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/peluquero.dart';
import '../../../domain/models/servicio.dart';
import '../application/service_provider.dart';
import '../application/hairstylist_provider.dart';
import '../application/appointment_provider.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  final Peluquero? initialHairstylist;

  const BookAppointmentScreen({
    super.key,
    this.initialHairstylist,
  });

  @override
  ConsumerState<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  Peluquero? selectedHairstylist;
  Servicio? selectedService;
  DateTime? selectedDate;
  String? selectedTime;
  final TextEditingController _notesController = TextEditingController();

  final List<String> timeSlots = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
    '11:00', '11:30', '12:00', '14:00', '14:30', '15:00',
    '15:30', '16:00', '16:30', '17:00', '17:30', '18:00',
  ];

  @override
  void initState() {
    super.initState();
    selectedHairstylist = widget.initialHairstylist;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 30));

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _submitBooking() async {
    if (selectedHairstylist == null || selectedService == null || selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    // Combinar fecha y hora en un DateTime ISO
    final timeParts = selectedTime!.split(':');
    final hour = int.tryParse(timeParts.first) ?? 0;
    final minute = int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0;
    final fechaHoraInicio = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      hour,
      minute,
    );

    final request = CreateAppointmentRequest(
      peluqueroId: selectedHairstylist!.id,
      servicioId: selectedService!.id,
      fechaHoraInicio: fechaHoraInicio,
      notasCliente: _notesController.text,
    );

    final navigator = Navigator.of(context, rootNavigator: true);

    // Mostrar loading (rootNavigator para que no quede sobre la navegación)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 16),
            Text('Agendando cita...'),
          ],
        ),
      ),
    );

    try {
      await ref.read(createAppointmentProvider(request).future)
          .timeout(const Duration(seconds: 8));

      if (mounted) {
        if (navigator.canPop()) navigator.pop(); // Cerrar loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Cita agendada exitosamente!')),
        );
        context.go('/appointments');
      }
    } catch (e) {
      if (navigator.canPop()) navigator.pop(); // Cerrar loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(serviceProviderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agendar cita'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seleccionar servicio PRIMERO
            Text('Servicio', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            servicesAsync.when(
              data: (services) {
                return DropdownButton<Servicio>(
                  isExpanded: true,
                  hint: const Text('Selecciona un servicio'),
                  value: selectedService,
                  items: services
                      .map((s) => DropdownMenuItem(
                            value: s,
                            child: Text('${s.nombre} - \$${s.precio}'),
                          ))
                      .toList(),
                  onChanged: (value) => setState(() {
                    selectedService = value;
                    selectedHairstylist = null; // Limpiar peluquero cuando cambia servicio
                  }),
                );
              },
              loading: () => const CircularProgressIndicator(),
              error: (error, _) => Text('Error: $error'),
            ),
            const SizedBox(height: 24),

            // Seleccionar peluquero (después de seleccionar servicio)
            Text('Peluquero', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (selectedService != null)
              Builder(builder: (context) {
                final hairstylistsAsync = ref.watch(hairstylistProviderProvider(selectedService!.id));
                return hairstylistsAsync.when(
                  data: (hairstylists) {
                    return DropdownButton<Peluquero>(
                      isExpanded: true,
                      hint: const Text('Selecciona un peluquero'),
                      value: selectedHairstylist,
                      items: hairstylists
                          .map((h) => DropdownMenuItem(
                                value: h,
                                 child: Text(h.nombre),
                              ))
                          .toList(),
                      onChanged: (value) => setState(() => selectedHairstylist = value),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (error, _) => Text('Error: $error'),
                );
              })
            else
              const Text('Selecciona un servicio primero'),
            const SizedBox(height: 24),

            // Notas opcionales
            Text('Notas (opcional)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Comentarios para el peluquero',
              ),
            ),
            const SizedBox(height: 24),

            // Seleccionar fecha
            Text('Fecha', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () => _selectDate(context),
              icon: const Icon(Icons.calendar_today),
              label: Text(
                selectedDate == null
                    ? 'Selecciona una fecha'
                    : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
              ),
            ),
            const SizedBox(height: 24),

            // Seleccionar hora
            Text('Hora', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: timeSlots
                  .map((time) => ChoiceChip(
                        label: Text(time),
                        selected: selectedTime == time,
                        onSelected: (selected) {
                          setState(() => selectedTime = selected ? time : null);
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 32),

            // Botón confirmar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitBooking,
                child: const Text('Confirmar cita'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
