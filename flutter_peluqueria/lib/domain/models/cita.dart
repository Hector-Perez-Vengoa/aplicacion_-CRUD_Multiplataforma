class Cita {
  final String id;
  final String cliente;
  final String peluquero;
  final String servicio;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final String estado;
  final double precioTotal;
  final String? notasCliente;
  final CancelacionInfo? cancelacion;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // IDs originales para edición
  final String? clienteId;
  final String? peluqueroId;
  final dynamic servicioId; // Puede ser String o Map

  Cita({
    required this.id,
    required this.cliente,
    required this.peluquero,
    required this.servicio,
    required this.fechaInicio,
    required this.fechaFin,
    required this.estado,
    required this.precioTotal,
    this.notasCliente,
    this.cancelacion,
    this.createdAt,
    this.updatedAt,
    this.clienteId,
    this.peluqueroId,
    this.servicioId,
  });

  factory Cita.fromJson(Map<String, dynamic> json) {
    final idValue = json['_id'] ?? json['id'];
    if (idValue == null) throw 'Cita sin id';

    String mapNombreOId(dynamic value, {String fallback = ''}) {
      if (value == null) return fallback;
      if (value is String) return value;
      if (value is Map<String, dynamic>) {
        return (value['nombre'] as String?) ?? (value['_id'] as String?) ?? fallback;
      }
      return fallback;
    }

    return Cita(
      id: idValue as String,
      cliente: mapNombreOId(json['cliente'] ?? json['clienteId']),
      peluquero: mapNombreOId(json['peluquero'] ?? json['peluqueroId']),
      servicio: mapNombreOId(json['servicio'] ?? json['servicioId']),
      fechaInicio: DateTime.parse((json['fechaInicio'] ?? json['fechaHoraInicio']) as String),
      fechaFin: DateTime.parse((json['fechaFin'] ?? json['fechaHoraFin']) as String),
      estado: (json['estado'] as String? ?? '').toLowerCase(),
      precioTotal: (json['precioTotal'] as num).toDouble(),
      notasCliente: json['notasCliente'] as String?,
      cancelacion: json['cancelacion'] != null
          ? CancelacionInfo.fromJson(json['cancelacion'] as Map<String, dynamic>)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : null,
      clienteId: json['clienteId'] is Map 
          ? (json['clienteId'] as Map)['_id'] 
          : json['clienteId'],
      peluqueroId: json['peluqueroId'] is Map 
          ? (json['peluqueroId'] as Map)['_id'] 
          : json['peluqueroId'],
      servicioId: json['servicioId'],
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'cliente': cliente,
        'peluquero': peluquero,
        'servicio': servicio,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaFin': fechaFin.toIso8601String(),
        'estado': estado,
        'precioTotal': precioTotal,
        'notasCliente': notasCliente,
        'cancelacion': cancelacion?.toJson(),
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };
}

class CancelacionInfo {
  final DateTime fecha;
  final String motivo;
  final String canceladoPor;

  CancelacionInfo({
    required this.fecha,
    required this.motivo,
    required this.canceladoPor,
  });

  factory CancelacionInfo.fromJson(Map<String, dynamic> json) =>
      CancelacionInfo(
        fecha: DateTime.parse(json['fecha'] as String),
        motivo: json['motivo'] as String,
        canceladoPor: json['canceladoPor'] as String,
      );

  Map<String, dynamic> toJson() => {
        'fecha': fecha.toIso8601String(),
        'motivo': motivo,
        'canceladoPor': canceladoPor,
      };
}
