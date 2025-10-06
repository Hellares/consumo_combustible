import 'package:consumo_combustible/data/datasource/remote/service/detalle_abastecimiento_service.dart';
import 'package:consumo_combustible/domain/models/detalle_abastecimiento.dart';
import 'package:consumo_combustible/domain/repository/detalle_abastecimiento_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class DetalleAbastecimientoRepositoryImpl implements DetalleAbastecimientoRepository {
  final DetalleAbastecimientoService service;

  DetalleAbastecimientoRepositoryImpl(this.service);

  @override
  Future<Resource<Map<String, dynamic>>> getDetallesByGrifo({
    required int grifoId,
    int page = 1,
    int pageSize = 10,
  }) {
    return service.getDetallesByGrifo(
      grifoId: grifoId,
      page: page,
      pageSize: pageSize,
    );
  }

  @override
  Future<Resource<DetalleAbastecimiento>> actualizarDetalle({
    required int detalleId,
    Map<String, dynamic>? data,
  }) {
    return service.actualizarDetalle(
      detalleId: detalleId,
      data: data,
    );
  }

  @override
  Future<Resource<DetalleAbastecimiento>> concluirDetalle({
    required int detalleId,
    required int concluidoPorId,
  }) {
    return service.concluirDetalle(
      detalleId: detalleId,
      concluidoPorId: concluidoPorId,
    );
  }
}