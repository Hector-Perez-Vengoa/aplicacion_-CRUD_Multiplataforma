import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/floating_notification.dart';
import '../../../core/widgets/premium_app_bar.dart';
import '../../../domain/models/peluquero.dart';
import '../../../domain/models/servicio.dart';
import '../application/service_provider.dart';
import '../application/hairstylist_provider.dart';
import '../application/appointment_provider.dart';

class BookAppointmentScreen extends ConsumerStatefulWidget {
  final Peluquero? initialHairstylist;
  const BookAppointmentScreen({super.key, this.initialHairstylist});

  @override
  ConsumerState<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends ConsumerState<BookAppointmentScreen> {
  Peluquero? selectedHairstylist;
  Servicio? selectedService;
  DateTime? selectedDate;
  String? selectedTime;
  late TextEditingController _notesController;

  final List<String> timeSlots = [
    '08:00', '08:30', '09:00', '09:30', '10:00', '10:30',
    '11:00', '11:30', '12:00', '14:00', '14:30', '15:00',
    '15:30', '16:00', '16:30', '17:00', '17:30', '18:00',
  ];

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    selectedHairstylist = widget.initialHairstylist;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _selectTime() async {
    await showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Selecciona una hora'),
        children: timeSlots.map((time) => SimpleDialogOption(
          onPressed: () {
            setState(() => selectedTime = time);
            Navigator.pop(context);
          },
          child: Text(time),
        )).toList(),
      ),
    );
  }

  Future<void> _submitBooking() async {
    if (selectedHairstylist == null || selectedService == null || selectedDate == null || selectedTime == null) {
      await showFloatingNotification(
        context,
        title: 'Campos requeridos',
        message: 'Por favor completa todos los campos',
        icon: Icons.info_outline,
        color: Colors.orange.shade50,
      );
      return;
    }

    final timeParts = selectedTime!.split(':');
    final hour = int.tryParse(timeParts.first) ?? 0;
    final minute = int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0;
    final fechaHoraInicio = DateTime(selectedDate!.year, selectedDate!.month, selectedDate!.day, hour, minute);

    final request = CreateAppointmentRequest(
      peluqueroId: selectedHairstylist!.id,
      servicioId: selectedService!.id,
      fechaHoraInicio: fechaHoraInicio,
      notasCliente: _notesController.text,
    );

    final navigator = Navigator.of(context, rootNavigator: true);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => const AlertDialog(
        content: Row(children: [CircularProgressIndicator(), SizedBox(width: 16), Text('Agendando cita...')]),
      ),
    );

    try {
      await ref.read(createAppointmentProvider(request).future).timeout(const Duration(seconds: 8));
      if (mounted) {
        if (navigator.canPop()) navigator.pop();
        await showFloatingNotification(
          context,
          title: 'Éxito',
          message: '¡Cita agendada exitosamente!',
          icon: Icons.check_circle_outline,
          color: Colors.green.shade50,
          duration: const Duration(seconds: 2),
        );
        if (mounted) context.go('/appointments');
      }
    } catch (e) {
      if (navigator.canPop()) navigator.pop();
      if (mounted) {
        await showFloatingNotification(
          context,
          title: 'Error',
          message: 'Error al agendar cita: $e',
          icon: Icons.error_outline,
          color: Colors.red.shade50,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(serviceProviderProvider);
    return Scaffold(
      appBar: PremiumAppBarWithIcon(icon: Icons.calendar_today, title: 'Agendar Cita'),
      body: Stack(
        children: [
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
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Theme.of(context).colorScheme.secondary.withValues(alpha: 0.85),
                          Theme.of(context).colorScheme.primary.withValues(alpha: 0.85),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      )],
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -15,
                          top: -15,
                          child: Container(width: 70, height: 70, decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.1),
                          )),
                        ),
                        Positioned(
                          left: -10,
                          bottom: -10,
                          child: Container(width: 60, height: 60, decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          )),
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.edit_calendar, size: 26, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Nueva Cita', style: TextStyle(
                                    color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 0.5,
                                  )),
                                  const SizedBox(height: 6),
                                  Text('Completa los detalles de tu cita', style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.95),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionCard(
                          icon: Icons.content_cut,
                          title: 'Servicio',
                          child: servicesAsync.when(
                            data: (services) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.6),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: DropdownButton<Servicio>(
                                isExpanded: true,
                                underline: const SizedBox(),
                                hint: const Text('Selecciona un servicio'),
                                value: selectedService,
                                items: services.map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [Expanded(child: Text(s.nombre, style: const TextStyle(fontWeight: FontWeight.w600))),
                                      Text('\$${s.precio}', style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontWeight: FontWeight.bold, fontSize: 13))],
                                  ),
                                )).toList(),
                                onChanged: (value) => setState(() {
                                  selectedService = value;
                                  selectedHairstylist = null;
                                }),
                              ),
                            ),
                            loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
                            error: (error, _) => Padding(padding: const EdgeInsets.all(16), child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _SectionCard(
                          icon: Icons.person,
                          title: 'Peluquero',
                          child: selectedService != null ? Builder(builder: (context) {
                            final hairstylistsAsync = ref.watch(hairstylistProviderProvider(selectedService!.id));
                            return hairstylistsAsync.when(
                              data: (hairstylists) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.grey.shade200),
                                ),
                                child: DropdownButton<Peluquero>(
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  hint: const Text('Selecciona un peluquero'),
                                  value: selectedHairstylist,
                                  items: hairstylists.map((h) => DropdownMenuItem(
                                    value: h,
                                    child: Row(
                                      children: [
                                        CircleAvatar(radius: 18,
                                          backgroundColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.25),
                                          child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary, size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(h.nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  )).toList(),
                                  onChanged: (value) => setState(() => selectedHairstylist = value),
                                ),
                              ),
                              loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
                              error: (error, _) => Padding(padding: const EdgeInsets.all(16), child: Text('Error: $error', style: const TextStyle(color: Colors.red))),
                            );
                          }) : Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange.shade200)),
                            child: Row(children: [Icon(Icons.info_outline, color: Colors.orange.shade700), const SizedBox(width: 12),
                              const Expanded(child: Text('Selecciona un servicio primero', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)))]),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: _SectionCard(
                              icon: Icons.calendar_today,
                              title: 'Fecha',
                              child: InkWell(onTap: () => _selectDate(context),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.grey.shade200),
                                ), child: Text(selectedDate == null ? 'Selecciona' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}', style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: selectedDate != null ? FontWeight.w700 : FontWeight.w500,
                                  color: selectedDate != null ? Theme.of(context).colorScheme.primary : Colors.grey[600],
                                )))),
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: _SectionCard(
                              icon: Icons.access_time,
                              title: 'Hora',
                              child: InkWell(onTap: _selectTime,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.grey.shade200),
                                ), child: Text(selectedTime ?? 'Selecciona', style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: selectedTime != null ? FontWeight.w700 : FontWeight.w500,
                                  color: selectedTime != null ? Theme.of(context).colorScheme.primary : Colors.grey[600],
                                )))),
                            )),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _SectionCard(
                          icon: Icons.note_alt_outlined,
                          title: 'Notas (opcional)',
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: TextField(controller: _notesController, maxLines: 3, decoration: const InputDecoration(
                              hintText: 'Comentarios o preferencias especiales',
                              filled: false,
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(14),
                            )),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _submitBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondary,
                              elevation: 4,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.check_circle_outline, color: Theme.of(context).colorScheme.onSecondary, size: 22),
                              const SizedBox(width: 10),
                              Text('CONFIRMAR CITA', style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                color: Theme.of(context).colorScheme.onSecondary,
                              )),
                            ]),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;
  const _SectionCard({required this.icon, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20), const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
