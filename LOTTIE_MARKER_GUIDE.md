# 🎬 Cómo Usar Lottie Animado como Marcador en Google Maps

## 🎯 Problema

Google Maps solo acepta **imágenes estáticas** (BitmapDescriptor) para los marcadores, no widgets animados directamente.

## ✅ Soluciones Disponibles

### Opción 1: Capturar Frame del Lottie (Recomendado)

Capturar un frame específico del Lottie y usarlo como imagen estática.

#### Paso 1: Agregar dependencia

```yaml
# pubspec.yaml
dependencies:
  lottie: ^3.1.0
```

#### Paso 2: Implementar captura de frame

```dart
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';

Future<BitmapDescriptor> createLottieMarker() async {
  // Cargar el Lottie
  final composition = await AssetLottie('assets/lottie/vehicle.json').load();
  
  // Crear un widget con el Lottie
  final lottieWidget = Lottie(
    composition: composition,
    width: 100,
    height: 100,
  );
  
  // Convertir widget a imagen
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  
  // Renderizar el widget
  final renderObject = RenderRepaintBoundary();
  final pipelineOwner = PipelineOwner();
  final buildOwner = BuildOwner(focusManager: FocusManager());
  
  final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
    container: renderObject,
    child: lottieWidget,
  ).attachToRenderTree(buildOwner);
  
  buildOwner.buildScope(rootElement);
  buildOwner.finalizeTree();
  
  pipelineOwner.flushLayout();
  pipelineOwner.flushCompositingBits();
  pipelineOwner.flushPaint();
  
  final picture = recorder.endRecording();
  final image = await picture.toImage(100, 100);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  
  return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
}
```

---

### Opción 2: Usar GIF Animado (Más Simple)

Convertir el Lottie a GIF y usar el primer frame.

#### Paso 1: Convertir Lottie a GIF

Usa herramientas online:
- [LottieFiles](https://lottiefiles.com/) - Exportar como GIF
- [Lottie to GIF](https://lottiefiles.com/tools/lottie-to-gif)

#### Paso 2: Extraer primer frame

Usa una herramienta como:
- [EZGIF](https://ezgif.com/split) - Extraer frames
- Photoshop / GIMP

#### Paso 3: Usar como PNG normal

```dart
final icon = await BitmapDescriptor.asset(
  const ImageConfiguration(size: Size(48, 48)),
  'assets/icons/vehicle_frame.png',
);
```

---

### Opción 3: Simular Animación con Múltiples Frames

Cambiar el icono periódicamente para simular animación.

```dart
class _TrackingMapWidgetState extends State<TrackingMapWidget> {
  int _currentFrame = 0;
  Timer? _animationTimer;
  List<BitmapDescriptor> _frames = [];
  
  @override
  void initState() {
    super.initState();
    _loadAnimationFrames();
    _startAnimation();
  }
  
  Future<void> _loadAnimationFrames() async {
    // Cargar múltiples frames del Lottie (exportados como PNG)
    for (int i = 0; i < 10; i++) {
      final frame = await BitmapDescriptor.asset(
        const ImageConfiguration(size: Size(48, 48)),
        'assets/icons/vehicle_frame_$i.png',
      );
      _frames.add(frame);
    }
  }
  
  void _startAnimation() {
    _animationTimer = Timer.periodic(
      const Duration(milliseconds: 100), // 10 FPS
      (timer) {
        if (mounted) {
          setState(() {
            _currentFrame = (_currentFrame + 1) % _frames.length;
          });
        }
      },
    );
  }
  
  @override
  Widget build(BuildContext context) {
    // Usar el frame actual
    final currentIcon = _frames.isNotEmpty 
        ? _frames[_currentFrame]
        : BitmapDescriptor.defaultMarker;
    
    // ... resto del código
  }
  
  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }
}
```

---

### Opción 4: Widget Overlay (Más Complejo)

Usar un widget overlay encima del mapa para mostrar el Lottie.

```dart
Stack(
  children: [
    // Mapa de Google
    GoogleMap(
      // ... configuración
      markers: {}, // Sin marcador
    ),
    
    // Overlay con Lottie
    Positioned(
      left: _calculateX(), // Calcular posición X
      top: _calculateY(),  // Calcular posición Y
      child: Lottie.asset(
        'assets/lottie/vehicle.json',
        width: 50,
        height: 50,
      ),
    ),
  ],
)
```

**Nota**: Esta opción requiere calcular la posición del Lottie basándose en las coordenadas GPS y el viewport del mapa.

---

## 🎨 Recomendación

Para tu caso de uso (vehículo en movimiento), te recomiendo:

### **Opción Práctica: PNG Estático con Buen Diseño**

1. Busca un icono de vehículo bien diseñado en:
   - [LottieFiles](https://lottiefiles.com/search?q=car&category=animations) - Descarga el Lottie
   - Exporta un frame específico como PNG
   - Usa ese PNG como marcador

2. **Ventajas**:
   - ✅ Rendimiento óptimo
   - ✅ No consume batería extra
   - ✅ Funciona perfectamente con rotación
   - ✅ Fácil de implementar

3. **Resultado Visual**:
   - Un icono estático pero bien diseñado se ve profesional
   - La rotación del vehículo ya da sensación de movimiento
   - El círculo de precisión añade dinamismo

---

## 📦 Recursos Recomendados

### Lottie Files de Vehículos:
1. [Car Animation](https://lottiefiles.com/animations/car-animation-Xk8fJYCJqF)
2. [Delivery Truck](https://lottiefiles.com/animations/delivery-truck-animation-qZJQqJqJqJ)
3. [GPS Car](https://lottiefiles.com/animations/gps-car-tracking-animation)

### Herramientas:
- **Lottie to PNG**: https://lottiefiles.com/tools/lottie-to-png
- **Frame Extractor**: https://ezgif.com/split
- **Icon Editor**: https://www.photopea.com/

---

## 💡 Consejo Final

Para un tracking GPS en tiempo real, un **icono estático bien diseñado** es la mejor opción porque:

1. ✅ **Rendimiento**: No consume recursos extra
2. ✅ **Batería**: No drena la batería con animaciones
3. ✅ **Claridad**: Es más fácil de ver en movimiento
4. ✅ **Profesional**: Se ve limpio y profesional

La **rotación automática** del vehículo según la dirección ya proporciona suficiente dinamismo visual.

---

## 🚀 Implementación Rápida

Si quieres probar con un Lottie, aquí está el código completo:

```dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:lottie/lottie.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LottieMarkerHelper {
  static Future<BitmapDescriptor> createFromLottie(
    String assetPath, {
    double width = 100,
    double height = 100,
  }) async {
    try {
      // Cargar composición
      final composition = await AssetLottie(assetPath).load();
      
      // Crear widget
      final widget = SizedBox(
        width: width,
        height: height,
        child: Lottie(composition: composition),
      );
      
      // Convertir a imagen
      final repaintBoundary = RepaintBoundary(child: widget);
      final renderRepaintBoundary = RenderRepaintBoundary();
      
      final pipelineOwner = PipelineOwner();
      final buildOwner = BuildOwner(focusManager: FocusManager());
      
      final rootElement = RenderObjectToWidgetAdapter<RenderBox>(
        container: renderRepaintBoundary,
        child: repaintBoundary,
      ).attachToRenderTree(buildOwner);
      
      buildOwner.buildScope(rootElement);
      buildOwner.finalizeTree();
      
      pipelineOwner.flushLayout();
      pipelineOwner.flushCompositingBits();
      pipelineOwner.flushPaint();
      
      final image = await renderRepaintBoundary.toImage(
        pixelRatio: 2.0,
      );
      
      final bytes = await image.toByteData(
        format: ui.ImageByteFormat.png,
      );
      
      return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
    } catch (e) {
      print('Error creando marcador desde Lottie: $e');
      return BitmapDescriptor.defaultMarker;
    }
  }
}

// Uso:
final lottieMarker = await LottieMarkerHelper.createFromLottie(
  'assets/lottie/vehicle.json',
  width: 80,
  height: 80,
);
```

---

**Fecha**: 2025-10-18  
**Estado**: Guía completa para Lottie en marcadores