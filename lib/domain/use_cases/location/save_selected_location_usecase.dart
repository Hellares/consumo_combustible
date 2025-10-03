import 'package:consumo_combustible/domain/models/selected_location.dart';
import 'package:consumo_combustible/domain/repository/location_repository.dart';

class SaveSelectedLocationUseCase {
  final LocationRepository repository;
  SaveSelectedLocationUseCase(this.repository);
  Future<void> run(SelectedLocation location) => 
      repository.saveSelectedLocation(location);
}