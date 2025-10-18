// =============================================
// Modelo de Estadísticas GPS
// =============================================

/// Estadísticas generales del sistema GPS
class GpsStats {
  final int totalUnidades;
  final int unidadesActivas;
  final int unidadesInactivas;
  final double porcentajeGpsDevice;
  final double porcentajeMobileApp;
  final double precisionPromedio;
  final DateTime timestamp;

  GpsStats({
    required this.totalUnidades,
    required this.unidadesActivas,
    required this.unidadesInactivas,
    required this.porcentajeGpsDevice,
    required this.porcentajeMobileApp,
    required this.precisionPromedio,
    required this.timestamp,
  });

  /// Factory: desde JSON (API Response)
  factory GpsStats.fromJson(Map<String, dynamic> json) {
    return GpsStats(
      totalUnidades: json['totalUnidades'] as int,
      unidadesActivas: json['unidadesActivas'] as int,
      unidadesInactivas: json['unidadesInactivas'] as int,
      porcentajeGpsDevice: (json['porcentajeGpsDevice'] as num).toDouble(),
      porcentajeMobileApp: (json['porcentajeMobileApp'] as num).toDouble(),
      precisionPromedio: (json['precisionPromedio'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'totalUnidades': totalUnidades,
      'unidadesActivas': unidadesActivas,
      'unidadesInactivas': unidadesInactivas,
      'porcentajeGpsDevice': porcentajeGpsDevice,
      'porcentajeMobileApp': porcentajeMobileApp,
      'precisionPromedio': precisionPromedio,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// CopyWith
  GpsStats copyWith({
    int? totalUnidades,
    int? unidadesActivas,
    int? unidadesInactivas,
    double? porcentajeGpsDevice,
    double? porcentajeMobileApp,
    double? precisionPromedio,
    DateTime? timestamp,
  }) {
    return GpsStats(
      totalUnidades: totalUnidades ?? this.totalUnidades,
      unidadesActivas: unidadesActivas ?? this.unidadesActivas,
      unidadesInactivas: unidadesInactivas ?? this.unidadesInactivas,
      porcentajeGpsDevice: porcentajeGpsDevice ?? this.porcentajeGpsDevice,
      porcentajeMobileApp: porcentajeMobileApp ?? this.porcentajeMobileApp,
      precisionPromedio: precisionPromedio ?? this.precisionPromedio,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Getters de conveniencia
  double get porcentajeActivas => totalUnidades > 0 
      ? (unidadesActivas / totalUnidades) * 100 
      : 0;

  double get porcentajeInactivas => totalUnidades > 0 
      ? (unidadesInactivas / totalUnidades) * 100 
      : 0;

  bool get hasGoodCoverage => porcentajeActivas > 80;

  bool get hasGoodPrecision => precisionPromedio < 20;

  String get precisionDisplayName {
    if (precisionPromedio < 10) return 'Excelente';
    if (precisionPromedio < 20) return 'Buena';
    if (precisionPromedio < 50) return 'Regular';
    return 'Baja';
  }

  @override
  String toString() {
    return 'GpsStats(total: $totalUnidades, activas: $unidadesActivas, '
        'inactivas: $unidadesInactivas, precision: ${precisionPromedio.toStringAsFixed(1)}m)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is GpsStats &&
        other.totalUnidades == totalUnidades &&
        other.unidadesActivas == unidadesActivas &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return totalUnidades.hashCode ^ 
        unidadesActivas.hashCode ^ 
        timestamp.hashCode;
  }
}