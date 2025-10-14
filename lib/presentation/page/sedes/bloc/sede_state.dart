import 'package:consumo_combustible/domain/models/sede.dart';
import 'package:consumo_combustible/domain/models/zona.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:equatable/equatable.dart';

class SedeState extends Equatable {
  // Estados de carga
  final bool isLoading;
  final bool isLoadingSedes;
  final bool isLoadingZonas;
  
  // Datos del formulario
  final int? selectedZonaId;
  final String nombre;
  final String codigo;
  final String direccion;
  final String telefono;
  final bool activo;
  
  // Listas
  final List<Sede> sedes;
  final List<Zona> zonas;
  
  // Recursos (Success/Error)
  final Resource<Sede>? createSedeResponse;
  final Resource<List<Sede>>? sedesResponse;
  final Resource<List<Zona>>? zonasResponse;
  
  // Validaciones
  final String? zonaError;
  final String? nombreError;
  final String? codigoError;
  
  // Estado del formulario
  final bool isFormValid;

  const SedeState({
    this.isLoading = false,
    this.isLoadingSedes = false,
    this.isLoadingZonas = false,
    this.selectedZonaId,
    this.nombre = '',
    this.codigo = '',
    this.direccion = '',
    this.telefono = '',
    this.activo = true,
    this.sedes = const [],
    this.zonas = const [],
    this.createSedeResponse,
    this.sedesResponse,
    this.zonasResponse,
    this.zonaError,
    this.nombreError,
    this.codigoError,
    this.isFormValid = false,
  });

  SedeState copyWith({
    bool? isLoading,
    bool? isLoadingSedes,
    bool? isLoadingZonas,
    int? selectedZonaId,
    String? nombre,
    String? codigo,
    String? direccion,
    String? telefono,
    bool? activo,
    List<Sede>? sedes,
    List<Zona>? zonas,
    Resource<Sede>? createSedeResponse,
    Resource<List<Sede>>? sedesResponse,
    Resource<List<Zona>>? zonasResponse,
    String? zonaError,
    String? nombreError,
    String? codigoError,
    bool? isFormValid,
  }) {
    return SedeState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingSedes: isLoadingSedes ?? this.isLoadingSedes,
      isLoadingZonas: isLoadingZonas ?? this.isLoadingZonas,
      selectedZonaId: selectedZonaId ?? this.selectedZonaId,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      activo: activo ?? this.activo,
      sedes: sedes ?? this.sedes,
      zonas: zonas ?? this.zonas,
      createSedeResponse: createSedeResponse,
      sedesResponse: sedesResponse,
      zonasResponse: zonasResponse,
      zonaError: zonaError,
      nombreError: nombreError,
      codigoError: codigoError,
      isFormValid: isFormValid ?? this.isFormValid,
    );
  }

  /// Resetear el formulario
  SedeState resetForm() {
    return SedeState(
      selectedZonaId: null,
      nombre: '',
      codigo: '',
      direccion: '',
      telefono: '',
      activo: true,
      zonas: zonas, // Mantener las zonas cargadas
      sedes: sedes, // Mantener las sedes cargadas
      zonaError: null,
      nombreError: null,
      codigoError: null,
      isFormValid: false,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isLoadingSedes,
        isLoadingZonas,
        selectedZonaId,
        nombre,
        codigo,
        direccion,
        telefono,
        activo,
        sedes,
        zonas,
        createSedeResponse,
        sedesResponse,
        zonasResponse,
        zonaError,
        nombreError,
        codigoError,
        isFormValid,
      ];
}