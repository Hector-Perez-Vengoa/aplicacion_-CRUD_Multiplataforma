import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/floating_notification.dart';
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
  TimeOfDay? selectedTime;
  late TextEditingController _notesController;

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
    final TimeOfDay initial = selectedTime ?? TimeOfDay.fromDateTime(DateTime.now().add(const Duration(minutes: 30)));
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initial,
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

    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Future<void> _submitBooking() async {
    if (selectedHairstylist == null || selectedService == null || selectedDate == null || selectedTime == null) {
      await showFloatingNotification(
        context,
        title: 'Campos requeridos',
        message: 'Por favor completa todos los campos',
        type: NotificationType.warning,
      );
      return;
    }

    final fechaHoraInicio = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

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
          type: NotificationType.success,
          duration: const Duration(seconds: 3),
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
          type: NotificationType.error,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final servicesAsync = ref.watch(serviceProviderProvider);
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.calendar_today, color: Color(0xFFD4AF37)),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Agendar Cita',
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.08),
                          Colors.white.withValues(alpha: 0.04),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD4AF37),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.edit_calendar, size: 26, color: Colors.black),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Nueva Cita',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Completa los detalles de tu cita',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.7),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
                          _SectionCard(
                          icon: Icons.content_cut,
                          title: 'Servicio',
                          child: servicesAsync.when(
                            data: (services) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                              ),
                              child: DropdownButton<Servicio>(
                                isExpanded: true,
                                underline: const SizedBox(),
                                dropdownColor: const Color(0xFF1A1A1E),
                                hint: const Text('Selecciona un servicio', style: TextStyle(color: Colors.white70)),
                                value: selectedService,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                items: services.map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(child: Text(s.nombre, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white))),
                                      Text('\$${s.precio}', style: const TextStyle(color: Color(0xFFD4AF37), fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
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
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                                ),
                                child: DropdownButton<Peluquero>(
                                  isExpanded: true,
                                  underline: const SizedBox(),
                                  dropdownColor: const Color(0xFF1A1A1E),
                                  hint: const Text('Selecciona un peluquero', style: TextStyle(color: Colors.white70)),
                                  value: selectedHairstylist,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  items: hairstylists.map((h) => DropdownMenuItem(
                                    value: h,
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 18,
                                          backgroundColor: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                                          child: const Icon(Icons.person, color: Color(0xFFD4AF37), size: 20),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(h.nombre, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
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
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.2)),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, color: const Color(0xFFD4AF37).withValues(alpha: 0.7)),
                                const SizedBox(width: 12),
                                const Expanded(child: Text('Selecciona un servicio primero', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white70))),
                              ],
                            ),
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
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                                ), child: Text(selectedDate == null ? 'Selecciona' : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}', style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: selectedDate != null ? FontWeight.w700 : FontWeight.w500,
                                  color: selectedDate != null ? const Color(0xFFD4AF37) : Colors.white60,
                                )))),
                            )),
                            const SizedBox(width: 12),
                            Expanded(child: _SectionCard(
                              icon: Icons.access_time,
                              title: 'Hora',
                              child: InkWell(onTap: _selectTime,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                                ), child: Text(selectedTime != null ? _formatTime(selectedTime!) : 'Selecciona', style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: selectedTime != null ? FontWeight.w700 : FontWeight.w500,
                                  color: selectedTime != null ? const Color(0xFFD4AF37) : Colors.white60,
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
                              color: Colors.white.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFD4AF37).withValues(alpha: 0.3)),
                            ),
                            child: TextField(
                              controller: _notesController,
                              maxLines: 3,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Comentarios o preferencias especiales',
                                hintStyle: TextStyle(color: Colors.white60),
                                filled: false,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.all(14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _submitBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD4AF37),
                              foregroundColor: Colors.black,
                              elevation: 8,
                              shadowColor: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Icon(Icons.check_circle_outline, color: Colors.black, size: 22),
                              SizedBox(width: 10),
                              Text('CONFIRMAR CITA', style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: Colors.black,
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

    String _formatTime(TimeOfDay time) {
      final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
      final minute = time.minute.toString().padLeft(2, '0');
      final period = time.period == DayPeriod.am ? 'AM' : 'PM';
      return '$hour:$minute $period';
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
          children: [
            Icon(icon, color: const Color(0xFFD4AF37), size: 20),
            const SizedBox(width: 8),
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}
