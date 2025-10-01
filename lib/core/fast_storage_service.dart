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
  
  // Solo el token va a SecureStorage
  static const _criticalSecureKeys = {'token', 'password', 'pin'};
  
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
  
  /// ✅ ELIMINACIÓN
  Future<void> delete(String key) async {
    _memoryCache.remove(key);
    
    try {
      final futures = <Future>[];
      
      // Eliminar de SharedPreferences
      futures.add(_getPrefs().then((prefs) => prefs.remove(key)).catchError((e) {
        if (kDebugMode) debugPrint('⚠️ Error eliminando de SharedPrefs: $e');
        return false; // Devolver un valor del tipo esperado
      }));
      
      // Eliminar de SecureStorage
      futures.add(_secureStorage.delete(key: key));
      
      await Future.wait(futures);
      
      if (kDebugMode) debugPrint('🗑️ [$key] Eliminado');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error deleting [$key]: $e');
    }
  }
  
  /// ✅ LIMPIAR 
  Future<void> clear() async {
    _memoryCache.clear();
    
    try {
      final futures = <Future>[];
      
      futures.add(_secureStorage.deleteAll());
      
      futures.add(_getPrefs().then((prefs) => prefs.clear()).catchError((e) {
        if (kDebugMode) debugPrint('⚠️ Error limpiando SharedPrefs: $e');
        return false; // Devolver un valor del tipo esperado
      }));
      
      await Future.wait(futures);
      
      if (kDebugMode) debugPrint('🧹 Todo limpiado');
    } catch (e) {
      if (kDebugMode) debugPrint('❌ Error clearing: $e');
    }
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
}

// import 'package:flutter/foundation.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:async';
// import 'dart:convert';

// class FastStorageService {
//   static SharedPreferences? _prefs;
//   static Completer<SharedPreferences>? _initCompleter;
  
//   Cache en memoria para lecturas ultra-rápidas
//   final Map<String, dynamic> _memoryCache = {};
//   bool _cacheLoaded = false;

//   ✅ NUEVO: Inicialización lazy - solo cuando se necesita
//   Future<SharedPreferences> get _prefsInstance async {
//     if (_prefs != null) return _prefs!;
    
//     Si ya está inicializando, esperar
//     if (_initCompleter != null) {
//       return _initCompleter!.future;
//     }
    
//     Iniciar nueva inicialización
//     _initCompleter = Completer<SharedPreferences>();
    
//     try {
//       final stopwatch = Stopwatch()..start();
//       _prefs = await SharedPreferences.getInstance();
//       stopwatch.stop();
      
//       if (kDebugMode) {
//         debugPrint('⚡ SharedPreferences inicializado en ${stopwatch.elapsedMilliseconds}ms');
//       }
      
//       _initCompleter!.complete(_prefs!);
//       return _prefs!;
//     } catch (e) {
//       _initCompleter!.completeError(e);
//       _initCompleter = null;
//       rethrow;
//     }
//   }

//   / ✅ Inicialización explícita (llamar desde Splash)
//   Future<void> initialize() async {
//     if (_prefs != null && _cacheLoaded) {
//       if (kDebugMode) debugPrint('⚡ FastStorage ya inicializado');
//       return;
//     }

//     final stopwatch = Stopwatch()..start();
    
//     Obtener prefs
//     await _prefsInstance;
    
//     Cargar cache crítico
//     await _loadCriticalDataToCache();
    
//     stopwatch.stop();
//     if (kDebugMode) {
//       debugPrint('✅ FastStorage listo en ${stopwatch.elapsedMilliseconds}ms');
//     }
//   }

//   / Cargar solo datos críticos al cache
//   Future<void> _loadCriticalDataToCache() async {
//     if (_cacheLoaded) return;
    
//     try {
//       final prefs = await _prefsInstance;
//       final criticalKeys = ['user', 'token']; // Solo lo esencial
      
//       int loadedCount = 0;
//       for (final key in criticalKeys) {
//         final value = prefs.getString(key);
//         if (value != null) {
//           try {
//             _memoryCache[key] = jsonDecode(value);
//             loadedCount++;
//           } catch (_) {
//             _memoryCache[key] = value;
//             loadedCount++;
//           }
//         }
//       }
      
//       _cacheLoaded = true;
      
//       if (kDebugMode) {
//         debugPrint('⚡ Datos cargados al cache: $loadedCount keys');
//       }
//     } catch (e) {
//       if (kDebugMode) debugPrint('⚠️ Error cargando cache: $e');
//       _cacheLoaded = true; // Continuar sin cache
//     }
//   }

//   / ✅ Lectura optimizada con cache
//   Future<dynamic> read(String key) async {
//     1. Intentar desde cache (ultra-rápido)
//     if (_memoryCache.containsKey(key)) {
//       if (kDebugMode) debugPrint('⚡ [$key] Cache hit');
//       return _memoryCache[key];
//     }
    
//     2. Cargar desde SharedPreferences
//     try {
//       final prefs = await _prefsInstance;
//       final value = prefs.getString(key);
      
//       if (value != null) {
//         try {
//           final decoded = jsonDecode(value);
//           _memoryCache[key] = decoded; // Guardar en cache
//           if (kDebugMode) debugPrint('✅ [$key] Cargado desde prefs');
//           return decoded;
//         } catch (_) {
//           _memoryCache[key] = value;
//           return value;
//         }
//       }
      
//       if (kDebugMode) debugPrint('❌ [$key] No encontrado');
//       return null;
//     } catch (e) {
//       if (kDebugMode) debugPrint('❌ Error leyendo [$key]: $e');
//       return null;
//     }
//   }

//   / ✅ Escritura síncrona con cache
//   Future<bool> write(String key, dynamic value) async {
//     try {
//       final prefs = await _prefsInstance;
//       final jsonString = jsonEncode(value);
      
//       Actualizar cache primero (instantáneo para la UI)
//       _memoryCache[key] = value;
      
//       Luego guardar en disco
//       final success = await prefs.setString(key, jsonString);
      
//       if (kDebugMode) {
//         debugPrint(success ? '✅ [$key] Guardado' : '❌ [$key] Falló');
//       }
      
//       return success;
//     } catch (e) {
//       if (kDebugMode) debugPrint('❌ Error escribiendo [$key]: $e');
//       return false;
//     }
//   }

//   / ✅ Escritura asíncrona (fire-and-forget para datos no críticos)
//   Future<void> writeAsync(String key, dynamic value) async {
//     Actualizar cache inmediatamente
//     _memoryCache[key] = value;
    
//     Guardar en background sin esperar
//     ignore: body_might_complete_normally_catch_error
//     write(key, value).catchError((e) {
//       if (kDebugMode) debugPrint('⚠️ Error async escribiendo [$key]: $e');
//     });
//   }

//   / ✅ Eliminar con cache
//   Future<bool> delete(String key) async {
//     try {
//       final prefs = await _prefsInstance;
      
//       Limpiar cache
//       _memoryCache.remove(key);
      
//       Eliminar de disco
//       final success = await prefs.remove(key);
      
//       if (kDebugMode) {
//         debugPrint(success ? '✅ [$key] Eliminado' : '❌ [$key] No existía');
//       }
      
//       return success;
//     } catch (e) {
//       if (kDebugMode) debugPrint('❌ Error eliminando [$key]: $e');
//       return false;
//     }
//   }

//   / Limpiar todo
//   Future<void> clear() async {
//     try {
//       final prefs = await _prefsInstance;
//       _memoryCache.clear();
//       await prefs.clear();
      
//       if (kDebugMode) debugPrint('🗑️ Almacenamiento limpiado');
//     } catch (e) {
//       if (kDebugMode) debugPrint('❌ Error limpiando storage: $e');
//     }
//   }

//   / Stats del cache
//   Map<String, dynamic> getStats() {
//     return {
//       'cache_size': _memoryCache.length,
//       'cache_loaded': _cacheLoaded,
//       'prefs_initialized': _prefs != null,
//       'cached_keys': _memoryCache.keys.toList(),
//     };
//   }
// }