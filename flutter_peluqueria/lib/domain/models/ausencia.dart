class Ausencia {
  final String id;
  final String peluquero;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String motivo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Ausencia({
    required this.id,
    required this.peluquero,
    required this.fechaInicio,
    required this.fechaFin,
    required this.motivo,
    this.createdAt,
    this.updatedAt,
  });

  factory Ausencia.fromJson(Map<String, dynamic> json) {
    final idValue = json['_id'] ?? json['id'];
    if (idValue == null) throw 'Ausencia sin id';

    return Ausencia(
      id: idValue as String,
      peluquero: json['peluquero'] as String,
      fechaInicio: DateTime.parse(json['fechaInicio'] as String),
      fechaFin: DateTime.parse(json['fechaFin'] as String),
      motivo: json['motivo'] as String,
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
        'peluquero': peluquero,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaFin': fechaFin.toIso8601String(),
        'motivo': motivo,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
