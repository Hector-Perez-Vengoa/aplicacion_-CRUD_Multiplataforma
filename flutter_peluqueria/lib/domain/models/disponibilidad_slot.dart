class DisponibilidadSlot {
  final DateTime inicio;
  final DateTime fin;
  final bool disponible;

  DisponibilidadSlot({
    required this.inicio,
    required this.fin,
    required this.disponible,
  });

  factory DisponibilidadSlot.fromJson(Map<String, dynamic> json) =>
      DisponibilidadSlot(
        inicio: DateTime.parse(json['inicio'] as String),
        fin: DateTime.parse(json['fin'] as String),
        disponible: json['disponible'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'inicio': inicio.toIso8601String(),
        'fin': fin.toIso8601String(),
        'disponible': disponible,
      };
}
