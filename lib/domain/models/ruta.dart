// lib/domain/models/ruta.dart

class Ruta {
  final int id;
  final String nombre;
  final String codigo;
  final String origen;
  final String destino;
  final double distanciaKm;
  final int tiempoEstimadoMinutos;
  final String? descripcion;
  final String estado; // ACTIVA, INACTIVA, MANTENIMIENTO
  final String? tipoRuta; // URBANA, INTERURBANA, REGIONAL
  final DateTime createdAt;
  final DateTime updatedAt;

  Ruta({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.origen,
    required this.destino,
    required this.distanciaKm,
    required this.tiempoEstimadoMinutos,
    this.descripcion,
    required this.estado,
    this.tipoRuta,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Ruta.fromJson(Map<String, dynamic> json) {
    return Ruta(
      id: json['id'],
      nombre: json['nombre'],
      codigo: json['codigo'],
      origen: json['origen'],
      destino: json['destino'],
      distanciaKm: double.parse(json['distanciaKm'].toString()),
      tiempoEstimadoMinutos: json['tiempoEstimadoMinutos'],
      descripcion: json['descripcion'],
      estado: json['estado'] ?? 'ACTIVA',
      tipoRuta: json['tipoRuta'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  bool get esActiva => estado == 'ACTIVA';

  String get trayecto => '$origen → $destino';

  String get distanciaFormateada => '${distanciaKm.toStringAsFixed(1)} km';

  String get tiempoFormateado {
    final horas = tiempoEstimadoMinutos ~/ 60;
    final minutos = tiempoEstimadoMinutos % 60;
    if (horas > 0) {
      return '${horas}h ${minutos}min';
    }
    return '${minutos}min';
  }
}