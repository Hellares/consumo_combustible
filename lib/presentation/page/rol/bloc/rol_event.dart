// lib/presentation/page/roles/bloc/rol_event.dart

import 'package:consumo_combustible/domain/models/create_rol_request.dart';
import 'package:equatable/equatable.dart';

abstract class RolEvent extends Equatable {
  const RolEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar roles con paginación
class GetRolesEvent extends RolEvent {
  final int page;
  final int limit;
  final bool isLoadMore; // Para diferenciar carga inicial vs paginación

  const GetRolesEvent({
    this.page = 1,
    this.limit = 10,
    this.isLoadMore = false,
  });

  @override
  List<Object?> get props => [page, limit, isLoadMore];
}

/// Evento para obtener un rol por ID
class GetRolByIdEvent extends RolEvent {
  final int rolId;

  const GetRolByIdEvent(this.rolId);

  @override
  List<Object?> get props => [rolId];
}

/// Evento para crear un nuevo rol
class CreateRolEvent extends RolEvent {
  final CreateRolRequest request;

  const CreateRolEvent(this.request);

  @override
  List<Object?> get props => [request];
}

/// Evento para actualizar un rol existente
class UpdateRolEvent extends RolEvent {
  final int rolId;
  final CreateRolRequest request;

  const UpdateRolEvent({
    required this.rolId,
    required this.request,
  });

  @override
  List<Object?> get props => [rolId, request];
}

/// Evento para eliminar (desactivar) un rol
class DeleteRolEvent extends RolEvent {
  final int rolId;

  const DeleteRolEvent(this.rolId);

  @override
  List<Object?> get props => [rolId];
}

/// Evento para activar un rol
class ActivarRolEvent extends RolEvent {
  final int rolId;

  const ActivarRolEvent(this.rolId);

  @override
  List<Object?> get props => [rolId];
}

/// Evento para resetear el estado (útil después de crear/actualizar)
class ResetRolStateEvent extends RolEvent {
  const ResetRolStateEvent();
}

/// Evento para limpiar mensajes de error o success
class ClearRolMessagesEvent extends RolEvent {
  const ClearRolMessagesEvent();
}