import 'package:consumo_combustible/domain/models/detalle_abastecimiento.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:equatable/equatable.dart';

class DetalleAbastecimientoState extends Equatable {
  final Resource<Map<String, dynamic>>? detallesResponse;
  final List<DetalleAbastecimiento> detalles;
  final DetalleAbastecimientoMeta? meta;
  final Resource<DetalleAbastecimiento>? actualizarResponse;
  final Resource<DetalleAbastecimiento>? concluirResponse;
  final int currentGrifoId;
  final int currentPage;
  final bool isLoadingMore;

  const DetalleAbastecimientoState({
    this.detallesResponse,
    this.detalles = const [],
    this.meta,
    this.actualizarResponse,
    this.concluirResponse,
    this.currentGrifoId = 0,
    this.currentPage = 1,
    this.isLoadingMore = false,
  });

  DetalleAbastecimientoState copyWith({
    Resource<Map<String, dynamic>>? detallesResponse,
    List<DetalleAbastecimiento>? detalles,
    DetalleAbastecimientoMeta? meta,
    Resource<DetalleAbastecimiento>? actualizarResponse,
    Resource<DetalleAbastecimiento>? concluirResponse,
    int? currentGrifoId,
    int? currentPage,
    bool? isLoadingMore,
  }) {
    return DetalleAbastecimientoState(
      detallesResponse: detallesResponse ?? this.detallesResponse,
      detalles: detalles ?? this.detalles,
      meta: meta ?? this.meta,
      actualizarResponse: actualizarResponse,
      concluirResponse: concluirResponse,
      currentGrifoId: currentGrifoId ?? this.currentGrifoId,
      currentPage: currentPage ?? this.currentPage,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  DetalleAbastecimientoState resetResponses() {
    return copyWith(
      actualizarResponse: null,
      concluirResponse: null,
    );
  }

  @override
  List<Object?> get props => [
        detallesResponse,
        detalles,
        meta,
        actualizarResponse,
        concluirResponse,
        currentGrifoId,
        currentPage,
        isLoadingMore,
      ];
}