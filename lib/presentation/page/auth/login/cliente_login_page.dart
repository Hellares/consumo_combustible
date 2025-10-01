import 'package:consumo_combustible/core/widgets/loadings/custom_loading.dart';
import 'package:consumo_combustible/core/widgets/snack.dart';
import 'package:consumo_combustible/domain/models/auth_response.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_bloc.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_event.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_state.dart';
import 'package:consumo_combustible/presentation/page/auth/login/cliente_login_content.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class ClienteLoginPage extends StatefulWidget {
  const ClienteLoginPage({super.key});

  @override
  State<ClienteLoginPage> createState() => _ClienteLoginPageState();
}

class _ClienteLoginPageState extends State<ClienteLoginPage> {
  LoginBloc? _bloc;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bloc?.add(const InitEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    _bloc = BlocProvider.of<LoginBloc>(context);

    return RepaintBoundary(
      child: BlocListener<LoginBloc, LoginState>(
        listener: (context, state) {
          final responseState = state.response;
          
          if (responseState is Error) {
            // Defer error handling para evitar bloquear UI
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handleError(context, responseState);
            });
            
          } else if (responseState is Success) {
            final authResponse = responseState.data as AuthResponse;
            _bloc?.add(LoginSaveUserSession(authResponse: authResponse));
            
            // Defer navegación y mostrar éxito
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _handleSuccess(context, authResponse);
            });
            // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            //     Navigator.pushNamedAndRemoveUntil(context, 'user/empresa/roles', (route) => false);
            //   });  
          }
        },
        child: BlocBuilder<LoginBloc, LoginState>(
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

  // Método optimizado para manejar errores
  void _handleError(BuildContext context, Error error) {
    // Verificar que el widget sigue montado
    if (!mounted) return;
    
    // Limpiar error primero
    _bloc?.add(const ClearError());
    
    if (error.isAuthError) {
      // Error de autenticación - UX optimizada con SnackBar
      SnackBarHelper.showError(
        context, 
        'Credenciales incorrectas. Verifica tu DNI y contraseña.'
      );
      
    } else if (error.isNetworkError) {
      // Error de red con opción de reintentar
      _showNetworkErrorDialog(context);
      
    } else if (error.isValidationError) {
      // Error de validación - SnackBar simple
      SnackBarHelper.showWarning(context, error.message);
      
    } else if (error.isServerError) {
      // Error del servidor
      _showServerErrorDialog(context);
      
    } else {
      // Error genérico
      SnackBarHelper.showError(
        context, 
        error.message.isNotEmpty ? error.message : 'Ha ocurrido un error inesperado'
      );
    }
  }

  // Método para manejar éxito
  void _handleSuccess(BuildContext context, AuthResponse authResponse) {
    if (!mounted) return;
    
    // Mostrar mensaje de bienvenida
    final userName = authResponse.data?.user.nombres ?? 'Usuario';
    SnackBarHelper.showSuccess(
      context, 
      'Bienvenido $userName'
    );   
    
  }

  // Diálogo para errores de red
  void _showNetworkErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.wifi_off, color: Colors.orange, size: 48),
        title: const Text('Error de conexión'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No se pudo conectar con el servidor.'),
            SizedBox(height: 8),
            Text(
              'Verifica tu conexión a internet e intenta nuevamente.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Reintentar login con los datos actuales
              Future.delayed(const Duration(milliseconds: 100), () {
                _bloc?.add(const LoginSubmit());
              });
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  // Diálogo para errores del servidor
  void _showServerErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.cloud_off, color: Colors.red, size: 48),
        title: const Text('Servicio no disponible'),
        content: const Text(
          'El servicio no está disponible en este momento. '
          'Por favor, intenta más tarde.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }
}


