import 'package:consumo_combustible/domain/models/create_zona_request.dart';
import 'package:equatable/equatable.dart';

abstract class ZonaEvent extends Equatable {
  const ZonaEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para inicializar el formulario
class InitZonaFormEvent extends ZonaEvent {
  const InitZonaFormEvent();
}

/// Evento para cargar la lista de zonas
class LoadZonasEvent extends ZonaEvent {
  const LoadZonasEvent();
}

/// Evento para crear una nueva zona
class CreateZonaEvent extends ZonaEvent {
  final CreateZonaRequest request;

  const CreateZonaEvent(this.request);

  @override
  List<Object?> get props => [request];
}

/// Evento para cambiar el nombre
class ZonaNameChangedEvent extends ZonaEvent {
  final String nombre;

  const ZonaNameChangedEvent(this.nombre);

  @override
  List<Object?> get props => [nombre];
}

/// Evento para cambiar el código
class ZonaCodigoChangedEvent extends ZonaEvent {
  final String codigo;

  const ZonaCodigoChangedEvent(this.codigo);

  @override
  List<Object?> get props => [codigo];
}

/// Evento para cambiar la descripción
class ZonaDescripcionChangedEvent extends ZonaEvent {
  final String descripcion;

  const ZonaDescripcionChangedEvent(this.descripcion);

  @override
  List<Object?> get props => [descripcion];
}

/// Evento para cambiar el estado activo
class ZonaActivoChangedEvent extends ZonaEvent {
  final bool activo;

  const ZonaActivoChangedEvent(this.activo);

  @override
  List<Object?> get props => [activo];
}

/// Evento para resetear el formulario
class ResetZonaFormEvent extends ZonaEvent {
  const ResetZonaFormEvent();
}