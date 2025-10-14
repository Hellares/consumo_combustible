
import 'package:consumo_combustible/domain/models/create_zona_request.dart';
import 'package:consumo_combustible/domain/models/zona.dart';
import 'package:consumo_combustible/domain/repository/zona_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class CreateZonaUseCase {
  final ZonaRepository repository;

  CreateZonaUseCase(this.repository);

  Future<Resource<Zona>> run(CreateZonaRequest request) {
    return repository.createZona(request);
  }
}