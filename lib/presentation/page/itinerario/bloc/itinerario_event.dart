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

/// 🔥 NUEVO: Evento para cargar un itinerario por ID
class LoadItinerarioById extends ItinerarioEvent {
  final int itinerarioId;

  const LoadItinerarioById(this.itinerarioId);

  @override
  List<Object?> get props => [itinerarioId];
}

/// 🔥 NUEVO: Evento para cargar un itinerario por código
class LoadItinerarioByCodigo extends ItinerarioEvent {
  final String codigo;

  const LoadItinerarioByCodigo(this.codigo);

  @override
  List<Object?> get props => [codigo];
}

/// 🔥 NUEVO: Evento para limpiar el itinerario detallado
class ClearItinerarioDetalle extends ItinerarioEvent {
  const ClearItinerarioDetalle();
  
  @override
  List<Object?> get props => [];
}