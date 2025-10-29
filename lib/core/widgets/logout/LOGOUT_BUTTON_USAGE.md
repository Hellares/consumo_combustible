# LogoutButton - Guía de Uso

## 📋 Descripción

Widget reutilizable para cerrar sesión con soporte para:
- ✅ Logout individual (sesión actual)
- ✅ Logout de todas las sesiones (todos los dispositivos)
- ✅ Múltiples estilos (icono, texto, icono+texto)
- ✅ Diálogo de confirmación personalizable
- ✅ Estados de carga

## 🎨 Estilos Disponibles

### 1. **LogoutButton.appBar()**
Para usar en AppBar (solo icono)

```dart
AppBar(
  title: Text('Mi App'),
  actions: [
    LogoutButton.appBar(
      icon: Icons.logout,
      onLogoutSuccess: () {
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
      },
    ),
  ],
)
```

### 2. **LogoutButton.drawer()**
Para usar en Drawer/menú lateral (icono + texto)

```dart
Drawer(
  child: ListView(
    children: [
      // ... otros items
      LogoutButton.drawer(
        text: 'Cerrar Sesión',
        icon: Icons.logout,
        onLogoutSuccess: () {
          Navigator.pop(context); // Cerrar drawer
          Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
        },
      ),
    ],
  ),
)
```

### 3. **LogoutButton.profile()**
Para usar en página de perfil (solo texto, estilo botón)

```dart
Column(
  children: [
    // ... información del perfil
    
    LogoutButton.profile(
      text: 'Cerrar Sesión',
      onLogoutSuccess: () {
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
      },
    ),
  ],
)
```

### 4. **LogoutButton.iconOnly()**
Solo icono sin fondo

```dart
Row(
  children: [
    LogoutButton.iconOnly(
      icon: Icons.logout,
      color: Colors.red,
      onLogoutSuccess: () {
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
      },
    ),
  ],
)
```

### 5. **LogoutButton.logoutAll()** ⭐ NUEVO
Para cerrar TODAS las sesiones del usuario

```dart
Column(
  children: [
    // Logout normal
    LogoutButton.profile(
      text: 'Cerrar Sesión',
      onLogoutSuccess: () {
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
      },
    ),
    
    SizedBox(height: 16),
    
    // Logout de todas las sesiones
    LogoutButton.logoutAll(
      text: 'Cerrar Todas las Sesiones',
      icon: Icons.logout_outlined,
      onLogoutSuccess: () {
        Navigator.pushNamedAndRemoveUntil(context, 'login', (route) => false);
      },
    ),
  ],
)
```

## 🔧 Personalización Avanzada

### Constructor Completo

```dart
LogoutButton(
  text: 'Cerrar Sesión',
  icon: Icons.logout,
  style: LogoutButtonStyle.iconWithText,
  logoutAll: false, // true para cerrar todas las sesiones
  showConfirmDialog: true,
  backgroundColor: Colors.blue,
  textColor: Colors.white,
  iconColor: Colors.white,
  fontSize: 14,
  padding: EdgeInsets.all(12),
  borderRadius: 8,
  onLogoutSuccess: () {
    // Callback después de logout exitoso
  },
  onLogoutError: () {
    // Callback en caso de error
  },
)
```

## 💡 Ejemplos de Uso Completos

### Ejemplo 1: Página de Perfil con Ambos Botones

```dart
class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mi Perfil'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // ... información del usuario
            
            SizedBox(height: 24),
            
            // Sección de seguridad
            Text(
              'Seguridad',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            SizedBox(height: 16),
            
            // Logout normal
            LogoutButton.profile(
              text: 'Cerrar Sesión',
              onLogoutSuccess: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  'login',
                  (route) => false,
                );
              },
            ),
            
            SizedBox(height: 12),
            
            // Logout de todas las sesiones
            LogoutButton.logoutAll(
              text: 'Cerrar Todas las Sesiones',
              icon: Icons.devices_other,
              onLogoutSuccess: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  'login',
                  (route) => false,
                );
              },
            ),
            
            SizedBox(height: 8),
            
            Text(
              'Cierra tu sesión en todos los dispositivos',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Ejemplo 2: Drawer con Ambas Opciones

```dart
Drawer(
  child: ListView(
    children: [
      DrawerHeader(
        child: Text('Menú'),
      ),
      
      // ... otros items del menú
      
      Divider(),
      
      // Logout normal
      LogoutButton.drawer(
        text: 'Cerrar Sesión',
        icon: Icons.logout,
        onLogoutSuccess: () {
          Navigator.pop(context); // Cerrar drawer
          Navigator.pushNamedAndRemoveUntil(
            context,
            'login',
            (route) => false,
          );
        },
      ),
      
      // Logout de todas las sesiones
      ListTile(
        leading: Icon(Icons.devices_other, color: Colors.red),
        title: Text(
          'Cerrar Todas las Sesiones',
          style: TextStyle(color: Colors.red),
        ),
        onTap: () {
          Navigator.pop(context); // Cerrar drawer
          // Mostrar diálogo de confirmación
          context.read<LoginBloc>().add(const LogoutAllRequested());
        },
      ),
    ],
  ),
)
```

### Ejemplo 3: Configuración de Seguridad

```dart
class SecuritySettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seguridad')),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Sección de sesiones activas
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.devices, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Sesiones Activas',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 12),
                  
                  Text(
                    'Tienes sesiones activas en múltiples dispositivos.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  
                  SizedBox(height: 16),
                  
                  // Botón para cerrar todas las sesiones
                  SizedBox(
                    width: double.infinity,
                    child: LogoutButton.logoutAll(
                      text: 'Cerrar Todas las Sesiones',
                      icon: Icons.logout_outlined,
                      onLogoutSuccess: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          'login',
                          (route) => false,
                        );
                      },
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  Text(
                    'Esto cerrará tu sesión en todos los dispositivos donde hayas iniciado sesión.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## 🔄 Diferencias entre Logout y LogoutAll

| Característica | Logout Normal | Logout All |
|----------------|---------------|------------|
| **Sesiones cerradas** | Solo la actual | Todas |
| **Dispositivos afectados** | Solo este | Todos |
| **Refresh tokens revocados** | 1 | Todos |
| **Uso recomendado** | Cierre normal | Seguridad/sospecha |
| **Confirmación** | Estándar | Más enfática |

## 🎯 Cuándo Usar LogoutAll

### ✅ Casos de Uso Recomendados:

1. **Cambio de Contraseña**
   - Después de cambiar la contraseña, cerrar todas las sesiones

2. **Sospecha de Acceso No Autorizado**
   - Si el usuario sospecha que alguien más tiene acceso

3. **Dispositivo Perdido/Robado**
   - Cerrar sesiones remotamente desde otro dispositivo

4. **Limpieza de Seguridad**
   - Opción en configuración de seguridad

### ❌ NO Usar LogoutAll Para:

- Cierre de sesión normal/diario
- Cambio de cuenta
- Testing/desarrollo

## 🛡️ Seguridad

### Confirmación Diferenciada

El widget muestra diferentes mensajes según el tipo de logout:

**Logout Normal:**
```
¿Estás seguro que deseas cerrar sesión?

Tendrás que iniciar sesión nuevamente.
```

**Logout All:**
```
¿Estás seguro que deseas cerrar sesión en TODOS los dispositivos?

Esto cerrará tu sesión en todos los lugares donde hayas iniciado sesión.
```

## 📱 Integración con BLoC

El widget se integra automáticamente con el `LoginBloc`:

```dart
// El widget internamente hace:
if (logoutAll) {
  context.read<LoginBloc>().add(const LogoutAllRequested());
} else {
  context.read<LoginBloc>().add(const LogoutRequested());
}
```

## 🎨 Personalización Visual

### Colores por Tipo

```dart
// Logout normal - Azul
LogoutButton.profile(
  text: 'Cerrar Sesión',
  // backgroundColor: AppColors.blue3 (por defecto)
)

// Logout all - Rojo (más llamativo)
LogoutButton.logoutAll(
  text: 'Cerrar Todas las Sesiones',
  // backgroundColor: Colors.red.shade50 (por defecto)
  // textColor: Colors.red.shade700 (por defecto)
)
```

---

**Archivo:** [`lib/core/widgets/logout/logout_button.dart`](lib/core/widgets/logout/logout_button.dart:20)  
**Última Actualización:** 29 de Octubre, 2025