class Servicio {
  final String id;
  final String nombre;
  final String descripcion;
  final double precio;
  final int duracion;
  final String? categoria;
  final bool activo;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Servicio({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.duracion,
    this.categoria,
    this.activo = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Servicio.fromJson(Map<String, dynamic> json) {
    final idValue = json['_id'] ?? json['id'];
    if (idValue == null) throw 'Servicio sin id';

    // Manejar duracion (Flutter) vs duracionMinutos (Backend)
    final duracion = (json['duracion'] ?? json['duracionMinutos']) as int;
    
    // Manejar activo (booleano) vs estado (string)
    bool activo = true;
    if (json['activo'] is bool) {
      activo = json['activo'] as bool;
    } else if (json['estado'] is String) {
      activo = (json['estado'] as String).toLowerCase() == 'activo';
    }

    return Servicio(
      id: idValue as String,
      nombre: json['nombre'] as String,
      descripcion: (json['descripcion'] ?? '') as String,
      precio: (json['precio'] as num).toDouble(),
      duracion: duracion,
      categoria: json['categoria'] as String?,
      activo: activo,
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
        'descripcion': descripcion,
        'precio': precio,
        'duracion': duracion,
        'categoria': categoria,
        'activo': activo,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}
