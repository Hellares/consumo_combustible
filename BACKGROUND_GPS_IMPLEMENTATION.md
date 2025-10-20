# 📱 Implementación de GPS Tracking en Segundo Plano

## ✅ Pasos Completados

### 1. Dependencias Agregadas
- ✅ `flutter_background_service: ^5.0.10`
- ✅ `flutter_local_notifications: ^18.0.1`

### 2. Permisos Configurados

#### Android (`android/app/src/main/AndroidManifest.xml`)
- ✅ `ACCESS_FINE_LOCATION`
- ✅ `ACCESS_COARSE_LOCATION`
- ✅ `ACCESS_BACKGROUND_LOCATION`
- ✅ `FOREGROUND_SERVICE`
- ✅ `FOREGROUND_SERVICE_LOCATION`
- ✅ `WAKE_LOCK`
- ✅ `POST_NOTIFICATIONS`
- ✅ `RECEIVE_BOOT_COMPLETED`
- ✅ Servicio declarado en manifest

#### iOS (`ios/Runner/Info.plist`)
- ✅ `NSLocationWhenInUseUsageDescription`
- ✅ `NSLocationAlwaysAndWhenInUseUsageDescription`
- ✅ `NSLocationAlwaysUsageDescription`
- ✅ `UIBackgroundModes` (location, fetch, processing)
- ✅ `BGTaskSchedulerPermittedIdentifiers`

### 3. Servicio Creado
- ✅ `lib/core/services/background_gps_service.dart`

## 🚀 Pasos Siguientes

### Paso 1: Instalar Dependencias

```bash
flutter pub get
```

### Paso 2: Inicializar el Servicio en `main.dart`

Agrega esto en tu función `main()` ANTES de `runApp()`:

```dart
import 'package:consumo_combustible/core/services/background_gps_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar servicio en segundo plano
  await BackgroundGpsService.initialize();
  
  // ... resto de tu código de inicialización
  
  runApp(MyApp());
}
```

### Paso 3: Integrar con ConductorTrackingPage

Reemplaza los métodos `_startTracking()` y `_stopTracking()` en `conductor_tracking_page.dart`:

```dart
/// Iniciar tracking automático
Future<void> _startTracking() async {
  if (_isTracking) return;

  // Verificar permisos de ubicación en segundo plano
  final permission = await Permission.locationAlways.request();
  
  if (!permission.isGranted) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se requiere permiso de ubicación en segundo plano'),
          backgroundColor: Colors.orange,
        ),
      );
    }
    return;
  }

  setState(() {
    _isTracking = true;
  });

  // Iniciar servicio en segundo plano
  final started = await BackgroundGpsService.startService(
    unidadId: widget.unidadId,
    apiUrl: 'http://TU_IP:3000/api', // Reemplaza con tu URL
    token: widget.jwtToken ?? '',
  );

  if (started && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚗 Tracking en segundo plano iniciado'),
        backgroundColor: Colors.green,
      ),
    );
  }
}

/// Detener tracking
Future<void> _stopTracking() async {
  if (!_isTracking) return;

  setState(() {
    _isTracking = false;
  });

  // Detener servicio en segundo plano
  await BackgroundGpsService.stopService();
  
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🛑 Tracking detenido'),
        backgroundColor: Colors.grey,
      ),
    );
  }
}
```

### Paso 4: Verificar Estado del Servicio

Agrega esto en `initState()` de `ConductorTrackingPage`:

```dart
@override
void initState() {
  super.initState();
  _checkBackgroundService();
  _initializeTracking();
}

Future<void> _checkBackgroundService() async {
  final isRunning = await BackgroundGpsService.isServiceRunning();
  if (isRunning && mounted) {
    setState(() {
      _isTracking = true;
    });
  }
}
```

## 📋 Configuración Adicional Requerida

### Android: Solicitar Permiso de Ubicación en Segundo Plano

Agrega en `conductor_tracking_page.dart`:

```dart
import 'package:permission_handler/permission_handler.dart';

Future<bool> _requestBackgroundLocationPermission() async {
  // Primero solicitar ubicación normal
  final locationPermission = await Permission.location.request();
  
  if (!locationPermission.isGranted) {
    return false;
  }

  // Luego solicitar ubicación en segundo plano (Android 10+)
  if (await Permission.locationAlways.isDenied) {
    final backgroundPermission = await Permission.locationAlways.request();
    return backgroundPermission.isGranted;
  }

  return true;
}
```

### iOS: Solicitar Permiso "Always"

En iOS, el sistema mostrará automáticamente un diálogo para solicitar permiso "Always" cuando uses `Permission.locationAlways.request()`.

## 🎯 Características del Servicio

### ✅ Lo que hace:
1. **Tracking continuo** - Envía ubicaciones cada 10 segundos
2. **Notificación persistente** - Muestra cuántas ubicaciones se han enviado
3. **Funciona en segundo plano** - Incluso con la app cerrada
4. **Ahorro de batería** - Usa `distanceFilter` de 10 metros
5. **Reconexión automática** - Reintenta si falla el envío

### 📊 Notificación Mostrada:
```
🚗 GPS Tracking Activo
📍 25 ubicaciones enviadas | Última: 14:30
```

## ⚙️ Configuración del Servicio

### Cambiar Intervalo de Envío

En `background_gps_service.dart`, línea 107:

```dart
// Cambiar de 10 a 30 segundos
Timer.periodic(const Duration(seconds: 30), (timer) async {
```

### Cambiar Precisión GPS

En `background_gps_service.dart`, línea 117:

```dart
locationSettings: const LocationSettings(
  accuracy: LocationAccuracy.high,  // Cambiar a .medium para ahorrar batería
  distanceFilter: 10,  // Cambiar a 50 para menos actualizaciones
),
```

## 🧪 Pruebas

### 1. Probar en Primer Plano
```bash
flutter run
```
- Iniciar tracking
- Verificar que aparece la notificación
- Verificar que se envían ubicaciones

### 2. Probar en Segundo Plano
- Iniciar tracking
- Presionar botón Home (minimizar app)
- Esperar 1-2 minutos
- Verificar en el backend que siguen llegando ubicaciones

### 3. Probar con App Cerrada
- Iniciar tracking
- Cerrar completamente la app (swipe up en recientes)
- Esperar 1-2 minutos
- Verificar en el backend que siguen llegando ubicaciones

## ⚠️ Notas Importantes

### Android
- ✅ Funciona perfectamente en segundo plano
- ✅ Funciona con app cerrada
- ⚠️ El usuario puede detener el servicio desde las notificaciones
- ⚠️ Algunos fabricantes (Xiaomi, Huawei) pueden matar el servicio agresivamente

### iOS
- ✅ Funciona en segundo plano
- ⚠️ iOS puede suspender el servicio después de ~3 horas
- ⚠️ Requiere permiso "Always" del usuario
- ⚠️ Apple revisa apps con tracking en segundo plano más estrictamente

## 🔧 Solución de Problemas

### El servicio se detiene en Android
1. Verificar que la notificación esté visible
2. Desactivar optimización de batería para la app
3. Permitir "Autostart" en configuración del sistema

### El servicio no inicia
1. Verificar permisos en configuración del dispositivo
2. Revisar logs: `flutter logs`
3. Verificar que el token JWT sea válido

### Las ubicaciones no llegan al backend
1. Verificar la URL del API en `startService()`
2. Verificar que el backend esté accesible
3. Revisar logs del backend

## 📱 Configuración del Dispositivo

### Android
```
Configuración > Apps > Tu App > Permisos > Ubicación > Permitir todo el tiempo
Configuración > Apps > Tu App > Batería > Sin restricciones
```

### iOS
```
Configuración > Privacidad > Ubicación > Tu App > Siempre
```

## 🎉 Resultado Final

Con esta implementación, tu app podrá:
- ✅ Rastrear vehículos 24/7
- ✅ Funcionar con la app en segundo plano
- ✅ Funcionar con la app cerrada (Android)
- ✅ Mostrar notificación informativa
- ✅ Ahorrar batería con configuración optimizada
- ✅ Reconectar automáticamente si pierde conexión
