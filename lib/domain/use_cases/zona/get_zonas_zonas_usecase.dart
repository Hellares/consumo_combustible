import 'package:consumo_combustible/domain/models/zona.dart';
import 'package:consumo_combustible/domain/repository/zona_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetZonasZonasUseCase {
  final ZonaRepository repository;

  GetZonasZonasUseCase(this.repository);

  Future<Resource<List<Zona>>> run() {
    return repository.getZonas();
  }
}