import 'package:consumo_combustible/domain/models/detalle_abastecimiento.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

abstract class DetalleAbastecimientoRepository {
  Future<Resource<Map<String, dynamic>>> getDetallesByGrifo({
    required int grifoId,
    int page = 1,
    int pageSize = 10,
  });

  Future<Resource<DetalleAbastecimiento>> actualizarDetalle({
    required int detalleId,
    Map<String, dynamic>? data,
  });

  Future<Resource<DetalleAbastecimiento>> concluirDetalle({
    required int detalleId,
    required int concluidoPorId,
  });
}