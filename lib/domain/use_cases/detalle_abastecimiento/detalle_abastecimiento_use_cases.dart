import 'package:consumo_combustible/domain/use_cases/detalle_abastecimiento/actualizar_detalle.dart';
import 'package:consumo_combustible/domain/use_cases/detalle_abastecimiento/concluir_detalle.dart';
import 'package:consumo_combustible/domain/use_cases/detalle_abastecimiento/get_detalles_abastecimiento.dart';

class DetalleAbastecimientoUseCases {
  final GetDetallesAbastecimiento getDetallesAbastecimiento;
  final ActualizarDetalle actualizarDetalle;
  final ConcluirDetalle concluirDetalle;

  DetalleAbastecimientoUseCases({
    required this.getDetallesAbastecimiento,
    required this.actualizarDetalle,
    required this.concluirDetalle,
  });
}