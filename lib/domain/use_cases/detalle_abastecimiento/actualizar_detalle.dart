import 'package:consumo_combustible/domain/models/detalle_abastecimiento.dart';
import 'package:consumo_combustible/domain/repository/detalle_abastecimiento_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class ActualizarDetalle {
  final DetalleAbastecimientoRepository repository;

  ActualizarDetalle(this.repository);

  Future<Resource<DetalleAbastecimiento>> run({
    required int detalleId,
    required Map<String, dynamic> data,
  }) {
    return repository.actualizarDetalle(
      detalleId: detalleId,
      data: data,
    );
  }
}