// =============================================
// Conductor Tracking Page
// Página principal para tracking del conductor
// =============================================

import 'dart:async';
import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import 'package:consumo_combustible/core/services/location_gps_service.dart';
import 'package:consumo_combustible/domain/models/gps_location.dart';
import 'package:consumo_combustible/presentation/page/gps/bloc/gps_bloc.dart';
import 'package:consumo_combustible/presentation/page/gps/bloc/gps_event.dart';
import 'package:consumo_combustible/presentation/page/gps/bloc/gps_state.dart';
import 'package:consumo_combustible/presentation/page/gps/conductor/widgets/tracking_map_widget.dart';
import 'package:consumo_combustible/presentation/page/gps/conductor/widgets/gps_info_card.dart';
import 'package:consumo_combustible/presentation/page/gps/conductor/widgets/connection_status_banner.dart';


class ConductorTrackingPage extends StatefulWidget {
  final int unidadId;
  final String placa;
  final String? jwtToken;

  const ConductorTrackingPage({
    super.key,
    required this.unidadId,
    required this.placa,
    this.jwtToken,
  });

  @override
  State<ConductorTrackingPage> createState() => _ConductorTrackingPageState();
}

class _ConductorTrackingPageState extends State<ConductorTrackingPage> {
  final LocationGpsService _locationService = LocationGpsService();
  
  Position? _currentPosition;
  Timer? _trackingTimer;
  bool _isTracking = false;
  
  // Control de SnackBars
  DateTime? _lastSuccessSnackBarTime;
  DateTime? _lastErrorSnackBarTime;
  static const _snackBarCooldown = Duration(seconds: 5);
  
  @override
  void initState() {
    super.initState();
    _initializeTracking();
  }

  /// Inicializar tracking
  Future<void> _initializeTracking() async {
    // Solicitar permisos de ubicación
    final hasPermission = await _locationService.requestPermissions();
    
    if (!hasPermission) {
      if (mounted) _showPermissionDeniedDialog();
      return;
    }

    // Verificar que el GPS esté habilitado
    final isEnabled = await _locationService.isLocationServiceEnabled();
    
    if (!isEnabled) {
      if (mounted) _showGpsDisabledDialog();
      return;
    }

    // Obtener ubicación inicial
    await _getCurrentLocation();

    // Conectar al WebSocket si hay token
    if (mounted && widget.jwtToken != null) {
      context.read<GpsBloc>().add(ConnectWebSocketEvent(widget.jwtToken!));
    }
  }

  /// Obtener ubicación actual
  Future<void> _getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    
    if (position != null && mounted) {
      setState(() {
        _currentPosition = position;
      });
    }
  }

  /// Iniciar tracking automático
  void _startTracking() {
    if (_isTracking) return;

    setState(() {
      _isTracking = true;
    });

    // Enviar ubicación inmediatamente
    _sendCurrentLocation();

    // Configurar timer para envío periódico (cada 10 segundos)
    _trackingTimer?.cancel();
    _trackingTimer = Timer.periodic(
      const Duration(seconds: 10),
      (timer) {
        if (mounted && _isTracking) {
          _sendCurrentLocation();
        } else {
          timer.cancel();
        }
      },
    );

    // Escuchar cambios de ubicación
    _locationService.startLocationUpdates(
      onLocationUpdate: (position) {
        if (mounted && _isTracking) {
          setState(() {
            _currentPosition = position;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          debugPrint('❌ Error obteniendo ubicación: $error');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error GPS: $error'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      },
      interval: const Duration(seconds: 10),
      distanceFilter: 10, // Solo actualizar si se movió 10 metros
      accuracy: LocationAccuracy.high,
    );
  }

  /// Detener tracking
  Future<void> _stopTracking() async {
    if (!_isTracking) return;

    setState(() {
      _isTracking = false;
    });

    _trackingTimer?.cancel();
    _trackingTimer = null;

    await _locationService.stopLocationUpdates();
    
    if (mounted) {
      debugPrint('✅ Tracking detenido correctamente');
    }
  }

  /// Enviar ubicación actual al backend
  Future<void> _sendCurrentLocation() async {
    if (_currentPosition == null) {
      await _getCurrentLocation();
      if (_currentPosition == null) return;
    }

    if (!mounted) return;

    final location = GpsLocation(
      unidadId: widget.unidadId,
      latitud: _currentPosition!.latitude,
      longitud: _currentPosition!.longitude,
      altitud: _currentPosition!.altitude,
      precision: _currentPosition!.accuracy,
      velocidad: _locationService.metersPerSecondToKmh(_currentPosition!.speed),
      rumbo: _currentPosition!.heading,
      fechaHora: DateTime.now(),
      proveedor: GpsProviderType.mobileApp,
      bateria: null, // TODO: Obtener nivel de batería
      senalGPS: _getSignalQuality(_currentPosition!.accuracy),
      appVersion: '1.0.0', // TODO: Obtener de package_info
      sistemaOperativo: Theme.of(context).platform.toString(),
      modeloDispositivo: 'Flutter Device', // TODO: Obtener modelo real
    );

    context.read<GpsBloc>().add(SendLocationEvent(location));
  }

  /// Determinar calidad de señal GPS según precisión
  GpsSignalQuality _getSignalQuality(double accuracy) {
    if (accuracy < 10) return GpsSignalQuality.excelente;
    if (accuracy < 20) return GpsSignalQuality.buena;
    if (accuracy < 50) return GpsSignalQuality.regular;
    if (accuracy < 100) return GpsSignalQuality.pobre;
    return GpsSignalQuality.sinSenal;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppTitle('Tracking GPS', fontSize: 14,),
            SizedBox(height: 5,),
            AppCaption(
              color: AppColors.blue3,
              fontSize: 12,
              font: AppFont.oxygenBold,
              items: [
                CaptionItem(
                  icon: Icons.local_shipping_outlined,
                  text: widget.placa
                )
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _getCurrentLocation,
            tooltip: 'Actualizar ubicación',
          ),
        ],
      ),
      body: BlocConsumer<GpsBloc, GpsState>(
        listener: (context, state) {
          final now = DateTime.now();
          
          // Manejar errores generales
          if (state is GpsError) {
            if (_lastErrorSnackBarTime == null ||
                now.difference(_lastErrorSnackBarTime!) > _snackBarCooldown) {
              _lastErrorSnackBarTime = now;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }

          // Manejar ubicación enviada - SOLO mostrar si NO está en tracking automático
          if (state is GpsLocationSent && !_isTracking) {
            if (_lastSuccessSnackBarTime == null ||
                now.difference(_lastSuccessSnackBarTime!) > _snackBarCooldown) {
              _lastSuccessSnackBarTime = now;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('📍 Ubicación enviada'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          }

          // Manejar error de envío
          if (state is GpsSendLocationError) {
            if (_lastErrorSnackBarTime == null ||
                now.difference(_lastErrorSnackBarTime!) > _snackBarCooldown) {
              _lastErrorSnackBarTime = now;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.message}'),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 3),
                  action: SnackBarAction(
                    label: 'Reintentar',
                    textColor: Colors.white,
                    onPressed: _sendCurrentLocation,
                  ),
                ),
              );
            }
          }
        },
        builder: (context, state) {
          // Determinar estado de conexión WebSocket
          final isConnected = state is GpsConnected ||
                             state is GpsReceivingUpdates ||
                             state is GpsTrackingActive ||
                             state is GpsLocationSent ||
                             state is GpsSendingLocation;

          // Determinar si está rastreando activamente
          // El tracking está activo si _isTracking es true (estado local)
          final isActivelyTracking = _isTracking;

          // Obtener información de tracking
          int locationsSent = 0;
          DateTime? lastLocationSentAt;

          if (state is GpsTrackingActive) {
            locationsSent = state.locationsSent;
            lastLocationSentAt = state.lastLocationSentAt;
          }

          String? errorMessage;
          if (state is GpsConnectionError) {
            errorMessage = state.message;
          } else if (state is GpsError) {
            errorMessage = state.message;
          }

          return SafeArea(
            child: Column(
              children: [
                // Banner de estado de conexión
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: ConnectionStatusBanner(
                    isConnected: isConnected,
                    isSubscribed: isActivelyTracking,
                    errorMessage: errorMessage,
                  ),
                ),

                // Mapa
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TrackingMapWidget(
                      currentPosition: _currentPosition,
                      isTracking: _isTracking,
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // Información GPS
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: GpsInfoCard(
                      position: _currentPosition,
                      locationsSent: locationsSent,
                      lastLocationSentAt: lastLocationSentAt,
                    ),
                  ),
                ),

                // const SizedBox(height: 5),

                // Botones de control
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  child: Column(
                    children: [
                      // Botón Iniciar/Detener Tracking
                      SizedBox(
                        width: double.infinity,
                        height: 40,
                        child: ElevatedButton.icon(
                          onPressed: _isTracking ? _stopTracking : _startTracking,
                          icon: Icon(
                            _isTracking ? Icons.stop : Icons.play_arrow,
                            size: 24,
                          ),
                          label: Text(
                            _isTracking ? 'DETENER TRACKING' : 'INICIAR TRACKING',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isTracking ? Colors.red : Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Botón Enviar Ubicación Manual
                      if (!_isTracking)
                        SizedBox(
                          width: double.infinity,
                          height: 40,
                          child: OutlinedButton.icon(
                            onPressed: state is GpsSendingLocation
                                ? null
                                : _sendCurrentLocation,
                            icon: state is GpsSendingLocation
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.send),
                            label: Text(
                              state is GpsSendingLocation
                                  ? 'Enviando...'
                                  : 'Enviar Ubicación Ahora',
                            ),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 5),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Mostrar diálogo de permisos denegados
  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permisos Requeridos'),
        content: const Text(
          'Esta aplicación necesita acceso a tu ubicación para funcionar correctamente.\n\n'
          'Por favor, habilita los permisos de ubicación en la configuración.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _locationService.requestPermissions();
            },
            child: const Text('Ir a Configuración'),
          ),
        ],
      ),
    );
  }

  /// Mostrar diálogo de GPS deshabilitado
  void _showGpsDisabledDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('GPS Deshabilitado'),
        content: const Text(
          'El GPS está deshabilitado en tu dispositivo.\n\n'
          'Por favor, habilita el GPS para usar el tracking.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Detener tracking si está activo
    if (_isTracking) {
      _isTracking = false;
      _trackingTimer?.cancel();
      _trackingTimer = null;
    }
    
    // Limpiar recursos de ubicación
    _locationService.stopLocationUpdates().then((_) {
      _locationService.dispose();
    }).catchError((error) {
      debugPrint('⚠️ Error limpiando location service: $error');
    });
    
    // Desconectar WebSocket al salir
    try {
      context.read<GpsBloc>().add(const DisconnectWebSocketEvent());
    } catch (e) {
      debugPrint('⚠️ Error desconectando WebSocket: $e');
    }
    
    super.dispose();
  }
}