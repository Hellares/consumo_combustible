import 'package:consumo_combustible/domain/models/zona.dart';
import 'package:consumo_combustible/domain/repository/location_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetZonasUseCase {
  final LocationRepository repository;
  GetZonasUseCase(this.repository);
  Future<Resource<List<Zona>>> run() => repository.getZonas();
}