// =============================================
// GPS BLoC
// Manejo de estado para GPS Tracking
// =============================================

import 'dart:async';
import 'package:consumo_combustible/domain/models/gps_stats.dart';
import 'package:consumo_combustible/domain/models/tracking_status.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:consumo_combustible/domain/models/gps_location.dart';
import 'package:consumo_combustible/domain/models/unidad_tracking.dart';
import 'package:consumo_combustible/domain/use_cases/gps/gps_usecases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

import 'gps_event.dart';
import 'gps_state.dart';

@injectable
class GpsBloc extends Bloc<GpsEvent, GpsState> {
  final GpsUseCases _gpsUseCases;

  // Subscripciones a streams
  StreamSubscription<UnidadTracking>? _locationUpdatesSubscription;
  StreamSubscription<bool>? _connectionStatusSubscription;
  StreamSubscription<dynamic>? _gpsDeviceStatusSubscription;

  // Timer para envío automático de ubicaciones
  Timer? _trackingTimer;
  
  // ✅ CORRECCIÓN: Cache de unidades cargadas para preservarlas
  List<UnidadTracking> _cachedUnidades = [];

  GpsBloc({
    required GpsUseCases gpsUseCases,
  })  : _gpsUseCases = gpsUseCases,
        super(const GpsInitial()) {
    
    // Registrar handlers de eventos
    on<ConnectWebSocketEvent>(_onConnectWebSocket);
    on<DisconnectWebSocketEvent>(_onDisconnectWebSocket);
    on<ReconnectWebSocketEvent>(_onReconnectWebSocket);
    
    on<SubscribeToAllUnitsEvent>(_onSubscribeToAllUnits);
    on<SubscribeToZoneEvent>(_onSubscribeToZone);
    on<SubscribeToUnitsEvent>(_onSubscribeToUnits);
    on<SubscribeToUnitEvent>(_onSubscribeToUnit);
    on<UnsubscribeFromTrackingEvent>(_onUnsubscribeFromTracking);
    
    on<SendLocationEvent>(_onSendLocation);
    on<StartLocationTrackingEvent>(_onStartLocationTracking);
    on<StopLocationTrackingEvent>(_onStopLocationTracking);
    
    on<LoadCurrentLocationsEvent>(_onLoadCurrentLocations);
    on<LoadUnitLocationEvent>(_onLoadUnitLocation);
    on<RefreshLocationsEvent>(_onRefreshLocations);
    
    on<LoadLocationHistoryEvent>(_onLoadLocationHistory);
    on<LoadTodayHistoryEvent>(_onLoadTodayHistory);
    
    on<LoadTrackingStatsEvent>(_onLoadTrackingStats);
    on<LoadUnitStatusEvent>(_onLoadUnitStatus);
    
    on<ClearGpsErrorEvent>(_onClearGpsError);
    on<ResetGpsStateEvent>(_onResetGpsState);

    on<LocationReceivedEvent>(_onLocationReceived);
  on<ConnectionStatusChangedEvent>(_onConnectionStatusChanged);
  }

  // ==========================================
  // WEBSOCKET - CONEXIÓN
  // ==========================================

  // Future<void> _onConnectWebSocket(
  //   ConnectWebSocketEvent event,
  //   Emitter<GpsState> emit,
  // ) async {
  //   try {
  //     if (kDebugMode) {
  //       print('🔌 [GPS BLoC] Conectando al WebSocket...');
  //     }

  //     emit(const GpsConnecting());

  //     // Conectar usando el use case
  //     final result = await _gpsUseCases.subscribeTracking.connect(event.token);

  //     if (result is Success) {
  //       if (kDebugMode) {
  //         print('✅ [GPS BLoC] WebSocket conectado exitosamente');
  //       }

  //       // Escuchar streams del WebSocket
  //       _listenToWebSocketStreams(emit);

  //       emit(GpsConnected(
  //         isSubscribed: false,
  //         connectedAt: DateTime.now(),
  //       ));

  //       // ✅ CORRECCIÓN: Auto-suscribirse si se especifica
  //       if (event.autoSubscribe ?? false) {
  //         if (kDebugMode) {
  //           print('🔄 [GPS BLoC] Auto-suscribiendo después de conexión...');
  //         }
          
  //         // Pequeño delay para asegurar que el socket esté listo
  //         await Future.delayed(const Duration(milliseconds: 500));
          
  //         // Disparar evento de suscripción
  //         add(const SubscribeToAllUnitsEvent());
  //       }
  //     } else if (result is Error) {
  //       if (kDebugMode) {
  //         print('❌ [GPS BLoC] Error conectando: ${result.message}');
  //       }

  //       emit(GpsConnectionError(
  //         message: result.message,
  //         canRetry: true,
  //       ));
  //     }
  //   } catch (e) {
  //     if (kDebugMode) {
  //       print('❌ [GPS BLoC] Excepción conectando: $e');
  //     }

  //     emit(GpsConnectionError(
  //       message: 'Error inesperado al conectar: $e',
  //       canRetry: true,
  //     ));
  //   }
  // }

  Future<void> _onConnectWebSocket(
  ConnectWebSocketEvent event,
  Emitter<GpsState> emit,
) async {
  try {
    if (kDebugMode) {
      print('🔌 [GPS BLoC] Conectando al WebSocket...');
    }

    emit(const GpsConnecting());

    final result = await _gpsUseCases.subscribeTracking.connect(event.token);

    if (result is Success) {
      if (kDebugMode) {
        print('✅ [GPS BLoC] WebSocket conectado exitosamente');
      }

      // ✅ CAMBIO: Ya no pasar el emitter
      _listenToWebSocketStreams();

      emit(GpsConnected(
        isSubscribed: false,
        connectedAt: DateTime.now(),
      ));

      if (event.autoSubscribe!) {
        if (kDebugMode) {
          print('🔄 [GPS BLoC] Auto-suscribiendo...');
        }
        add(const SubscribeToAllUnitsEvent());
      }
    } else if (result is Error) {
      if (kDebugMode) {
        print('❌ [GPS BLoC] Error conectando: ${result.message}');
      }

      emit(GpsConnectionError(
        message: result.message,
        canRetry: true,
      ));
    }
  } catch (e) {
    if (kDebugMode) {
      print('❌ [GPS BLoC] Excepción conectando: $e');
    }

    emit(GpsConnectionError(
      message: 'Error inesperado al conectar: $e',
      canRetry: true,
    ));
  }
}

  /// Desconectar del WebSocket
  Future<void> _onDisconnectWebSocket(
    DisconnectWebSocketEvent event,
    Emitter<GpsState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🔌 [GPS BLoC] Desconectando del WebSocket...');
      }

      // Cancelar subscripciones a streams
      await _cancelStreamSubscriptions();

      // Desconectar
      await _gpsUseCases.subscribeTracking.disconnect();

      if (kDebugMode) {
        print('✅ [GPS BLoC] Desconectado exitosamente');
      }

      emit(const GpsDisconnected(reason: 'Desconexión manual'));
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS BLoC] Error desconectando: $e');
      }

      emit(GpsError(
        message: 'Error al desconectar: $e',
        occurredAt: DateTime.now(),
      ));
    }
  }

  /// Reconectar al WebSocket
  Future<void> _onReconnectWebSocket(
    ReconnectWebSocketEvent event,
    Emitter<GpsState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🔄 [GPS BLoC] Reconectando...');
      }

      emit(const GpsConnecting());

      // Primero desconectar
      await _gpsUseCases.subscribeTracking.disconnect();
      await Future.delayed(const Duration(milliseconds: 500));

      // Intentar reconectar
      // Nota: Necesitamos el token guardado
      // Por ahora mostramos error pidiendo reconexión manual
      emit(const GpsConnectionError(
        message: 'Reconexión manual requerida. Por favor, vuelve a conectar.',
        canRetry: true,
      ));
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS BLoC] Error reconectando: $e');
      }

      emit(GpsConnectionError(
        message: 'Error al reconectar: $e',
        canRetry: true,
      ));
    }
  }

  Future<void> _onLocationReceived(
  LocationReceivedEvent event,
  Emitter<GpsState> emit,
) async {
  final unidadTracking = event.unidadTracking;

  if (kDebugMode) {
    print('📍 [GPS BLoC] Procesando ubicación recibida: ${unidadTracking.placa}');
    print('   Estado actual: ${state.runtimeType}');
  }

  // Actualizar estado con nueva ubicación
  if (state is GpsReceivingUpdates) {
    final currentState = state as GpsReceivingUpdates;
    
    if (kDebugMode) {
      print('   Unidades antes de actualizar: ${currentState.unidades.length}');
      print('   Placas antes: ${currentState.unidades.map((u) => u.placa).join(", ")}');
    }
    
    final newState = currentState.updateUnidad(unidadTracking);
    
    if (kDebugMode) {
      print('   Unidades después de actualizar: ${newState.unidades.length}');
      print('   Placas después: ${newState.unidades.map((u) => u.placa).join(", ")}');
    }
    
    emit(newState);
  } else {
    // Primer ubicación recibida
    if (kDebugMode) {
      print('⚠️ [GPS BLoC] Primera ubicación recibida sin estado previo');
    }
    
    emit(GpsReceivingUpdates(
      unidades: [unidadTracking],
      lastUpdate: DateTime.now(),
      isConnected: true,
      totalUnidades: 1,
    ));
  }
}

Future<void> _onConnectionStatusChanged(
  ConnectionStatusChangedEvent event,
  Emitter<GpsState> emit,
) async {
  final isConnected = event.isConnected;

  if (!isConnected) {
    emit(const GpsDisconnected(reason: 'Conexión perdida'));
  } else if (state is GpsDisconnected) {
    emit(GpsConnected(
      isSubscribed: false,
      connectedAt: DateTime.now(),
    ));
  }

  // Actualizar estado si estamos recibiendo updates
  if (state is GpsReceivingUpdates) {
    final currentState = state as GpsReceivingUpdates;
    emit(currentState.copyWith(isConnected: isConnected));
  }
}

/// Escuchar streams del WebSocket
void _listenToWebSocketStreams() {
  // Stream de ubicaciones en tiempo real
  _locationUpdatesSubscription = 
      _gpsUseCases.subscribeTracking.locationUpdates.listen(
    (unidadTracking) {
      if (kDebugMode) {
        print('📍 [GPS BLoC] Nueva ubicación recibida: ${unidadTracking.placa}');
      }

      // ✅ SOLUCIÓN: Usar add() para disparar un nuevo evento
      // Esto crea un nuevo handler con su propio Emitter
      add(LocationReceivedEvent(unidadTracking));
    },
    onError: (error) {
      if (kDebugMode) {
        print('❌ [GPS BLoC] Error en stream de ubicaciones: $error');
      }
    },
  );

  // Stream de estado de conexión
  _connectionStatusSubscription = 
      _gpsUseCases.subscribeTracking.connectionStatus.listen(
    (isConnected) {
      if (kDebugMode) {
        print('🔌 [GPS BLoC] Estado de conexión: $isConnected');
      }

      // ✅ SOLUCIÓN: Usar add() para disparar un nuevo evento
      add(ConnectionStatusChangedEvent(isConnected));
    },
    onError: (error) {
      if (kDebugMode) {
        print('❌ [GPS BLoC] Error en stream de conexión: $error');
      }
    },
  );

  // Stream de estado de GPS devices
  _gpsDeviceStatusSubscription = 
      _gpsUseCases.subscribeTracking.gpsDeviceStatus.listen(
    (deviceStatus) {
      if (kDebugMode) {
        print('🛰️ [GPS BLoC] GPS Device status: $deviceStatus');
      }
      // Si necesitas emitir estado, usa add() también
      // add(_GpsDeviceStatusChangedEvent(deviceStatus));
    },
    onError: (error) {
      if (kDebugMode) {
        print('❌ [GPS BLoC] Error en stream de GPS device: $error');
      }
    },
  );
}


  /// Cancelar subscripciones a streams
  Future<void> _cancelStreamSubscriptions() async {
    await _locationUpdatesSubscription?.cancel();
    await _connectionStatusSubscription?.cancel();
    await _gpsDeviceStatusSubscription?.cancel();

    _locationUpdatesSubscription = null;
    _connectionStatusSubscription = null;
    _gpsDeviceStatusSubscription = null;
  }

  // ==========================================
  // WEBSOCKET - SUSCRIPCIONES
  // ==========================================

  /// Suscribirse a todas las unidades
  Future<void> _onSubscribeToAllUnits(
    SubscribeToAllUnitsEvent event,
    Emitter<GpsState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('📡 [GPS BLoC] Suscribiendo a todas las unidades...');
        print('   Estado actual antes de suscribir: ${state.runtimeType}');
      }

      // ✅ CRÍTICO: Esperar confirmación del servidor
      final result = await _gpsUseCases.subscribeTracking.subscribe(all: true);

      if (result is Success<void>) {
        if (kDebugMode) {
          print('✅ [GPS BLoC] Suscripción confirmada por el servidor');
        }

        // Actualizar estado de conexión
        if (state is GpsConnected) {
          final currentState = state as GpsConnected;
          emit(currentState.copyWith(isSubscribed: true));
        }

        // ✅ CORRECCIÓN: Usar unidades del caché
        if (kDebugMode) {
          print('📦 [GPS BLoC] Usando unidades del caché: ${_cachedUnidades.length}');
          if (_cachedUnidades.isNotEmpty) {
            print('   Placas: ${_cachedUnidades.map((u) => u.placa).join(", ")}');
          }
        }

        // Inicializar estado de recepción con las unidades del caché
        emit(GpsReceivingUpdates(
          unidades: List.from(_cachedUnidades),
          lastUpdate: DateTime.now(),
          isConnected: true,
          totalUnidades: _cachedUnidades.length,
        ));
      } else if (result is Error<void>) {
        if (kDebugMode) {
          print('❌ [GPS BLoC] Error en suscripción: ${result.message}');
        }

        emit(GpsError(
          message: 'Error al suscribirse: ${result.message}',
          occurredAt: DateTime.now(),
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS BLoC] Excepción suscribiendo: $e');
      }

      emit(GpsError(
        message: 'Error al suscribirse: $e',
        occurredAt: DateTime.now(),
      ));
    }
  }

  /// Suscribirse a unidades de una zona
  Future<void> _onSubscribeToZone(
    SubscribeToZoneEvent event,
    Emitter<GpsState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('📡 [GPS BLoC] Suscribiendo a zona ${event.zonaId}...');
      }

      await _gpsUseCases.subscribeTracking.subscribe(zonaId: event.zonaId);

      if (kDebugMode) {
        print('✅ [GPS BLoC] Suscrito a zona ${event.zonaId}');
      }

      if (state is GpsConnected) {
        final currentState = state as GpsConnected;
        emit(currentState.copyWith(isSubscribed: true));
      }

      emit(GpsReceivingUpdates(
        unidades: const [],
        lastUpdate: DateTime.now(),
        isConnected: true,
        totalUnidades: 0,
      ));
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS BLoC] Error suscribiendo a zona: $e');
      }

      emit(GpsError(
        message: 'Error al suscribirse a la zona: $e',
        occurredAt: DateTime.now(),
      ));
    }
  }

  /// Suscribirse a unidades específicas
  Future<void> _onSubscribeToUnits(
    SubscribeToUnitsEvent event,
    Emitter<GpsState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('📡 [GPS BLoC] Suscribiendo a unidades ${event.unidadesIds}...');
      }

      await _gpsUseCases.subscribeTracking.subscribe(
        unidadesIds: event.unidadesIds,
      );

      if (kDebugMode) {
        print('✅ [GPS BLoC] Suscrito a ${event.unidadesIds.length} unidades');
      }

      if (state is GpsConnected) {
        final currentState = state as GpsConnected;
        emit(currentState.copyWith(isSubscribed: true));
      }

      emit(GpsReceivingUpdates(
        unidades: const [],
        lastUpdate: DateTime.now(),
        isConnected: true,
        totalUnidades: 0,
      ));
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS BLoC] Error suscribiendo a unidades: $e');
      }

      emit(GpsError(
        message: 'Error al suscribirse a las unidades: $e',
        occurredAt: DateTime.now(),
      ));
    }
  }

  /// Suscribirse a una unidad específica
  Future<void> _onSubscribeToUnit(
    SubscribeToUnitEvent event,
    Emitter<GpsState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('📡 [GPS BLoC] Suscribiendo a unidad ${event.unidadId}...');
      }

      await _gpsUseCases.subscribeTracking.subscribeToUnit(event.unidadId);

      if (kDebugMode) {
        print('✅ [GPS BLoC] Suscrito a unidad ${event.unidadId}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS BLoC] Error suscribiendo a unidad: $e');
      }

      emit(GpsError(
        message: 'Error al suscribirse a la unidad: $e',
        occurredAt: DateTime.now(),
      ));
    }
  }

  /// Desuscribirse de tracking
  Future<void> _onUnsubscribeFromTracking(
    UnsubscribeFromTrackingEvent event,
    Emitter<GpsState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('📡 [GPS BLoC] Desuscribiendo de tracking...');
      }

      await _gpsUseCases.subscribeTracking.unsubscribe(
        all: event.all,
        zonaId: event.zonaId,
        unidadesIds: event.unidadesIds,
      );

      if (kDebugMode) {
        print('✅ [GPS BLoC] Desuscrito exitosamente');
      }

      if (state is GpsConnected) {
        final currentState = state as GpsConnected;
        emit(currentState.copyWith(isSubscribed: false));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS BLoC] Error desuscribiendo: $e');
      }
    }
  }

  // ==========================================
  // ENVIAR UBICACIÓN
  // ==========================================

  /// Enviar ubicación GPS (una vez)
  Future<void> _onSendLocation(
    SendLocationEvent event,
    Emitter<GpsState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('📤 [GPS BLoC] Enviando ubicación...');
      }

      emit(const GpsSendingLocation());

      // Enviar usando el use case
      final result = await _gpsUseCases.sendLocation(event.location);

      if (result is Success<GpsLocation>) {
        if (kDebugMode) {
          print('✅ [GPS BLoC] Ubicación enviada exitosamente');
        }

        emit(GpsLocationSent(
          location: result.data,
          sentAt: DateTime.now(),
        ));

        // Si estamos en tracking activo, incrementar contador
        if (state is GpsTrackingActive) {
          final trackingState = state as GpsTrackingActive;
          emit(trackingState.incrementSent());
        }
      } else if (result is Error<GpsLocation>) {
        if (kDebugMode) {
          print('❌ [GPS BLoC] Error enviando ubicación: ${result.message}');
        }

        emit(GpsSendLocationError(
          message: result.message,
          failedLocation: event.location,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS BLoC] Excepción enviando ubicación: $e');
      }

      emit(GpsSendLocationError(
        message: 'Error inesperado: $e',
        failedLocation: event.location,
      ));
    }
  }

  /// Iniciar envío automático de ubicaciones
  Future<void> _onStartLocationTracking(
    StartLocationTrackingEvent event,
    Emitter<GpsState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🎯 [GPS BLoC] Iniciando tracking automático...');
        print('   Unidad: ${event.unidadId}');
        print('   Intervalo: ${event.interval.inSeconds}s');
      }

      // Cancelar timer anterior si existe
      _trackingTimer?.cancel();

      emit(GpsTrackingActive(
        unidadId: event.unidadId,
        startedAt: DateTime.now(),
        locationsSent: 0,
      ));

      // Crear timer para envío periódico
      _trackingTimer = Timer.periodic(event.interval, (timer) async {
        if (kDebugMode) {
          print('⏰ [GPS BLoC] Timer tick - enviando ubicación automática');
        }

        // Aquí deberías obtener la ubicación actual del GPS del dispositivo
        // Por ahora esto es un placeholder
        // En la implementación real, usarías el paquete geolocator
        
        // TODO: Implementar obtención de ubicación real
        // final position = await Geolocator.getCurrentPosition();
        // final location = GpsLocation(
        //   unidadId: event.unidadId,
        //   latitud: position.latitude,
        //   longitud: position.longitude,
        //   ...
        // );
        // add(SendLocationEvent(location));
      });

      if (kDebugMode) {
        print('✅ [GPS BLoC] Tracking automático iniciado');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS BLoC] Error iniciando tracking: $e');
      }

      emit(GpsError(
        message: 'Error al iniciar tracking: $e',
        occurredAt: DateTime.now(),
      ));
    }
  }

  /// Detener envío automático de ubicaciones
  Future<void> _onStopLocationTracking(
    StopLocationTrackingEvent event,
    Emitter<GpsState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🛑 [GPS BLoC] Deteniendo tracking automático...');
      }

      _trackingTimer?.cancel();
      _trackingTimer = null;

      if (kDebugMode) {
        print('✅ [GPS BLoC] Tracking detenido');
      }

      // Volver a estado inicial o conectado
      if (_gpsUseCases.subscribeTracking.isConnected()) {
        emit(GpsConnected(
          isSubscribed: false,
          connectedAt: DateTime.now(),
        ));
      } else {
        emit(const GpsInitial());
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS BLoC] Error deteniendo tracking: $e');
      }
    }
  }

  // ==========================================
  // CONSULTAS REST - UBICACIONES ACTUALES
  // ==========================================

  /// Cargar ubicaciones actuales
  Future<void> _onLoadCurrentLocations(
    LoadCurrentLocationsEvent event,
    Emitter<GpsState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🔍 [GPS BLoC] Cargando ubicaciones actuales...');
        print('   Estado actual: ${state.runtimeType}');
      }

      // ✅ CORRECCIÓN CRÍTICA: Guardar el estado anterior ANTES de emitir loading
      final previousState = state;
      final wasReceivingUpdates = previousState is GpsReceivingUpdates;
      
      if (kDebugMode) {
        print('   ¿Estaba recibiendo updates?: $wasReceivingUpdates');
      }

      // Solo emitir loading si NO estamos recibiendo updates
      if (!wasReceivingUpdates) {
        emit(const GpsLoadingLocations());
      }

      final result = await _gpsUseCases.getCurrentLocations(
        unidadesIds: event.unidadesIds,
        zonaId: event.zonaId,
        soloActivas: event.soloActivas,
        proveedor: event.proveedor,
      );

      if (result is Success<UnidadesTrackingList>) {
        if (kDebugMode) {
          print('✅ [GPS BLoC] Ubicaciones cargadas: ${result.data.total}');
          print('   Unidades REST: ${result.data.data.map((u) => u.placa).join(", ")}');
        }

        // ✅ CORRECCIÓN: Guardar unidades en caché
        _cachedUnidades = result.data.data;
        
        if (kDebugMode) {
          print('💾 [GPS BLoC] Unidades guardadas en caché: ${_cachedUnidades.length}');
        }

        // ✅ CORRECCIÓN CRÍTICA: Si estábamos recibiendo updates, mantener ese estado
        if (wasReceivingUpdates) {
          // Dart ya sabe que previousState es GpsReceivingUpdates por el if
          final currentState = previousState;
          
          if (kDebugMode) {
            print('📦 [GPS BLoC] Manteniendo GpsReceivingUpdates');
            print('   Unidades actuales en estado: ${currentState.unidades.length}');
            print('   Placas actuales: ${currentState.unidades.map((u) => u.placa).join(", ")}');
          }
          
          // Combinar unidades: mantener las del WebSocket y agregar/actualizar con las del REST
          final Map<int, UnidadTracking> unidadesMap = {};
          
          // Primero agregar todas las unidades del REST
          for (var unidad in result.data.data) {
            unidadesMap[unidad.unidadId] = unidad;
          }
          
          // Luego sobrescribir con las del WebSocket (más recientes)
          for (var unidad in currentState.unidades) {
            unidadesMap[unidad.unidadId] = unidad;
          }
          
          if (kDebugMode) {
            print('🔄 [GPS BLoC] Unidades combinadas: ${unidadesMap.length}');
            print('   Placas finales: ${unidadesMap.values.map((u) => u.placa).join(", ")}');
          }
          
          // ✅ MANTENER GpsReceivingUpdates
          emit(GpsReceivingUpdates(
            unidades: unidadesMap.values.toList(),
            lastUpdate: DateTime.now(),
            isConnected: currentState.isConnected,
            totalUnidades: unidadesMap.length,
          ));
        } else {
          // Solo emitir GpsLocationsLoaded si NO estábamos en modo WebSocket
          if (kDebugMode) {
            print('📦 [GPS BLoC] Emitiendo GpsLocationsLoaded (no hay WebSocket activo)');
          }
          emit(GpsLocationsLoaded(
            data: result.data,
            loadedAt: DateTime.now(),
          ));
        }
      } else if (result is Error<UnidadesTrackingList>) {
        if (kDebugMode) {
          print('❌ [GPS BLoC] Error cargando ubicaciones: ${result.message}');
        }

        emit(GpsError(
          message: result.message,
          occurredAt: DateTime.now(),
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS BLoC] Excepción cargando ubicaciones: $e');
      }

      emit(GpsError(
        message: 'Error inesperado: $e',
        occurredAt: DateTime.now(),
      ));
    }
  }

  /// Cargar ubicación de una unidad
  Future<void> _onLoadUnitLocation(
    LoadUnitLocationEvent event,
    Emitter<GpsState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🔍 [GPS BLoC] Cargando ubicación de unidad ${event.unidadId}...');
      }

      emit(const GpsLoadingLocations());

      final result = await _gpsUseCases.getCurrentLocation(event.unidadId);

      if (result is Success<UnidadTracking>) {
        if (kDebugMode) {
          print('✅ [GPS BLoC] Ubicación de unidad cargada: ${result.data.placa}');
        }

        // Convertir a UnidadesTrackingList con un solo elemento
        final list = UnidadesTrackingList(
          data: [result.data],
          total: 1,
          activas: result.data.isActive ? 1 : 0,
          inactivas: result.data.isActive ? 0 : 1,
        );

        emit(GpsLocationsLoaded(
          data: list,
          loadedAt: DateTime.now(),
        ));
      } else if (result is Error<UnidadTracking>) {
        if (kDebugMode) {
          print('❌ [GPS BLoC] Error cargando ubicación: ${result.message}');
        }

        emit(GpsError(
          message: result.message,
          occurredAt: DateTime.now(),
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS BLoC] Excepción cargando ubicación: $e');
      }

      emit(GpsError(
        message: 'Error inesperado: $e',
        occurredAt: DateTime.now(),
      ));
    }
  }

  /// Refrescar ubicaciones actuales
  Future<void> _onRefreshLocations(
    RefreshLocationsEvent event,
    Emitter<GpsState> emit,
  ) async {
    // Reusar el mismo handler que cargar ubicaciones
    add(const LoadCurrentLocationsEvent());
  }

  // ==========================================
  // CONSULTAS REST - HISTORIAL
  // ==========================================

  /// Cargar historial de ubicaciones
  Future<void> _onLoadLocationHistory(
    LoadLocationHistoryEvent event,
    Emitter<GpsState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('📜 [GPS BLoC] Cargando historial...');
      }

      emit(const GpsLoadingHistory());

      final result = await _gpsUseCases.getLocationHistory(
        unidadId: event.unidadId,
        fechaInicio: event.fechaInicio,
        fechaFin: event.fechaFin,
        proveedor: event.proveedor,
        page: event.page,
        pageSize: event.pageSize,
      );

      if (result is Success<List<GpsLocation>>) {
        if (kDebugMode) {
          print('✅ [GPS BLoC] Historial cargado: ${result.data.length} ubicaciones');
        }

        emit(GpsHistoryLoaded(
          locations: result.data,
          unidadId: event.unidadId,
          fechaInicio: event.fechaInicio,
          fechaFin: event.fechaFin,
          loadedAt: DateTime.now(),
        ));
      } else if (result is Error<List<GpsLocation>>) {
        if (kDebugMode) {
          print('❌ [GPS BLoC] Error cargando historial: ${result.message}');
        }

        emit(GpsError(
          message: result.message,
          occurredAt: DateTime.now(),
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS BLoC] Excepción cargando historial: $e');
      }

      emit(GpsError(
        message: 'Error inesperado: $e',
        occurredAt: DateTime.now(),
      ));
    }
  }

  /// Cargar historial del día actual
  Future<void> _onLoadTodayHistory(
    LoadTodayHistoryEvent event,
    Emitter<GpsState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('📜 [GPS BLoC] Cargando historial de hoy...');
      }

      emit(const GpsLoadingHistory());

      final result = await _gpsUseCases.getLocationHistory.getTodayHistory(
        unidadId: event.unidadId,
      );

      if (result is Success<List<GpsLocation>>) {
        if (kDebugMode) {
          print('✅ [GPS BLoC] Historial de hoy cargado: ${result.data.length} ubicaciones');
        }

        final now = DateTime.now();
        final startOfDay = DateTime(now.year, now.month, now.day);

        emit(GpsHistoryLoaded(
          locations: result.data,
          unidadId: event.unidadId,
          fechaInicio: startOfDay,
          fechaFin: now,
          loadedAt: DateTime.now(),
        ));
      } else if (result is Error<List<GpsLocation>>) {
        if (kDebugMode) {
          print('❌ [GPS BLoC] Error cargando historial de hoy: ${result.message}');
        }

        emit(GpsError(
          message: result.message,
          occurredAt: DateTime.now(),
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS BLoC] Excepción cargando historial de hoy: $e');
      }

      emit(GpsError(
        message: 'Error inesperado: $e',
        occurredAt: DateTime.now(),
      ));
    }
  }

  // ==========================================
  // CONSULTAS REST - ESTADÍSTICAS
  // ==========================================

  /// Cargar estadísticas generales
  Future<void> _onLoadTrackingStats(
    LoadTrackingStatsEvent event,
    Emitter<GpsState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('📊 [GPS BLoC] Cargando estadísticas...');
      }

      emit(const GpsLoadingStats());

      final result = await _gpsUseCases.getTrackingStats();

      if (result is Success<GpsStats>) {
        if (kDebugMode) {
          print('✅ [GPS BLoC] Estadísticas cargadas');
        }

        emit(GpsStatsLoaded(
          stats: result.data,
          loadedAt: DateTime.now(),
        ));
      } else if (result is Error<GpsStats>) {
        if (kDebugMode) {
          print('❌ [GPS BLoC] Error cargando estadísticas: ${result.message}');
        }

        emit(GpsError(
          message: result.message,
          occurredAt: DateTime.now(),
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS BLoC] Excepción cargando estadísticas: $e');
      }

      emit(GpsError(
        message: 'Error inesperado: $e',
        occurredAt: DateTime.now(),
      ));
    }
  }

  /// Cargar estado de una unidad
  Future<void> _onLoadUnitStatus(
    LoadUnitStatusEvent event,
    Emitter<GpsState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🔍 [GPS BLoC] Cargando estado de unidad ${event.unidadId}...');
      }

      emit(const GpsLoadingStats());

      final result = await _gpsUseCases.getTrackingStats.getUnitStatus(
        event.unidadId,
      );

      if (result is Success<TrackingStatus>) {
        if (kDebugMode) {
          print('✅ [GPS BLoC] Estado de unidad cargado');
        }

        emit(GpsUnitStatusLoaded(
          status: result.data,
          loadedAt: DateTime.now(),
        ));
      } else if (result is Error<TrackingStatus>) {
        if (kDebugMode) {
          print('❌ [GPS BLoC] Error cargando estado: ${result.message}');
        }

        emit(GpsError(
          message: result.message,
          occurredAt: DateTime.now(),
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS BLoC] Excepción cargando estado: $e');
      }

      emit(GpsError(
        message: 'Error inesperado: $e',
        occurredAt: DateTime.now(),
      ));
    }
  }

  // ==========================================
  // UTILIDADES
  // ==========================================

  /// Limpiar errores
  Future<void> _onClearGpsError(
    ClearGpsErrorEvent event,
    Emitter<GpsState> emit,
  ) async {
    if (kDebugMode) {
      print('🧹 [GPS BLoC] Limpiando error...');
    }

    // Volver al estado anterior o inicial
    if (_gpsUseCases.subscribeTracking.isConnected()) {
      emit(GpsConnected(
        isSubscribed: false,
        connectedAt: DateTime.now(),
      ));
    } else {
      emit(const GpsInitial());
    }
  }

  /// Reset completo del state
  Future<void> _onResetGpsState(
    ResetGpsStateEvent event,
    Emitter<GpsState> emit,
  ) async {
    if (kDebugMode) {
      print('🔄 [GPS BLoC] Reseteando estado...');
    }

    // Cancelar tracking si está activo
    _trackingTimer?.cancel();
    _trackingTimer = null;

    // Cancelar subscripciones
    await _cancelStreamSubscriptions();

    // Desconectar WebSocket si está conectado
    if (_gpsUseCases.subscribeTracking.isConnected()) {
      await _gpsUseCases.subscribeTracking.disconnect();
    }

    emit(const GpsInitial());
  }

  // ==========================================
  // DISPOSE
  // ==========================================

  @override
  Future<void> close() async {
    if (kDebugMode) {
      print('🗑️ [GPS BLoC] Dispose - Limpiando recursos...');
    }

    // Cancelar timer
    _trackingTimer?.cancel();

    // Cancelar subscripciones a streams
    await _cancelStreamSubscriptions();

    // Desconectar WebSocket
    try {
      if (_gpsUseCases.subscribeTracking.isConnected()) {
        await _gpsUseCases.subscribeTracking.disconnect();
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ [GPS BLoC] Error desconectando en dispose: $e');
      }
    }

    if (kDebugMode) {
      print('✅ [GPS BLoC] Dispose completado');
    }

    return super.close();
  }
}