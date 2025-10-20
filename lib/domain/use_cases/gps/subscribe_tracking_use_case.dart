// =============================================
// Subscribe Tracking Use Case
// Suscribirse a actualizaciones de tracking en tiempo real
// =============================================

import 'package:consumo_combustible/domain/models/unidad_tracking.dart';
import 'package:consumo_combustible/domain/repository/gps_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

/// Use Case para suscribirse a tracking en tiempo real
/// 
/// **Responsabilidades:**
/// - Validar que WebSocket esté conectado
/// - Suscribirse a tracking de unidades (all/zona/específicas)
/// - Exponer stream de ubicaciones
class SubscribeTrackingUseCase {
  final GpsRepository _repository;

  SubscribeTrackingUseCase(this._repository);

  /// Conectar al WebSocket primero (requisito previo)
  /// 
  /// **Parámetros:**
  /// - [token]: Token JWT de autenticación
  /// 
  /// **Retorna:**
  /// - [Resource<void>]: Success si se conectó, Error si falló
  Future<Resource<void>> connect(String token) async {
    if (token.isEmpty) {
      return Error('Token JWT vacío');
    }

    return await _repository.connectWebSocket(token);
  }

  /// Suscribirse a tracking
  ///
  /// **Parámetros:**
  /// - [all]: Suscribirse a todas las unidades (admin)
  /// - [zonaId]: Suscribirse a unidades de una zona
  /// - [unidadesIds]: Suscribirse a unidades específicas
  ///
  /// **Nota:** Solo uno de los parámetros debe estar presente
  ///
  /// **Retorna:**
  /// - [Resource<void>]: Success si se suscribió correctamente, Error si falló
  Future<Resource<void>> subscribe({
    bool all = false,
    int? zonaId,
    List<int>? unidadesIds,
  }) async {
    // Validar que solo haya una opción seleccionada
    final optionsCount = [
      all,
      zonaId != null,
      unidadesIds != null && unidadesIds.isNotEmpty,
    ].where((option) => option).length;

    if (optionsCount == 0) {
      return Error('Debe especificar al menos una opción de suscripción');
    }

    if (optionsCount > 1) {
      return Error('Solo puede especificar una opción de suscripción a la vez');
    }

    // Validar parámetros específicos
    if (zonaId != null && zonaId <= 0) {
      return Error('ID de zona inválido');
    }

    if (unidadesIds != null && unidadesIds.isEmpty) {
      return Error('La lista de unidades no puede estar vacía');
    }

    // Suscribirse y esperar confirmación
    return await _repository.subscribeToTracking(
      all: all,
      zonaId: zonaId,
      unidadesIds: unidadesIds,
    );
  }

  /// Desuscribirse de tracking
  Future<void> unsubscribe({
    bool all = false,
    int? zonaId,
    List<int>? unidadesIds,
  }) async {
    await _repository.unsubscribeFromTracking(
      all: all,
      zonaId: zonaId,
      unidadesIds: unidadesIds,
    );
  }

  /// Suscribirse a una unidad específica
  Future<void> subscribeToUnit(int unidadId) async {
    if (unidadId <= 0) {
      throw Exception('ID de unidad inválido');
    }

    await _repository.subscribeToUnit(unidadId);
  }

  /// Desuscribirse de una unidad específica
  Future<void> unsubscribeFromUnit(int unidadId) async {
    if (unidadId <= 0) {
      throw Exception('ID de unidad inválido');
    }

    await _repository.unsubscribeFromUnit(unidadId);
  }

  /// Desconectar WebSocket
  Future<void> disconnect() async {
    await _repository.disconnectWebSocket();
  }

  /// Verificar si está conectado
  bool isConnected() {
    return _repository.isWebSocketConnected();
  }

  /// Stream de ubicaciones en tiempo real
  Stream<UnidadTracking> get locationUpdates {
    return _repository.locationUpdatesStream;
  }

  /// Stream de estado de conexión
  Stream<bool> get connectionStatus {
    return _repository.connectionStatusStream;
  }

  /// Stream de estado de GPS devices
  Stream<GpsDeviceStatus> get gpsDeviceStatus {
    return _repository.gpsDeviceStatusStream;
  }
}