// // lib/presentation/page/ruta/bloc/ruta_state.dart

// import 'package:consumo_combustible/domain/models/ruta.dart';
// import 'package:consumo_combustible/domain/utils/resource.dart';
// import 'package:equatable/equatable.dart';

// class RutaState extends Equatable {
//   final Resource? rutasResponse;
//   final List<Ruta> rutas;

//   const RutaState({
//     this.rutasResponse,
//     this.rutas = const [],
//   });

//   RutaState copyWith({
//     Resource? rutasResponse,
//     List<Ruta>? rutas,
//   }) {
//     return RutaState(
//       rutasResponse: rutasResponse ?? this.rutasResponse,
//       rutas: rutas ?? this.rutas,
//     );
//   }

//   @override
//   List<Object?> get props => [rutasResponse, rutas];

//   // Helpers
//   bool get isLoading => rutasResponse is Loading;
//   bool get hasError => rutasResponse is Error;
//   bool get hasRutas => rutas.isNotEmpty;

//   String? get errorMessage {
//     if (rutasResponse is Error) {
//       return (rutasResponse as Error).message;
//     }
//     return null;
//   }
// }

// lib/presentation/page/ruta/bloc/ruta_state.dart

import 'package:consumo_combustible/domain/models/ruta.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:equatable/equatable.dart';

class RutaState extends Equatable {
  // ✅ Estado para lista de rutas activas (YA EXISTE)
  final Resource<List<Ruta>>? rutasResponse;
  final List<Ruta> rutas;

  // 🔥 NUEVO: Estado para una ruta específica
  final Resource<Ruta>? rutaDetalleResponse;
  final Ruta? rutaDetalle;

  const RutaState({
    this.rutasResponse,
    this.rutas = const [],
    this.rutaDetalleResponse,
    this.rutaDetalle,
  });

  RutaState copyWith({
    Resource<List<Ruta>>? rutasResponse,
    List<Ruta>? rutas,
    Resource<Ruta>? rutaDetalleResponse,
    Ruta? rutaDetalle,
    bool clearRutaDetalle = false,
  }) {
    return RutaState(
      rutasResponse: rutasResponse ?? this.rutasResponse,
      rutas: rutas ?? this.rutas,
      rutaDetalleResponse: clearRutaDetalle 
          ? null 
          : (rutaDetalleResponse ?? this.rutaDetalleResponse),
      rutaDetalle: clearRutaDetalle 
          ? null 
          : (rutaDetalle ?? this.rutaDetalle),
    );
  }

  @override
  List<Object?> get props => [
        rutasResponse,
        rutas,
        rutaDetalleResponse,
        rutaDetalle,
      ];

  // ========================================
  // HELPERS PARA LISTA DE RUTAS
  // ========================================

  bool get isLoadingRutas => rutasResponse is Loading<List<Ruta>>;
  bool get hasRutasError => rutasResponse is Error<List<Ruta>>;
  bool get hasRutas => rutasResponse is Success<List<Ruta>> && rutas.isNotEmpty;

  String? get rutasErrorMessage {
    if (rutasResponse is Error<List<Ruta>>) {
      return (rutasResponse as Error<List<Ruta>>).message;
    }
    return null;
  }

  // ========================================
  // 🔥 NUEVOS: HELPERS PARA RUTA DETALLE
  // ========================================

  bool get isLoadingDetalle => rutaDetalleResponse is Loading<Ruta>;
  bool get hasDetalleError => rutaDetalleResponse is Error<Ruta>;
  bool get hasDetalle => rutaDetalleResponse is Success<Ruta> && rutaDetalle != null;

  String? get detalleErrorMessage {
    if (rutaDetalleResponse is Error<Ruta>) {
      return (rutaDetalleResponse as Error<Ruta>).message;
    }
    return null;
  }
}