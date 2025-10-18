// =============================================
// Get Tracking Stats Use Case
// Obtener estadísticas del sistema GPS
// =============================================

import 'package:consumo_combustible/domain/models/gps_stats.dart';
import 'package:consumo_combustible/domain/models/tracking_status.dart';
import 'package:consumo_combustible/domain/repository/gps_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

/// Use Case para obtener estadísticas del sistema GPS
/// 
/// **Responsabilidades:**
/// - Obtener estadísticas generales del sistema
/// - Obtener estado de tracking de unidades específicas
/// - Verificar unidades inactivas
class GetTrackingStatsUseCase {
  final GpsRepository _repository;

  GetTrackingStatsUseCase(this._repository);

  /// Obtener estadísticas generales del sistema
  /// 
  /// **Retorna:**
  /// - [Resource<GpsStats>]: Estadísticas completas
  Future<Resource<GpsStats>> call() async {
    return await _repository.getTrackingStats();
  }

  /// Obtener estado de tracking de una unidad
  /// 
  /// **Parámetros:**
  /// - [unidadId]: ID de la unidad
  /// 
  /// **Retorna:**
  /// - [Resource<TrackingStatus>]: Estado detallado
  Future<Resource<TrackingStatus>> getUnitStatus(int unidadId) async {
    if (unidadId <= 0) {
      return Error('ID de unidad inválido');
    }

    return await _repository.getTrackingStatus(unidadId);
  }

  /// Verificar si una unidad está activa
  /// 
  /// **Parámetros:**
  /// - [unidadId]: ID de la unidad
  /// 
  /// **Retorna:**
  /// - [Resource<bool>]: true si está activa
  Future<Resource<bool>> isUnitActive(int unidadId) async {
    if (unidadId <= 0) {
      return Error('ID de unidad inválido');
    }

    return await _repository.isUnitActive(unidadId);
  }

  /// Verificar si tiene GPS vehicular activo
  /// 
  /// **Parámetros:**
  /// - [unidadId]: ID de la unidad
  /// 
  /// **Retorna:**
  /// - [Resource<bool>]: true si tiene GPS device
  Future<Resource<bool>> hasGpsDevice(int unidadId) async {
    if (unidadId <= 0) {
      return Error('ID de unidad inválido');
    }

    return await _repository.hasActiveGpsDevice(unidadId);
  }

  /// Obtener lista de unidades inactivas
  /// 
  /// **Parámetros:**
  /// - [minutesThreshold]: Minutos sin señal (default: 60)
  /// 
  /// **Retorna:**
  /// - [Resource<List<int>>]: Lista de IDs de unidades inactivas
  Future<Resource<List<int>>> getInactiveUnits({
    int minutesThreshold = 60,
  }) async {
    if (minutesThreshold <= 0) {
      return Error('El umbral de minutos debe ser mayor a 0');
    }

    return await _repository.getInactiveUnits(
      minutesThreshold: minutesThreshold,
    );
  }

  /// Health check del sistema GPS
  /// 
  /// **Retorna:**
  /// - [Resource<Map<String, dynamic>>]: Estado de salud del sistema
  Future<Resource<Map<String, dynamic>>> healthCheck() async {
    return await _repository.healthCheck();
  }
}