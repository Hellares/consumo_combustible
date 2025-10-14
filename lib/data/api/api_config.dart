import 'package:flutter/foundation.dart';

class ApiConfig {
  // static const String localApi = "api-gateway.syncronize.net.pe";
  static const String localApi = "192.168.100.3:3000";
  static const String productionApi = 'combustible-api.syncronize.net.pe';
  // static const String productionApi = '192.168.100.3:3000';
  
  static bool get isProduction => kReleaseMode;

  static String get apiSyncronize => isProduction ? productionApi : localApi;

  static String get baseUrl => isProduction 
    ? 'https://$productionApi'
    : 'http://$localApi';

  static Uri getUri(String path) {
    return isProduction
      ? Uri.https(apiSyncronize, path)
      : Uri.https(apiSyncronize, path);
  }

  // ✅ TIMEOUTS AJUSTADOS PARA MICROSERVICIOS
  static Duration get connectTimeout => isProduction 
    ? const Duration(seconds: 15)  // Más tiempo para conexión externa
    : const Duration(seconds: 8);  // Más tiempo para desarrollo local

  static Duration get receiveTimeout => isProduction 
    ? const Duration(seconds: 15)  // Suficiente para microservicios en producción
    : const Duration(seconds: 12); // Suficiente para desarrollo local

  static Duration get sendTimeout => isProduction 
    ? const Duration(seconds: 15) 
    : const Duration(seconds: 8);

  // ✅ TIMEOUTS ESPECÍFICOS PARA LOGIN (más tiempo)
  static Duration get loginReceiveTimeout => isProduction 
    ? const Duration(seconds: 20)  // Login puede tardar más por validaciones
    : const Duration(seconds: 15); // Desarrollo local

  static Duration get loginConnectTimeout => isProduction 
    ? const Duration(seconds: 12) 
    : const Duration(seconds: 10);

  // Headers específicos por entorno
  static Map<String, String> get headers {
    final baseHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Connection': 'keep-alive',
    };

    if (isProduction) {
      baseHeaders.addAll({
        'X-API-Version': '1.0',
        'X-Client-Platform': 'flutter',
      });
    }

    return baseHeaders;
  }

  // Configuraciones de retry por entorno
  static int get maxRetries => isProduction ? 3 : 2; // Más reintentos
  static Duration get retryDelay => isProduction 
    ? const Duration(milliseconds: 800)  // Más tiempo entre reintentos
    : const Duration(milliseconds: 500);

  // Info de debugging
  static void logEnvironmentInfo() {
    if (kDebugMode) {
      print('🌐 Entorno: ${isProduction ? "PRODUCCIÓN" : "DESARROLLO"}');
      print('🔗 Base URL: $baseUrl');
      print('⏱️ Timeouts: Connect=${connectTimeout.inSeconds}s, Receive=${receiveTimeout.inSeconds}s');
      print('🔐 Login Timeouts: Connect=${loginConnectTimeout.inSeconds}s, Receive=${loginReceiveTimeout.inSeconds}s');
    }
  }
}
