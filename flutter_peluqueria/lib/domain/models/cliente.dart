class Cliente {
  final String id;
  final String usuario;
  final List<String>? peluquerosFavoritos;
  final List<String>? serviciosFrecuentes;
  final String? notasInternas;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Cliente({
    required this.id,
    required this.usuario,
    this.peluquerosFavoritos,
    this.serviciosFrecuentes,
    this.notasInternas,
    this.createdAt,
    this.updatedAt,
  });

  factory Cliente.fromJson(Map<String, dynamic> json) {
    final idValue = json['_id'] ?? json['id'];
    if (idValue == null) throw 'Cliente sin id';

    return Cliente(
      id: idValue as String,
      usuario: json['usuario'] as String,
      peluquerosFavoritos: (json['peluquerosFavoritos'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      serviciosFrecuentes: (json['serviciosFrecuentes'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      notasInternas: json['notasInternas'] as String?,
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
        'usuario': usuario,
        'peluquerosFavoritos': peluquerosFavoritos,
        'serviciosFrecuentes': serviciosFrecuentes,
        'notasInternas': notasInternas,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
