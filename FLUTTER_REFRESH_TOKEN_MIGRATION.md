# Migración a Sistema de Refresh Tokens - Flutter App

## 📋 Resumen de Cambios

Se ha implementado un sistema completo de **Dual Token** (Access Token + Refresh Token) en la aplicación Flutter para sincronizar con los cambios del backend.

## 🔄 Cambios Implementados

### 1. **Modelo AuthResponse Actualizado**

**Archivo:** [`lib/domain/models/auth_response.dart`](lib/domain/models/auth_response.dart:5)

**Cambios:**
- ✅ Agregado `accessToken` (reemplaza `token`)
- ✅ Agregado `refreshToken` 
- ✅ Agregado `expiresIn` (duración del token en segundos)
- ✅ Agregado `tokenType` (Bearer por defecto)
- ✅ Mantenida compatibilidad con `token` (deprecated)

```dart
class Data {
  User user;
  String accessToken;
  String refreshToken;
  int expiresIn;
  String tokenType;
}
```

### 2. **AuthService - Nuevos Métodos**

**Archivo:** [`lib/data/datasource/remote/service/auth_service.dart`](lib/data/datasource/remote/service/auth_service.dart:11)

**Métodos Agregados:**

#### `refreshToken(String refreshToken)`
Renueva los tokens usando el refresh token.

```dart
final result = await authService.refreshToken(refreshToken);
if (result is Success<AuthResponse>) {
  // Tokens renovados exitosamente
}
```

#### `logout(String? refreshToken)`
Cierra sesión enviando el refresh token al backend para revocarlo.

```dart
final result = await authService.logout(refreshToken);
```

#### `logoutAll()`
Cierra todas las sesiones activas del usuario.

```dart
final result = await authService.logoutAll();
```

### 3. **AuthRepository - Nuevos Métodos**

**Archivos:** 
- [`lib/domain/repository/auth_repository.dart`](lib/domain/repository/auth_repository.dart:7)
- [`lib/data/repository/auth_repository_impl.dart`](lib/data/repository/auth_repository_impl.dart:11)

**Métodos Agregados:**

```dart
// Renovar tokens
Future<Resource<AuthResponse>> refreshToken(String refreshToken);

// Cerrar todas las sesiones
Future<bool> logoutAll();

// Obtener refresh token del almacenamiento
Future<String?> getRefreshToken();
```

### 4. **Interceptor Automático de Renovación**

**Archivo:** [`lib/data/api/dio_config.dart`](lib/data/api/dio_config.dart:66)

**Características:**
- ✅ Detecta automáticamente errores 401 (token expirado)
- ✅ Renueva tokens automáticamente usando refresh token
- ✅ Reintenta la petición original con el nuevo token
- ✅ Evita múltiples refreshes simultáneos
- ✅ Maneja errores de renovación correctamente

**Flujo Automático:**
```
1. Petición → Error 401
2. Interceptor detecta token expirado
3. Llama a /api/auth/refresh con refreshToken
4. Guarda nuevos tokens
5. Reintenta petición original con nuevo accessToken
6. ✅ Petición exitosa (transparente para el usuario)
```

### 5. **Almacenamiento de Tokens**

**Archivo:** [`lib/data/repository/auth_repository_impl.dart`](lib/data/repository/auth_repository_impl.dart:38)

**Tokens Guardados:**
- `access_token` - Token de acceso (15 minutos)
- `refresh_token` - Token de renovación (7 días)
- `token` - Compatibilidad con código existente
- `user` - Objeto completo con toda la información

**Limpieza en Logout:**
```dart
await Future.wait([
  fastStorage.delete('user'),
  fastStorage.delete('token'),
  fastStorage.delete('access_token'),
  fastStorage.delete('refresh_token'),
  fastStorage.delete('selected_role'),
  fastStorage.delete('selected_location'),
]);
```

## 🚀 Uso en la Aplicación

### Login (Sin Cambios)

El login funciona igual que antes, pero ahora recibe ambos tokens:

```dart
final result = await authRepository.login(dni, password);
if (result is Success<AuthResponse>) {
  final authResponse = result.data;
  // Automáticamente guarda accessToken y refreshToken
  await authRepository.saveUserSession(authResponse);
}
```

### Peticiones Normales (Sin Cambios)

Las peticiones funcionan igual, el interceptor maneja todo automáticamente:

```dart
// El interceptor agrega automáticamente el accessToken
final response = await dio.get('/api/unidades');

// Si el token expira, el interceptor:
// 1. Detecta el error 401
// 2. Renueva los tokens automáticamente
// 3. Reintenta la petición
// Todo esto es TRANSPARENTE para el código
```

### Logout Individual

```dart
// Cierra la sesión actual
final success = await authRepository.logout();
if (success) {
  // Navegar a login
}
```

### Logout de Todas las Sesiones

**Usando Use Case:**
```dart
// Cierra todas las sesiones del usuario en todos los dispositivos
final authUseCases = locator<AuthUseCases>();
final success = await authUseCases.logoutAll.run();
if (success) {
  // Navegar a login
}
```

**Usando Widget LogoutButton:**
```dart
// Botón normal de logout (solo sesión actual)
LogoutButton.profile(
  text: 'Cerrar Sesión',
  onLogoutSuccess: () {
    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
  },
)

// Botón para cerrar TODAS las sesiones
LogoutButton.logoutAll(
  text: 'Cerrar Todas las Sesiones',
  icon: Icons.logout_outlined,
  onLogoutSuccess: () {
    Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
  },
)
```

**Usando BLoC directamente:**
```dart
// Logout normal
context.read<LoginBloc>().add(const LogoutRequested());

// Logout de todas las sesiones
context.read<LoginBloc>().add(const LogoutAllRequested());
```

### Renovación Manual (Opcional)

Si necesitas renovar tokens manualmente:

```dart
final refreshToken = await authRepository.getRefreshToken();
if (refreshToken != null) {
  final result = await authRepository.refreshToken(refreshToken);
  if (result is Success<AuthResponse>) {
    // Tokens renovados
  }
}
```

## 🔧 Compatibilidad con Código Existente

### ✅ Código Antiguo Sigue Funcionando

El código que usa `authResponse.data?.token` sigue funcionando gracias al getter deprecated:

```dart
// ✅ Código antiguo (sigue funcionando)
final token = authResponse.data?.token;

// ✅ Código nuevo (recomendado)
final accessToken = authResponse.data?.accessToken;
final refreshToken = authResponse.data?.refreshToken;
```

### ⚠️ Deprecation Warnings

Verás warnings en el código que usa `.token`, pero no afecta la funcionalidad:

```dart
// Warning: 'token' is deprecated. Use 'accessToken' instead
final token = authResponse.data?.token; // ⚠️ Deprecated pero funcional
```

## 📊 Flujo Completo de Autenticación

```
┌─────────────────────────────────────────────────────────┐
│                    FLUJO EN FLUTTER                     │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. LOGIN                                               │
│     ├─ Usuario ingresa credenciales                    │
│     ├─ authRepository.login(dni, password)             │
│     ├─ Backend retorna accessToken + refreshToken      │
│     ├─ Se guardan ambos tokens en FastStorage          │
│     └─ Usuario autenticado ✅                           │
│                                                         │
│  2. PETICIONES NORMALES                                 │
│     ├─ dio.get('/api/resource')                        │
│     ├─ Interceptor agrega: Authorization: Bearer {at}  │
│     └─ Petición exitosa ✅                              │
│                                                         │
│  3. TOKEN EXPIRA (Automático)                           │
│     ├─ dio.get('/api/resource')                        │
│     ├─ Backend retorna 401 (token expirado)            │
│     ├─ Interceptor detecta 401                         │
│     ├─ Llama a /api/auth/refresh con refreshToken      │
│     ├─ Backend retorna nuevos tokens                   │
│     ├─ Guarda nuevos tokens                            │
│     ├─ Reintenta petición original                     │
│     └─ Petición exitosa ✅ (transparente)              │
│                                                         │
│  4. LOGOUT                                              │
│     ├─ authRepository.logout()                         │
│     ├─ Envía refreshToken al backend                   │
│     ├─ Backend revoca el token                         │
│     ├─ Limpia almacenamiento local                     │
│     └─ Navega a login ✅                                │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## 🛡️ Seguridad

### Tokens Almacenados de Forma Segura

- Los tokens se guardan usando `FastStorageService`
- Access Token: Duración corta (15 minutos)
- Refresh Token: Duración larga (7 días)
- Ambos se limpian completamente en logout

### Renovación Automática

- El interceptor maneja la renovación transparentemente
- No se requiere intervención del usuario
- Si falla la renovación, se redirige a login

### Revocación de Tokens

- Logout individual: Revoca solo el refresh token actual
- Logout all: Revoca todos los refresh tokens del usuario
- Los tokens revocados no pueden usarse nuevamente

## 🎨 Use Cases Implementados

### Archivos Creados:
- ✅ [`logout_all_usecase.dart`](lib/domain/use_cases/auth/logout_all_usecase.dart:1) - Cerrar todas las sesiones
- ✅ [`refresh_token_usecase.dart`](lib/domain/use_cases/auth/refresh_token_usecase.dart:1) - Renovar tokens
- ✅ [`get_refresh_token_usecase.dart`](lib/domain/use_cases/auth/get_refresh_token_usecase.dart:1) - Obtener refresh token

### AuthUseCases Actualizado:
```dart
class AuthUseCases {
  LoginUseCase login;
  LogoutUseCase logout;
  LogoutAllUseCase logoutAll;              // ✅ NUEVO
  RefreshTokenUseCase refreshToken;         // ✅ NUEVO
  GetRefreshTokenUseCase getRefreshToken;   // ✅ NUEVO
  // ... otros use cases
}
```

## 📝 Notas Importantes

### 1. **Código Completamente Actualizado**

Todo el código ha sido migrado para usar `accessToken`:
- No hay código deprecated
- No hay warnings de deprecation
- Todo usa la nueva estructura de tokens

### 2. **Testing**

Prueba estos escenarios:
- ✅ Login normal
- ✅ Peticiones con token válido
- ✅ Esperar 15 minutos y hacer petición (renovación automática)
- ✅ Logout individual
- ✅ Logout desde múltiples dispositivos

### 3. **Manejo de Errores**

Si la renovación falla:
- El interceptor limpia los tokens
- La petición retorna error 401
- El usuario debe hacer login nuevamente

### 4. **Múltiples Dispositivos**

- Cada dispositivo tiene su propio refresh token
- Máximo 5 sesiones activas por usuario
- Al exceder el límite, se revoca la sesión más antigua

## 🔍 Debugging

### Ver Tokens en Debug

```dart
if (kDebugMode) {
  final accessToken = await authRepository.getUserToken();
  final refreshToken = await authRepository.getRefreshToken();
  print('Access Token: ${accessToken?.substring(0, 20)}...');
  print('Refresh Token: ${refreshToken?.substring(0, 20)}...');
}
```

### Logs del Interceptor

El interceptor muestra logs detallados en modo debug:
```
🔄 Token expirado, intentando renovar...
✅ Tokens renovados exitosamente
✅ Petición reintentada con éxito
```

## ✅ Checklist de Migración

- [x] Modelo AuthResponse actualizado sin código deprecated
- [x] AuthService con métodos refresh, logout y logoutAll
- [x] AuthRepository con métodos de refresh tokens
- [x] Interceptor automático de renovación implementado
- [x] Almacenamiento de access_token y refresh_token
- [x] Logout actualizado para enviar refreshToken
- [x] Método logoutAll implementado
- [x] Use cases creados (LogoutAllUseCase, RefreshTokenUseCase, GetRefreshTokenUseCase)
- [x] BLoC actualizado con evento LogoutAllRequested
- [x] Widget LogoutButton con soporte para logoutAll
- [x] Inyección de dependencias actualizada
- [x] Todo el código migrado a accessToken
- [x] Documentación completa

## 🎯 Próximos Pasos

1. **Probar la aplicación** con los nuevos cambios
2. **Verificar** que el login funciona correctamente
3. **Esperar 15 minutos** y hacer una petición para probar la renovación automática
4. **Probar logout** individual y logout-all
5. **Migrar gradualmente** el código para usar `accessToken` en lugar de `token`

## 📚 Referencias

- [Backend Documentation](lib/presentation/page/auth/README_REFRESH_TOKENS.md)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)
- [OWASP Authentication](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)

---

**Fecha de Implementación:** 29 de Octubre, 2025  
**Versión:** 1.0.0  
**Estado:** ✅ Completado