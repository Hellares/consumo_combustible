import 'package:consumo_combustible/domain/models/licencia_conducir.dart';
import 'package:consumo_combustible/domain/repository/licencia_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetLicenciaByIdUseCase {
  final LicenciaRepository repository;
  
  GetLicenciaByIdUseCase(this.repository);

  // Future<Resource<LicenciaConducir>> run(int licenciaId) =>
  //     repository.getLicenciaById(licenciaId);
  Future<Resource<LicenciaConducir>> run({
    required int licenciaId,
  }){
    return repository.getLicenciaById(licenciaId);
  }
}