
import 'package:consumo_combustible/domain/models/create_grifo_request.dart';
import 'package:equatable/equatable.dart';

abstract class GrifoEvent extends Equatable {
  const GrifoEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para inicializar el formulario
class InitGrifoFormEvent extends GrifoEvent {
  const InitGrifoFormEvent();
}

/// Evento para cargar la lista de grifos
class LoadGrifosEvent extends GrifoEvent {
  const LoadGrifosEvent();
}

/// Evento para cargar sedes (para el dropdown)
class LoadSedesForDropdownEvent extends GrifoEvent {
  const LoadSedesForDropdownEvent();
}

/// Evento para crear un nuevo grifo
class CreateGrifoEvent extends GrifoEvent {
  final CreateGrifoRequest request;

  const CreateGrifoEvent(this.request);

  @override
  List<Object?> get props => [request];
}

/// Evento para seleccionar sede en el dropdown
class GrifoSedeSelectedEvent extends GrifoEvent {
  final int sedeId;

  const GrifoSedeSelectedEvent(this.sedeId);

  @override
  List<Object?> get props => [sedeId];
}

/// Evento para cambiar el nombre
class GrifoNameChangedEvent extends GrifoEvent {
  final String nombre;

  const GrifoNameChangedEvent(this.nombre);

  @override
  List<Object?> get props => [nombre];
}

/// Evento para cambiar el código
class GrifoCodigoChangedEvent extends GrifoEvent {
  final String codigo;

  const GrifoCodigoChangedEvent(this.codigo);

  @override
  List<Object?> get props => [codigo];
}

/// Evento para cambiar la dirección
class GrifoDireccionChangedEvent extends GrifoEvent {
  final String direccion;

  const GrifoDireccionChangedEvent(this.direccion);

  @override
  List<Object?> get props => [direccion];
}

/// Evento para cambiar el teléfono
class GrifoTelefonoChangedEvent extends GrifoEvent {
  final String telefono;

  const GrifoTelefonoChangedEvent(this.telefono);

  @override
  List<Object?> get props => [telefono];
}

/// Evento para cambiar horario de apertura
class GrifoHorarioAperturaChangedEvent extends GrifoEvent {
  final String horarioApertura;

  const GrifoHorarioAperturaChangedEvent(this.horarioApertura);

  @override
  List<Object?> get props => [horarioApertura];
}

/// Evento para cambiar horario de cierre
class GrifoHorarioCierreChangedEvent extends GrifoEvent {
  final String horarioCierre;

  const GrifoHorarioCierreChangedEvent(this.horarioCierre);

  @override
  List<Object?> get props => [horarioCierre];
}

/// Evento para cambiar el estado activo
class GrifoActivoChangedEvent extends GrifoEvent {
  final bool activo;

  const GrifoActivoChangedEvent(this.activo);

  @override
  List<Object?> get props => [activo];
}

/// Evento para resetear el formulario
class ResetGrifoFormEvent extends GrifoEvent {
  const ResetGrifoFormEvent();
}

// Evento para cargar grifo por ID (para editar)
class LoadGrifoByIdEvent extends GrifoEvent {
  final int grifoId;

  const LoadGrifoByIdEvent(this.grifoId);

  @override
  List<Object?> get props => [grifoId];
}

/// Evento para actualizar un grifo
class UpdateGrifoEvent extends GrifoEvent {
  final int grifoId;
  final CreateGrifoRequest request;

  const UpdateGrifoEvent(this.grifoId, this.request);

  @override
  List<Object?> get props => [grifoId, request];
}

/// Evento para inicializar formulario de edición
class InitEditGrifoFormEvent extends GrifoEvent {
  final int grifoId;

  const InitEditGrifoFormEvent(this.grifoId);

  @override
  List<Object?> get props => [grifoId];
}