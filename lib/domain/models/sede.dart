import 'package:consumo_combustible/domain/models/zona.dart';

class Sede {
  final int id;
  final int? zonaId; // ✅ NULLABLE
  final String nombre;
  final String codigo;
  final String? direccion; // ✅ NULLABLE
  final String? telefono;
  final bool? activo; // ✅ NULLABLE
  final Zona? zona;
  final int? grifosCount; // ✅ NULLABLE

  Sede({
    required this.id,
    this.zonaId, // ✅ OPCIONAL
    required this.nombre,
    required this.codigo,
    this.direccion,
    this.telefono,
    this.activo,
    this.zona,
    this.grifosCount,
  });

  factory Sede.fromJson(Map<String, dynamic> json) {
    return Sede(
      id: json['id'],
      zonaId: json['zonaId'], // ✅ Puede ser null
      nombre: json['nombre'],
      codigo: json['codigo'],
      direccion: json['direccion'],
      telefono: json['telefono'],
      activo: json['activo'],
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
      'zona': zona?.toJson(),
      'grifosCount': grifosCount,
    };
  }
}