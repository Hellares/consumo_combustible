import 'dart:ui';

class TicketAbastecimiento {
  final int id;
  final String numeroTicket;
  final String fecha;
  final String hora;
  final UnidadTicket unidad;
  final ConductorTicket conductor;
  final GrifoTicket grifo;
  final double kilometrajeActual;
  final double? kilometrajeAnterior;
  final double diferenciaKilometraje;
  final String precintoNuevo;
  final String tipoCombustible;
  final double cantidad;
  final String? observacionesSolicitud;
  final EstadoTicket estado;
  final SolicitantTicket solicitadoPor;
  final DateTime fechaSolicitud;
  final String? motivoRechazo;
  final DateTime? fechaRechazo;
  final DateTime createdAt;
  final DateTime updatedAt;

  TicketAbastecimiento({
    required this.id,
    required this.numeroTicket,
    required this.fecha,
    required this.hora,
    required this.unidad,
    required this.conductor,
    required this.grifo,
    required this.kilometrajeActual,
    this.kilometrajeAnterior,
    required this.diferenciaKilometraje,
    required this.precintoNuevo,
    required this.tipoCombustible,
    required this.cantidad,
    this.observacionesSolicitud,
    required this.estado,
    required this.solicitadoPor,
    required this.fechaSolicitud,
    this.motivoRechazo,
    this.fechaRechazo,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TicketAbastecimiento.fromJson(Map<String, dynamic> json) {
    return TicketAbastecimiento(
      id: json['id'],
      numeroTicket: json['numeroTicket'],
      fecha: json['fecha'],
      hora: json['hora'],
      unidad: UnidadTicket.fromJson(json['unidad']),
      conductor: ConductorTicket.fromJson(json['conductor']),
      grifo: GrifoTicket.fromJson(json['grifo']),
      kilometrajeActual: (json['kilometrajeActual'] as num).toDouble(),
      kilometrajeAnterior: json['kilometrajeAnterior'] != null
          ? (json['kilometrajeAnterior'] as num).toDouble()
          : null,
      diferenciaKilometraje: (json['diferenciaKilometraje'] as num).toDouble(),
      precintoNuevo: json['precintoNuevo'],
      tipoCombustible: json['tipoCombustible'],
      cantidad: (json['cantidad'] as num).toDouble(),
      observacionesSolicitud: json['observacionesSolicitud'],
      estado: EstadoTicket.fromJson(json['estado']),
      solicitadoPor: SolicitantTicket.fromJson(json['solicitadoPor']),
      fechaSolicitud: DateTime.parse(json['fechaSolicitud']),
      motivoRechazo: json['motivoRechazo'],
      fechaRechazo: json['fechaRechazo'] != null
          ? DateTime.parse(json['fechaRechazo'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}

class UnidadTicket {
  final int id;
  final String placa;
  final String marca;
  final String modelo;
  final String tipoCombustible;

  UnidadTicket({
    required this.id,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.tipoCombustible,
  });

  factory UnidadTicket.fromJson(Map<String, dynamic> json) {
    return UnidadTicket(
      id: json['id'],
      placa: json['placa'],
      marca: json['marca'],
      modelo: json['modelo'],
      tipoCombustible: json['tipoCombustible'],
    );
  }
}

class ConductorTicket {
  final int id;
  final String nombres;
  final String apellidos;
  final String dni;
  final String codigoEmpleado;

  ConductorTicket({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.dni,
    required this.codigoEmpleado,
  });

  factory ConductorTicket.fromJson(Map<String, dynamic> json) {
    return ConductorTicket(
      id: json['id'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      dni: json['dni'],
      codigoEmpleado: json['codigoEmpleado'],
    );
  }
}

class GrifoTicket {
  final int id;
  final String nombre;
  final String codigo;
  final String direccion;

  GrifoTicket({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.direccion,
  });

  factory GrifoTicket.fromJson(Map<String, dynamic> json) {
    return GrifoTicket(
      id: json['id'],
      nombre: json['nombre'],
      codigo: json['codigo'],
      direccion: json['direccion'],
    );
  }
}

class EstadoTicket {
  final int id;
  final String nombre;
  final String descripcion;
  final String color;

  EstadoTicket({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.color,
  });

  factory EstadoTicket.fromJson(Map<String, dynamic> json) {
    return EstadoTicket(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      color: json['color'],
    );
  }

  Color get colorValue {
    return Color(int.parse(color.replaceFirst('#', '0xFF')));
  }
}

class SolicitantTicket {
  final int id;
  final String nombres;
  final String apellidos;
  final String codigoEmpleado;

  SolicitantTicket({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.codigoEmpleado,
  });

  factory SolicitantTicket.fromJson(Map<String, dynamic> json) {
    return SolicitantTicket(
      id: json['id'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
      codigoEmpleado: json['codigoEmpleado'],
    );
  }
}