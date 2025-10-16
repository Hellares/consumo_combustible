// import 'package:consumo_combustible/domain/models/grifo.dart';
// import 'package:consumo_combustible/domain/models/sede.dart';
// import 'package:consumo_combustible/domain/utils/resource.dart';
// import 'package:equatable/equatable.dart';

// class GrifoState extends Equatable {
//   // Estados de carga
//   final bool isLoading;
//   final bool isLoadingGrifos;
//   final bool isLoadingSedes;
//   final bool isLoadingGrifoById;
  
//   // Datos del formulario
//   final int? selectedSedeId;
//   final String nombre;
//   final String codigo;
//   final String direccion;
//   final String telefono;
//   final String horarioApertura;
//   final String horarioCierre;
//   final bool activo;
  
//   // Listas
//   final List<Grifo> grifos;
//   final List<Sede> sedes;
  
//   // Recursos (Success/Error)
//   final Resource<Grifo>? createGrifoResponse;
//   final Resource<List<Grifo>>? grifosResponse;
//   final Resource<List<Sede>>? sedesResponse;
//   final Resource<Grifo>? updateGrifoResponse;
//   final Resource<Grifo>? grifoByIdResponse;
  
//   // Validaciones
//   final String? sedeError;
//   final String? nombreError;
//   final String? codigoError;
  
//   // Estado del formulario
//   final bool isFormValid;
//   final bool isEditMode;
//   final int? editingGrifoId;

//   const GrifoState({
//     this.isLoading = false,
//     this.isLoadingGrifos = false,
//     this.isLoadingSedes = false,
//     this.isLoadingGrifoById = false,
//     this.selectedSedeId,
//     this.nombre = '',
//     this.codigo = '',
//     this.direccion = '',
//     this.telefono = '',
//     this.horarioApertura = '',
//     this.horarioCierre = '',
//     this.activo = true,
//     this.grifos = const [],
//     this.sedes = const [],
//     this.createGrifoResponse,
//     this.grifosResponse,
//     this.sedesResponse,
//     this.updateGrifoResponse,
//     this.grifoByIdResponse,
//     this.sedeError,
//     this.nombreError,
//     this.codigoError,
//     this.isFormValid = false,
//     this.isEditMode = false,
//     this.editingGrifoId,
//   });

//   GrifoState copyWith({
//     bool? isLoading,
//     bool? isLoadingGrifos,
//     bool? isLoadingSedes,
//     bool? isLoadingGrifoById,
//     int? selectedSedeId,
//     String? nombre,
//     String? codigo,
//     String? direccion,
//     String? telefono,
//     String? horarioApertura,
//     String? horarioCierre,
//     bool? activo,
//     List<Grifo>? grifos,
//     List<Sede>? sedes,
//     Resource<Grifo>? createGrifoResponse,
//     Resource<List<Grifo>>? grifosResponse,
//     Resource<List<Sede>>? sedesResponse,
//     Resource<Grifo>? updateGrifoResponse,
//     Resource<Grifo>? grifoByIdResponse,
//     String? sedeError,
//     String? nombreError,
//     String? codigoError,
//     bool? isFormValid,
//     bool? isEditMode,
//     int? editingGrifoId,
//   }) {
//     return GrifoState(
//       isLoading: isLoading ?? this.isLoading,
//       isLoadingGrifos: isLoadingGrifos ?? this.isLoadingGrifos,
//       isLoadingSedes: isLoadingSedes ?? this.isLoadingSedes,
//       isLoadingGrifoById: isLoadingGrifoById ?? this.isLoadingGrifoById,
//       selectedSedeId: selectedSedeId ?? this.selectedSedeId,
//       nombre: nombre ?? this.nombre,
//       codigo: codigo ?? this.codigo,
//       direccion: direccion ?? this.direccion,
//       telefono: telefono ?? this.telefono,
//       horarioApertura: horarioApertura ?? this.horarioApertura,
//       horarioCierre: horarioCierre ?? this.horarioCierre,
//       activo: activo ?? this.activo,
//       grifos: grifos ?? this.grifos,
//       sedes: sedes ?? this.sedes,
//       createGrifoResponse: createGrifoResponse ?? this.createGrifoResponse,
//       grifosResponse: grifosResponse ?? this.grifosResponse,
//       sedesResponse: sedesResponse ?? this.sedesResponse,
//       updateGrifoResponse: updateGrifoResponse ?? this.updateGrifoResponse,
//       grifoByIdResponse: grifoByIdResponse ?? this.grifoByIdResponse,
//       sedeError: sedeError ?? this.sedeError,
//       nombreError: nombreError ?? this.nombreError,
//       codigoError: codigoError ?? this.codigoError,
//       isFormValid: isFormValid ?? this.isFormValid,
//       isEditMode: isEditMode ?? this.isEditMode,
//       editingGrifoId: editingGrifoId ?? this.editingGrifoId,
//     );
//   }

//   /// Resetear el formulario
//   GrifoState resetForm() {
//     return GrifoState(
//       selectedSedeId: null,
//       nombre: '',
//       codigo: '',
//       direccion: '',
//       telefono: '',
//       horarioApertura: '',
//       horarioCierre: '',
//       activo: true,
//       sedes: sedes, // Mantener las sedes cargadas
//       grifos: grifos, // Mantener los grifos cargados
//       sedeError: null,
//       nombreError: null,
//       codigoError: null,
//       isFormValid: false,
//       isEditMode: false,
//       editingGrifoId: null,
//       grifoByIdResponse: null, // Resetear respuesta de carga por ID
//       updateGrifoResponse: null, // Resetear respuesta de actualización
//     );
//   }

//   @override
//   List<Object?> get props => [
//         isLoading,
//         isLoadingGrifos,
//         isLoadingSedes,
//         isLoadingGrifoById,
//         selectedSedeId,
//         nombre,
//         codigo,
//         direccion,
//         telefono,
//         horarioApertura,
//         horarioCierre,
//         activo,
//         grifos,
//         sedes,
//         createGrifoResponse,
//         grifosResponse,
//         sedesResponse,
//         updateGrifoResponse,
//         grifoByIdResponse,
//         sedeError,
//         nombreError,
//         codigoError,
//         isFormValid,
//         isEditMode,
//         editingGrifoId,
//       ];
// }

import 'package:consumo_combustible/domain/models/grifo.dart';
import 'package:consumo_combustible/domain/models/sede.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:equatable/equatable.dart';

class GrifoState extends Equatable {
  // Estados de carga
  final bool isLoading;
  final bool isLoadingGrifos;
  final bool isLoadingSedes;
  final bool isLoadingGrifoById;
  
  // Datos del formulario
  final int? selectedSedeId;
  final String nombre;
  final String codigo;
  final String direccion;
  final String telefono;
  final String horarioApertura;
  final String horarioCierre;
  final bool activo;
  
  // Listas
  final List<Grifo> grifos;
  final List<Sede> sedes;
  
  // Recursos (Success/Error)
  final Resource<Grifo>? createGrifoResponse;
  final Resource<List<Grifo>>? grifosResponse;
  final Resource<List<Sede>>? sedesResponse;
  final Resource<Grifo>? updateGrifoResponse;
  final Resource<Grifo>? grifoByIdResponse;
  
  // Validaciones
  final String? sedeError;
  final String? nombreError;
  final String? codigoError;
  
  // Estado del formulario
  final bool isFormValid;
  final bool isEditMode;
  final int? editingGrifoId;

  const GrifoState({
    this.isLoading = false,
    this.isLoadingGrifos = false,
    this.isLoadingSedes = false,
    this.isLoadingGrifoById = false,
    this.selectedSedeId,
    this.nombre = '',
    this.codigo = '',
    this.direccion = '',
    this.telefono = '',
    this.horarioApertura = '',
    this.horarioCierre = '',
    this.activo = true,
    this.grifos = const [],
    this.sedes = const [],
    this.createGrifoResponse,
    this.grifosResponse,
    this.sedesResponse,
    this.updateGrifoResponse,
    this.grifoByIdResponse,
    this.sedeError,
    this.nombreError,
    this.codigoError,
    this.isFormValid = false,
    this.isEditMode = false,
    this.editingGrifoId,
  });

  GrifoState copyWith({
    bool? isLoading,
    bool? isLoadingGrifos,
    bool? isLoadingSedes,
    bool? isLoadingGrifoById,
    int? selectedSedeId,
    String? nombre,
    String? codigo,
    String? direccion,
    String? telefono,
    String? horarioApertura,
    String? horarioCierre,
    bool? activo,
    List<Grifo>? grifos,
    List<Sede>? sedes,
    Resource<Grifo>? createGrifoResponse,
    Resource<List<Grifo>>? grifosResponse,
    Resource<List<Sede>>? sedesResponse,
    Resource<Grifo>? updateGrifoResponse,
    Resource<Grifo>? grifoByIdResponse,
    Object? sedeError = const _Undefined(),
    Object? nombreError = const _Undefined(),
    Object? codigoError = const _Undefined(),
    bool? isFormValid,
    bool? isEditMode,
    int? editingGrifoId,
  }) {
    return GrifoState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingGrifos: isLoadingGrifos ?? this.isLoadingGrifos,
      isLoadingSedes: isLoadingSedes ?? this.isLoadingSedes,
      isLoadingGrifoById: isLoadingGrifoById ?? this.isLoadingGrifoById,
      selectedSedeId: selectedSedeId ?? this.selectedSedeId,
      nombre: nombre ?? this.nombre,
      codigo: codigo ?? this.codigo,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      horarioApertura: horarioApertura ?? this.horarioApertura,
      horarioCierre: horarioCierre ?? this.horarioCierre,
      activo: activo ?? this.activo,
      grifos: grifos ?? this.grifos,
      sedes: sedes ?? this.sedes,
      createGrifoResponse: createGrifoResponse ?? this.createGrifoResponse,
      grifosResponse: grifosResponse ?? this.grifosResponse,
      sedesResponse: sedesResponse ?? this.sedesResponse,
      updateGrifoResponse: updateGrifoResponse ?? this.updateGrifoResponse,
      grifoByIdResponse: grifoByIdResponse ?? this.grifoByIdResponse,
      sedeError: sedeError is _Undefined ? this.sedeError : sedeError as String?,
      nombreError: nombreError is _Undefined ? this.nombreError : nombreError as String?,
      codigoError: codigoError is _Undefined ? this.codigoError : codigoError as String?,
      isFormValid: isFormValid ?? this.isFormValid,
      isEditMode: isEditMode ?? this.isEditMode,
      editingGrifoId: editingGrifoId ?? this.editingGrifoId,
    );
  }

  /// Resetear el formulario
  GrifoState resetForm() {
    return GrifoState(
      selectedSedeId: null,
      nombre: '',
      codigo: '',
      direccion: '',
      telefono: '',
      horarioApertura: '',
      horarioCierre: '',
      activo: true,
      sedes: sedes, // Mantener las sedes cargadas
      grifos: grifos, // Mantener los grifos cargados
      sedeError: null,
      nombreError: null,
      codigoError: null,
      isFormValid: false,
      isEditMode: false,
      editingGrifoId: null,
      grifoByIdResponse: null, // Resetear respuesta de carga por ID
      updateGrifoResponse: null, // Resetear respuesta de actualización
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isLoadingGrifos,
        isLoadingSedes,
        isLoadingGrifoById,
        selectedSedeId,
        nombre,
        codigo,
        direccion,
        telefono,
        horarioApertura,
        horarioCierre,
        activo,
        grifos,
        sedes,
        createGrifoResponse,
        grifosResponse,
        sedesResponse,
        updateGrifoResponse,
        grifoByIdResponse,
        sedeError,
        nombreError,
        codigoError,
        isFormValid,
        isEditMode,
        editingGrifoId,
      ];
}

// Clase privada para detectar cuando un parámetro no fue proporcionado
class _Undefined {
  const _Undefined();
}