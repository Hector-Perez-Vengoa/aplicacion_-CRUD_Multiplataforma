import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../domain/models/servicio.dart';
import '../../../features/auth/application/auth_provider.dart';
import '../application/service_provider.dart';

class ClientHomeScreen extends ConsumerWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peluquería - Cliente'),
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
                    'Bienvenido ${authState.usuario?.nombre ?? 'Cliente'}',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  _ServicesSection(),
                  const SizedBox(height: 24),
                  _HairstylistsSection(),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/appointments'),
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Ver mis citas'),
                  ),
                ],
              ),
            )
          : const Center(child: Text('No autorizado')),
    );
  }
}

class _ServicesSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servicesAsync = ref.watch(serviceProviderProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Servicios disponibles',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        servicesAsync.when(
          data: (services) {
            if (services.isEmpty) {
              return const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No hay servicios disponibles'),
                ),
              );
            }
            return SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: services.length,
                itemBuilder: (context, index) {
                  final service = services[index];
                  return _ServiceCard(service: service);
                },
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error: $error'),
            ),
          ),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final Servicio service;

  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(right: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: 160,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.nombre,
                style: Theme.of(context).textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                service.descripcion,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${service.precio}',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '${service.duracion} min',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HairstylistsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Peluqueros disponibles',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Para ver peluqueros especializados en un servicio, ve a agendar una cita.'),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () => context.go('/appointments/new'),
                  child: const Text('Agendar cita'),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
