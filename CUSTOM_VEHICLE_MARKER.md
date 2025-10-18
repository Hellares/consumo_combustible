# 🚗 Cómo Agregar Icono de Vehículo Personalizado en Google Maps

## 📋 Opciones Disponibles

He modificado el código para soportar un icono de vehículo personalizado. Tienes **3 opciones**:

---

## ✅ Opción 1: Usar un Asset de Imagen (Recomendado)

### Paso 1: Crear el Icono

Necesitas una imagen PNG del vehículo. Puedes:

1. **Descargar un icono gratuito**:
   - [Flaticon](https://www.flaticon.com/search?word=car) - Busca "car top view"
   - [Icons8](https://icons8.com/icons/set/car) - Busca "car marker"
   - Recomendación: Icono de vista superior (top view) del vehículo

2. **Especificaciones del icono**:
   - Formato: PNG con transparencia
   - Tamaño recomendado: 96x96 px o 128x128 px
   - Color: Azul o verde para tracking activo
   - Vista: Superior (top view) para que se vea bien rotando

### Paso 2: Agregar el Asset

1. Crea la carpeta `assets/icons/` en la raíz del proyecto:
   ```
   proyecto/
   ├── assets/
   │   └── icons/
   │       └── vehicle_marker.png  ← Aquí
   ├── lib/
   └── pubspec.yaml
   ```

2. Actualiza `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/icons/vehicle_marker.png
   ```

3. Ejecuta:
   ```bash
   flutter pub get
   ```

### Paso 3: ¡Listo!

El código ya está configurado para usar el icono. Características:
- ✅ El vehículo **rota según la dirección** del movimiento
- ✅ Cambia de color según el estado (tracking activo/detenido)
- ✅ Fallback automático si no encuentra el asset

---

## 🎨 Opción 2: Generar Icono desde Widget (Sin Assets)

Si no quieres usar assets, puedes generar el icono desde código:

```dart
Future<BitmapDescriptor> _createVehicleIcon() async {
  return await BitmapDescriptor.fromAssetImage(
    const ImageConfiguration(
      size: Size(48, 48),
      devicePixelRatio: 2.5,
    ),
    'assets/icons/vehicle_marker.png',
  );
}
```

O crear uno desde un Widget:

```dart
import 'dart:ui' as ui;
import 'package:flutter/services.dart';

Future<BitmapDescriptor> _createVehicleIconFromWidget() async {
  final pictureRecorder = ui.PictureRecorder();
  final canvas = Canvas(pictureRecorder);
  
  // Dibujar un vehículo simple
  final paint = Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.fill;
  
  // Cuerpo del vehículo
  canvas.drawRRect(
    RRect.fromRectAndRadius(
      const Rect.fromLTWH(10, 15, 30, 50),
      const Radius.circular(5),
    ),
    paint,
  );
  
  // Ventanas
  paint.color = Colors.white;
  canvas.drawRect(const Rect.fromLTWH(15, 20, 20, 15), paint);
  canvas.drawRect(const Rect.fromLTWH(15, 45, 20, 15), paint);
  
  final picture = pictureRecorder.endRecording();
  final image = await picture.toImage(50, 80);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  
  return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
}
```

---

## 🔧 Opción 3: Usar Iconos de Material (Más Simple)

Si quieres algo rápido sin assets, modifica el código así:

```dart
// En tracking_map_widget.dart, línea ~40
icon: BitmapDescriptor.defaultMarkerWithHue(
  widget.isTracking
      ? BitmapDescriptor.hueBlue    // Azul para activo
      : BitmapDescriptor.hueOrange, // Naranja para detenido
),
```

Colores disponibles:
- `BitmapDescriptor.hueRed` - Rojo
- `BitmapDescriptor.hueOrange` - Naranja
- `BitmapDescriptor.hueYellow` - Amarillo
- `BitmapDescriptor.hueGreen` - Verde
- `BitmapDescriptor.hueBlue` - Azul
- `BitmapDescriptor.hueViolet` - Violeta

---

## 🎯 Características Implementadas

El código actual ya incluye:

### 1. **Rotación Automática**
```dart
rotation: position.heading,  // Rota según la dirección del movimiento
```

### 2. **Anclaje Centrado**
```dart
anchor: const Offset(0.5, 0.5),  // Centra el icono en la posición
```

### 3. **Info Window Personalizado**
```dart
infoWindow: InfoWindow(
  title: '🚗 Mi Vehículo',
  snippet: widget.isTracking ? '✅ Tracking activo' : '⏸️ Detenido',
),
```

### 4. **Círculo de Precisión**
Muestra un círculo azul alrededor del vehículo indicando la precisión del GPS.

---

## 📦 Recursos Recomendados

### Iconos Gratuitos de Vehículos:

1. **Flaticon** (Requiere atribución):
   - https://www.flaticon.com/free-icon/car_3097108
   - https://www.flaticon.com/free-icon/truck_2736991

2. **Icons8** (Gratis con link):
   - https://icons8.com/icon/13842/car
   - https://icons8.com/icon/85038/truck

3. **Material Icons** (Gratis):
   - https://fonts.google.com/icons?icon.query=directions_car

### Herramientas para Editar:

- **Photopea** (online, gratis): https://www.photopea.com/
- **GIMP** (desktop, gratis): https://www.gimp.org/
- **Figma** (online, gratis): https://www.figma.com/

---

## 🎨 Ejemplo de Icono Personalizado

Si quieres crear tu propio icono, aquí está el código completo:

```dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class VehicleMarkerPainter extends CustomPainter {
  final Color color;
  
  VehicleMarkerPainter({required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    // Dibujar vehículo simple
    final path = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.8, size.height * 0.3)
      ..lineTo(size.width * 0.8, size.height * 0.7)
      ..lineTo(size.width * 0.5, size.height)
      ..lineTo(size.width * 0.2, size.height * 0.7)
      ..lineTo(size.width * 0.2, size.height * 0.3)
      ..close();
    
    canvas.drawPath(path, paint);
    
    // Ventanas
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.4),
      size.width * 0.1,
      paint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

Future<BitmapDescriptor> createCustomVehicleMarker(Color color) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  final painter = VehicleMarkerPainter(color: color);
  painter.paint(canvas, const Size(50, 80));
  
  final picture = recorder.endRecording();
  final image = await picture.toImage(50, 80);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  
  return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
}
```

---

## ✅ Checklist de Implementación

- [ ] Descargar o crear icono de vehículo PNG
- [ ] Guardar en `assets/icons/vehicle_marker.png`
- [ ] Actualizar `pubspec.yaml` con el asset
- [ ] Ejecutar `flutter pub get`
- [ ] Probar en la app
- [ ] (Opcional) Ajustar tamaño del icono si es necesario

---

## 🔍 Troubleshooting

### Problema: El icono no aparece

**Solución**:
1. Verifica que el archivo existe en `assets/icons/vehicle_marker.png`
2. Verifica que `pubspec.yaml` tiene el asset correctamente
3. Ejecuta `flutter clean && flutter pub get`
4. Reinicia la app

### Problema: El icono es muy grande/pequeño

**Solución**: Ajusta el tamaño en el código:
```dart
final icon = await BitmapDescriptor.asset(
  const ImageConfiguration(size: Size(64, 64)), // Ajusta aquí
  'assets/icons/vehicle_marker.png',
);
```

### Problema: El icono no rota

**Solución**: Asegúrate de que el GPS está enviando el `heading`:
```dart
rotation: position.heading, // Debe tener un valor válido
```

---

## 📝 Notas Adicionales

- El icono rota automáticamente según la dirección del movimiento
- El círculo azul muestra la precisión del GPS
- El fallback usa el marcador por defecto si no encuentra el asset
- Puedes tener diferentes iconos para diferentes estados (activo/detenido)

---

**Fecha**: 2025-10-18  
**Estado**: ✅ Implementado y listo para usar