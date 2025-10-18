// =============================================
// Get Current Locations Use Case
// Obtener ubicaciones actuales de unidades
// =============================================

import 'package:consumo_combustible/domain/models/gps_location.dart';
import 'package:consumo_combustible/domain/models/unidad_tracking.dart';
import 'package:consumo_combustible/domain/repository/gps_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

/// Use Case para obtener ubicaciones actuales
/// 
/// **Responsabilidades:**
/// - Obtener ubicaciones de múltiples unidades
/// - Permitir filtros (zona, solo activas, proveedor)
/// - Retornar lista organizada con estadísticas
class GetCurrentLocationsUseCase {
  final GpsRepository _repository;

  GetCurrentLocationsUseCase(this._repository);

  /// Ejecutar el use case
  /// 
  /// **Parámetros:**
  /// - [unidadesIds]: Lista de IDs de unidades específicas (opcional)
  /// - [zonaId]: Filtrar por zona (opcional)
  /// - [soloActivas]: Solo unidades con señal reciente (default: false)
  /// - [proveedor]: Filtrar por tipo de proveedor (opcional)
  /// 
  /// **Retorna:**
  /// - [Resource<UnidadesTrackingList>]: Lista de unidades con tracking
  Future<Resource<UnidadesTrackingList>> call({
    List<int>? unidadesIds,
    int? zonaId,
    bool soloActivas = false,
    GpsProviderType? proveedor,
  }) async {
    // Validar parámetros
    if (unidadesIds != null && unidadesIds.isEmpty) {
      return Error('La lista de unidades no puede estar vacía');
    }

    if (zonaId != null && zonaId <= 0) {
      return Error('ID de zona inválido');
    }

    // Obtener del repository
    return await _repository.getCurrentLocations(
      unidadesIds: unidadesIds,
      zonaId: zonaId,
      soloActivas: soloActivas,
      proveedor: proveedor,
    );
  }
}

/// Use Case para obtener ubicación de una sola unidad
class GetCurrentLocationUseCase {
  final GpsRepository _repository;

  GetCurrentLocationUseCase(this._repository);

  /// Ejecutar el use case
  /// 
  /// **Parámetros:**
  /// - [unidadId]: ID de la unidad
  /// 
  /// **Retorna:**
  /// - [Resource<UnidadTracking>]: Unidad con su ubicación actual
  Future<Resource<UnidadTracking>> call(int unidadId) async {
    // Validar
    if (unidadId <= 0) {
      return Error('ID de unidad inválido');
    }

    // Obtener del repository
    return await _repository.getCurrentLocation(unidadId);
  }
}