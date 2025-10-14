import 'package:consumo_combustible/domain/models/zona.dart';

class Sede {
  final int id;
  final int? zonaId;
  final String nombre;
  final String codigo;
  final String? direccion;
  final String? telefono;
  final bool? activo;
  final DateTime? createdAt;  // ⭐ NUEVO
  final DateTime? updatedAt;  // ⭐ NUEVO
  final Zona? zona;
  final int? grifosCount;

  Sede({
    required this.id,
    this.zonaId,
    required this.nombre,
    required this.codigo,
    this.direccion,
    this.telefono,
    this.activo,
    this.createdAt,  // ⭐ NUEVO
    this.updatedAt,  // ⭐ NUEVO
    this.zona,
    this.grifosCount,
  });

  factory Sede.fromJson(Map<String, dynamic> json) {
    return Sede(
      id: json['id'],
      zonaId: json['zonaId'],
      nombre: json['nombre'],
      codigo: json['codigo'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      activo: json['activo'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,  // ⭐ NUEVO
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,  // ⭐ NUEVO
      zona: json['zona'] != null ? Zona.fromJson(json['zona']) : null,
      grifosCount: json['grifosCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zonaId': zonaId,
      'nombre': nombre,
      'codigo': codigo,
      'direccion': direccion,
      'telefono': telefono,
      'activo': activo,
      'createdAt': createdAt?.toIso8601String(),  // ⭐ NUEVO
      'updatedAt': updatedAt?.toIso8601String(),  // ⭐ NUEVO
      'zona': zona?.toJson(),
      'grifosCount': grifosCount,
    };
  }
}