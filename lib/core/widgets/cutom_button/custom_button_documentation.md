# 🚀 CustomButton - Documentación Completa

## 📋 Índice
- [Descripción General](#descripción-general)
- [Características Principales](#características-principales)
- [Estados del Botón](#estados-del-botón)
- [Propiedades](#propiedades)
- [Instalación y Uso Básico](#instalación-y-uso-básico)
- [Integración con BLoC](#integración-con-bloc)
- [Ejemplos de Uso](#ejemplos-de-uso)
- [Casos de Uso Comunes](#casos-de-uso-comunes)
- [Optimizaciones de Rendimiento](#optimizaciones-de-rendimiento)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Descripción General

El `CustomButton` es un widget avanzado diseñado específicamente para trabajar con BLoC (Business Logic Component) y gestionar estados de manera eficiente. Proporciona feedback visual inmediato y previene interacciones no deseadas durante procesos asíncronos.

### ✨ Características Destacadas
- **Gestión automática de estados** (idle, loading, success, error)
- **Animaciones fluidas** con efectos de presión y flash
- **Optimizado para rendimiento** con sistema de cache
- **Integración nativa con BLoC**
- **Feedback háptico** opcional
- **Personalización completa** de colores y estilos

---

## 🎨 Características Principales

### 🎭 Estados Visuales
- **Idle**: Estado normal, completamente interactivo
- **Loading**: Muestra spinner + texto, deshabilitado
- **Success**: Muestra ícono de check + texto, deshabilitado
- **Error**: Muestra ícono de error + texto, deshabilitado

### 🎪 Efectos Visuales
- **Animación de escala** al presionar
- **Efecto flash** al hacer clic
- **Sombras dinámicas** basadas en colores
- **Bordes animados** que cambian de grosor
- **Gradientes personalizables**

### ⚡ Optimizaciones
- **Cache inteligente** de valores calculados
- **Pre-cálculo** de colores y estilos
- **Reducción de rebuilds** innecesarios
- **Gestión eficiente de memoria**

---

## 📊 Estados del Botón

```dart
enum ButtonState {
  idle,     // Estado normal - completamente interactivo
  loading,  // Cargando - muestra CircularProgressIndicator
  success,  // Éxito - muestra ícono de check
  error,    // Error - muestra ícono de error
}
```

### 🔄 Flujo de Estados Típico
```
idle → loading → success → idle
idle → loading → error → idle
```

---

## 🛠️ Propiedades

### 🔧 Propiedades Básicas
```dart
class CustomButton extends StatefulWidget {
  final String text;                    // Texto principal del botón
  final VoidCallback? onPressed;        // Callback al presionar
  final bool enabled;                   // Habilitar/deshabilitar
  final ButtonState buttonState;        // Estado actual del botón
}
```

### 🎨 Propiedades de Estilo
```dart
final Gradient gradient;                 // Gradiente de fondo
final Color? borderColor;               // Color del borde
final double borderWidth;               // Grosor del borde
final double? width;                    // Ancho personalizado
final double? height;                   // Alto personalizado
final double? borderRadius;             // Radio de las esquinas
final EdgeInsetsGeometry? padding;      // Padding interno
final TextStyle? textStyle;             // Estilo del texto (prioridad alta)
```

### 🎨 Propiedades de Texto Personalizables
```dart
final Color? textColor;                 // Color del texto
final FontWeight? fontWeight;           // Peso de la fuente
final double? fontSize;                 // Tamaño de la fuente
```

### 🎨 Propiedades de Íconos Personalizables
```dart
final Color? iconColor;                 // Color de los íconos (check y error)
```

### 🔄 Propiedades de Estado
```dart
final String? loadingText;              // Texto durante carga
final String? successText;              // Texto en éxito
final String? errorText;                // Texto en error
final Color? loadingIndicatorColor;     // Color del spinner
final double? loadingIndicatorSize;     // Tamaño del spinner
final Duration? stateResetDuration;     // Duración para resetear estado
```

### ⚙️ Propiedades de Animación
```dart
final Duration animationDuration;       // Duración de animaciones
final bool showHapticFeedback;         // Feedback háptico
```

---

## 🚀 Instalación y Uso Básico

### 1. Importar el Widget
```dart
import 'package:tu_app/src/presentation/widgets/custom_button.dart';
```

### 2. Uso Básico
```dart
CustomButton(
  text: 'Presionar',
  gradient: AppGradients.fondo,
  onPressed: () {
    print('¡Botón presionado!');
  },
)
```

### 3. Con Estado
```dart
CustomButton(
  text: 'Iniciar Sesión',
  gradient: AppGradients.fondo,
  buttonState: ButtonState.loading,
  loadingText: 'Iniciando...',
  onPressed: () {
    // Lógica del botón
  },
)
```

---

## 🔄 Integración con BLoC

### 1. Mapeo de Estados
```dart
ButtonState _mapBlocStateToButtonState(AuthState blocState) {
  switch (blocState) {
    case AuthState.idle:
      return ButtonState.idle;
    case AuthState.loading:
      return ButtonState.loading;
    case AuthState.success:
      return ButtonState.success;
    case AuthState.error:
      return ButtonState.error;
  }
}
```

### 2. Implementación con BlocBuilder
```dart
BlocBuilder<AuthBloc, AuthState>(
  builder: (context, state) {
    return CustomButton(
      text: 'Iniciar Sesión',
      gradient: AppGradients.fondo,
      borderColor: AppColors.blue,
      buttonState: _mapBlocStateToButtonState(state),
      loadingText: 'Iniciando sesión...',
      successText: '¡Bienvenido!',
      errorText: 'Error de conexión',
      onPressed: () {
        context.read<AuthBloc>().add(LoginRequested(
          email: _emailController.text,
          password: _passwordController.text,
        ));
      },
    );
  },
)
```

### 3. BLoC Event Handler
```dart
Future<void> _onLoginRequested(
  LoginRequested event,
  Emitter<AuthState> emit,
) async {
  emit(AuthState.loading); // → ButtonState.loading
  
  try {
    final result = await authRepository.login(
      event.email,
      event.password,
    );
    
    emit(AuthState.success); // → ButtonState.success
    await Future.delayed(Duration(seconds: 1));
    emit(AuthState.idle); // → ButtonState.idle
    
  } catch (e) {
    emit(AuthState.error); // → ButtonState.error
    await Future.delayed(Duration(seconds: 2));
    emit(AuthState.idle); // → ButtonState.idle
  }
}
```

---

## 📝 Ejemplos de Uso

### 🎯 Ejemplo 1: Login Simple
```dart
CustomButton(
  text: 'Iniciar Sesión',
  gradient: AppGradients.fondo,
  borderColor: AppColors.blue,
  buttonState: _loginButtonState,
  loadingText: 'Iniciando sesión...',
  successText: '¡Bienvenido!',
  errorText: 'Error de conexión',
  onPressed: _handleLogin,
)
```

### 🎯 Ejemplo 2: Registro con Validación
```dart
CustomButton(
  text: 'Crear Cuenta',
  gradient: AppGradients.fondoVertical(),
  borderColor: AppColors.green,
  buttonState: _registerButtonState,
  loadingText: 'Creando cuenta...',
  successText: '¡Cuenta creada!',
  errorText: 'Error al registrar',
  onPressed: _isFormValid ? _handleRegister : null,
)
```

### 🎯 Ejemplo 3: Botón con Personalización Avanzada
```dart
CustomButton(
  text: 'Enviar Datos',
  gradient: AppGradients.fondoHorizontal(),
  borderColor: AppColors.orange,
  borderWidth: 2.0,
  borderRadius: 12.0,
  width: 200,
  height: 50,
  buttonState: _submitButtonState,
  loadingText: 'Enviando...',
  successText: '¡Enviado!',
  errorText: 'Error al enviar',
  loadingIndicatorColor: Colors.white,
  loadingIndicatorSize: 20.0,
  showHapticFeedback: true,
  onPressed: _handleSubmit,
)
```

### 🎯 Ejemplo 4: Botón con Texto Personalizado
```dart
CustomButton(
  text: 'Texto Personalizado',
  gradient: AppGradients.fondo,
  borderColor: AppColors.blue,
  textColor: Colors.white,           // Color del texto
  fontWeight: FontWeight.bold,       // Peso de la fuente
  fontSize: 18.0,                   // Tamaño de la fuente
  onPressed: () => print('Presionado'),
)
```

### 🎯 Ejemplo 5: Botón con Diferentes Estilos de Texto
```dart
// Texto grande y negrita
CustomButton(
  text: 'Título Grande',
  gradient: AppGradients.fondo,
  fontSize: 24.0,
  fontWeight: FontWeight.w900,
  textColor: Colors.white,
  onPressed: () {},
)

// Texto pequeño y ligero
CustomButton(
  text: 'Texto Pequeño',
  gradient: AppGradients.fondoVertical(),
  fontSize: 12.0,
  fontWeight: FontWeight.w300,
  textColor: Colors.black87,
  onPressed: () {},
)

// Texto con color personalizado
CustomButton(
  text: 'Texto Azul',
  gradient: AppGradients.sinfondo,
  borderColor: AppColors.blue,
  textColor: AppColors.blue,
  fontWeight: FontWeight.w600,
  fontSize: 16.0,
  onPressed: () {},
)
```

### 🎯 Ejemplo 4: Botón Simple (Sin Estados)
```dart
CustomButton(
  text: 'Botón Simple',
  gradient: AppGradients.sinfondo,
  borderColor: AppColors.red,
  onPressed: () {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Funcionando!')),
    );
  },
)
```

### 🎯 Ejemplo 5: Botón con Texto Personalizado
```dart
CustomButton(
  text: 'Texto Personalizado',
  gradient: AppGradients.fondo,
  borderColor: AppColors.blue,
  textColor: Colors.white,           // Color del texto
  fontWeight: FontWeight.bold,       // Peso de la fuente
  fontSize: 18.0,                   // Tamaño de la fuente
  onPressed: () => print('Presionado'),
)
```

### 🎯 Ejemplo 6: Botón con Diferentes Estilos de Texto
```dart
// Texto grande y negrita
CustomButton(
  text: 'Título Grande',
  gradient: AppGradients.fondo,
  fontSize: 24.0,
  fontWeight: FontWeight.w900,
  textColor: Colors.white,
  onPressed: () {},
)

// Texto pequeño y ligero
CustomButton(
  text: 'Texto Pequeño',
  gradient: AppGradients.fondoVertical(),
  fontSize: 12.0,
  fontWeight: FontWeight.w300,
  textColor: Colors.black87,
  onPressed: () {},
)

// Texto con color personalizado
CustomButton(
  text: 'Texto Azul',
  gradient: AppGradients.sinfondo,
  borderColor: AppColors.blue,
  textColor: AppColors.blue,
  fontWeight: FontWeight.w600,
  fontSize: 16.0,
  onPressed: () {},
)
```

### 🎯 Ejemplo 7: Botón con Íconos Personalizados
```dart
// Botón con íconos verdes
CustomButton(
  text: 'Éxito Verde',
  gradient: AppGradients.fondo,
  borderColor: AppColors.green,
  iconColor: Colors.green,           // Color de los íconos
  textColor: Colors.white,
  fontWeight: FontWeight.bold,
  fontSize: 16.0,
  buttonState: ButtonState.success,   // Para ver el ícono de check
  successText: '¡Completado!',
  onPressed: () {},
)

// Botón con íconos rojos
CustomButton(
  text: 'Error Rojo',
  gradient: AppGradients.fondo,
  borderColor: AppColors.red,
  iconColor: Colors.red,             // Color de los íconos
  textColor: Colors.white,
  fontWeight: FontWeight.bold,
  fontSize: 16.0,
  buttonState: ButtonState.error,     // Para ver el ícono de error
  errorText: 'Error',
  onPressed: () {},
)

// Botón con íconos azules
CustomButton(
  text: 'Info Azul',
  gradient: AppGradients.sinfondo,
  borderColor: AppColors.blue,
  iconColor: AppColors.blue,         // Color de los íconos
  textColor: AppColors.blue,
  fontWeight: FontWeight.w600,
  fontSize: 14.0,
  buttonState: ButtonState.success,
  successText: 'Información',
  onPressed: () {},
)
```

---

## 🎯 Casos de Uso Comunes

### 🔐 Autenticación
```dart
// Login
CustomButton(
  text: 'Iniciar Sesión',
  buttonState: _authBloc.state.buttonState,
  loadingText: 'Verificando...',
  successText: '¡Bienvenido!',
  errorText: 'Credenciales inválidas',
  onPressed: () => _authBloc.add(LoginRequested()),
)

// Registro
CustomButton(
  text: 'Crear Cuenta',
  buttonState: _authBloc.state.registerState,
  loadingText: 'Creando cuenta...',
  successText: '¡Cuenta creada!',
  errorText: 'Error al registrar',
  onPressed: () => _authBloc.add(RegisterRequested()),
)
```

### 💾 Operaciones CRUD
```dart
// Guardar
CustomButton(
  text: 'Guardar',
  buttonState: _formBloc.state.saveState,
  loadingText: 'Guardando...',
  successText: '¡Guardado!',
  errorText: 'Error al guardar',
  onPressed: () => _formBloc.add(SaveRequested()),
)

// Eliminar
CustomButton(
  text: 'Eliminar',
  gradient: AppGradients.error,
  borderColor: AppColors.red,
  buttonState: _deleteBloc.state.deleteState,
  loadingText: 'Eliminando...',
  successText: '¡Eliminado!',
  errorText: 'Error al eliminar',
  onPressed: () => _deleteBloc.add(DeleteRequested()),
)
```

### 📤 Envío de Datos
```dart
// Enviar formulario
CustomButton(
  text: 'Enviar',
  buttonState: _formBloc.state.submitState,
  loadingText: 'Enviando...',
  successText: '¡Enviado!',
  errorText: 'Error al enviar',
  onPressed: _isFormValid ? () => _formBloc.add(SubmitRequested()) : null,
)
```

---

## ⚡ Optimizaciones de Rendimiento

### 🎯 Sistema de Cache
El botón implementa un sistema de cache inteligente que:
- **Pre-calcula** colores de sombra
- **Cachea** gradientes deshabilitados
- **Almacena** estilos de texto
- **Optimiza** border radius y padding

### 🔄 Reducción de Rebuilds
- **AnimatedBuilder** optimizado
- **Listenable.merge** para múltiples animaciones
- **setState** mínimo necesario

### 💾 Gestión de Memoria
- **Dispose** automático de controllers
- **Cache** con null safety
- **Prevención** de memory leaks

---

## 🔧 Troubleshooting

### ❌ Problema: Botón no responde
**Solución:**
```dart
// Verificar que el estado sea idle
buttonState: ButtonState.idle, // ✅ Correcto
buttonState: ButtonState.loading, // ❌ Deshabilitado
```

### ❌ Problema: Animaciones lentas
**Solución:**
```dart
// Reducir duración de animación
animationDuration: Duration(milliseconds: 200), // Más rápido
```

### ❌ Problema: Colores no se aplican
**Solución:**
```dart
// Asegurar que las propiedades estén definidas
borderColor: AppColors.blue, // ✅ Definido
gradient: AppGradients.fondo, // ✅ Definido
```

### ❌ Problema: Texto no se muestra
**Solución:**
```dart
// Verificar que el texto esté definido
text: 'Mi Botón', // ✅ Definido
loadingText: 'Cargando...', // ✅ Opcional
```

---

## 📚 Mejores Prácticas

### ✅ DO's
- ✅ Usar `BlocBuilder` para gestión de estados
- ✅ Proporcionar textos para todos los estados
- ✅ Manejar errores apropiadamente
- ✅ Usar colores consistentes con tu tema
- ✅ Implementar feedback háptico para mejor UX

### ❌ DON'Ts
- ❌ No usar estados loading sin timeout
- ❌ No olvidar resetear estados después de error
- ❌ No usar colores que no contrasten bien
- ❌ No hacer el botón muy pequeño para touch

---

## 🎨 Personalización Avanzada

### 🎨 Gradientes Personalizados
```dart
CustomButton(
  text: 'Botón Personalizado',
  gradient: LinearGradient(
    colors: [Colors.blue, Colors.purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  ),
  // ...
)
```

### 🎨 Sombras Personalizadas
```dart
// El botón automáticamente genera sombras basadas en borderColor
CustomButton(
  text: 'Con Sombra',
  borderColor: AppColors.blue, // Genera sombra azul
  // ...
)
```

### 🎨 Animaciones Personalizadas
```dart
CustomButton(
  text: 'Animación Rápida',
  animationDuration: Duration(milliseconds: 150),
  showHapticFeedback: false,
  // ...
)
```

### 🎨 Texto Personalizado
```dart
// Personalización básica de texto
CustomButton(
  text: 'Mi Botón',
  textColor: Colors.white,           // Color del texto
  fontWeight: FontWeight.bold,       // Peso de la fuente
  fontSize: 16.0,                   // Tamaño de la fuente
  // ...
)

// Prioridad de estilos (textStyle tiene prioridad)
CustomButton(
  text: 'Texto con Prioridad',
  textColor: Colors.red,             // Se ignora si textStyle está definido
  fontWeight: FontWeight.w600,       // Se ignora si textStyle está definido
  fontSize: 18.0,                   // Se ignora si textStyle está definido
  textStyle: TextStyle(              // Este tiene prioridad
    color: Colors.blue,
    fontWeight: FontWeight.w900,
    fontSize: 20.0,
  ),
  // ...
)
```

### 🎨 Íconos Personalizados
```dart
// Color de íconos personalizado
CustomButton(
  text: 'Con Íconos',
  iconColor: Colors.green,           // Color de check y error
  textColor: Colors.white,
  // ...
)

// Combinación de texto e íconos personalizados
CustomButton(
  text: 'Estilo Completo',
  textColor: Colors.white,           // Color del texto
  iconColor: Colors.orange,          // Color de los íconos
  fontWeight: FontWeight.bold,
  fontSize: 18.0,
  // ...
)
```

---

## 📱 Compatibilidad

### ✅ Plataformas Soportadas
- ✅ Android
- ✅ iOS
- ✅ Web
- ✅ Desktop (Windows, macOS, Linux)

### ✅ Versiones de Flutter
- ✅ Flutter 3.0+
- ✅ Dart 2.17+

---

## 🤝 Contribución

Para contribuir al desarrollo del `CustomButton`:

1. **Fork** el repositorio
2. **Crea** una rama para tu feature
3. **Implementa** tus cambios
4. **Testea** exhaustivamente
5. **Envía** un Pull Request

---

## 📄 Licencia

Este widget está bajo la licencia MIT. Ver `LICENSE` para más detalles.

---

## 📞 Soporte

Si tienes preguntas o problemas:

- 📧 Email: soporte@tuapp.com
- 🐛 Issues: GitHub Issues
- 📖 Documentación: Esta guía
- 💬 Discord: Canal de la comunidad

---

*¡Disfruta usando tu CustomButton optimizado para BLoC! 🚀* 