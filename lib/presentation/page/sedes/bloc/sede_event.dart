
import 'package:consumo_combustible/domain/models/create_sede_request.dart';
import 'package:equatable/equatable.dart';

abstract class SedeEvent extends Equatable {
  const SedeEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para inicializar el formulario
class InitSedeFormEvent extends SedeEvent {
  const InitSedeFormEvent();
}

/// Evento para cargar la lista de sedes
class LoadSedesEvent extends SedeEvent {
  const LoadSedesEvent();
}

/// Evento para cargar zonas (para el dropdown)
class LoadZonasForDropdownEvent extends SedeEvent {
  const LoadZonasForDropdownEvent();
}

/// Evento para crear una nueva sede
class CreateSedeEvent extends SedeEvent {
  final CreateSedeRequest request;

  const CreateSedeEvent(this.request);

  @override
  List<Object?> get props => [request];
}

/// Evento para seleccionar zona en el dropdown
class SedeZonaSelectedEvent extends SedeEvent {
  final int zonaId;

  const SedeZonaSelectedEvent(this.zonaId);

  @override
  List<Object?> get props => [zonaId];
}

/// Evento para cambiar el nombre
class SedeNameChangedEvent extends SedeEvent {
  final String nombre;

  const SedeNameChangedEvent(this.nombre);

  @override
  List<Object?> get props => [nombre];
}

/// Evento para cambiar el código
class SedeCodigoChangedEvent extends SedeEvent {
  final String codigo;

  const SedeCodigoChangedEvent(this.codigo);

  @override
  List<Object?> get props => [codigo];
}

/// Evento para cambiar la dirección
class SedeDireccionChangedEvent extends SedeEvent {
  final String direccion;

  const SedeDireccionChangedEvent(this.direccion);

  @override
  List<Object?> get props => [direccion];
}

/// Evento para cambiar el teléfono
class SedeTelefonoChangedEvent extends SedeEvent {
  final String telefono;

  const SedeTelefonoChangedEvent(this.telefono);

  @override
  List<Object?> get props => [telefono];
}

/// Evento para cambiar el estado activo
class SedeActivoChangedEvent extends SedeEvent {
  final bool activo;

  const SedeActivoChangedEvent(this.activo);

  @override
  List<Object?> get props => [activo];
}

/// Evento para resetear el formulario
class ResetSedeFormEvent extends SedeEvent {
  const ResetSedeFormEvent();
}