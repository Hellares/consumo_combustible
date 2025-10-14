// lib/presentation/bloc/unidad/unidad_event.dart

import 'package:consumo_combustible/domain/models/create_unidad_request.dart';
import 'package:equatable/equatable.dart';

abstract class UnidadEvent extends Equatable {
  const UnidadEvent();

  @override
  List<Object?> get props => [];
}

/// Evento para cargar todas las unidades con paginación
class LoadAllUnidades extends UnidadEvent {
  final int page;
  final int pageSize;
  final bool refresh; // Para indicar si es un refresh (limpia la lista actual)

  const LoadAllUnidades({
    this.page = 1,
    this.pageSize = 10,
    this.refresh = false,
  });

  @override
  List<Object?> get props => [page, pageSize, refresh];
}

/// Evento para cargar unidades de una zona específica
class LoadUnidadesByZona extends UnidadEvent {
  final int zonaId;

  const LoadUnidadesByZona(this.zonaId);

  @override
  List<Object?> get props => [zonaId];
}

/// Evento para cargar una unidad por ID
class LoadUnidadById extends UnidadEvent {
  final int unidadId;

  const LoadUnidadById(this.unidadId);

  @override
  List<Object?> get props => [unidadId];
}

/// Evento para crear una nueva unidad
class CreateUnidad extends UnidadEvent {
  final CreateUnidadRequest request;

  const CreateUnidad(this.request);

  @override
  List<Object?> get props => [request];
}

/// Evento para resetear el estado del formulario después de crear
class ResetCreateUnidadState extends UnidadEvent {
  const ResetCreateUnidadState();
}

/// Evento para limpiar el caché de unidades
class ClearUnidadesCache extends UnidadEvent {
  final int? zonaId;

  const ClearUnidadesCache({this.zonaId});

  @override
  List<Object?> get props => [zonaId];
}

/// Evento para cargar la siguiente página (paginación infinita)
class LoadNextPage extends UnidadEvent {
  const LoadNextPage();
}