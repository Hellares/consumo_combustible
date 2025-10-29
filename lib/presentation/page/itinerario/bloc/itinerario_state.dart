// // lib/presentation/page/itinerario/bloc/itinerario_state.dart

// import 'package:consumo_combustible/domain/models/itinerario.dart';
// import 'package:consumo_combustible/domain/utils/resource.dart';
// import 'package:equatable/equatable.dart';

// class ItinerarioState extends Equatable {
//   final Resource? itinerariosResponse;
//   final List<Itinerario> itinerarios;

//   const ItinerarioState({
//     this.itinerariosResponse,
//     this.itinerarios = const [],
//   });

//   ItinerarioState copyWith({
//     Resource? itinerariosResponse,
//     List<Itinerario>? itinerarios,
//   }) {
//     return ItinerarioState(
//       itinerariosResponse: itinerariosResponse ?? this.itinerariosResponse,
//       itinerarios: itinerarios ?? this.itinerarios,
//     );
//   }

//   @override
//   List<Object?> get props => [itinerariosResponse, itinerarios];

//   // Helpers
//   bool get isLoading => itinerariosResponse is Loading;
//   bool get hasError => itinerariosResponse is Error;
//   bool get hasItinerarios => itinerarios.isNotEmpty;

//   String? get errorMessage {
//     if (itinerariosResponse is Error) {
//       return (itinerariosResponse as Error).message;
//     }
//     return null;
//   }
// }

// lib/presentation/page/itinerario/bloc/itinerario_state.dart

import 'package:consumo_combustible/domain/models/itinerario.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:equatable/equatable.dart';

class ItinerarioState extends Equatable {
  // ✅ Estado para lista de itinerarios activos (YA EXISTE)
  final Resource<List<Itinerario>>? itinerariosResponse;
  final List<Itinerario> itinerarios;

  // 🔥 NUEVO: Estado para un itinerario específico (con tramos completos)
  final Resource<Itinerario>? itinerarioDetalleResponse;
  final Itinerario? itinerarioDetalle;

  const ItinerarioState({
    this.itinerariosResponse,
    this.itinerarios = const [],
    this.itinerarioDetalleResponse,
    this.itinerarioDetalle,
  });

  ItinerarioState copyWith({
    Resource<List<Itinerario>>? itinerariosResponse,
    List<Itinerario>? itinerarios,
    Resource<Itinerario>? itinerarioDetalleResponse,
    Itinerario? itinerarioDetalle,
    bool clearItinerarioDetalle = false,
  }) {
    return ItinerarioState(
      itinerariosResponse: itinerariosResponse ?? this.itinerariosResponse,
      itinerarios: itinerarios ?? this.itinerarios,
      itinerarioDetalleResponse: clearItinerarioDetalle 
          ? null 
          : (itinerarioDetalleResponse ?? this.itinerarioDetalleResponse),
      itinerarioDetalle: clearItinerarioDetalle 
          ? null 
          : (itinerarioDetalle ?? this.itinerarioDetalle),
    );
  }

  @override
  List<Object?> get props => [
        itinerariosResponse,
        itinerarios,
        itinerarioDetalleResponse,
        itinerarioDetalle,
      ];

  // ========================================
  // HELPERS PARA LISTA DE ITINERARIOS
  // ========================================

  /// ¿Está cargando la lista de itinerarios?
  bool get isLoadingItinerarios =>
      itinerariosResponse is Loading<List<Itinerario>>;

  /// ¿Hubo error al cargar la lista?
  bool get hasItinerariosError =>
      itinerariosResponse is Error<List<Itinerario>>;

  /// ¿Se cargaron los itinerarios exitosamente?
  bool get hasItinerarios =>
      itinerariosResponse is Success<List<Itinerario>> &&
      itinerarios.isNotEmpty;

  /// Mensaje de error de la lista
  String? get itinerariosErrorMessage {
    if (itinerariosResponse is Error<List<Itinerario>>) {
      return (itinerariosResponse as Error<List<Itinerario>>).message;
    }
    return null;
  }

  // ========================================
  // 🔥 NUEVOS: HELPERS PARA ITINERARIO DETALLE
  // ========================================

  /// ¿Está cargando el detalle del itinerario?
  bool get isLoadingDetalle =>
      itinerarioDetalleResponse is Loading<Itinerario>;

  /// ¿Hubo error al cargar el detalle?
  bool get hasDetalleError =>
      itinerarioDetalleResponse is Error<Itinerario>;

  /// ¿Se cargó el detalle exitosamente?
  bool get hasDetalle =>
      itinerarioDetalleResponse is Success<Itinerario> &&
      itinerarioDetalle != null;

  /// Mensaje de error del detalle
  String? get detalleErrorMessage {
    if (itinerarioDetalleResponse is Error<Itinerario>) {
      return (itinerarioDetalleResponse as Error<Itinerario>).message;
    }
    return null;
  }

  /// ¿El itinerario tiene tramos?
  bool get hasTramos =>
      itinerarioDetalle != null && itinerarioDetalle!.tramos!.isNotEmpty;

  /// Número de tramos
  int get cantidadTramos => itinerarioDetalle!.tramos?.length ?? 0;
}