# Guía de Implementación: Evento `authenticated` en Backend

## 📋 Resumen

El frontend ahora espera un evento `authenticated` del servidor antes de suscribirse al tracking GPS. Esto elimina race conditions y hace el sistema más robusto.

## 🎯 Objetivo

Emitir un evento `authenticated` cuando el cliente complete exitosamente la autenticación JWT en el WebSocket.

---

## 🔧 Implementación en NestJS

### Ubicación del Código

Archivo: `src/gps/gps.gateway.ts` (o similar)

### Cambios Necesarios

#### 1. Emitir evento después de autenticación exitosa

```typescript
@WebSocketGateway({
  namespace: '/gps',
  cors: { origin: '*' }
})
export class GpsGateway implements OnGatewayConnection, OnGatewayDisconnect {
  
  async handleConnection(client: Socket) {
    try {
      // ... código existente de autenticación JWT ...
      
      const token = this.extractToken(client);
      const payload = await this.jwtService.verifyAsync(token);
      const user = await this.usuariosService.findOne(payload.id);
      
      if (!user) {
        throw new WsException('Usuario no encontrado');
      }

      // Guardar usuario en socket
      client.data.user = user;
      client.data.userId = user.id;
      client.data.roles = user.roles;

      // Unir a rooms
      await this.joinUserRooms(client, user);

      // ✅ NUEVO: Emitir evento de autenticación completada
      client.emit('authenticated', {
        userId: user.id,
        dni: user.dni,
        roles: user.roles.map(r => r.nombre),
        timestamp: new Date().toISOString()
      });

      this.logger.log(
        `✅ Cliente autenticado: ${client.id} | Usuario: ${user.dni}`
      );

    } catch (error) {
      this.logger.error(`❌ Error en autenticación: ${error.message}`);
      client.emit('error', {
        event: 'connection',
        message: 'Error de autenticación',
        code: 'AUTH_ERROR'
      });
      client.disconnect();
    }
  }

  // ... resto del código ...
}
```

#### 2. Actualizar evento `connection:status` (Opcional - Fallback)

Si ya tienes un evento `connection:status`, asegúrate de incluir la información de autenticación:

```typescript
client.emit('connection:status', {
  connected: true,
  userId: user.id,
  roles: user.roles.map(r => r.nombre),
  timestamp: new Date().toISOString()
});
```

---

## 📊 Flujo Completo

### Antes (con delay)
```
1. Cliente conecta → connect event
2. Cliente espera 1.5s (delay arbitrario)
3. Cliente envía tracking:subscribe
4. Servidor procesa (puede fallar si aún no autenticó)
```

### Ahora (con evento authenticated)
```
1. Cliente conecta → connect event
2. Servidor autentica JWT
3. Servidor emite → authenticated event ✅
4. Cliente recibe authenticated
5. Cliente envía tracking:subscribe
6. Servidor procesa (siempre autenticado) ✅
```

---

## 🧪 Testing

### Verificar que el evento se emite correctamente

```typescript
// En tus tests
it('should emit authenticated event after successful connection', (done) => {
  const client = io('http://localhost:3000/gps', {
    auth: { token: validToken }
  });

  client.on('authenticated', (data) => {
    expect(data).toHaveProperty('userId');
    expect(data).toHaveProperty('roles');
    expect(data).toHaveProperty('timestamp');
    done();
  });

  client.on('connect_error', (error) => {
    done(error);
  });
});
```

### Logs esperados en el servidor

```
🔌 [Gateway] Cliente intentando conectar: abc123
🔍 [Gateway] Token encontrado
✅ [Gateway] Token válido - User ID: 35
✅ [Gateway] Usuario encontrado: 11111111 (JAMES)
📡 [Gateway] Uniendo a rooms...
✅ [Gateway] Unido a room: all
✅ [Gateway] Unido a room: admins
✅ Cliente autenticado: abc123 | Usuario: 11111111  ← NUEVO LOG
```

---

## 🔄 Compatibilidad con Frontend Antiguo

El cambio es **backward compatible**. Si el frontend no escucha el evento `authenticated`, el sistema usa el evento `connection:status` como fallback.

```typescript
// Frontend maneja ambos casos
_socket!.on('authenticated', handleAuth);  // Preferido
_socket!.on('connection:status', handleAuthFallback);  // Fallback
```

---

## ⚠️ Consideraciones Importantes

1. **Timeout**: El frontend espera máximo 5 segundos por el evento
2. **Orden**: El evento debe emitirse DESPUÉS de unir al usuario a los rooms
3. **Errores**: Si la autenticación falla, NO emitir el evento
4. **Reconexión**: Emitir el evento también en reconexiones

---

## 📝 Checklist de Implementación

- [ ] Agregar emisión de evento `authenticated` después de autenticación exitosa
- [ ] Incluir `userId`, `roles` y `timestamp` en el payload
- [ ] Actualizar logs para confirmar emisión del evento
- [ ] Probar con cliente real (Flutter app)
- [ ] Verificar que funciona en reconexiones
- [ ] Documentar en README del backend

---

## 🐛 Troubleshooting

### El frontend no recibe el evento

**Verificar:**
1. ¿El evento se emite DESPUÉS de la autenticación?
2. ¿El nombre del evento es exactamente `authenticated`?
3. ¿El payload incluye los campos requeridos?
4. ¿Los logs del servidor muestran la emisión?

### El frontend sigue usando el delay

**Verificar:**
1. ¿El código del frontend está actualizado?
2. ¿Se recompiló la app después de los cambios?
3. ¿Los logs muestran "Esperando autenticación..."?

---

## 📚 Referencias

- Socket.IO Events: https://socket.io/docs/v4/emitting-events/
- NestJS WebSockets: https://docs.nestjs.com/websockets/gateways
- JWT Authentication: https://docs.nestjs.com/security/authentication

---

## ✅ Resultado Esperado

Después de implementar estos cambios:

✅ No más delays arbitrarios en el frontend
✅ Sincronización determinística basada en eventos
✅ Mejor experiencia de usuario (más rápido)
✅ Sistema más robusto y predecible
✅ Logs claros del flujo de autenticación
