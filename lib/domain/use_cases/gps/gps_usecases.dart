// =============================================
// GPS Use Cases - Agrupador
// Agrupa todos los use cases de GPS
// =============================================

import 'package:consumo_combustible/domain/use_cases/gps/send_location_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/gps/get_current_locations_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/gps/subscribe_tracking_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/gps/get_location_history_use_case.dart';
import 'package:consumo_combustible/domain/use_cases/gps/get_tracking_stats_use_case.dart';

/// Agrupador de todos los use cases de GPS
/// 
/// Facilita la inyección de dependencias y el acceso
/// a todos los use cases desde un solo punto
class GpsUseCases {
  // Envío de ubicaciones
  final SendLocationUseCase sendLocation;

  // Obtener ubicaciones actuales
  final GetCurrentLocationsUseCase getCurrentLocations;
  final GetCurrentLocationUseCase getCurrentLocation;

  // Tracking en tiempo real (WebSocket)
  final SubscribeTrackingUseCase subscribeTracking;

  // Historial
  final GetLocationHistoryUseCase getLocationHistory;

  // Estadísticas
  final GetTrackingStatsUseCase getTrackingStats;

  GpsUseCases({
    required this.sendLocation,
    required this.getCurrentLocations,
    required this.getCurrentLocation,
    required this.subscribeTracking,
    required this.getLocationHistory,
    required this.getTrackingStats,
  });
}