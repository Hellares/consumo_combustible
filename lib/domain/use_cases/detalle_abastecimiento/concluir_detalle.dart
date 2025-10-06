import 'package:consumo_combustible/domain/models/detalle_abastecimiento.dart';
import 'package:consumo_combustible/domain/repository/detalle_abastecimiento_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class ConcluirDetalle {
  final DetalleAbastecimientoRepository repository;

  ConcluirDetalle(this.repository);

  Future<Resource<DetalleAbastecimiento>> run({
    required int detalleId,
    required int concluidoPorId,
  }) {
    return repository.concluirDetalle(
      detalleId: detalleId,
      concluidoPorId: concluidoPorId,
    );
  }
}