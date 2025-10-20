// =============================================
// Background GPS Service
// Servicio para tracking GPS en segundo plano
// =============================================

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundGpsService {
  static const String _notificationChannelId = 'gps_tracking_channel';
  static const String _notificationChannelName = 'GPS Tracking';
  static const int _notificationId = 888;

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  /// Inicializar el servicio en segundo plano
  static Future<void> initialize() async {
    final service = FlutterBackgroundService();

    // Configurar notificaciones
    await _configureNotifications();

    // Configurar el servicio
    await service.configure(
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: _onStart,
        onBackground: _onIosBackground,
      ),
      androidConfiguration: AndroidConfiguration(
        autoStart: false,
        onStart: _onStart,
        isForegroundMode: true,
        autoStartOnBoot: false,
        notificationChannelId: _notificationChannelId,
        initialNotificationTitle: 'GPS Tracking',
        initialNotificationContent: 'Inicializando...',
        foregroundServiceNotificationId: _notificationId,
        foregroundServiceTypes: [AndroidForegroundType.location],
      ),
    );
  }

  /// Configurar notificaciones
  static Future<void> _configureNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);

    // Crear canal de notificación para Android
    const androidChannel = AndroidNotificationChannel(
      _notificationChannelId,
      _notificationChannelName,
      description: 'Canal para notificaciones de tracking GPS',
      importance: Importance.low,
      playSound: false,
      enableVibration: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Callback para iOS en segundo plano
  @pragma('vm:entry-point')
  static Future<bool> _onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  /// Callback cuando el servicio inicia
  @pragma('vm:entry-point')
  static void _onStart(ServiceInstance service) async {
    DartPluginRegistrant.ensureInitialized();

    // Obtener configuración guardada
    final prefs = await SharedPreferences.getInstance();
    final unidadId = prefs.getInt('tracking_unidad_id');
    final apiUrl = prefs.getString('tracking_api_url');
    final token = prefs.getString('tracking_token');

    if (unidadId == null || apiUrl == null || token == null) {
      debugPrint('❌ [Background Service] Configuración incompleta');
      service.stopSelf();
      return;
    }

    debugPrint('✅ [Background Service] Iniciado para unidad $unidadId');

    // Variable para controlar si el servicio está activo
    bool isServiceActive = true;

    // Timer para enviar ubicaciones cada 10 segundos
    Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!isServiceActive) {
        timer.cancel();
        return;
      }

      try {
        // Obtener ubicación actual
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 10,
          ),
        );

        // Enviar al backend
        await _sendLocation(
          unidadId: unidadId,
          position: position,
          apiUrl: apiUrl,
          token: token,
        );

        // Actualizar notificación
        await _updateNotification(
          locationsSent: timer.tick,
          lastUpdate: DateTime.now(),
        );

        debugPrint('📍 [Background Service] Ubicación enviada: ${timer.tick}');
      } catch (e) {
        debugPrint('❌ [Background Service] Error: $e');
      }
    });

    // Escuchar comandos para detener el servicio
    service.on('stop').listen((event) {
      debugPrint('🛑 [Background Service] Deteniendo...');
      isServiceActive = false;
      service.stopSelf();
    });
  }

  /// Enviar ubicación al backend
  static Future<void> _sendLocation({
    required int unidadId,
    required Position position,
    required String apiUrl,
    required String token,
  }) async {
    final dio = Dio();
    
    try {
      await dio.post(
        '$apiUrl/gps/location',
        data: {
          'unidadId': unidadId,
          'latitud': position.latitude,
          'longitud': position.longitude,
          'altitud': position.altitude,
          'precision': position.accuracy,
          'velocidad': position.speed * 3.6, // m/s a km/h
          'rumbo': position.heading,
          'fechaHora': DateTime.now().toIso8601String(),
          'proveedor': 'MOBILE_APP',
          'senalGPS': _getSignalQuality(position.accuracy),
          'appVersion': '1.0.0',
          'sistemaOperativo': 'Android/iOS',
          'modeloDispositivo': 'Background Service',
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ Error enviando ubicación: $e');
      rethrow;
    }
  }

  /// Determinar calidad de señal GPS
  static String _getSignalQuality(double accuracy) {
    if (accuracy < 10) return 'EXCELENTE';
    if (accuracy < 20) return 'BUENA';
    if (accuracy < 50) return 'REGULAR';
    if (accuracy < 100) return 'POBRE';
    return 'SIN_SENAL';
  }

  /// Actualizar notificación
  static Future<void> _updateNotification({
    required int locationsSent,
    required DateTime lastUpdate,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _notificationChannelId,
      _notificationChannelName,
      channelDescription: 'Canal para notificaciones de tracking GPS',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      autoCancel: false,
      playSound: false,
      enableVibration: false,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final timeStr = '${lastUpdate.hour.toString().padLeft(2, '0')}:${lastUpdate.minute.toString().padLeft(2, '0')}';

    await _notifications.show(
      _notificationId,
      '🚗 GPS Tracking Activo',
      '📍 $locationsSent ubicaciones enviadas | Última: $timeStr',
      details,
    );
  }

  /// Iniciar el servicio
  static Future<bool> startService({
    required int unidadId,
    required String apiUrl,
    required String token,
  }) async {
    // Guardar configuración
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('tracking_unidad_id', unidadId);
    await prefs.setString('tracking_api_url', apiUrl);
    await prefs.setString('tracking_token', token);

    final service = FlutterBackgroundService();
    final isRunning = await service.isRunning();

    if (isRunning) {
      debugPrint('⚠️ [Background Service] Ya está en ejecución');
      return true;
    }

    return await service.startService();
  }

  /// Detener el servicio
  static Future<void> stopService() async {
    final service = FlutterBackgroundService();
    service.invoke('stop');
    
    // Limpiar configuración
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('tracking_unidad_id');
    await prefs.remove('tracking_api_url');
    await prefs.remove('tracking_token');

    // Cancelar notificación
    await _notifications.cancel(_notificationId);
  }

  /// Verificar si el servicio está corriendo
  static Future<bool> isServiceRunning() async {
    final service = FlutterBackgroundService();
    return await service.isRunning();
  }
}