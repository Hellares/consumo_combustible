import 'package:consumo_combustible/core/widgets/loadings/custom_loading.dart';
import 'package:consumo_combustible/core/widgets/snack.dart';
import 'package:consumo_combustible/domain/models/auth_response.dart';
import 'package:consumo_combustible/domain/models/roles.dart';
import 'package:consumo_combustible/domain/models/selected_role.dart';
import 'package:consumo_combustible/domain/models/user.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_bloc.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_event.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_state.dart';
import 'package:consumo_combustible/presentation/page/auth/login/cliente_login_content.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// ✅ CLIENTE LOGIN PAGE - VERSIÓN OPTIMIZADA
/// 
/// MEJORAS IMPLEMENTADAS:
/// ✓ LoginBloc NO nullable (late final)
/// ✓ Uso de context.read() en initState
/// ✓ BlocListener/Builder con bloc explícito
/// ✓ Navegación context-safe
/// ✓ Lógica de roles completa
/// ✓ Rate limiting incorporado
/// ✓ Manejo robusto de errores
class ClienteLoginPage extends StatefulWidget {
  const ClienteLoginPage({super.key});

  @override
  State<ClienteLoginPage> createState() => _ClienteLoginPageState();
}

class _ClienteLoginPageState extends State<ClienteLoginPage> {
  // ✅ CRÍTICO: LoginBloc NO nullable, obtenido UNA SOLA VEZ
  late final LoginBloc _bloc;
  
  // ✅ Rate limiting en cliente (básico)
  int _failedAttempts = 0;
  DateTime? _lockUntil;
  static const int _maxFailedAttempts = 3;
  static const Duration _lockDuration = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();
    
    // ✅ OBTENER BLOC UNA SOLA VEZ
    _bloc = context.read<LoginBloc>();
    
    // ✅ Inicializar después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _bloc.add(const InitEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: BlocListener<LoginBloc, LoginState>(
        bloc: _bloc, // ✅ Bloc explícito
        listener: _handleStateChange,
        child: BlocBuilder<LoginBloc, LoginState>(
          bloc: _bloc, // ✅ Bloc explícito
          builder: (context, state) {
            final responseState = state.response;
            
            if (responseState is Loading) {
              return Stack(
                children: [
                  ClienteLoginContent(_bloc, state),
                  CustomLoading.login(),
                ],
              );
            }
            
            return ClienteLoginContent(_bloc, state);
          },
        ),
      ),
    );
  }

  /// ✅ SEPARACIÓN DE RESPONSABILIDADES: Manejo de cambios de estado
  void _handleStateChange(BuildContext context, LoginState state) {
    final responseState = state.response;
    
    if (responseState is Error) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleError(context, responseState);
        }
      });
      
    } else if (responseState is Success) {
      final authResponse = responseState.data as AuthResponse;
      
      // ✅ Resetear intentos fallidos en éxito
      _resetRateLimiting();
      
      // Guardar sesión
      _bloc.add(LoginSaveUserSession(authResponse: authResponse));
      
      // Manejar éxito
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _handleSuccess(context, authResponse);
        }
      });
    }
  }

  /// ✅ MANEJO DE ERRORES MEJORADO con Rate Limiting
  void _handleError(BuildContext context, Error error) {
    if (!mounted) return;
    
    // Limpiar estado de error
    _bloc.add(const ClearError());
    
    // ✅ RATE LIMITING: Control de intentos fallidos
    if (error.isAuthError) {
      _failedAttempts++;
      
      if (_failedAttempts >= _maxFailedAttempts) {
        _lockUntil = DateTime.now().add(_lockDuration);
        
        SnackBarHelper.showError(
          context,
          'Demasiados intentos fallidos. Cuenta bloqueada por ${_lockDuration.inMinutes} minutos.',
        );
        
        if (kDebugMode) {
          print('🔒 Cuenta bloqueada hasta: $_lockUntil');
        }
        return;
      }
      
      // Mostrar intentos restantes
      final remaining = _maxFailedAttempts - _failedAttempts;
      SnackBarHelper.showError(
        context,
        'Credenciales incorrectas. Te ${remaining == 1 ? 'queda' : 'quedan'} $remaining intento${remaining != 1 ? 's' : ''}.',
      );
      
    } else if (error.isNetworkError) {
      _showNetworkErrorDialog(context);
      
    } else if (error.isValidationError) {
      SnackBarHelper.showWarning(context, error.message);
      
    } else if (error.isServerError) {
      _showServerErrorDialog(context);
      
    } else {
      SnackBarHelper.showError(
        context,
        error.message.isNotEmpty 
          ? error.message 
          : 'Ha ocurrido un error inesperado',
      );
    }
  }

  /// ✅ MANEJO DE ÉXITO MEJORADO con Context-Safe Navigation
  void _handleSuccess(BuildContext context, AuthResponse authResponse) {
    if (!mounted) return;
    
    try {
      final user = authResponse.data?.user;
      
      // Validaciones
      if (user == null) {
        SnackBarHelper.showError(context, 'Datos de usuario inválidos');
        return;
      }
      
      if (user.roles.isEmpty) {
        SnackBarHelper.showError(context, 'Usuario sin roles asignados');
        return;
      }
      
      // ✅ Capturar referencias ANTES de async
      final userName = user.nombres;
      
      // Mostrar bienvenida
      SnackBarHelper.showSuccess(context, 'Bienvenido $userName');
      
      // ✅ Navegación con delay para mejor UX
      Future.delayed(const Duration(milliseconds: 600), () {
        if (!mounted) return;
        
        if (user.roles.length == 1) {
          // UN SOLO ROL - Guardar automáticamente
          _saveRoleAndNavigateHome(user, user.roles.first);
        } else {
          // MÚLTIPLES ROLES - Ir a selector
          _navigateToRoleSelection(user);
        }
      });
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en _handleSuccess: $e');
      }
      if (mounted) {
        SnackBarHelper.showError(context, 'Error procesando login');
      }
    }
  }

  /// ✅ GUARDAR ROL ÚNICO Y NAVEGAR A HOME
  Future<void> _saveRoleAndNavigateHome(User user, Role role) async {
    if (!mounted) return;
    
    try {
      final selectedRole = SelectedRole(
        userId: user.id,
        role: role,
        selectedAt: DateTime.now(),
      );
      
      // ✅ Capturar Navigator ANTES de async
      final navigator = Navigator.of(context);
      
      // Guardar rol
      await _bloc.authUseCases.saveSelectedRole.run(selectedRole);
      
      if (kDebugMode) {
        print('✅ Rol único guardado: ${role.rol.nombre}');
      }
      
      if (mounted) {
        // Navegar usando navigator capturado
        navigator.pushNamedAndRemoveUntil('home', (route) => false);
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error guardando rol: $e');
      }
      
      if (mounted) {
        SnackBarHelper.showError(context, 'Error guardando rol');
      }
    }
  }

  /// ✅ NAVEGAR A SELECCIÓN DE ROL
  void _navigateToRoleSelection(User user) {
    if (!mounted) return;
    
    if (kDebugMode) {
      print('📋 Usuario con ${user.roles.length} roles - Mostrando selector');
    }
    
    // ✅ Capturar Navigator ANTES de usar
    final navigator = Navigator.of(context);
    
    navigator.pushNamedAndRemoveUntil(
      'role-selection',
      (route) => false,
      arguments: user,
    );
  }

  /// ✅ DIÁLOGO DE ERROR DE RED con Reintentar
  void _showNetworkErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.wifi_off,
          color: Colors.orange,
          size: 48,
        ),
        title: const Text('Error de conexión'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'No se pudo conectar con el servidor.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Verifica tu conexión a internet e intenta nuevamente.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              
              // Reintentar después de cerrar diálogo
              Future.delayed(const Duration(milliseconds: 100), () {
                if (mounted) {
                  _bloc.add(const LoginSubmit());
                }
              });
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  /// ✅ DIÁLOGO DE ERROR DEL SERVIDOR
  void _showServerErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.cloud_off,
          color: Colors.red,
          size: 48,
        ),
        title: const Text('Servicio no disponible'),
        content: const Text(
          'El servicio no está disponible en este momento. '
          'Por favor, intenta más tarde.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  /// ✅ HELPERS: Rate Limiting

  void _resetRateLimiting() {
    _failedAttempts = 0;
    _lockUntil = null;
  }

  bool get isLocked {
    if (_lockUntil == null) return false;
    
    if (DateTime.now().isAfter(_lockUntil!)) {
      _resetRateLimiting();
      return false;
    }
    
    return true;
  }

  int get lockTimeRemaining {
    if (_lockUntil == null) return 0;
    
    final remaining = _lockUntil!.difference(DateTime.now());
    return remaining.inSeconds > 0 ? remaining.inSeconds : 0;
  }

  @override
  void dispose() {
    // Limpiar recursos si es necesario
    super.dispose();
  }
}