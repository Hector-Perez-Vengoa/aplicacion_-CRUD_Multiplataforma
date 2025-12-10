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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
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
        title: Row(
          children: [
            Icon(
              Icons.calendar_month,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            const Text('AGENDAR CITA'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/home'),
          ),
        ],
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header decorativo
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.tertiary,
                  ],
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.event_available,
                    size: 50,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Agenda tu Transformación',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Selecciona el servicio y hora que prefieras',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Seleccionar servicio
                  _SectionCard(
                    icon: Icons.content_cut,
                    title: 'Servicio',
                    child: servicesAsync.when(
                      data: (services) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: DropdownButton<Servicio>(
                            isExpanded: true,
                            underline: const SizedBox(),
                            hint: const Text('Selecciona un servicio'),
                            value: selectedService,
                            items: services
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              s.nombre,
                                              style: const TextStyle(fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                          Text(
                                            '\$${s.precio}',
                                            style: TextStyle(
                                              color: Theme.of(context).colorScheme.secondary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))
                                .toList(),
                            onChanged: (value) => setState(() {
                              selectedService = value;
                              selectedHairstylist = null;
                            }),
                          ),
                        );
                      },
                      loading: () => const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      error: (error, _) => Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text('Error: $error', style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Seleccionar peluquero
                  _SectionCard(
                    icon: Icons.person,
                    title: 'Peluquero',
                    child: selectedService != null
                        ? Builder(builder: (context) {
                            final hairstylistsAsync = ref.watch(hairstylistProviderProvider(selectedService!.id));
                            return hairstylistsAsync.when(
                              data: (hairstylists) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey.shade300),
                                  ),
                                  child: DropdownButton<Peluquero>(
                                    isExpanded: true,
                                    underline: const SizedBox(),
                                    hint: const Text('Selecciona un peluquero'),
                                    value: selectedHairstylist,
                                    items: hairstylists
                                        .map((h) => DropdownMenuItem(
                                              value: h,
                                              child: Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2),
                                                    child: Icon(
                                                      Icons.person,
                                                      color: Theme.of(context).colorScheme.primary,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  Text(
                                                    h.nombre,
                                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                                  ),
                                                ],
                                              ),
                                            ))
                                        .toList(),
                                    onChanged: (value) => setState(() => selectedHairstylist = value),
                                  ),
                                );
                              },
                              loading: () => const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: CircularProgressIndicator(),
                                ),
                              ),
                              error: (error, _) => Padding(
                                padding: const EdgeInsets.all(16),
                                child: Text('Error: $error', style: TextStyle(color: Colors.red)),
                              ),
                            );
                          })
                        : Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: Colors.grey[600]),
                                const SizedBox(width: 12),
                                const Text('Selecciona un servicio primero'),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 20),

                  // Seleccionar fecha
                  _SectionCard(
                    icon: Icons.calendar_today,
                    title: 'Fecha',
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedDate == null
                                  ? 'Selecciona una fecha'
                                  : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: selectedDate != null ? FontWeight.w600 : FontWeight.normal,
                                color: selectedDate != null ? Theme.of(context).colorScheme.primary : Colors.grey[600],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey[400],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Seleccionar hora
                  _SectionCard(
                    icon: Icons.access_time,
                    title: 'Hora',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: timeSlots
                          .map((time) => ChoiceChip(
                                label: Text(
                                  time,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: selectedTime == time 
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.grey[700],
                                  ),
                                ),
                                selected: selectedTime == time,
                                selectedColor: Theme.of(context).colorScheme.secondary,
                                backgroundColor: Colors.white,
                                side: BorderSide(
                                  color: selectedTime == time 
                                      ? Theme.of(context).colorScheme.secondary
                                      : Colors.grey.shade300,
                                ),
                                onSelected: (selected) {
                                  setState(() => selectedTime = selected ? time : null);
                                },
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Notas opcionales
                  _SectionCard(
                    icon: Icons.note_alt_outlined,
                    title: 'Notas (opcional)',
                    child: TextField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'Comentarios o preferencias especiales',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botón confirmar
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _submitBooking,
                      child: const Text(
                        'CONFIRMAR CITA',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
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
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
