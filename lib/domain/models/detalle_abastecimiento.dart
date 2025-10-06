import 'package:flutter/material.dart';

/// Helper para convertir valores numéricos que pueden venir como String o num
double? _parseToDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) {
    return double.tryParse(value);
  }
  return null;
}

/// Modelo principal de Detalle de Abastecimiento
class DetalleAbastecimiento {
  final int id;
  final int ticketId;
  final double? cantidadAbastecida;
  final String? motivoDiferencia;
  final double? horometroActual;
  final double? horometroAnterior;
  final String? precintoAnterior;
  final String? precinto2;
  final String unidadMedida;
  final String costoPorUnidad;
  final String costoTotal;
  final String? numeroTicketGrifo;
  final String? valeDiesel;
  final String? numeroFactura;
  final String? importeFactura;
  final String? requerimiento;
  final String? numeroSalidaAlmacen;
  final String? observacionesControlador;
  final int? controladorId;
  final int? aprobadoPorId;
  final DateTime? fechaAprobacion;
  final String estado;
  final DateTime? fechaConcluido;
  final int? concluidoPorId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final TicketDetalle ticket;
  final AprobadoPor? aprobadoPor;

  DetalleAbastecimiento({
    required this.id,
    required this.ticketId,
    this.cantidadAbastecida,
    this.motivoDiferencia,
    this.horometroActual,
    this.horometroAnterior,
    this.precintoAnterior,
    this.precinto2,
    required this.unidadMedida,
    required this.costoPorUnidad,
    required this.costoTotal,
    this.numeroTicketGrifo,
    this.valeDiesel,
    this.numeroFactura,
    this.importeFactura,
    this.requerimiento,
    this.numeroSalidaAlmacen,
    this.observacionesControlador,
    this.controladorId,
    this.aprobadoPorId,
    this.fechaAprobacion,
    required this.estado,
    this.fechaConcluido,
    this.concluidoPorId,
    required this.createdAt,
    required this.updatedAt,
    required this.ticket,
    this.aprobadoPor,
  });

  factory DetalleAbastecimiento.fromJson(Map<String, dynamic> json) {
    return DetalleAbastecimiento(
      id: json['id'],
      ticketId: json['ticketId'],
      cantidadAbastecida: _parseToDouble(json['cantidadAbastecida']),
      motivoDiferencia: json['motivoDiferencia'],
      horometroActual: _parseToDouble(json['horometroActual']),
      horometroAnterior: _parseToDouble(json['horometroAnterior']),
      precintoAnterior: json['precintoAnterior'],
      precinto2: json['precinto2'],
      unidadMedida: json['unidadMedida'] ?? 'GALONES',
      costoPorUnidad: json['costoPorUnidad'] ?? '0',
      costoTotal: json['costoTotal'] ?? '0',
      numeroTicketGrifo: json['numeroTicketGrifo'],
      valeDiesel: json['valeDiesel'],
      numeroFactura: json['numeroFactura'],
      importeFactura: json['importeFactura'],
      requerimiento: json['requerimiento'],
      numeroSalidaAlmacen: json['numeroSalidaAlmacen'],
      observacionesControlador: json['observacionesControlador'],
      controladorId: json['controladorId'],
      aprobadoPorId: json['aprobadoPorId'],
      fechaAprobacion: json['fechaAprobacion'] != null
          ? DateTime.parse(json['fechaAprobacion'])
          : null,
      estado: json['estado'] ?? 'EN_PROGRESO',
      fechaConcluido: json['fechaConcluido'] != null
          ? DateTime.parse(json['fechaConcluido'])
          : null,
      concluidoPorId: json['concluidoPorId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      ticket: TicketDetalle.fromJson(json['ticket']),
      aprobadoPor: json['aprobadoPor'] != null
          ? AprobadoPor.fromJson(json['aprobadoPor'])
          : null,
    );
  }

  Color get estadoColor {
    switch (estado) {
      case 'EN_PROGRESO':
        return const Color(0xFFFFC107); // Amarillo
      case 'CONCLUIDO':
        return const Color(0xFF28A745); // Verde
      default:
        return Colors.grey;
    }
  }

  String get estadoTexto {
    switch (estado) {
      case 'EN_PROGRESO':
        return 'En Progreso';
      case 'CONCLUIDO':
        return 'Concluido';
      default:
        return estado;
    }
  }
}

/// Modelo de Ticket reducido (solo info necesaria)
class TicketDetalle {
  final int id;
  final String numeroTicket;
  final DateTime fecha;
  final DateTime hora;
  final String placaUnidad;
  final String unidadDescripcion;
  final String conductorNombre;
  final String grifoNombre;
  final double cantidad; // Cantidad de combustible solicitada
  final String estadoTicket;
  final String estadoColor;

  TicketDetalle({
    required this.id,
    required this.numeroTicket,
    required this.fecha,
    required this.hora,
    required this.placaUnidad,
    required this.unidadDescripcion,
    required this.conductorNombre,
    required this.grifoNombre,
    required this.cantidad,
    required this.estadoTicket,
    required this.estadoColor,
  });

  factory TicketDetalle.fromJson(Map<String, dynamic> json) {
    return TicketDetalle(
      id: json['id'],
      numeroTicket: json['numeroTicket'],
      fecha: DateTime.parse(json['fecha']),
      hora: DateTime.parse(json['hora']),
      placaUnidad: json['placaUnidad'],
      unidadDescripcion: json['unidadDescripcion'],
      conductorNombre: json['conductorNombre'],
      grifoNombre: json['grifoNombre'],
      cantidad: _parseToDouble(json['cantidad']) ?? 0.0,
      estadoTicket: json['estadoTicket'],
      estadoColor: json['estadoColor'],
    );
  }

  Color get estadoColorValue {
    return Color(int.parse(estadoColor.replaceFirst('#', '0xFF')));
  }
}

/// Modelo de quien aprobó
class AprobadoPor {
  final int id;
  final String nombreCompleto;
  final String email;

  AprobadoPor({
    required this.id,
    required this.nombreCompleto,
    required this.email,
  });

  factory AprobadoPor.fromJson(Map<String, dynamic> json) {
    return AprobadoPor(
      id: json['id'],
      nombreCompleto: json['nombreCompleto'],
      email: json['email'],
    );
  }
}

/// Metadata de paginación
class DetalleAbastecimientoMeta {
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final int offset;
  final int limit;
  final int? nextOffset;
  final int? prevOffset;
  final bool hasNext;
  final bool hasPrevious;
  final Map<String, dynamic> filtro;

  DetalleAbastecimientoMeta({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.offset,
    required this.limit,
    this.nextOffset,
    this.prevOffset,
    required this.hasNext,
    required this.hasPrevious,
    required this.filtro,
  });

  factory DetalleAbastecimientoMeta.fromJson(Map<String, dynamic> json) {
    return DetalleAbastecimientoMeta(
      total: json['total'],
      page: json['page'],
      pageSize: json['pageSize'],
      totalPages: json['totalPages'],
      offset: json['offset'],
      limit: json['limit'],
      nextOffset: json['nextOffset'],
      prevOffset: json['prevOffset'],
      hasNext: json['hasNext'],
      hasPrevious: json['hasPrevious'],
      filtro: json['filtro'] ?? {},
    );
  }
}