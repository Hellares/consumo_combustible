// lib/presentation/page/ruta_map/widgets/mapa_widget.dart

import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/domain/models/mapa_ruta_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapaWidget extends StatefulWidget {
  final MapaRutaData data;

  const MapaWidget({super.key, required this.data});

  @override
  State<MapaWidget> createState() => _MapaWidgetState();
}

class _MapaWidgetState extends State<MapaWidget> {
  final MapController _mapController = MapController();
  List<LatLng> _puntosRuta = [];
  LatLng? _centro;
  double _zoom = 8.0;

  @override
  void initState() {
    super.initState();
    _calcularPuntosYCentro();
  }

  /// Calcular puntos de la ruta y centro del mapa
  void _calcularPuntosYCentro() {
    _puntosRuta = [];

    if (widget.data.esItinerario && widget.data.itinerario != null) {
      // Obtener puntos de cada tramo del itinerario
      final tramos = widget.data.itinerario!.tramos ?? [];
      for (var tramo in tramos) {
        // Coordenadas de origen
        final coordOrigen = _convertirCoordenadas(tramo.ciudadOrigen);
        if (coordOrigen != null && !_puntosRuta.contains(coordOrigen)) {
          _puntosRuta.add(coordOrigen);
        }

        // Coordenadas de destino
        final coordDestino = _convertirCoordenadas(tramo.ciudadDestino);
        if (coordDestino != null && !_puntosRuta.contains(coordDestino)) {
          _puntosRuta.add(coordDestino);
        }
      }
    } else if (widget.data.esRutaSimple && widget.data.ruta != null) {
      // Obtener puntos de origen y destino de la ruta simple
      final origen = widget.data.ruta!.origen;
      final destino = widget.data.ruta!.destino;

      final coordOrigen = _convertirCoordenadas(origen);
      if (coordOrigen != null) _puntosRuta.add(coordOrigen);

      final coordDestino = _convertirCoordenadas(destino);
      if (coordDestino != null) _puntosRuta.add(coordDestino);
    }

    // Calcular centro y zoom
    if (_puntosRuta.isNotEmpty) {
      _centro = _calcularCentroLatLng(_puntosRuta);
      _zoom = _calcularZoomLatLng(_puntosRuta);
    } else {
      // Lima por defecto
      _centro = LatLng(-12.0463731, -77.0427934);
      _zoom = 6.0;
    }
  }

  /// Convertir coordenadas de google_maps_flutter a latlong2
  LatLng? _convertirCoordenadas(String ciudad) {
    // Normalizar el nombre (quitar tildes, mayúsculas)
    final ciudadNormalizada = _normalizarNombre(ciudad);

    // Mapa de coordenadas usando latlong2
    final Map<String, LatLng> coordenadas = {
      // Norte
      'trujillo': LatLng(-8.1116778, -79.0287740),
      'chiclayo': LatLng(-6.7714112, -79.8410023),
      'piura': LatLng(-5.1944929, -80.6328406),
      'tumbes': LatLng(-3.5669214, -80.4515449),
      'cajamarca': LatLng(-7.1637830, -78.5001210),
      'chimbote': LatLng(-9.0853491, -78.5684713),
      'tarapoto': LatLng(-6.4850773, -76.3647023),
      'iquitos': LatLng(-3.7436735, -73.2516326),

      // Centro
      'lima': LatLng(-12.0463731, -77.0427934),
      'callao': LatLng(-12.0565901, -77.1181530),
      'huancayo': LatLng(-12.0653732, -75.2048776),
      'huanuco': LatLng(-9.9305431, -76.2422371),
      'pucallpa': LatLng(-8.3791551, -74.5538615),
      'ica': LatLng(-14.0678791, -75.7285508),

      // Sur
      'arequipa': LatLng(-16.4090474, -71.5374909),
      'cusco': LatLng(-13.5319068, -71.9678451),
      'puno': LatLng(-15.8402218, -70.0218805),
      'tacna': LatLng(-18.0145940, -70.2532980),
      'moquegua': LatLng(-17.1932663, -70.9354240),
      'juliaca': LatLng(-15.5002309, -70.1347149),
      'ayacucho': LatLng(-13.1631424, -74.2236700),

      // Adicionales comunes
      'huaraz': LatLng(-9.5317842, -77.5275969),
      'sullana': LatLng(-4.9033732, -80.6851111),
      'talara': LatLng(-4.5772498, -81.2719670),
      'nazca': LatLng(-14.8308100, -74.9378939),
      'chincha': LatLng(-13.4100041, -76.1319799),
      'lambayeque': LatLng(-6.7018462, -79.9061279),
    };

    // Buscar coincidencia exacta primero
    if (coordenadas.containsKey(ciudadNormalizada)) {
      return coordenadas[ciudadNormalizada];
    }

    // Buscar coincidencia parcial
    for (var entry in coordenadas.entries) {
      if (entry.key.contains(ciudadNormalizada) ||
          ciudadNormalizada.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  /// Normalizar nombre de ciudad para comparación
  String _normalizarNombre(String nombre) {
    return nombre
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .trim();
  }

  /// Calcular centro geográfico entre múltiples puntos
  LatLng _calcularCentroLatLng(List<LatLng> puntos) {
    if (puntos.isEmpty) {
      return LatLng(-12.0463731, -77.0427934); // Lima por defecto
    }

    if (puntos.length == 1) {
      return puntos.first;
    }

    double latSum = 0;
    double lngSum = 0;

    for (var punto in puntos) {
      latSum += punto.latitude;
      lngSum += punto.longitude;
    }

    return LatLng(latSum / puntos.length, lngSum / puntos.length);
  }

  /// Calcular zoom apropiado basado en la distancia entre puntos
  double _calcularZoomLatLng(List<LatLng> puntos) {
    if (puntos.isEmpty || puntos.length == 1) {
      return 13.0; // Zoom cercano para un solo punto
    }

    // Encontrar bounds
    double minLat = puntos.first.latitude;
    double maxLat = puntos.first.latitude;
    double minLng = puntos.first.longitude;
    double maxLng = puntos.first.longitude;

    for (var punto in puntos) {
      if (punto.latitude < minLat) minLat = punto.latitude;
      if (punto.latitude > maxLat) maxLat = punto.latitude;
      if (punto.longitude < minLng) minLng = punto.longitude;
      if (punto.longitude > maxLng) maxLng = punto.longitude;
    }

    double latDiff = maxLat - minLat;
    double lngDiff = maxLng - minLng;
    double maxDiff = latDiff > lngDiff ? latDiff : lngDiff;

    // Ajustar zoom basado en la diferencia
    if (maxDiff > 10) return 4.0; // Muy lejos
    if (maxDiff > 5) return 5.0; // Lejos
    if (maxDiff > 2) return 6.0; // Medio
    if (maxDiff > 1) return 7.0; // Cerca
    if (maxDiff > 0.5) return 8.0; // Más cerca
    return 9.0; // Muy cerca
  }

  @override
  Widget build(BuildContext context) {
    if (_puntosRuta.isEmpty) {
      return _buildNoDataView();
    }

    return Stack(
      children: [
        // Mapa
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _centro!,
            initialZoom: _zoom,
            minZoom: 5.0,
            maxZoom: 18.0,
          ),
          children: [
            // Capa 1: Mapa base - Usando CartoDB Positron (sin restricciones)
            TileLayer(
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
              userAgentPackageName: 'com.consumo_combustible.app',
              maxNativeZoom: 19,
            ),

            // Capa 2: Líneas de la ruta planificada
            if (_puntosRuta.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _puntosRuta,
                    color: Colors.grey.withValues(alpha: 0.6),
                    strokeWidth: 3.0,
                    pattern: const StrokePattern.dotted(),
                  ),
                ],
              ),

            // Capa 3: Marcadores de ciudades
            MarkerLayer(markers: _buildMarkers()),
          ],
        ),

        // Botones de control
        Positioned(
          right: 16,
          bottom: 16,
          child: Column(
            children: [
              // Botón zoom in
              SizedBox(
                width: 32,
                height: 32,
                child: FloatingActionButton(
                  heroTag: 'zoom_in',
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom + 1,
                    );
                  },
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.add, color: AppColors.blue3, size: 18),
                ),
              ),
              const SizedBox(height: 8),
              // Botón zoom out
              SizedBox(
                width: 32,
                height: 32,
                child: FloatingActionButton(
                  heroTag: 'zoom_out',
                  onPressed: () {
                    _mapController.move(
                      _mapController.camera.center,
                      _mapController.camera.zoom - 1,
                    );
                  },
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.remove, color: AppColors.blue3, size: 18),
                ),
              ),
              const SizedBox(height: 8),
              // Botón centrar
              SizedBox(
                width: 32,
                height: 32,
                child: FloatingActionButton(
                  heroTag: 'center',
                  onPressed: () {
                    if (_centro != null) {
                      _mapController.move(_centro!, _zoom);
                    }
                  },
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.my_location,
                    color: AppColors.blue3,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Leyenda
        Positioned(top: 16, left: 16, child: _buildLeyenda()),
      ],
    );
  }

  /// Construir marcadores de las ciudades
  List<Marker> _buildMarkers() {
    List<Marker> markers = [];

    if (widget.data.esItinerario && widget.data.itinerario != null) {
      // Marcadores para itinerario
      final tramos = widget.data.itinerario!.tramos ?? [];
      for (int i = 0; i < tramos.length; i++) {
        final tramo = tramos[i];

        // Marcador de origen (solo para el primer tramo)
        if (i == 0) {
          final coordOrigen = _convertirCoordenadas(tramo.ciudadOrigen);
          if (coordOrigen != null) {
            markers.add(
              _createMarker(
                coordOrigen,
                tramo.ciudadOrigen,
                Colors.green,
                Icons.play_circle,
                'Inicio',
              ),
            );
          }
        }

        // Marcador de destino
        final coordDestino = _convertirCoordenadas(tramo.ciudadDestino);
        if (coordDestino != null) {
          final esUltimo = i == tramos.length - 1;
          markers.add(
            _createMarker(
              coordDestino,
              tramo.ciudadDestino,
              esUltimo ? Colors.red : AppColors.blue3,
              esUltimo ? Icons.flag : Icons.location_on,
              esUltimo ? 'Fin' : 'Tramo ${i + 1}',
            ),
          );
        }
      }
    } else if (widget.data.esRutaSimple && widget.data.ruta != null) {
      // Marcadores para ruta simple
      final origen = widget.data.ruta!.origen;
      final destino = widget.data.ruta!.destino;

      final coordOrigen = _convertirCoordenadas(origen);
      if (coordOrigen != null) {
        markers.add(
          _createMarker(
            coordOrigen,
            origen,
            Colors.green,
            Icons.play_circle,
            'Origen',
          ),
        );
      }

      final coordDestino = _convertirCoordenadas(destino);
      if (coordDestino != null) {
        markers.add(
          _createMarker(
            coordDestino,
            destino,
            Colors.red,
            Icons.flag,
            'Destino',
          ),
        );
      }
    }

    return markers;
  }

  /// Crear un marcador
  Marker _createMarker(
    LatLng position,
    String ciudad,
    Color color,
    IconData icon,
    String label,
  ) {
    return Marker(
      point: position,
      width: 60,
      height: 60,
      child: GestureDetector(
        onTap: () => _showCityInfo(ciudad, label),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icono
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 14),
            ),
            const SizedBox(height: 2),
            // Etiqueta
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(color: color, width: 0.8),
              ),
              child: Text(
                ciudad,
                style: TextStyle(
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mostrar información de la ciudad
  void _showCityInfo(String ciudad, String label) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.location_city, color: AppColors.blue3, size: 20),
            const SizedBox(width: 8),
            Text(ciudad, style: const TextStyle(fontSize: 14)),
          ],
        ),
        content: Text(label, style: const TextStyle(fontSize: 12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  /// Construir leyenda del mapa
  Widget _buildLeyenda() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 3,
                decoration: BoxDecoration(color: Colors.grey.withOpacity(0.6)),
              ),
              const SizedBox(width: 6),
              const Text('Ruta planificada', style: TextStyle(fontSize: 9)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.play_circle, color: Colors.green, size: 14),
              const SizedBox(width: 6),
              const Text('Inicio', style: TextStyle(fontSize: 9)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.flag, color: Colors.red, size: 14),
              const SizedBox(width: 6),
              const Text('Fin', style: TextStyle(fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }

  /// Vista cuando no hay datos
  Widget _buildNoDataView() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No se pudo determinar la ruta',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Las ciudades no están registradas en el sistema',
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
