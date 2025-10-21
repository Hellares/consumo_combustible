import 'dart:async';
import 'dart:convert';
import 'package:consumo_combustible/core/fast_storage_service.dart';
import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/fonts/app_text_widgets.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/domain/models/auth_response.dart';
import 'package:consumo_combustible/domain/models/selected_role.dart';
import 'package:consumo_combustible/domain/models/user.dart';
import 'package:consumo_combustible/domain/use_cases/auth/auth_use_cases.dart';
import 'package:consumo_combustible/domain/use_cases/location/location_use_cases.dart';
import 'package:consumo_combustible/injection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get_it/get_it.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final _storage = GetIt.instance<FastStorageService>();
  final _authUseCases = locator<AuthUseCases>();
  final _locationUseCases = locator<LocationUseCases>(); // NUEVO

  String _statusText = 'Inicializando...';
  bool _hasNavigated = false;
  bool _hasSession = false;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _initializeAppWithConditionalTiming();
    });
  }

  void _updateStatus(String status) {
    if (mounted && !_hasNavigated) {
      setState(() => _statusText = status);
    }
  }

  Future<void> _initializeAppWithConditionalTiming() async {
    if (_hasNavigated) return;

    Stopwatch? totalStopwatch;
    if (kDebugMode) {
      totalStopwatch = Stopwatch()..start();
      print('🎬 Splash iniciado con timing condicional...');
    }

    try {
      // PASO 1: Verificar rápidamente si hay sesión
      _updateStatus('Verificando sesión...');
      await _quickSessionCheck();

      // PASO 2: Timing condicional según estado de sesión
      if (_hasSession) {
        await _fastSplashForLoggedUser();
      } else {
        await _extendedSplashForNewUser();
      }

      // PASO 3: Navegación final
      await _finalNavigation();

      if (kDebugMode) {
        totalStopwatch?.stop();
        print(
          '🎯 Splash completado en ${totalStopwatch?.elapsedMilliseconds}ms',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        totalStopwatch?.stop();
        print(
          '💥 Error en splash (${totalStopwatch?.elapsedMilliseconds}ms): $e',
        );
      }
      _showErrorAndRetry(e.toString());
    }
  }

  /// Verificación rápida de sesión para determinar el timing
  Future<void> _quickSessionCheck() async {
    try {
      await _initializeStorageFast();
      final userData = await _storage.read('user');
      _hasSession = userData != null;

      if (kDebugMode) {
        print(
          _hasSession
              ? '✅ Sesión detectada - Splash rápido'
              : 'ℹ️ Sin sesión - Splash extendido',
        );
      }
    } catch (e) {
      _hasSession = false;
      if (kDebugMode) print('⚠️ Error verificando sesión: $e');
    }
  }

  /// Splash rápido para usuarios con sesión activa
  Future<void> _fastSplashForLoggedUser() async {
    _updateStatus('Restaurando sesión...');
    await Future.delayed(const Duration(milliseconds: 500));

    _updateStatus('Preparando aplicación...');
    await Future.delayed(const Duration(milliseconds: 300));
  }

  /// Splash extendido para usuarios nuevos o sin sesión
  Future<void> _extendedSplashForNewUser() async {
    _updateStatus('Preparando servicios...');
    await Future.delayed(const Duration(milliseconds: 900));

    _updateStatus('Configurando seguridad...');
    await Future.delayed(const Duration(milliseconds: 700));

    _updateStatus('Inicializando interfaz...');
    await Future.delayed(const Duration(milliseconds: 600));

    _updateStatus('Preparando experiencia...');
    await Future.delayed(const Duration(milliseconds: 700));
  }

  /// Inicialización rápida del storage
  Future<void> _initializeStorageFast() async {
    try {
      await _storage.initialize();
    } catch (e) {
      if (kDebugMode) print('⚠️ FastStorage error: $e');
    }
  }

  /// Navegación final según estado de sesión
  Future<void> _finalNavigation() async {
    if (_hasNavigated) return;

    _updateStatus('Finalizando...');
    await Future.delayed(const Duration(milliseconds: 250));

    if (_hasSession) {
      await _navigateLoggedUser();
    } else {
      _navigateToLogin();
    }
  }

  /// ✅ NAVEGACIÓN ACTUALIZADA con verificación de ubicación
  Future<void> _navigateLoggedUser() async {
    try {
      final userData = await _storage.read('user');
      if (userData != null) {
        final authResponse = _parseUserDataSync(userData);

        if (authResponse != null) {
          final user = authResponse.data?.user;

          // PASO 1: Verificar rol seleccionado
          final selectedRole = await _authUseCases.getSelectedRole.run();

          if (selectedRole != null) {
            // ✅ Tiene rol - verificar ubicación
            if (kDebugMode) {
              print('✅ Rol guardado: ${selectedRole.role.rol.nombre}');
            }

            // PASO 2: Verificar ubicación seleccionada
            _updateStatus('Verificando ubicación...');
            final selectedLocation = await _locationUseCases.getSelectedLocation
                .run();

            if (selectedLocation != null) {
              // ✅ Tiene todo: rol + ubicación → Home
              if (kDebugMode) {
                print('✅ Ubicación guardada: ${selectedLocation.grifo.nombre}');
                print('📍 Zona: ${selectedLocation.zona.nombre}');
                print('🏢 Sede: ${selectedLocation.sede.nombre}');
              }
              _navigateToHome();
            } else {
              // ⚠️ Falta ubicación → Selección de ubicación
              if (kDebugMode) {
                print('⚠️ Falta ubicación - ir a selección');
              }
              _navigateToLocationSelection();
            }
          } else if (user != null && user.roles.length == 1) {
            // ✅ Un solo rol - guardarlo primero
            if (kDebugMode) {
              print('✅ Usuario con 1 rol - guardando automáticamente');
            }
            await _saveDefaultRoleAndNavigate(user);
          } else if (user != null && user.roles.length > 1) {
            // ✅ Múltiples roles - ir a selección de rol
            if (kDebugMode) {
              print(
                '📋 Usuario con ${user.roles.length} roles - ir a selección',
              );
            }
            _navigateToRoleSelection(user);
          } else {
            // ❌ Sin roles o error
            if (kDebugMode) print('❌ Usuario sin roles - ir a login');
            _navigateToLogin();
          }
          return;
        }
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ Error navegando usuario logueado: $e');
    }

    _navigateToLogin();
  }

  /// ✅ ACTUALIZADO: Guardar rol y verificar ubicación
  Future<void> _saveDefaultRoleAndNavigate(User user) async {
    try {
      final selectedRole = SelectedRole(
        userId: user.id,
        role: user.roles.first,
        selectedAt: DateTime.now(),
      );

      await _authUseCases.saveSelectedRole.run(selectedRole);

      if (kDebugMode) {
        print('✅ Rol único guardado: ${selectedRole.role.rol.nombre}');
      }

      // ✅ Verificar ubicación después de guardar rol
      _updateStatus('Verificando ubicación...');
      final selectedLocation = await _locationUseCases.getSelectedLocation
          .run();

      if (selectedLocation != null) {
        // Tiene ubicación → Home
        if (kDebugMode) {
          print('✅ Ubicación ya configurada: ${selectedLocation.grifo.nombre}');
        }
        _navigateToHome();
      } else {
        // Sin ubicación → Selección de ubicación
        if (kDebugMode) {
          print('⚠️ Falta ubicación - ir a selección');
        }
        _navigateToLocationSelection();
      }
    } catch (e) {
      if (kDebugMode) print('❌ Error guardando rol default: $e');
      _navigateToLogin();
    }
  }

  /// NUEVA: Navegación a selección de ubicación
  void _navigateToLocationSelection() {
    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      Navigator.pushNamedAndRemoveUntil(
        context,
        'location-selection',
        (route) => false, // ✅ Limpiar el stack completamente
      );
    }
  }

  AuthResponse? _parseUserDataSync(dynamic userData) {
    try {
      if (userData is Map<String, dynamic>) {
        return AuthResponse.fromJson(userData);
      }

      if (userData is String) {
        final decoded = jsonDecode(userData) as Map<String, dynamic>;
        return AuthResponse.fromJson(decoded);
      }

      return null;
    } catch (e) {
      if (kDebugMode) print('❌ Error parseando datos: $e');
      return null;
    }
  }

  void _navigateToLogin() {
    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      Navigator.pushNamedAndRemoveUntil(
        context,
        'login',
        (route) => false, // ✅ Limpiar el stack completamente
      );
    }
  }

  void _navigateToHome() {
    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      Navigator.pushNamedAndRemoveUntil(
        context,
        'home',
        (route) => false, // ✅ Limpiar el stack completamente
      );
    }
  }

  void _navigateToRoleSelection(User user) {
    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      Navigator.pushNamedAndRemoveUntil(
        context,
        'role-selection',
        (route) => false, // ✅ Limpiar el stack completamente
        arguments: user,
      );
    }
  }

  void _showErrorAndRetry(String error) {
    if (!mounted || _hasNavigated) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Error de inicialización'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Ocurrió un error:\n\n$error'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _hasNavigated = false;
              _initializeAppWithConditionalTiming();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color(0xFF1E3A8A),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 140,
              height: 120,
              alignment: Alignment.center,
              child: SvgPicture.asset(
                'assets/img/logo.svg',
                width: 140,
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            Text(
              'Syncronize',
              style: TextStyle(
                fontSize: 22,
                fontFamily: AppFonts.getFontFamily(
                  AppFont.airstrikeBold3d,
                ),
                color: Color(0xFF004A94),
              ),
            ),
            // ),
            const SizedBox(height: 8),
            AppTitle(
              font: AppFont.pirulentBold,
              fontSize: 8,
              'Sistema de Gestión',
              color: AppColors.blue2,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColors.blue2,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _statusText,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.blue2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}