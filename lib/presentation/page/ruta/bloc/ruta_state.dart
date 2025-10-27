// lib/presentation/page/ruta/bloc/ruta_state.dart

import 'package:consumo_combustible/domain/models/ruta.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:equatable/equatable.dart';

class RutaState extends Equatable {
  final Resource? rutasResponse;
  final List<Ruta> rutas;

  const RutaState({
    this.rutasResponse,
    this.rutas = const [],
  });

  RutaState copyWith({
    Resource? rutasResponse,
    List<Ruta>? rutas,
  }) {
    return RutaState(
      rutasResponse: rutasResponse ?? this.rutasResponse,
      rutas: rutas ?? this.rutas,
    );
  }

  @override
  List<Object?> get props => [rutasResponse, rutas];

  // Helpers
  bool get isLoading => rutasResponse is Loading;
  bool get hasError => rutasResponse is Error;
  bool get hasRutas => rutas.isNotEmpty;

  String? get errorMessage {
    if (rutasResponse is Error) {
      return (rutasResponse as Error).message;
    }
    return null;
  }
}