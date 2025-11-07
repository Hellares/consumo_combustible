# 🔄 Guía de Pruebas para Refresh Token

## 🧪 Pasos para verificar que el refresh token funciona correctamente:

### 1. **Activar Debug Logs**
Asegúrate que `kDebugMode` esté activo para ver los logs de refresh.

### 2. **Probar Manualmente**

```bash
# 1. Inicia sesión y espera 15 minutos (tiempo de expiración del token)
# 2. Realiza cualquier llamada a la API (ej: listar tickets)
# 3. Observa los logs en la consola:

# ✅ Esperado:
# 🔄 Token expirado, intentando renovar...
# 📡 Llamando a /api/auth/refresh...
# 📡 Refresh response status: 200
# ✅ Tokens renovados exitosamente
# ✅ Petición reintentada exitosamente

# ❌ Si hay problemas:
# ❌ Refresh token inválido o expirado
# 🧹 Tokens limpiados - usuario debe hacer login nuevamente
```

### 3. **Verificar Storage**

```dart
// En cualquier parte de tu código, puedes verificar los tokens:
final fastStorage = GetIt.instance<FastStorageService>();
final accessToken = await fastStorage.read('access_token');
final refreshToken = await fastStorage.read('refresh_token');
print('Access Token: $accessToken');
print('Refresh Token: $refreshToken');
```

### 4. **Casos de Prueba**

#### ✅ **Caso 1: Refresh exitoso**
1. Token expira (401)
2. Interceptor detecta 401
3. Llama a /api/auth/refresh
4. Obtiene nuevos tokens
5. Reintenta petición original
6. Petición original funciona con nuevo token

#### ❌ **Caso 2: Refresh token expirado**
1. Token expira (401)
2. Interceptor llama a /api/auth/refresh
3. Backend responde con error (refresh inválido)
4. Se limpian todos los tokens locales
5. Usuario debe hacer login nuevamente

#### ❌ **Caso 3: Sin conexión**
1. Token expira (401)
2. Interceptor intenta refresh
3. Falla por conexión
4. Se limpian tokens locales
5. Usuario debe hacer login nuevamente

### 5. **Logs Importantes a Observar**

- `🔄 Token expirado, intentando renovar...` - Inicio del refresh
- `📡 Refresh response status: 200` - Refresh exitoso
- `✅ Tokens renovados exitosamente` - Tokens guardados
- `✅ Petición reintentada exitosamente` - Reintento funcionó
- `❌ Refresh token inválido o expirado` - Error en refresh
- `🧹 Tokens limpiados` - Sesión cerrada por seguridad

### 6. **Verificación en Red**

Usa herramientas como Charles Proxy o Wireshark para ver:
1. Primera petición con Authorization: Bearer <token_viejo>
2. Respuesta 401 del servidor
3. Petición a /api/auth/refresh con refreshToken
4. Nueva petición original con Authorization: Bearer <token_nuevo>

### 7. **Troubleshooting Común**

#### Si el refresh no se dispara:
- Verifica que el endpoint no esté en `_isAuthEndpoint()`
- Asegúrate que la respuesta sea exactamente 401
- Verifica que el interceptor esté registrado en Dio

#### Si el refresh falla:
- Revisa que el refresh token esté guardado correctamente
- Verifica que el backend esté funcionando
- Revisa la URL del endpoint de refresh

#### Si el reintento falla:
- Verifica que el nuevo token se esté guardando correctamente
- Revisa los headers de la petición reintentada
- Asegúrate que `_isRefreshing` se resetee correctamente

### 8. **Testing con Postman**

1. Copia el refresh token del storage
2. Haz una petición POST a `/api/auth/refresh` con:
   ```json
   {
     "refreshToken": "tu_refresh_token_aqui"
   }
   ```
3. Deberías recibir:
   ```json
   {
     "success": true,
     "message": "Tokens renovados",
     "data": {
       "accessToken": "nuevo_access_token",
       "refreshToken": "nuevo_refresh_token",
       "expiresIn": 900,
       "tokenType": "Bearer"
     }
   }
   ```

## 🚨 **Importante**

- Los refresh tokens son más largos que los access tokens
- El refresh token también expira, pero después de más tiempo
- Si el refresh token expira, el usuario debe hacer login manualmente
- El sistema automáticamente limpia los tokens cuando el refresh falla