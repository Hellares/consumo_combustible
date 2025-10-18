// =============================================
// Get Location History Use Case
// Obtener historial de ubicaciones
// =============================================

import 'package:consumo_combustible/domain/models/gps_location.dart';
import 'package:consumo_combustible/domain/repository/gps_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

/// Use Case para obtener historial de ubicaciones
/// 
/// **Responsabilidades:**
/// - Validar parámetros de búsqueda
/// - Obtener historial paginado
/// - Filtrar por unidad, fechas, proveedor
class GetLocationHistoryUseCase {
  final GpsRepository _repository;

  GetLocationHistoryUseCase(this._repository);

  /// Ejecutar el use case
  /// 
  /// **Parámetros:**
  /// - [unidadId]: ID de la unidad (opcional)
  /// - [fechaInicio]: Fecha de inicio (opcional)
  /// - [fechaFin]: Fecha de fin (opcional)
  /// - [proveedor]: Filtrar por proveedor (opcional)
  /// - [page]: Número de página (default: 1)
  /// - [pageSize]: Elementos por página (default: 50, max: 100)
  /// 
  /// **Retorna:**
  /// - [Resource<List<GpsLocation>>]: Lista de ubicaciones históricas
  Future<Resource<List<GpsLocation>>> call({
    int? unidadId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    GpsProviderType? proveedor,
    int page = 1,
    int pageSize = 50,
  }) async {
    // Validar parámetros
    final validation = _validateParams(
      unidadId: unidadId,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      page: page,
      pageSize: pageSize,
    );

    if (validation != null) {
      return Error(validation);
    }

    // Obtener del repository
    return await _repository.getLocationHistory(
      unidadId: unidadId,
      fechaInicio: fechaInicio,
      fechaFin: fechaFin,
      proveedor: proveedor,
      page: page,
      pageSize: pageSize,
    );
  }

  /// Validar parámetros de búsqueda
  String? _validateParams({
    int? unidadId,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    required int page,
    required int pageSize,
  }) {
    // Validar unidad ID
    if (unidadId != null && unidadId <= 0) {
      return 'ID de unidad inválido';
    }

    // Validar fechas
    if (fechaInicio != null && fechaFin != null) {
      if (fechaInicio.isAfter(fechaFin)) {
        return 'La fecha de inicio no puede ser posterior a la fecha de fin';
      }

      // Validar que no sea más de 1 año de diferencia
      final diff = fechaFin.difference(fechaInicio);
      if (diff.inDays > 365) {
        return 'El rango de fechas no puede ser mayor a 1 año';
      }
    }

    // Validar que las fechas no sean futuras
    if (fechaInicio != null && fechaInicio.isAfter(DateTime.now())) {
      return 'La fecha de inicio no puede ser futura';
    }

    if (fechaFin != null && fechaFin.isAfter(DateTime.now())) {
      return 'La fecha de fin no puede ser futura';
    }

    // Validar paginación
    if (page < 1) {
      return 'El número de página debe ser mayor a 0';
    }

    if (pageSize < 1 || pageSize > 100) {
      return 'El tamaño de página debe estar entre 1 y 100';
    }

    return null; // Validación OK
  }

  /// Obtener historial del día actual
  Future<Resource<List<GpsLocation>>> getTodayHistory({
    required int unidadId,
    GpsProviderType? proveedor,
  }) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return await call(
      unidadId: unidadId,
      fechaInicio: startOfDay,
      fechaFin: endOfDay,
      proveedor: proveedor,
      pageSize: 100,
    );
  }

  /// Obtener historial de la última semana
  Future<Resource<List<GpsLocation>>> getLastWeekHistory({
    required int unidadId,
    GpsProviderType? proveedor,
  }) async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(const Duration(days: 7));

    return await call(
      unidadId: unidadId,
      fechaInicio: startOfWeek,
      fechaFin: now,
      proveedor: proveedor,
      pageSize: 100,
    );
  }

  /// Obtener historial del último mes
  Future<Resource<List<GpsLocation>>> getLastMonthHistory({
    required int unidadId,
    GpsProviderType? proveedor,
  }) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month - 1, now.day);

    return await call(
      unidadId: unidadId,
      fechaInicio: startOfMonth,
      fechaFin: now,
      proveedor: proveedor,
      pageSize: 100,
    );
  }
}