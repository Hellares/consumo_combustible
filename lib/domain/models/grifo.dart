import 'package:consumo_combustible/domain/models/sede.dart';

class Grifo {
  final int id;
  final int sedeId;
  final String nombre;
  final String codigo;
  final String direccion;
  final String? telefono;
  final String? horarioApertura;
  final String? horarioCierre;
  final bool activo;
  final Sede? sede;
  final int ticketsAbastecimientoCount;
  final bool estaAbierto;

  Grifo({
    required this.id,
    required this.sedeId,
    required this.nombre,
    required this.codigo,
    required this.direccion,
    this.telefono,
    this.horarioApertura,
    this.horarioCierre,
    required this.activo,
    this.sede,
    required this.ticketsAbastecimientoCount,
    required this.estaAbierto,
  });

  factory Grifo.fromJson(Map<String, dynamic> json) {
    return Grifo(
      id: json['id'],
      sedeId: json['sedeId'],
      nombre: json['nombre'],
      codigo: json['codigo'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      horarioApertura: json['horarioApertura'],
      horarioCierre: json['horarioCierre'],
      activo: json['activo'] ?? true,
      sede: json['sede'] != null ? Sede.fromJson(json['sede']) : null,
      ticketsAbastecimientoCount: json['ticketsAbastecimientoCount'] ?? 0,
      estaAbierto: json['estaAbierto'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sedeId': sedeId,
      'nombre': nombre,
      'codigo': codigo,
      'direccion': direccion,
      'telefono': telefono,
      'horarioApertura': horarioApertura,
      'horarioCierre': horarioCierre,
      'activo': activo,
      'sede': sede?.toJson(),
      'ticketsAbastecimientoCount': ticketsAbastecimientoCount,
      'estaAbierto': estaAbierto,
    };
  }
}