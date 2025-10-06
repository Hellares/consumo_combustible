import 'package:equatable/equatable.dart';

abstract class DetalleAbastecimientoEvent extends Equatable {
  const DetalleAbastecimientoEvent();
}

/// Cargar detalles de abastecimiento
class LoadDetallesAbastecimiento extends DetalleAbastecimientoEvent {
  final int grifoId;
  final int page;
  final int pageSize;

  const LoadDetallesAbastecimiento({
    required this.grifoId,
    this.page = 1,
    this.pageSize = 10,
  });

  @override
  List<Object?> get props => [grifoId, page, pageSize];
}

/// Cargar más detalles (paginación)
class LoadMoreDetalles extends DetalleAbastecimientoEvent {
  const LoadMoreDetalles();

  @override
  List<Object?> get props => [];
}

/// Actualizar detalle
class ActualizarDetalleEvent extends DetalleAbastecimientoEvent {
  final int detalleId;
  final Map<String, dynamic> data;

  const ActualizarDetalleEvent({
    required this.detalleId,
    required this.data,
  });

  @override
  List<Object?> get props => [detalleId, data];
}

/// Concluir detalle
class ConcluirDetalleEvent extends DetalleAbastecimientoEvent {
  final int detalleId;
  final int concluidoPorId;

  const ConcluirDetalleEvent({
    required this.detalleId,
    required this.concluidoPorId,
  });

  @override
  List<Object?> get props => [detalleId, concluidoPorId];
}

/// Resetear estado
class ResetDetallesState extends DetalleAbastecimientoEvent {
  const ResetDetallesState();

  @override
  List<Object?> get props => [];
}