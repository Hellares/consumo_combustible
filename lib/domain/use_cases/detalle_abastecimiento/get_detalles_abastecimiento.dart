import 'package:consumo_combustible/domain/repository/detalle_abastecimiento_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetDetallesAbastecimiento {
  final DetalleAbastecimientoRepository repository;

  GetDetallesAbastecimiento(this.repository);

  Future<Resource<Map<String, dynamic>>> run({
    required int grifoId,
    int page = 1,
    int pageSize = 10,
  }) {
    return repository.getDetallesByGrifo(
      grifoId: grifoId,
      page: page,
      pageSize: pageSize,
    );
  }
}