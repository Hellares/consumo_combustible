import 'package:consumo_combustible/domain/models/licencia_conducir.dart';
import 'package:consumo_combustible/domain/repository/licencia_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetLicenciasVencidasUseCase {
  final LicenciaRepository repository;
  
  GetLicenciasVencidasUseCase(this.repository);

  Future<Resource<List<LicenciaConducir>>> run() =>
      repository.getLicenciasVencidas();
}