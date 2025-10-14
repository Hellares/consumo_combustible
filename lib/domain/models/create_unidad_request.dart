// lib/domain/models/create_unidad_request.dart

class CreateUnidadRequest {
  final String placa;
  final int conductorOperadorId;
  final String operacion;
  final String marca;
  final String modelo;
  final int anio;
  final String nroVin;
  final String nroMotor;
  final int zonaOperacionId;
  final double capacidadTanque;
  final String tipoCombustible;
  final double odometroInicial;
  final double horometroInicial;
  final String fechaAdquisicion; // formato: "YYYY-MM-DD"
  final String estado;
  final bool activo;

  CreateUnidadRequest({
    required this.placa,
    required this.conductorOperadorId,
    required this.operacion,
    required this.marca,
    required this.modelo,
    required this.anio,
    required this.nroVin,
    required this.nroMotor,
    required this.zonaOperacionId,
    required this.capacidadTanque,
    required this.tipoCombustible,
    required this.odometroInicial,
    required this.horometroInicial,
    required this.fechaAdquisicion,
    required this.estado,
    this.activo = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'placa': placa,
      'conductorOperadorId': conductorOperadorId,
      'operacion': operacion,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'nroVin': nroVin,
      'nroMotor': nroMotor,
      'zonaOperacionId': zonaOperacionId,
      'capacidadTanque': capacidadTanque,
      'tipoCombustible': tipoCombustible,
      'odometroInicial': odometroInicial,
      'horometroInicial': horometroInicial,
      'fechaAdquisicion': fechaAdquisicion,
      'estado': estado,
      'activo': activo,
    };
  }

  // Constructor vacío para inicializar formularios
  factory CreateUnidadRequest.empty() {
    return CreateUnidadRequest(
      placa: '',
      conductorOperadorId: 0,
      operacion: '',
      marca: '',
      modelo: '',
      anio: DateTime.now().year,
      nroVin: '',
      nroMotor: '',
      zonaOperacionId: 0,
      capacidadTanque: 0.0,
      tipoCombustible: 'DIESEL',
      odometroInicial: 0.0,
      horometroInicial: 0.0,
      fechaAdquisicion: DateTime.now().toString().split(' ')[0],
      estado: 'OPERATIVO',
      activo: true,
    );
  }

  // CopyWith para facilitar la actualización de campos en el formulario
  CreateUnidadRequest copyWith({
    String? placa,
    int? conductorOperadorId,
    String? operacion,
    String? marca,
    String? modelo,
    int? anio,
    String? nroVin,
    String? nroMotor,
    int? zonaOperacionId,
    double? capacidadTanque,
    String? tipoCombustible,
    double? odometroInicial,
    double? horometroInicial,
    String? fechaAdquisicion,
    String? estado,
    bool? activo,
  }) {
    return CreateUnidadRequest(
      placa: placa ?? this.placa,
      conductorOperadorId: conductorOperadorId ?? this.conductorOperadorId,
      operacion: operacion ?? this.operacion,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      anio: anio ?? this.anio,
      nroVin: nroVin ?? this.nroVin,
      nroMotor: nroMotor ?? this.nroMotor,
      zonaOperacionId: zonaOperacionId ?? this.zonaOperacionId,
      capacidadTanque: capacidadTanque ?? this.capacidadTanque,
      tipoCombustible: tipoCombustible ?? this.tipoCombustible,
      odometroInicial: odometroInicial ?? this.odometroInicial,
      horometroInicial: horometroInicial ?? this.horometroInicial,
      fechaAdquisicion: fechaAdquisicion ?? this.fechaAdquisicion,
      estado: estado ?? this.estado,
      activo: activo ?? this.activo,
    );
  }
}