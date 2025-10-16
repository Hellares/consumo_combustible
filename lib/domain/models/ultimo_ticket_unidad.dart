// lib/domain/models/ultimo_ticket_unidad.dart

import 'package:equatable/equatable.dart';

/// Modelo que representa la información del último ticket de una unidad
class UltimoTicketUnidad extends Equatable {
  final UnidadBasicInfo unidad;
  final UltimoTicketInfo? ultimoTicket;
  final SugerenciasTicket sugerencias;

  const UltimoTicketUnidad({
    required this.unidad,
    this.ultimoTicket,
    required this.sugerencias,
  });

  @override
  List<Object?> get props => [unidad, ultimoTicket, sugerencias];

  /// Factory para crear desde JSON
  factory UltimoTicketUnidad.fromJson(Map<String, dynamic> json) {
    return UltimoTicketUnidad(
      unidad: UnidadBasicInfo.fromJson(json['unidad']),
      ultimoTicket: json['ultimoTicket'] != null 
          ? UltimoTicketInfo.fromJson(json['ultimoTicket'])
          : null,
      sugerencias: SugerenciasTicket.fromJson(json['sugerencias']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'unidad': unidad.toJson(),
      'ultimoTicket': ultimoTicket?.toJson(),
      'sugerencias': sugerencias.toJson(),
    };
  }
}

/// Información básica de la unidad
class UnidadBasicInfo extends Equatable {
  final int id;
  final String placa;
  final String marca;
  final String modelo;
  final String tipoCombustible;
  final String capacidadTanque;

  const UnidadBasicInfo({
    required this.id,
    required this.placa,
    required this.marca,
    required this.modelo,
    required this.tipoCombustible,
    required this.capacidadTanque,
  });

  @override
  List<Object?> get props => [id, placa, marca, modelo, tipoCombustible, capacidadTanque];

  factory UnidadBasicInfo.fromJson(Map<String, dynamic> json) {
    return UnidadBasicInfo(
      id: json['id'],
      placa: json['placa'],
      marca: json['marca'],
      modelo: json['modelo'],
      tipoCombustible: json['tipoCombustible'],
      capacidadTanque: json['capacidadTanque'].toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'placa': placa,
      'marca': marca,
      'modelo': modelo,
      'tipoCombustible': tipoCombustible,
      'capacidadTanque': capacidadTanque,
    };
  }
}

/// Información del último ticket
class UltimoTicketInfo extends Equatable {
  final int id;
  final String numeroTicket;
  final String fecha;
  final String hora;
  final double kilometrajeActual;
  final double? kilometrajeAnterior;
  final double diferenciaKilometraje;
  final String precintoNuevo;
  final String tipoCombustible;
  final double cantidad;
  final EstadoTicketBasic estado;
  final ConductorBasicInfo conductor;
  final GrifoBasicInfo grifo;

  const UltimoTicketInfo({
    required this.id,
    required this.numeroTicket,
    required this.fecha,
    required this.hora,
    required this.kilometrajeActual,
    this.kilometrajeAnterior,
    required this.diferenciaKilometraje,
    required this.precintoNuevo,
    required this.tipoCombustible,
    required this.cantidad,
    required this.estado,
    required this.conductor,
    required this.grifo,
  });

  @override
  List<Object?> get props => [
        id,
        numeroTicket,
        fecha,
        hora,
        kilometrajeActual,
        kilometrajeAnterior,
        diferenciaKilometraje,
        precintoNuevo,
        tipoCombustible,
        cantidad,
        estado,
        conductor,
        grifo,
      ];

  factory UltimoTicketInfo.fromJson(Map<String, dynamic> json) {
    return UltimoTicketInfo(
      id: json['id'],
      numeroTicket: json['numeroTicket'],
      fecha: json['fecha'],
      hora: json['hora'],
      kilometrajeActual: (json['kilometrajeActual'] as num).toDouble(),
      kilometrajeAnterior: json['kilometrajeAnterior'] != null 
          ? (json['kilometrajeAnterior'] as num).toDouble()
          : null,
      diferenciaKilometraje: (json['diferenciaKilometraje'] as num).toDouble(),
      precintoNuevo: json['precintoNuevo'],
      tipoCombustible: json['tipoCombustible'],
      cantidad: (json['cantidad'] as num).toDouble(),
      estado: EstadoTicketBasic.fromJson(json['estado']),
      conductor: ConductorBasicInfo.fromJson(json['conductor']),
      grifo: GrifoBasicInfo.fromJson(json['grifo']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'numeroTicket': numeroTicket,
      'fecha': fecha,
      'hora': hora,
      'kilometrajeActual': kilometrajeActual,
      'kilometrajeAnterior': kilometrajeAnterior,
      'diferenciaKilometraje': diferenciaKilometraje,
      'precintoNuevo': precintoNuevo,
      'tipoCombustible': tipoCombustible,
      'cantidad': cantidad,
      'estado': estado.toJson(),
      'conductor': conductor.toJson(),
      'grifo': grifo.toJson(),
    };
  }
}

/// Estado básico del ticket
class EstadoTicketBasic extends Equatable {
  final int id;
  final String nombre;
  final String color;

  const EstadoTicketBasic({
    required this.id,
    required this.nombre,
    required this.color,
  });

  @override
  List<Object?> get props => [id, nombre, color];

  factory EstadoTicketBasic.fromJson(Map<String, dynamic> json) {
    return EstadoTicketBasic(
      id: json['id'],
      nombre: json['nombre'],
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'color': color,
    };
  }
}

/// Información básica del conductor
class ConductorBasicInfo extends Equatable {
  final int id;
  final String nombres;
  final String apellidos;

  const ConductorBasicInfo({
    required this.id,
    required this.nombres,
    required this.apellidos,
  });

  String get nombreCompleto => '$nombres $apellidos';

  @override
  List<Object?> get props => [id, nombres, apellidos];

  factory ConductorBasicInfo.fromJson(Map<String, dynamic> json) {
    return ConductorBasicInfo(
      id: json['id'],
      nombres: json['nombres'],
      apellidos: json['apellidos'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombres': nombres,
      'apellidos': apellidos,
    };
  }
}

/// Información básica del grifo
class GrifoBasicInfo extends Equatable {
  final int id;
  final String nombre;

  const GrifoBasicInfo({
    required this.id,
    required this.nombre,
  });

  @override
  List<Object?> get props => [id, nombre];

  factory GrifoBasicInfo.fromJson(Map<String, dynamic> json) {
    return GrifoBasicInfo(
      id: json['id'],
      nombre: json['nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
    };
  }
}

/// Sugerencias para el nuevo ticket
class SugerenciasTicket extends Equatable {
  final double kilometrajeAnteriorSugerido;
  final String precintoAnteriorSugerido;

  const SugerenciasTicket({
    required this.kilometrajeAnteriorSugerido,
    required this.precintoAnteriorSugerido,
  });

  @override
  List<Object?> get props => [kilometrajeAnteriorSugerido, precintoAnteriorSugerido];

  factory SugerenciasTicket.fromJson(Map<String, dynamic> json) {
    return SugerenciasTicket(
      kilometrajeAnteriorSugerido: (json['kilometrajeAnteriorSugerido'] as num).toDouble(),
      precintoAnteriorSugerido: json['precintoAnteriorSugerido'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kilometrajeAnteriorSugerido': kilometrajeAnteriorSugerido,
      'precintoAnteriorSugerido': precintoAnteriorSugerido,
    };
  }
}