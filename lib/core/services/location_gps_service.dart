// =============================================
// Location GPS Service
// Servicio para obtener ubicación del dispositivo
// =============================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationGpsService {
  
  // Stream de posiciones
  StreamSubscription<Position>? _positionStreamSubscription;
  
  // ==========================================
  // VERIFICAR Y SOLICITAR PERMISOS
  // ==========================================
  
  /// Verificar si los permisos están otorgados
  Future<bool> hasPermissions() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }
  
  /// Solicitar permisos de ubicación
  Future<bool> requestPermissions() async {
    if (kDebugMode) {
      print('📍 [Location Service] Solicitando permisos de ubicación...');
    }

    // Verificar si ya están otorgados
    if (await hasPermissions()) {
      if (kDebugMode) {
        print('✅ [Location Service] Permisos ya otorgados');
      }
      return true;
    }

    // Solicitar permisos
    final status = await Permission.location.request();

    if (status.isGranted) {
      if (kDebugMode) {
        print('✅ [Location Service] Permisos otorgados');
      }
      return true;
    } else if (status.isDenied) {
      if (kDebugMode) {
        print('❌ [Location Service] Permisos denegados');
      }
      return false;
    } else if (status.isPermanentlyDenied) {
      if (kDebugMode) {
        print('❌ [Location Service] Permisos permanentemente denegados');
        print('   Usuario debe ir a configuración');
      }
      // Abrir configuración
      await openAppSettings();
      return false;
    }

    return false;
  }

  /// Verificar si el GPS está habilitado
  Future<bool> isLocationServiceEnabled() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    
    if (!enabled && kDebugMode) {
      print('⚠️ [Location Service] GPS deshabilitado en el dispositivo');
    }
    
    return enabled;
  }

  // ==========================================
  // OBTENER UBICACIÓN
  // ==========================================

  /// Obtener ubicación actual (una sola vez)
  Future<Position?> getCurrentLocation() async {
    try {
      if (kDebugMode) {
        print('📍 [Location Service] Obteniendo ubicación actual...');
      }

      // Verificar permisos
      if (!await hasPermissions()) {
        final granted = await requestPermissions();
        if (!granted) {
          if (kDebugMode) {
            print('❌ [Location Service] No hay permisos');
          }
          return null;
        }
      }

      // Verificar que el GPS esté habilitado
      if (!await isLocationServiceEnabled()) {
        if (kDebugMode) {
          print('❌ [Location Service] GPS deshabilitado');
        }
        return null;
      }

      // ✅ ACTUALIZADO: Usar LocationSettings
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        timeLimit: Duration(seconds: 10),
      );

      // Obtener ubicación
      final position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      if (kDebugMode) {
        print('✅ [Location Service] Ubicación obtenida:');
        print('   Lat: ${position.latitude}');
        print('   Lng: ${position.longitude}');
        print('   Precisión: ${position.accuracy}m');
        print('   Velocidad: ${position.speed} m/s (${metersPerSecondToKmh(position.speed).toStringAsFixed(1)} km/h)');
        print('   Altitud: ${position.altitude}m');
        print('   Rumbo: ${position.heading}°');
      }

      return position;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Location Service] Error obteniendo ubicación: $e');
      }
      return null;
    }
  }

  /// Obtener stream de ubicaciones (tracking continuo)
  Stream<Position> getLocationStream({
    Duration interval = const Duration(seconds: 10),
    int distanceFilter = 10, // metros
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) {
    if (kDebugMode) {
      print('📡 [Location Service] Iniciando stream de ubicaciones');
      print('   Intervalo: ${interval.inSeconds}s');
      print('   Filtro distancia: ${distanceFilter}m');
      print('   Precisión: $accuracy');
    }

    // ✅ ACTUALIZADO: Usar LocationSettings correctamente
    final locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
      timeLimit: interval,
    );

    return Geolocator.getPositionStream(
      locationSettings: locationSettings,
    );
  }

  /// Iniciar escucha de ubicaciones con callback
  void startLocationUpdates({
    required Function(Position) onLocationUpdate,
    required Function(dynamic) onError,
    Duration interval = const Duration(seconds: 10),
    int distanceFilter = 10,
    LocationAccuracy accuracy = LocationAccuracy.high,
  }) {
    if (kDebugMode) {
      print('🎯 [Location Service] Iniciando updates de ubicación');
    }

    // Cancelar suscripción anterior si existe
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;

    try {
      _positionStreamSubscription = getLocationStream(
        interval: interval,
        distanceFilter: distanceFilter,
        accuracy: accuracy,
      ).listen(
        onLocationUpdate,
        onError: (error) {
          if (kDebugMode) {
            print('❌ [Location Service] Error en stream: $error');
          }
          onError(error);
        },
        cancelOnError: false,
        onDone: () {
          if (kDebugMode) {
            print('✅ [Location Service] Stream completado');
          }
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Location Service] Error iniciando stream: $e');
      }
      onError(e);
    }
  }

  /// Detener escucha de ubicaciones
  Future<void> stopLocationUpdates() async {
    if (kDebugMode) {
      print('🛑 [Location Service] Deteniendo updates de ubicación');
    }

    try {
      await _positionStreamSubscription?.cancel();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [Location Service] Error cancelando stream: $e');
      }
    } finally {
      _positionStreamSubscription = null;
    }
  }

  // ==========================================
  // CONFIGURACIONES ESPECÍFICAS POR PLATAFORMA
  // ==========================================

  /// Obtener ubicación con configuración específica de Android
  Future<Position?> getCurrentLocationAndroid({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeLimit = const Duration(seconds: 10),
    bool forceLocationManager = false,
  }) async {
    try {
      final androidSettings = AndroidSettings(
        accuracy: accuracy,
        distanceFilter: 0,
        forceLocationManager: forceLocationManager,
        intervalDuration: timeLimit,
      );

      return await Geolocator.getCurrentPosition(
        locationSettings: androidSettings,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Location Service] Error obteniendo ubicación (Android): $e');
      }
      return null;
    }
  }

  /// Obtener ubicación con configuración específica de iOS
  Future<Position?> getCurrentLocationIOS({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeLimit = const Duration(seconds: 10),
    bool pauseLocationUpdatesAutomatically = false,
  }) async {
    try {
      final appleSettings = AppleSettings(
        accuracy: accuracy,
        distanceFilter: 0,
        timeLimit: timeLimit,
        pauseLocationUpdatesAutomatically: pauseLocationUpdatesAutomatically,
      );

      return await Geolocator.getCurrentPosition(
        locationSettings: appleSettings,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ [Location Service] Error obteniendo ubicación (iOS): $e');
      }
      return null;
    }
  }

  // ==========================================
  // UTILIDADES
  // ==========================================

  /// Calcular distancia entre dos puntos (en metros)
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );
  }

  /// Convertir velocidad de m/s a km/h
  double metersPerSecondToKmh(double metersPerSecond) {
    return metersPerSecond * 3.6;
  }

  /// Convertir velocidad de km/h a m/s
  double kmhToMetersPerSecond(double kmh) {
    return kmh / 3.6;
  }

  /// Formatear coordenadas para display
  String formatCoordinates(double lat, double lng) {
    return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
  }

  /// Obtener estado de precisión
  String getAccuracyLabel(double accuracy) {
    if (accuracy < 10) return 'Excelente';
    if (accuracy < 20) return 'Buena';
    if (accuracy < 50) return 'Regular';
    return 'Baja';
  }

  /// Dispose
  Future<void> dispose() async {
    if (kDebugMode) {
      print('🗑️ [Location Service] Dispose');
    }
    
    try {
      await stopLocationUpdates();
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [Location Service] Error en dispose: $e');
      }
    }
  }
}