import 'package:consumo_combustible/domain/models/selected_location.dart';
import 'package:consumo_combustible/domain/repository/location_repository.dart';

class GetSelectedLocationUseCase {
  final LocationRepository repository;
  GetSelectedLocationUseCase(this.repository);
  Future<SelectedLocation?> run() => repository.getSelectedLocation();
}