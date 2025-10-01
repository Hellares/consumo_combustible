import 'dart:async';
import 'dart:convert';
import 'package:consumo_combustible/core/fast_storage_service.dart';
import 'package:consumo_combustible/domain/models/auth_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get_it/get_it.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  final _storage = GetIt.instance<FastStorageService>();
  
  String _statusText = 'Inicializando...';
  bool _hasNavigated = false;
  bool _hasSession = false; // Para determinar el timing

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _initializeAppWithConditionalTiming();
    });
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();
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
      print('🏎️ Splash iniciado con timing condicional...');
    }
    
    try {
      // PASO 1: Verificar rápidamente si hay sesión
      _updateStatus('Verificando sesión...');
      await _quickSessionCheck();
      
      // PASO 2: Timing condicional según estado de sesión
      if (_hasSession) {
        // Usuario con sesión: splash rápido
        await _fastSplashForLoggedUser();
      } else {
        // Usuario sin sesión: splash más elaborado
        await _extendedSplashForNewUser();
      }
      
      // PASO 3: Navegación final
      await _finalNavigation();
      
      if (kDebugMode) {
        totalStopwatch?.stop();
        print('🎯 Splash completado en ${totalStopwatch?.elapsedMilliseconds}ms');
      }
      
    } catch (e) {
      if (kDebugMode) {
        totalStopwatch?.stop();
        print('💥 Error en splash (${totalStopwatch?.elapsedMilliseconds}ms): $e');
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
        print(_hasSession 
            ? '✅ Sesión detectada - Splash rápido' 
            : 'ℹ️ Sin sesión - Splash extendido');
      }
    } catch (e) {
      _hasSession = false;
      if (kDebugMode) print('⚠️ Error verificando sesión: $e');
    }
  }

  /// Splash rápido para usuarios con sesión activa
  Future<void> _fastSplashForLoggedUser() async {
    _updateStatus('Restaurando sesión...');
    
    // Mínimo tiempo para suavidad visual
    await Future.delayed(const Duration(milliseconds: 300));
    
    _updateStatus('Preparando aplicación...');
    await Future.delayed(const Duration(milliseconds: 200));
  }

  /// Splash extendido para usuarios nuevos o sin sesión
  Future<void> _extendedSplashForNewUser() async {
    _updateStatus('Preparando servicios...');
    await Future.delayed(const Duration(milliseconds: 800));
    
    _updateStatus('Configurando seguridad...');
    await Future.delayed(const Duration(milliseconds: 600));
    
    _updateStatus('Inicializando interfaz...');
    await Future.delayed(const Duration(milliseconds: 500));
    
    _updateStatus('Preparando experiencia...');
    await Future.delayed(const Duration(milliseconds: 400));
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
    await Future.delayed(const Duration(milliseconds: 150));
    
    if (_hasSession) {
      await _navigateLoggedUser();
    } else {
      _navigateToLogin();
    }
  }

  /// Navegación para usuario con sesión
  Future<void> _navigateLoggedUser() async {
    try {
      final userData = await _storage.read('user');
      if (userData != null) {
        final authResponse = _parseUserDataSync(userData);
        
        if (authResponse != null) {
          if (kDebugMode) {
            print('✅ Sesión activa para: ${authResponse.data?.user.nombres}');
          }
          
          
          // if (authResponse.data!.needsEmpresaSelection) {
          //   _navigateToEmpresaSelection();
          // } else {
            _navigateToHome();
          // }
          // return;
        }
      }
    } catch (e) {
      if (kDebugMode) print('⚠️ Error navegando usuario logueado: $e');
    }
    
    // Fallback a login si hay error
    _navigateToLogin();
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
      Navigator.pushReplacementNamed(context, 'login');
    }
  }

  void _navigateToHome() {
    if (mounted && !_hasNavigated) {
      _hasNavigated = true;
      Navigator.pushReplacementNamed(context, 'home');
    }
  }

  // void _navigateToEmpresaSelection() {
  //   if (mounted && !_hasNavigated) {
  //     _hasNavigated = true;
  //     Navigator.pushNamedAndRemoveUntil(
  //       context, 
  //       'user/empresa/roles',
  //       (route) => false,
  //     );
  //   }
  // }

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
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: RepaintBoundary(
        child: Center(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RepaintBoundary(
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.sync,
                            size: 60,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Syncronize',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sistema de Gestión',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withValues(alpha: 0.8),
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 48),
                      RepaintBoundary(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          _statusText,
                          key: ValueKey(_statusText),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

