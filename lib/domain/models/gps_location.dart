// =============================================
// Modelo de Ubicación GPS
// =============================================

/// Tipo de proveedor de GPS
enum GpsProviderType {
  mobileApp('MOBILE_APP'),
  gpsDevice('GPS_DEVICE'),
  gpsDeviceObd('GPS_DEVICE_OBD'),
  gpsDeviceHardwired('GPS_DEVICE_HARDWIRED'),
  externalApi('EXTERNAL_API');

  final String value;
  const GpsProviderType(this.value);

  static GpsProviderType fromString(String value) {
    return GpsProviderType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GpsProviderType.mobileApp,
    );
  }
}

/// Calidad de señal GPS
enum GpsSignalQuality {
  excelente('EXCELENTE'),
  buena('BUENA'),
  regular('REGULAR'),
  pobre('POBRE'),
  sinSenal('SIN_SENAL');

  final String value;
  const GpsSignalQuality(this.value);

  static GpsSignalQuality fromString(String value) {
    return GpsSignalQuality.values.firstWhere(
      (e) => e.value == value,
      orElse: () => GpsSignalQuality.regular,
    );
  }
}

/// Modelo principal de ubicación GPS
class GpsLocation {
  // Identificación
  final int? id;
  final int unidadId;
  final int? ejecucionId;
  final int? registroTramoId;

  // Coordenadas
  final double latitud;
  final double longitud;
  final double? altitud;
  final double? precision; // en metros

  // Datos del vehículo
  final double? velocidad; // km/h
  final double? rumbo; // 0-360 grados
  final double? kilometraje;

  // Timestamp
  final DateTime fechaHora;

  // Proveedor
  final GpsProviderType proveedor;
  final String? dispositivoId; // IMEI o deviceId

  // Estado del dispositivo
  final int? bateria; // Porcentaje 0-100
  final GpsSignalQuality? senalGPS; // ✅ Sin ñ

  // Información del dispositivo (para MOBILE_APP)
  final String? appVersion;
  final String? sistemaOperativo;
  final String? modeloDispositivo;

  // Metadata flexible
  final Map<String, dynamic>? metadata;

  // Timestamps de auditoría
  final DateTime? createdAt;

  GpsLocation({
    this.id,
    required this.unidadId,
    this.ejecucionId,
    this.registroTramoId,
    required this.latitud,
    required this.longitud,
    this.altitud,
    this.precision,
    this.velocidad,
    this.rumbo,
    this.kilometraje,
    required this.fechaHora,
    required this.proveedor,
    this.dispositivoId,
    this.bateria,
    this.senalGPS,
    this.appVersion,
    this.sistemaOperativo,
    this.modeloDispositivo,
    this.metadata,
    this.createdAt,
  });

  /// Factory: desde JSON (API Response)
  factory GpsLocation.fromJson(Map<String, dynamic> json) {
    return GpsLocation(
      id: json['id'],
      unidadId: json['unidadId'],
      ejecucionId: json['ejecucionId'],
      registroTramoId: json['registroTramoId'],
      latitud: (json['latitud'] as num).toDouble(),
      longitud: (json['longitud'] as num).toDouble(),
      altitud: json['altitud'] != null ? (json['altitud'] as num).toDouble() : null,
      precision: json['precision'] != null ? (json['precision'] as num).toDouble() : null,
      velocidad: json['velocidad'] != null ? (json['velocidad'] as num).toDouble() : null,
      rumbo: json['rumbo'] != null ? (json['rumbo'] as num).toDouble() : null,
      kilometraje: json['kilometraje'] != null ? (json['kilometraje'] as num).toDouble() : null,
      fechaHora: DateTime.parse(json['fechaHora']),
      proveedor: GpsProviderType.fromString(json['proveedor'] ?? 'MOBILE_APP'),
      dispositivoId: json['dispositivoId'],
      bateria: json['bateria'],
      senalGPS: json['señalGPS'] != null  // ✅ Backend envía "señalGPS" con ñ
          ? GpsSignalQuality.fromString(json['señalGPS'])
          : null,
      appVersion: json['appVersion'],
      sistemaOperativo: json['sistemaOperativo'],
      modeloDispositivo: json['modeloDispositivo'],
      metadata: json['metadata'] != null 
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }

  /// Convertir a JSON (para enviar al API)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'unidadId': unidadId,
      if (ejecucionId != null) 'ejecucionId': ejecucionId,
      if (registroTramoId != null) 'registroTramoId': registroTramoId,
      'latitud': latitud,
      'longitud': longitud,
      if (altitud != null) 'altitud': altitud,
      if (precision != null) 'precision': precision,
      if (velocidad != null) 'velocidad': velocidad,
      if (rumbo != null) 'rumbo': rumbo,
      if (kilometraje != null) 'kilometraje': kilometraje,
      'fechaHora': fechaHora.toIso8601String(),
      'proveedor': proveedor.value,
      if (dispositivoId != null) 'dispositivoId': dispositivoId,
      if (bateria != null) 'bateria': bateria,
      if (senalGPS != null) 'señalGPS': senalGPS!.value, // Backend espera "señalGPS" con ñ
      if (appVersion != null) 'appVersion': appVersion,
      if (sistemaOperativo != null) 'sistemaOperativo': sistemaOperativo,
      if (modeloDispositivo != null) 'modeloDispositivo': modeloDispositivo,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// CopyWith para inmutabilidad
  GpsLocation copyWith({
    int? id,
    int? unidadId,
    int? ejecucionId,
    int? registroTramoId,
    double? latitud,
    double? longitud,
    double? altitud,
    double? precision,
    double? velocidad,
    double? rumbo,
    double? kilometraje,
    DateTime? fechaHora,
    GpsProviderType? proveedor,
    String? dispositivoId,
    int? bateria,
    GpsSignalQuality? senalGPS, // Parámetro con nombre correcto
    String? appVersion,
    String? sistemaOperativo,
    String? modeloDispositivo,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return GpsLocation(
      id: id ?? this.id,
      unidadId: unidadId ?? this.unidadId,
      ejecucionId: ejecucionId ?? this.ejecucionId,
      registroTramoId: registroTramoId ?? this.registroTramoId,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      altitud: altitud ?? this.altitud,
      precision: precision ?? this.precision,
      velocidad: velocidad ?? this.velocidad,
      rumbo: rumbo ?? this.rumbo,
      kilometraje: kilometraje ?? this.kilometraje,
      fechaHora: fechaHora ?? this.fechaHora,
      proveedor: proveedor ?? this.proveedor,
      dispositivoId: dispositivoId ?? this.dispositivoId,
      bateria: bateria ?? this.bateria,
      senalGPS: senalGPS ?? this.senalGPS, // Ahora el nombre coincide
      appVersion: appVersion ?? this.appVersion,
      sistemaOperativo: sistemaOperativo ?? this.sistemaOperativo,
      modeloDispositivo: modeloDispositivo ?? this.modeloDispositivo,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Getters de conveniencia
  bool get isMobileApp => proveedor == GpsProviderType.mobileApp;
  
  bool get isGpsDevice => proveedor == GpsProviderType.gpsDevice ||
      proveedor == GpsProviderType.gpsDeviceObd ||
      proveedor == GpsProviderType.gpsDeviceHardwired;

  bool get hasGoodSignal =>
      senalGPS == GpsSignalQuality.excelente || 
      senalGPS == GpsSignalQuality.buena;

  bool get hasGoodPrecision => precision != null && precision! < 20;

  bool get isMoving => velocidad != null && velocidad! > 5;

  String get proveedorDisplayName {
    switch (proveedor) {
      case GpsProviderType.mobileApp:
        return 'GPS Móvil';
      case GpsProviderType.gpsDevice:
        return 'GPS Vehicular';
      case GpsProviderType.gpsDeviceObd:
        return 'GPS OBD-II';
      case GpsProviderType.gpsDeviceHardwired:
        return 'GPS Instalado';
      case GpsProviderType.externalApi:
        return 'API Externa';
    }
  }

  @override
  String toString() {
    return 'GpsLocation(id: $id, unidadId: $unidadId, '
        'lat: ${latitud.toStringAsFixed(6)}, lng: ${longitud.toStringAsFixed(6)}, '
        'proveedor: ${proveedor.value}, velocidad: $velocidad km/h)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GpsLocation &&
        other.id == id &&
        other.unidadId == unidadId &&
        other.latitud == latitud &&
        other.longitud == longitud &&
        other.fechaHora == fechaHora;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        unidadId.hashCode ^
        latitud.hashCode ^
        longitud.hashCode ^
        fechaHora.hashCode;
  }
}