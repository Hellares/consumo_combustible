import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Map<String, dynamic> _memoryCache = {};

  // / Guarda datos críticos (por ejemplo sesión de usuario)
  Future<void> save(String key, dynamic value) async {
    
    // final stopwatch = kDebugMode ? Stopwatch()..start() : null;
    Stopwatch? stopwatch;
    if (kDebugMode) {
  stopwatch = Stopwatch()..start();
}

    try {
      _memoryCache[key] = value;
      await _storage.write(key: key, value: jsonEncode(value));

      if (kDebugMode) {
        stopwatch?.stop();
        print('💾 [$key] Guardado en ${stopwatch?.elapsedMilliseconds}ms');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error guardando [$key]: $e');
      rethrow;
    }
  }

  // / Guarda en segundo plano (ideal para preferencias no críticas)
  Future<void> saveAsync(String key, dynamic value) {
    _memoryCache[key] = value;
    if (kDebugMode) print('💾 [$key] Guardado en memoria (async)');
    return _storage.write(key: key, value: jsonEncode(value));
  }

  // / Lee datos, priorizando el cache en memoria
  Future<dynamic> read(String key) async {
    Stopwatch? stopwatch;
    if (kDebugMode) {
  stopwatch = Stopwatch()..start();
}

    // ✅ Primero intenta desde el cache en memoria
    if (_memoryCache.containsKey(key)) {
      if (kDebugMode) {
        stopwatch?.stop();
        print('⚡ [$key] Leído desde memoria en ${stopwatch?.elapsedMicroseconds}µs');
      }
      return _memoryCache[key];
    }

    // ⏳ Si no está en memoria, leer de almacenamiento seguro
    try {
      final jsonStr = await _storage.read(key: key);
      if (jsonStr != null) {
        final value = jsonDecode(jsonStr);
        _memoryCache[key] = value;

        if (kDebugMode) {
          stopwatch?.stop();
          print('🐢 [$key] Leído desde disco en ${stopwatch?.elapsedMilliseconds}ms (cacheado en memoria)');
        }

        return value;
      } else {
        if (kDebugMode) {
          stopwatch?.stop();
          print('ℹ️ [$key] No existe en almacenamiento seguro');
        }
        return null;
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error leyendo [$key]: $e');
      return null;
    }
  }

  // / Borra datos tanto en memoria como en almacenamiento seguro
  Future<void> delete(String key) async {
    _memoryCache.remove(key);
    await _storage.delete(key: key);
    if (kDebugMode) print('🗑️ [$key] Eliminado de memoria y disco');
  }

  // / Limpia TODO el almacenamiento
  Future<void> clear() async {
    _memoryCache.clear();
    await _storage.deleteAll();
    if (kDebugMode) print('🧹 Todos los datos eliminados');
  }

  // / Stats del cache (solo debug)
  Map<String, dynamic> getCacheStats() => {
        'items_in_memory': _memoryCache.length,
        'keys': _memoryCache.keys.toList(),
      };
}
