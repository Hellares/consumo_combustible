import 'package:consumo_combustible/domain/models/zona.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:equatable/equatable.dart';

class ZonaState extends Equatable {
  // Estados de carga
  final bool isLoading;
  final bool isLoadingZonas;
  
  // Datos del formulario
  final String nombre;
  final String codigo;
  final String descripcion;
  final bool activo;
  
  // Lista de zonas
  final List<Zona> zonas;
  
  // Recursos (Success/Error)
  final Resource<Zona>? createZonaResponse;
  final Resource<List<Zona>>? zonasResponse;
  
  // Validaciones
  final String? nombreError;
  final String? codigoError;
  
  // Estado del formulario
  final bool isFormValid;

  const ZonaState({
    this.isLoading = false,
    this.isLoadingZonas = false,
    this.nombre = '',
    this.codigo = '',
    this.descripcion = '',
    this.activo = true,
    this.zonas = const [],
    this.createZonaResponse,
    this.zonasResponse,
    this.nombreError,
    this.codigoError,
    this.isFormValid = false,
  });

  ZonaState copyWith({
    bool? isLoading,
    bool? isLoadingZonas,
    String? nombre,
    String? codigo,
    String? descripcion,
    bool? activo,
    List<Zona>? zonas,
    Resource<Zona>? createZonaResponse,
    Resource<List<Zona>>? zonasResponse,
    String? nombreError,
    String? codigoError,
    bool? isFormValid,
  }) {
    return ZonaState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingZonas: isLoadingZonas ?? this.isLoadingZonas,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
      zonas: zonas ?? this.zonas,
      createZonaResponse: createZonaResponse,
      zonasResponse: zonasResponse,
      nombreError: nombreError,
      codigoError: codigoError,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }

  /// Resetear el formulario
  ZonaState resetForm() {
    return const ZonaState(
      nombre: '',
      codigo: '',
      descripcion: '',
      activo: true,
      nombreError: null,
      codigoError: null,
      isFormValid: false,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isLoadingZonas,
        nombre,
        codigo,
        descripcion,
        activo,
        zonas,
        createZonaResponse,
        zonasResponse,
        nombreError,
        codigoError,
        isFormValid,
      ];
}