import 'package:flutter/material.dart';

class HairstylistHomeScreen extends StatelessWidget {
  const HairstylistHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Peluquero'),
      ),
      body: const Center(
        child: Text('Pantalla de Peluquero - En desarrollo'),
      ),
    );
  }
}
