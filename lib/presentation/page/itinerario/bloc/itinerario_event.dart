// lib/presentation/page/itinerario/bloc/itinerario_event.dart

import 'package:equatable/equatable.dart';

abstract class ItinerarioEvent extends Equatable {
  const ItinerarioEvent();
}

/// Evento para cargar itinerarios activos
class LoadItinerariosActivos extends ItinerarioEvent {
  const LoadItinerariosActivos();

  @override
  List<Object?> get props => [];
}

/// Evento para limpiar el estado
class ClearItinerarios extends ItinerarioEvent {
  const ClearItinerarios();

  @override
  List<Object?> get props => [];
}