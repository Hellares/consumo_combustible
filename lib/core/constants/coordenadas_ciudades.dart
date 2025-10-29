// lib/core/constants/coordenadas_ciudades.dart


import 'package:google_maps_flutter/google_maps_flutter.dart';

/// Coordenadas GPS de ciudades principales de Perú
class CoordenadasCiudades {
  static final Map<String, LatLng> _coordenadas = {
    // Norte
    'Trujillo': LatLng(-8.1116778, -79.0287740),
    'Chiclayo': LatLng(-6.7714112, -79.8410023),
    'Piura': LatLng(-5.1944929, -80.6328406),
    'Tumbes': LatLng(-3.5669214, -80.4515449),
    'Cajamarca': LatLng(-7.1637830, -78.5001210),
    'Chimbote': LatLng(-9.0853491, -78.5684713),
    'Tarapoto': LatLng(-6.4850773, -76.3647023),
    'Iquitos': LatLng(-3.7436735, -73.2516326),
    
    // Centro
    'Lima': LatLng(-12.0463731, -77.0427934),
    'Callao': LatLng(-12.0565901, -77.1181530),
    'Huancayo': LatLng(-12.0653732, -75.2048776),
    'Huánuco': LatLng(-9.9305431, -76.2422371),
    'Pucallpa': LatLng(-8.3791551, -74.5538615),
    'Ica': LatLng(-14.0678791, -75.7285508),
    
    // Sur
    'Arequipa': LatLng(-16.4090474, -71.5374909),
    'Cusco': LatLng(-13.5319068, -71.9678451),
    'Puno': LatLng(-15.8402218, -70.0218805),
    'Tacna': LatLng(-18.0145940, -70.2532980),
    'Moquegua': LatLng(-17.1932663, -70.9354240),
    'Juliaca': LatLng(-15.5002309, -70.1347149),
    'Ayacucho': LatLng(-13.1631424, -74.2236700),
    
    // Adicionales comunes
    'Huaraz': LatLng(-9.5317842, -77.5275969),
    'Sullana': LatLng(-4.9033732, -80.6851111),
    'Talara': LatLng(-4.5772498, -81.2719670),
    'Nazca': LatLng(-14.8308100, -74.9378939),
    'Chincha': LatLng(-13.4100041, -76.1319799),
    'Lambayeque': LatLng(-6.7018462, -79.9061279),
  };

  /// Obtener coordenadas de una ciudad
  static LatLng? obtenerCoordenadas(String ciudad) {
    // Normalizar el nombre (quitar tildes, mayúsculas)
    final ciudadNormalizada = _normalizarNombre(ciudad);
    
    // Buscar coincidencia exacta primero
    for (var entry in _coordenadas.entries) {
      if (_normalizarNombre(entry.key) == ciudadNormalizada) {
        return entry.value;
      }
    }
    
    // Buscar coincidencia parcial
    for (var entry in _coordenadas.entries) {
      if (_normalizarNombre(entry.key).contains(ciudadNormalizada) ||
          ciudadNormalizada.contains(_normalizarNombre(entry.key))) {
        return entry.value;
      }
    }
    
    return null;
  }

  /// Normalizar nombre de ciudad para comparación
  static String _normalizarNombre(String nombre) {
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

  /// Verificar si existe una ciudad en el mapa
  static bool existeCiudad(String ciudad) {
    return obtenerCoordenadas(ciudad) != null;
  }

  /// Obtener todas las ciudades disponibles
  static List<String> obtenerTodasLasCiudades() {
    return _coordenadas.keys.toList()..sort();
  }

  /// Calcular centro geográfico entre múltiples puntos
  static LatLng calcularCentro(List<LatLng> puntos) {
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
    
    return LatLng(
      latSum / puntos.length,
      lngSum / puntos.length,
    );
  }

  /// Calcular zoom apropiado basado en la distancia entre puntos
  static double calcularZoom(List<LatLng> puntos) {
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
    if (maxDiff > 10) return 6.0;  // Muy lejos
    if (maxDiff > 5) return 7.0;   // Lejos
    if (maxDiff > 2) return 8.0;   // Medio
    if (maxDiff > 1) return 9.0;   // Cerca
    if (maxDiff > 0.5) return 10.0; // Más cerca
    return 11.0; // Muy cerca
  }
}