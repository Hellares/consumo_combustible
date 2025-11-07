import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ✅ SOLUCIÓN DEFINITIVA: Inicialización lazy + operaciones no bloqueantes
class FastStorageService {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      sharedPreferencesName: 'sync_secure',
      preferencesKeyPrefix: 'ss_',
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  // Cache en memoria ultra rápido
  final Map<String, dynamic> _memoryCache = {};
  SharedPreferences? _prefs;
  Completer<SharedPreferences>? _prefsCompleter;
  
  // Tokens y datos sensibles van a SecureStorage
  static const _criticalSecureKeys = {'token', 'password', 'pin', 'access_token', 'refresh_token'};
  
  /// ✅ NUEVO: Obtener SharedPreferences de forma lazy y cached
  Future<SharedPreferences> _getPrefs() async {
    if (_prefs != null) return _prefs!;
    
    if (_prefsCompleter != null) {
      // Si ya hay una inicialización en progreso, esperar a que termine
      return _prefsCompleter!.future;
    }
    
    // Inicializar por primera vez
    _prefsCompleter = Completer<SharedPreferences>();
    
    try {
      // final stopwatch = kDebugMode ? Stopwatch()..start() : null;
      Stopwatch? stopwatch;
    if (kDebugMode) {
      stopwatch = Stopwatch()..start();
    }
      _prefs = await SharedPreferences.getInstance();
      
      // Cargar datos existentes al cache inmediatamente
      _loadExistingDataToCache();
      
      if (kDebugMode) {
        stopwatch?.stop();
        debugPrint('⚡ SharedPreferences inicializado en ${stopwatch?.elapsedMilliseconds}ms');
      }
      
      _prefsCompleter!.complete(_prefs!);
      return _prefs!;
    } catch (e) {
      _prefsCompleter!.completeError(e);
      _prefsCompleter = null;
      rethrow;
    }
  }
  
  /// ✅ INICIALIZACIÓN SÚPER RÁPIDA - Ya no es necesaria llamarla explícitamente
  Future<void> initialize() async {
    await _getPrefs(); // Esto se hace automáticamente cuando se necesite
  }
  
  /// ✅ LECTURA ULTRA RÁPIDA
  Future<dynamic> read(String key) async {
    // 1. Cache hit - instantáneo
    if (_memoryCache.containsKey(key)) {
      if (kDebugMode) debugPrint('⚡ [$key] Cache hit (0ms)');
      return _memoryCache[key];
    }
    
    // 2. SharedPreferences (inicialización lazy)
    // final stopwatch = kDebugMode ? Stopwatch()..start() : null;
    Stopwatch? stopwatch;
    if (kDebugMode) {
      stopwatch = Stopwatch()..start();
    }
    
    try {
      final prefs = await _getPrefs();
      final rawValue = prefs.getString(key);
      
      if (rawValue != null) {
        final value = _decodeValue(rawValue);
        _memoryCache[key] = value;
        
        if (kDebugMode) {
          stopwatch?.stop();
          debugPrint('⚡ [$key] SharedPrefs: ${stopwatch?.elapsedMilliseconds}ms');
        }
        return value;
      }
      
      // 3. SOLO si no existe en SharedPrefs Y es crítico, buscar en SecureStorage
      if (_isCriticalSecureKey(key)) {
        final secureValue = await _secureStorage.read(key: key);
        if (secureValue != null) {
          final value = _decodeValue(secureValue);
          _memoryCache[key] = value;
          
          // Migrar a SharedPreferences para próximas veces (excepto tokens críticos)
          if (!_isTokenKey(key)) {
            prefs.setString(key, secureValue);
            _secureStorage.delete(key: key); // Limpiar SecureStorage
          }
          
          if (kDebugMode) {
            stopwatch?.stop();
            debugPrint('🔍 [$key] SecureStorage (migrado): ${stopwatch?.elapsedMilliseconds}ms');
          }
          return value;
        }
      }
      
      if (kDebugMode) {
        stopwatch?.stop();
        debugPrint('❌ [$key] No encontrado');
      }
      return null;
      
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error reading [$key]: $e');
      return null;
    }
  }
  
  /// ✅ ESCRITURA OPTIMIZADA
  Future<void> write(String key, dynamic value) async {
    // Actualizar cache inmediatamente
    _memoryCache[key] = value;
    
    final encodedValue = _encodeValue(value);
    
    try {
      if (_isTokenKey(key)) {
        // Solo tokens van a SecureStorage
        await _secureStorage.write(key: key, value: encodedValue);
        if (kDebugMode) debugPrint('💾 [$key] Guardado en SecureStorage');
      } else {
        // Todo lo demás va a SharedPreferences
        final prefs = await _getPrefs();
        await prefs.setString(key, encodedValue);
        if (kDebugMode) debugPrint('💾 [$key] Guardado en SharedPrefs');
      }
    } catch (e) {
      // Si falla, remover del cache para mantener consistencia
      _memoryCache.remove(key);
      if (kDebugMode) debugPrint('❌ Error writing [$key]: $e');
      rethrow;
    }
  }
  
  /// ✅ ESCRITURA ASYNC (súper rápida)
  Future<void> writeAsync(String key, dynamic value) async {
    // Actualizar cache inmediatamente
    _memoryCache[key] = value;
    
    final encodedValue = _encodeValue(value);
    
    if (_isTokenKey(key)) {
      _secureStorage.write(key: key, value: encodedValue).catchError((e) {
        if (kDebugMode) debugPrint('⚠️ Async SecureStorage write failed [$key]: $e');
        return; // SecureStorage.write devuelve void
      });
    } else {
      _getPrefs().then((prefs) {
        return prefs.setString(key, encodedValue);
      }).catchError((e) {
        if (kDebugMode) debugPrint('⚠️ Async SharedPrefs write failed [$key]: $e');
        return false; // setString devuelve Future<bool>
      });
    }
    
    if (kDebugMode) debugPrint('💾 [$key] Guardado async');
  }
  
  /// ✅ ELIMINACIÓN MEJORADA
  Future<void> delete(String key) async {
    // 1. Eliminar del cache en memoria PRIMERO
    _memoryCache.remove(key);
    
    try {
      // 2. Eliminar de SharedPreferences de forma síncrona
      final prefs = await _getPrefs();
      await prefs.remove(key);
      
      // 3. Eliminar de SecureStorage también
      await _secureStorage.delete(key: key);
      
      if (kDebugMode) debugPrint('🗑️ [$key] Eliminado completamente');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error deleting [$key]: $e');
      rethrow; // Relanzar para que el llamador sepa que falló
    }
  }
  
  /// ✅ LIMPIAR TODO MEJORADO
  Future<void> clear() async {
    // 1. Limpiar cache en memoria
    _memoryCache.clear();
    
    try {
      // 2. Limpiar SharedPreferences de forma síncrona
      final prefs = await _getPrefs();
      await prefs.clear();
      
      // 3. Limpiar SecureStorage
      await _secureStorage.deleteAll();
      
      if (kDebugMode) {
        debugPrint('🧹 Todo limpiado completamente');
        debugPrint('   - Cache en memoria: limpiado');
        debugPrint('   - SharedPreferences: limpiado');
        debugPrint('   - SecureStorage: limpiado');
      }
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error clearing: $e');
      rethrow;
    }
  }
  
  /// ✅ LIMPIAR CACHE EN MEMORIA (útil para forzar recarga)
  void clearMemoryCache() {
    _memoryCache.clear();
    if (kDebugMode) debugPrint('🧹 Cache en memoria limpiado');
  }
  
  /// ✅ WARM UP - Ya no es crítico llamarlo
  Future<void> warmUp() async {
    // Solo asegurar que SharedPreferences esté listo
    await _getPrefs();
  }
  
  // === MÉTODOS PRIVADOS ===
  
  bool _isCriticalSecureKey(String key) {
    return _criticalSecureKeys.any((secureKey) => key.contains(secureKey));
  }
  
  bool _isTokenKey(String key) {
    return key.contains('token') || key == 'token';
  }
  
  /// ✅ Cargar datos existentes al cache de forma síncrona (no bloquear)
  void _loadExistingDataToCache() {
    if (_prefs == null) return;
    
    // Hacer esto en el próximo tick para no bloquear
    Timer(Duration.zero, () {
      try {
        final keys = _prefs!.getKeys();
        for (final key in keys) {
          final value = _prefs!.getString(key);
          if (value != null) {
            _memoryCache[key] = _decodeValue(value);
          }
        }
        
        if (kDebugMode) {
          debugPrint('⚡ Datos cargados al cache: ${keys.length} keys');
        }
      } catch (e) {
        if (kDebugMode) debugPrint('⚠️ Error cargando datos al cache: $e');
      }
    });
  }
  
  String _encodeValue(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is num || value is bool) return value.toString();
    
    try {
      return jsonEncode(value);
    } catch (e) {
      return value.toString();
    }
  }
  
  dynamic _decodeValue(String value) {
    if (value.isEmpty) return null;
    
    try {
      return jsonDecode(value);
    } catch (e) {
      return value;
    }
  }
  
  /// Stats para debug
  Map<String, dynamic> getStats() => {
    'cached_items': _memoryCache.length,
    'cached_keys': _memoryCache.keys.toList(),
    'prefs_initialized': _prefs != null,
    'storage_strategy': 'Lazy SharedPrefs + SecureStorage(tokens only)',
  };
  
  /// ✅ NUEVO: Verificar si una key existe (útil para debugging)
  Future<bool> exists(String key) async {
    // Verificar en cache
    if (_memoryCache.containsKey(key)) {
      return true;
    }
    
    // Verificar en SharedPreferences
    try {
      final prefs = await _getPrefs();
      if (prefs.containsKey(key)) {
        return true;
      }
      
      // Verificar en SecureStorage si es crítico
      if (_isCriticalSecureKey(key)) {
        final value = await _secureStorage.read(key: key);
        return value != null;
      }
      
      return false;
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error verificando existencia de [$key]: $e');
      return false;
    }
  }
}

