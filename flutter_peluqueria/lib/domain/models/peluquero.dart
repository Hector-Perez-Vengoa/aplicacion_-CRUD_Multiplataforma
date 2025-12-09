import 'servicio.dart';

class Peluquero {
  final String id;
  final String nombre;
  final String email;
  final List<Servicio> serviciosEspecializados;
  final Map<String, HorarioDisponible> horarioDisponible;
  final String estado;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Peluquero({
    required this.id,
    required this.nombre,
    required this.email,
    required this.serviciosEspecializados,
    required this.horarioDisponible,
    required this.estado,
    this.createdAt,
    this.updatedAt,
  });

  factory Peluquero.fromJson(Map<String, dynamic> json) {
    final idValue = json['_id'] ?? json['id'];
    if (idValue == null) throw 'Peluquero sin id';

    // Mapear servicios especializados (pueden ser objetos Servicio o strings)
    final servicios = (json['serviciosEspecializados'] as List<dynamic>?)
            ?.map((e) {
              if (e is Map<String, dynamic>) {
                return Servicio.fromJson(e);
              } else if (e is String) {
                // Si es solo string, crear un Servicio mínimo
                return Servicio(
                  id: e,
                  nombre: '',
                  descripcion: '',
                  precio: 0,
                  duracion: 0,
                  activo: true,
                );
              }
              return null;
            })
            .whereType<Servicio>()
            .toList() ??
        <Servicio>[];

    final horarioMap = <String, HorarioDisponible>{};
    final rawHorario = json['horarioDisponible'] as Map<String, dynamic>?;
    if (rawHorario != null) {
      rawHorario.forEach((key, value) {
        if (value is Map<String, dynamic>) {
          horarioMap[key] = HorarioDisponible.fromJson(value);
        }
      });
    }

    return Peluquero(
      id: idValue as String,
      nombre: json['nombre'] as String? ?? '',
      email: json['email'] as String? ?? '',
      serviciosEspecializados: servicios,
      horarioDisponible: horarioMap,
      estado: json['estado'] as String? ?? 'activo',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'nombre': nombre,
        'email': email,
        'serviciosEspecializados': serviciosEspecializados.map((s) => s.toJson()).toList(),
        'horarioDisponible': horarioDisponible.map(
          (key, value) => MapEntry(key, value.toJson()),
        ),
        'estado': estado,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}

class HorarioDisponible {
  final String inicio;
  final String fin;
  final bool disponible;

  HorarioDisponible({
    required this.inicio,
    required this.fin,
    this.disponible = true,
  });

  factory HorarioDisponible.fromJson(Map<String, dynamic> json) {
    return HorarioDisponible(
      inicio: json['inicio'] as String,
      fin: json['fin'] as String,
      disponible: json['disponible'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'inicio': inicio,
        'fin': fin,
        'disponible': disponible,
      };
}
