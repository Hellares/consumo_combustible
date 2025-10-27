// lib/presentation/page/itinerario/bloc/itinerario_state.dart

import 'package:consumo_combustible/domain/models/itinerario.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:equatable/equatable.dart';

class ItinerarioState extends Equatable {
  final Resource? itinerariosResponse;
  final List<Itinerario> itinerarios;

  const ItinerarioState({
    this.itinerariosResponse,
    this.itinerarios = const [],
  });

  ItinerarioState copyWith({
    Resource? itinerariosResponse,
    List<Itinerario>? itinerarios,
  }) {
    return ItinerarioState(
      itinerariosResponse: itinerariosResponse ?? this.itinerariosResponse,
      itinerarios: itinerarios ?? this.itinerarios,
    );
  }

  @override
  List<Object?> get props => [itinerariosResponse, itinerarios];

  // Helpers
  bool get isLoading => itinerariosResponse is Loading;
  bool get hasError => itinerariosResponse is Error;
  bool get hasItinerarios => itinerarios.isNotEmpty;

  String? get errorMessage {
    if (itinerariosResponse is Error) {
      return (itinerariosResponse as Error).message;
    }
    return null;
  }
}