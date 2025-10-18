// =============================================
// Send Location Use Case
// Enviar ubicación GPS al servidor
// =============================================

import 'package:consumo_combustible/domain/models/gps_location.dart';
import 'package:consumo_combustible/domain/repository/gps_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

/// Use Case para enviar ubicación GPS
/// 
/// **Responsabilidades:**
/// - Validar datos de ubicación antes de enviar
/// - Intentar enviar por WebSocket primero
/// - Fallback a REST si WebSocket falla
/// - Retornar resultado de la operación
class SendLocationUseCase {
  final GpsRepository _repository;

  SendLocationUseCase(this._repository);

  /// Ejecutar el use case
  /// 
  /// **Parámetros:**
  /// - [location]: Ubicación GPS a enviar
  /// 
  /// **Retorna:**
  /// - [Resource<GpsLocation>]: Success si se envió, Error si falló
  Future<Resource<GpsLocation>> call(GpsLocation location) async {
    // Validación básica
    final validation = _validateLocation(location);
    if (validation != null) {
      return Error(validation);
    }

    // Enviar al repository (intenta WebSocket, fallback a REST)
    return await _repository.sendLocation(location);
  }

  /// Validar datos de ubicación
  String? _validateLocation(GpsLocation location) {
    // Validar coordenadas
    if (location.latitud < -90 || location.latitud > 90) {
      return 'Latitud inválida: debe estar entre -90 y 90';
    }

    if (location.longitud < -180 || location.longitud > 180) {
      return 'Longitud inválida: debe estar entre -180 y 180';
    }

    // Validar precisión (si existe)
    if (location.precision != null && location.precision! < 0) {
      return 'Precisión no puede ser negativa';
    }

    // Validar velocidad (si existe)
    if (location.velocidad != null && location.velocidad! < 0) {
      return 'Velocidad no puede ser negativa';
    }

    // Validar rumbo (si existe)
    if (location.rumbo != null && 
        (location.rumbo! < 0 || location.rumbo! > 360)) {
      return 'Rumbo debe estar entre 0 y 360 grados';
    }

    // Validar batería (si existe)
    if (location.bateria != null && 
        (location.bateria! < 0 || location.bateria! > 100)) {
      return 'Batería debe estar entre 0 y 100%';
    }

    // Validar que la fecha no sea futura
    if (location.fechaHora.isAfter(DateTime.now())) {
      return 'La fecha no puede ser futura';
    }

    // Validar que la fecha no sea muy antigua (más de 24 horas)
    final diff = DateTime.now().difference(location.fechaHora);
    if (diff.inHours > 24) {
      return 'La ubicación es muy antigua (más de 24 horas)';
    }

    return null; // Validación OK
  }
}