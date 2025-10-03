import 'package:consumo_combustible/domain/repository/location_repository.dart';

class ClearSelectedLocationUseCase {
  final LocationRepository repository;
  ClearSelectedLocationUseCase(this.repository);
  Future<void> run() => repository.clearSelectedLocation();
}