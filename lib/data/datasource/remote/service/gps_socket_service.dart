import 'dart:async';
import 'package:consumo_combustible/domain/models/gps_location.dart';
import 'package:consumo_combustible/domain/models/tracking_status.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:consumo_combustible/domain/models/unidad_tracking.dart';
import 'package:consumo_combustible/domain/repository/gps_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GpsSocketService {
  // Socket.IO client
  io.Socket? _socket;

  // Configuración
  final String baseUrl;
  static const String _namespace = '/gps';

  // Estado de conexión
  bool _isConnected = false;
  bool _isSubscribed = false;
  bool _isAuthenticated = false; // ✅ NUEVO: Estado de autenticación
  String? _currentToken;

  // Streams Controllers
  final _locationUpdatesController = StreamController<UnidadTracking>.broadcast();
  final _connectionStatusController = StreamController<bool>.broadcast();
  final _gpsDeviceStatusController = StreamController<GpsDeviceStatus>.broadcast();
  final _subscriptionStatusController = StreamController<bool>.broadcast();

  // ✅ NUEVO: Completers para sincronización
  Completer<void>? _subscriptionCompleter;
  Completer<void>? _authenticationCompleter; // ✅ NUEVO: Para esperar autenticación

  // Getters para streams
  Stream<UnidadTracking> get locationUpdatesStream => 
      _locationUpdatesController.stream;
  
  Stream<bool> get connectionStatusStream => 
      _connectionStatusController.stream;
  
  Stream<GpsDeviceStatus> get gpsDeviceStatusStream => 
      _gpsDeviceStatusController.stream;

  // ✅ NUEVO: Stream de estado de suscripción
  Stream<bool> get subscriptionStatusStream =>
      _subscriptionStatusController.stream;

  bool get isConnected => _isConnected;
  bool get isSubscribed => _isSubscribed; // ✅ NUEVO

  GpsSocketService({required this.baseUrl}) {
    if (kDebugMode) {
      print('🌐 [GPS Socket] Configurado con URL: $baseUrl');
      print('   Namespace: $_namespace');
      print('   Full URL: $baseUrl$_namespace');
    }
  }

  // ==========================================
  // CONEXIÓN Y DESCONEXIÓN
  // ==========================================

  /// Conectar al WebSocket
  Future<Resource<void>> connect(String token) async {
    try {
      if (_isConnected && _socket != null) {
        if (kDebugMode) {
          print('ℹ️ [GPS Socket] Ya está conectado');
        }
        return Success(null);
      }

      if (kDebugMode) {
        print('🔌 [GPS Socket] Conectando a $baseUrl$_namespace...');
      }

      _currentToken = token;

      // Configurar opciones del socket
      _socket = io.io(
        '$baseUrl$_namespace',
        io.OptionBuilder()
            .setTransports(['websocket', 'polling']) // ✅ Cambiado: Ambos transportes
            .enableAutoConnect()
            .enableReconnection()
            .setReconnectionAttempts(5)
            .setReconnectionDelay(2000)
            .setReconnectionDelayMax(10000)
            .setPath('/socket.io')
            // Autenticación JWT
            .setAuth({
              'token': token,
            })
            .setExtraHeaders({
              'Authorization': 'Bearer $token',
            })
            // Query params (alternativa)
            .setQuery({
              'token': token,
            })
            .build(),
      );

      // ✅ IMPORTANTE: Configurar listeners ANTES de conectar
      _setupSocketListeners();

      // Conectar
      _socket!.connect();

      // Esperar confirmación de conexión (timeout 10 segundos)
      await _waitForConnection(timeout: const Duration(seconds: 10));

      if (_isConnected) {
        if (kDebugMode) {
          print('✅ [GPS Socket] Conectado exitosamente');
        }
        return Success(null);
      } else {
        if (kDebugMode) {
          print('❌ [GPS Socket] Timeout esperando conexión');
        }
        return Error('Timeout: No se pudo conectar al servidor');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS Socket] Error conectando: $e');
      }
      _isConnected = false;
      _connectionStatusController.add(false);
      return Error('Error al conectar: $e');
    }
  }

  /// Esperar a que se establezca la conexión
  Future<void> _waitForConnection({
    required Duration timeout,
  }) async {
    final completer = Completer<void>();
    Timer? timeoutTimer;

    // Listener temporal para detectar conexión
    void onConnect(dynamic data) {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    _socket?.on('connect', onConnect);

    // Timer de timeout
    timeoutTimer = Timer(timeout, () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    // Esperar
    await completer.future;

    // Limpiar
    _socket?.off('connect', onConnect);
    timeoutTimer.cancel();
  }

  /// Desconectar del WebSocket
  Future<void> disconnect() async {
    try {
      if (kDebugMode) {
        print('🔌 [GPS Socket] Desconectando...');
      }

      // ✅ Resetear estados
      _isSubscribed = false;
      _isAuthenticated = false;
      _subscriptionStatusController.add(false);
      _subscriptionCompleter = null;
      _authenticationCompleter = null;

      _socket?.disconnect();
      _socket?.dispose();
      _socket = null;

      _isConnected = false;
      _currentToken = null;
      _connectionStatusController.add(false);

      if (kDebugMode) {
        print('✅ [GPS Socket] Desconectado');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS Socket] Error desconectando: $e');
      }
    }
  }

  /// Reconectar con el mismo token
  Future<Resource<void>> reconnect() async {
    if (_currentToken == null) {
      return Error('No hay token guardado para reconectar');
    }

    if (kDebugMode) {
      print('🔄 [GPS Socket] Reconectando...');
    }

    await disconnect();
    await Future.delayed(const Duration(milliseconds: 500));
    return await connect(_currentToken!);
  }

  // ==========================================
  // CONFIGURACIÓN DE LISTENERS
  // ==========================================

  /// Configurar todos los event listeners del socket
  void _setupSocketListeners() {
    if (_socket == null) return;

    // Conexión exitosa
    _socket!.onConnect((_) {
      if (kDebugMode) {
        print('✅ [GPS Socket] Conectado - Socket ID: ${_socket!.id}');
      }
      _isConnected = true;
      _connectionStatusController.add(true);
    });

    // Desconexión
    _socket!.onDisconnect((reason) {
      if (kDebugMode) {
        print('❌ [GPS Socket] Desconectado - Razón: $reason');
      }
      _isConnected = false;
      _isSubscribed = false;
      _isAuthenticated = false; // ✅ Resetear autenticación
      _connectionStatusController.add(false);
      _subscriptionStatusController.add(false);
    });

    // Error de conexión
    _socket!.onConnectError((error) {
      if (kDebugMode) {
        print('❌ [GPS Socket] Error de conexión: $error');
      }
      _isConnected = false;
      _connectionStatusController.add(false);
    });

    // Error general
    _socket!.onError((error) {
      if (kDebugMode) {
        print('❌ [GPS Socket] Error: $error');
      }
    });

    // Reconexión exitosa
    _socket!.onReconnect((attemptNumber) {
      if (kDebugMode) {
        print('🔄 [GPS Socket] Reconectado exitosamente (intento $attemptNumber)');
      }
      _isConnected = true;
      _connectionStatusController.add(true);
      // ✅ Resetear estados al reconectar
      _isSubscribed = false;
      _isAuthenticated = false;
      _subscriptionStatusController.add(false);
    });

    // Intentando reconectar
    _socket!.on('reconnect_attempt', (attemptNumber) {
      if (kDebugMode) {
        print('🔄 [GPS Socket] Intentando reconectar... (intento $attemptNumber)');
      }
    });

    // Error al reconectar
    _socket!.on('reconnect_error', (error) {
      if (kDebugMode) {
        print('❌ [GPS Socket] Error al reconectar: $error');
      }
    });

    // Reconexión fallida (se agotaron intentos)
    _socket!.on('reconnect_failed', (_) {
      if (kDebugMode) {
        print('❌ [GPS Socket] Reconexión fallida - Agotados los intentos');
      }
      _isConnected = false;
      _connectionStatusController.add(false);
    });

    // Ping/Pong (opcional, para monitoreo)
    _socket!.on('ping', (_) {
      if (kDebugMode) {
        print('🏓 [GPS Socket] Ping recibido del servidor');
      }
    });

    _socket!.on('pong', (latency) {
      if (kDebugMode) {
        print('🏓 [GPS Socket] Pong - Latencia: ${latency}ms');
      }
    });

    // ✅ NUEVO: Evento de autenticación completada
    _socket!.on('authenticated', (data) {
      if (kDebugMode) {
        print('✅ [GPS Socket] Autenticación completada');
        print('   Data: $data');
      }
      
      _isAuthenticated = true;
      
      // Completar el Future si está esperando
      if (_authenticationCompleter != null && !_authenticationCompleter!.isCompleted) {
        _authenticationCompleter!.complete();
        if (kDebugMode) {
          print('✅ [GPS Socket] Completer de autenticación completado');
        }
      }
    });

    // Confirmación de conexión del servidor (fallback)
    _socket!.on('connection:status', (data) {
      if (kDebugMode) {
        print('📡 [GPS Socket] Estado de conexión: $data');
      }
      
      // ✅ Usar como fallback si no hay evento 'authenticated'
      if (data != null && data is Map) {
        final connected = data['connected'] as bool?;
        final userId = data['userId'];
        
        if (connected == true && userId != null && !_isAuthenticated) {
          if (kDebugMode) {
            print('✅ [GPS Socket] Autenticación detectada via connection:status');
          }
          _isAuthenticated = true;
          
          if (_authenticationCompleter != null && !_authenticationCompleter!.isCompleted) {
            _authenticationCompleter!.complete();
          }
        }
      }
    });

    // Configurar eventos GPS
    _setupGpsEventListeners();
  }

  /// ✅ NUEVO: Esperar a que se complete la autenticación
  Future<void> _waitForAuthentication({
    required Duration timeout,
  }) async {
    if (_isAuthenticated) {
      if (kDebugMode) {
        print('✅ [GPS Socket] Ya autenticado');
      }
      return;
    }

    if (kDebugMode) {
      print('⏳ [GPS Socket] Esperando autenticación del servidor...');
    }

    _authenticationCompleter = Completer<void>();

    try {
      await _authenticationCompleter!.future.timeout(
        timeout,
        onTimeout: () {
          if (kDebugMode) {
            print('⚠️ [GPS Socket] Timeout esperando autenticación');
          }
          throw TimeoutException('Timeout esperando autenticación del servidor');
        },
      );

      if (kDebugMode) {
        print('✅ [GPS Socket] Autenticación confirmada');
      }
    } finally {
      _authenticationCompleter = null;
    }
  }

  // ==========================================
  // EVENTOS GPS DEL SERVIDOR
  // ==========================================

  /// Configurar listeners para eventos GPS
  void _setupGpsEventListeners() {
    if (_socket == null) return;

    // === EVENTOS DE UBICACIONES ===

    // Broadcast de nueva ubicación
    _socket!.on('location:broadcast', (data) {
      try {
        if (kDebugMode) {
          print('📍 [GPS Socket] location:broadcast recibido');
        }

        if (data == null) {
          if (kDebugMode) {
            print('⚠️ [GPS Socket] location:broadcast sin datos');
          }
          return;
        }

        // Parsear datos
        final Map<String, dynamic> jsonData = data is Map<String, dynamic>
            ? data
            : Map<String, dynamic>.from(data as Map);

        // Crear UnidadTracking desde el broadcast
        final unidadTracking = _parseLocationBroadcast(jsonData);

        if (unidadTracking != null) {
          // Emitir al stream
          _locationUpdatesController.add(unidadTracking);

          if (kDebugMode) {
            print('✅ [GPS Socket] Ubicación emitida: ${unidadTracking.placa}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ [GPS Socket] Error parseando location:broadcast: $e');
        }
      }
    });

    // Confirmación de ubicación enviada (ACK)
    _socket!.on('location:ack', (data) {
      if (kDebugMode) {
        print('✅ [GPS Socket] location:ack: $data');
      }
    });

    // === EVENTOS DE ESTADO ===

    // Actualización de estado de unidad
    _socket!.on('status:update', (data) {
      try {
        if (kDebugMode) {
          print('📊 [GPS Socket] status:update recibido');
        }

        if (data != null) {
          final Map<String, dynamic> jsonData = data is Map<String, dynamic>
              ? data
              : Map<String, dynamic>.from(data as Map);

          if (kDebugMode) {
            print('   Unidad: ${jsonData['unidadId']}, isOnline: ${jsonData['status']?['isOnline']}');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ [GPS Socket] Error parseando status:update: $e');
        }
      }
    });

    // === EVENTOS DE UNIDADES ===

    // Unidad conectada
    _socket!.on('unit:online', (data) {
      if (kDebugMode) {
        print('🟢 [GPS Socket] unit:online: $data');
      }
    });

    // Unidad desconectada
    _socket!.on('unit:offline', (data) {
      if (kDebugMode) {
        print('🔴 [GPS Socket] unit:offline: $data');
      }
    });

    // === EVENTOS DE GPS DEVICE ===

    // GPS Device activo
    _socket!.on('gps:device:active', (data) {
      try {
        if (kDebugMode) {
          print('🛰️ [GPS Socket] gps:device:active recibido');
        }

        if (data != null) {
          final Map<String, dynamic> jsonData = data is Map<String, dynamic>
              ? data
              : Map<String, dynamic>.from(data as Map);

          final status = GpsDeviceStatus.fromJson(jsonData);
          _gpsDeviceStatusController.add(status);

          if (kDebugMode) {
            print('   Unidad ${status.unidadId}: GPS Device ACTIVO');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ [GPS Socket] Error parseando gps:device:active: $e');
        }
      }
    });

    // GPS Device inactivo
    _socket!.on('gps:device:inactive', (data) {
      try {
        if (kDebugMode) {
          print('🔵 [GPS Socket] gps:device:inactive recibido');
        }

        if (data != null) {
          final Map<String, dynamic> jsonData = data is Map<String, dynamic>
              ? data
              : Map<String, dynamic>.from(data as Map);

          final status = GpsDeviceStatus.fromJson(jsonData);
          _gpsDeviceStatusController.add(status);

          if (kDebugMode) {
            print('   Unidad ${status.unidadId}: GPS Device INACTIVO');
          }
        }
      } catch (e) {
        if (kDebugMode) {
          print('❌ [GPS Socket] Error parseando gps:device:inactive: $e');
        }
      }
    });

    // === EVENTOS DE CONFIRMACIÓN ===

    // ✅ CRÍTICO: Suscripción exitosa
    _socket!.on('tracking:subscribed', (data) {
      if (kDebugMode) {
        print('✅ [GPS Socket] tracking:subscribed recibido');
        print('   Data: $data');
      }

      // ✅ Actualizar estado
      _isSubscribed = true;
      _subscriptionStatusController.add(true);

      // ✅ Completar el Future si está esperando
      if (_subscriptionCompleter != null && !_subscriptionCompleter!.isCompleted) {
        _subscriptionCompleter!.complete();
        if (kDebugMode) {
          print('✅ [GPS Socket] Completer de suscripción completado');
        }
      }
    });

    // Desuscripción exitosa
    _socket!.on('tracking:unsubscribed', (data) {
      if (kDebugMode) {
        print('✅ [GPS Socket] tracking:unsubscribed: $data');
      }
      _isSubscribed = false;
      _subscriptionStatusController.add(false);
    });

    // === EVENTOS DE ERROR ===

    // Error general
    _socket!.on('error', (data) {
      if (kDebugMode) {
        print('❌ [GPS Socket] error: $data');
      }

      // ✅ Si hay error durante suscripción, completar con error
      if (_subscriptionCompleter != null && !_subscriptionCompleter!.isCompleted) {
        _subscriptionCompleter!.completeError(data ?? 'Error desconocido');
      }

      if (data != null) {
        try {
          final Map<String, dynamic> jsonData = data is Map<String, dynamic>
              ? data
              : Map<String, dynamic>.from(data as Map);

          final event = jsonData['event'];
          final message = jsonData['message'];
          final code = jsonData['code'];

          if (kDebugMode) {
            print('   Event: $event, Message: $message, Code: $code');
          }
        } catch (e) {
          if (kDebugMode) {
            print('   Error parseando error event: $e');
          }
        }
      }
    });
  }

  // ==========================================
  // PARSERS AUXILIARES
  // ==========================================

  /// Parsear broadcast de ubicación a UnidadTracking
  UnidadTracking? _parseLocationBroadcast(Map<String, dynamic> data) {
    try {
      final unidadId = data['unidadId'] as int?;
      final placa = data['placa'] as String?;
      final locationData = data['location'] as Map<String, dynamic>?;
      final conductorData = data['conductor'] as Map<String, dynamic>?;

      if (unidadId == null || placa == null || locationData == null) {
        if (kDebugMode) {
          print('⚠️ [GPS Socket] Datos incompletos en location:broadcast');
        }
        return null;
      }

      final location = _parseGpsLocation(locationData);
      final conductor = conductorData != null 
          ? ConductorInfo.fromJson(conductorData)
          : null;

      final tiempoTranscurrido = location != null
          ? DateTime.now().difference(location.fechaHora).inSeconds
          : 0;

      UnitMovementStatus estado;
      if (location?.velocidad != null && location!.velocidad! > 5) {
        estado = UnitMovementStatus.activo;
      } else if (location != null) {
        estado = UnitMovementStatus.detenido;
      } else {
        estado = UnitMovementStatus.inactivo;
      }

      return UnidadTracking(
        unidadId: unidadId,
        placa: placa,
        ultimaUbicacion: location,
        tiempoTranscurrido: tiempoTranscurrido,
        estado: estado,
        conductor: conductor,
      );
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS Socket] Error parseando UnidadTracking: $e');
      }
      return null;
    }
  }

  /// Parsear datos de GpsLocation
  GpsLocation? _parseGpsLocation(Map<String, dynamic> data) {
    try {
      return GpsLocation.fromJson(data);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS Socket] Error parseando GpsLocation: $e');
      }
      return null;
    }
  }

  // ==========================================
  // ENVIAR UBICACIÓN POR WEBSOCKET
  // ==========================================

  /// Enviar ubicación GPS por WebSocket (más eficiente que REST)
  Future<void> sendLocation(GpsLocation location) async {
    if (!_isConnected || _socket == null) {
      if (kDebugMode) {
        print('⚠️ [GPS Socket] No conectado, no se puede enviar ubicación');
      }
      throw Exception('WebSocket no conectado');
    }

    try {
      if (kDebugMode) {
        print('📤 [GPS Socket] Enviando ubicación: Unidad ${location.unidadId}');
      }

      _socket!.emit('location:update', location.toJson());

      if (kDebugMode) {
        print('✅ [GPS Socket] Ubicación enviada');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS Socket] Error enviando ubicación: $e');
      }
      rethrow;
    }
  }

  // ==========================================
  // SUSCRIPCIONES A TRACKING - MEJORADO ✅
  // ==========================================

  /// Suscribirse a actualizaciones de tracking CON CONFIRMACIÓN
  Future<Resource<void>> subscribeToTracking({
    List<int>? unidadesIds,
    int? zonaId,
    bool all = false,
    Duration authTimeout = const Duration(seconds: 5),
    Duration subscriptionTimeout = const Duration(seconds: 5),
  }) async {
    if (!_isConnected || _socket == null) {
      if (kDebugMode) {
        print('⚠️ [GPS Socket] No conectado para suscribirse');
      }
      return Error('WebSocket no conectado');
    }

    try {
      // ✅ PASO 1: Esperar autenticación del servidor
      if (!_isAuthenticated) {
        if (kDebugMode) {
          print('⏳ [GPS Socket] Esperando autenticación antes de suscribirse...');
        }
        
        try {
          await _waitForAuthentication(timeout: authTimeout);
        } catch (e) {
          if (kDebugMode) {
            print('❌ [GPS Socket] Error esperando autenticación: $e');
          }
          return Error('Timeout esperando autenticación del servidor');
        }
      }

      // ✅ PASO 2: Suscribirse al tracking
      if (kDebugMode) {
        print('📡 [GPS Socket] Suscribiendo a tracking...');
      }

      _subscriptionCompleter = Completer<void>();

      final payload = <String, dynamic>{};

      if (all) {
        payload['all'] = true;
      }

      if (zonaId != null) {
        payload['zonaId'] = zonaId;
      }

      if (unidadesIds != null && unidadesIds.isNotEmpty) {
        payload['unidadesIds'] = unidadesIds;
      }

      // Emitir evento de suscripción
      _socket!.emit('tracking:subscribe', payload);

      if (kDebugMode) {
        print('📤 [GPS Socket] Solicitud de suscripción enviada');
        if (all) print('   - Modo: TODAS las unidades');
        if (zonaId != null) print('   - Zona: $zonaId');
        if (unidadesIds != null) print('   - Unidades: $unidadesIds');
      }

      // ✅ PASO 3: Esperar confirmación de suscripción
      await _subscriptionCompleter!.future.timeout(
        subscriptionTimeout,
        onTimeout: () {
          throw TimeoutException('Timeout esperando confirmación de suscripción');
        },
      );

      if (kDebugMode) {
        print('✅ [GPS Socket] Suscripción confirmada por el servidor');
      }

      return Success(null);
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS Socket] Error suscribiendo: $e');
      }
      _isSubscribed = false;
      _subscriptionStatusController.add(false);
      return Error('Error al suscribirse: $e');
    } finally {
      _subscriptionCompleter = null;
    }
  }

  /// Desuscribirse de actualizaciones de tracking
  Future<void> unsubscribeFromTracking({
    List<int>? unidadesIds,
    int? zonaId,
    bool all = false,
  }) async {
    if (!_isConnected || _socket == null) {
      if (kDebugMode) {
        print('⚠️ [GPS Socket] No conectado para desuscribirse');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('📡 [GPS Socket] Desuscribiendo de tracking...');
      }

      final payload = <String, dynamic>{};

      if (all) {
        payload['all'] = true;
      }

      if (zonaId != null) {
        payload['zonaId'] = zonaId;
      }

      if (unidadesIds != null && unidadesIds.isNotEmpty) {
        payload['unidadesIds'] = unidadesIds;
      }

      _socket!.emit('tracking:unsubscribe', payload);

      // ✅ Actualizar estado local
      _isSubscribed = false;
      _subscriptionStatusController.add(false);

      if (kDebugMode) {
        print('✅ [GPS Socket] Solicitud de desuscripción enviada');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS Socket] Error desuscribiendo: $e');
      }
    }
  }

  /// Suscribirse a una unidad específica
  Future<void> subscribeToUnit(int unidadId) async {
    if (!_isConnected || _socket == null) {
      if (kDebugMode) {
        print('⚠️ [GPS Socket] No conectado para suscribirse a unidad');
      }
      throw Exception('WebSocket no conectado');
    }

    try {
      if (kDebugMode) {
        print('📡 [GPS Socket] Suscribiendo a unidad $unidadId...');
      }

      _socket!.emit('unit:subscribe', {
        'unidadId': unidadId,
      });

      if (kDebugMode) {
        print('✅ [GPS Socket] Suscrito a unidad $unidadId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS Socket] Error suscribiendo a unidad: $e');
      }
      rethrow;
    }
  }

  /// Desuscribirse de una unidad específica
  Future<void> unsubscribeFromUnit(int unidadId) async {
    if (!_isConnected || _socket == null) {
      if (kDebugMode) {
        print('⚠️ [GPS Socket] No conectado para desuscribirse de unidad');
      }
      return;
    }

    try {
      if (kDebugMode) {
        print('📡 [GPS Socket] Desuscribiendo de unidad $unidadId...');
      }

      _socket!.emit('unit:unsubscribe', {
        'unidadId': unidadId,
      });

      if (kDebugMode) {
        print('✅ [GPS Socket] Desuscrito de unidad $unidadId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS Socket] Error desuscribiendo de unidad: $e');
      }
    }
  }

  /// Solicitar estado actual de una unidad
  Future<void> requestUnitStatus(int unidadId) async {
    if (!_isConnected || _socket == null) {
      if (kDebugMode) {
        print('⚠️ [GPS Socket] No conectado para solicitar estado');
      }
      throw Exception('WebSocket no conectado');
    }

    try {
      if (kDebugMode) {
        print('📡 [GPS Socket] Solicitando estado de unidad $unidadId...');
      }

      _socket!.emit('status:request', {
        'unidadId': unidadId,
      });

      if (kDebugMode) {
        print('✅ [GPS Socket] Solicitud de estado enviada');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [GPS Socket] Error solicitando estado: $e');
      }
      rethrow;
    }
  }

  // ==========================================
  // MÉTODOS AUXILIARES
  // ==========================================

  /// Verificar si está conectado (para uso externo)
  bool isWebSocketConnected() {
    return _isConnected && _socket != null && _socket!.connected;
  }

  /// Obtener información de conexión
  Map<String, dynamic> getConnectionInfo() {
    return {
      'isConnected': _isConnected,
      'isAuthenticated': _isAuthenticated, // ✅ NUEVO
      'isSubscribed': _isSubscribed,
      'hasSocket': _socket != null,
      'socketConnected': _socket?.connected ?? false,
      'socketId': _socket?.id,
      'hasToken': _currentToken != null,
    };
  }

  /// Ping manual al servidor (opcional, para testing)
  void ping() {
    if (_socket != null && _isConnected) {
      _socket!.emit('ping', {'timestamp': DateTime.now().toIso8601String()});
      
      if (kDebugMode) {
        print('🏓 [GPS Socket] Ping enviado');
      }
    }
  }

  // ==========================================
  // LIMPIEZA
  // ==========================================

  /// Cerrar todos los streams y desconectar
  void dispose() {
    if (kDebugMode) {
      print('🗑️ [GPS Socket] Dispose');
    }

    disconnect();
    
    _locationUpdatesController.close();
    _connectionStatusController.close();
    _gpsDeviceStatusController.close();
    _subscriptionStatusController.close(); // ✅ NUEVO
  }
}