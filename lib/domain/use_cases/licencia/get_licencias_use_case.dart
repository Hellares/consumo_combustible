import 'package:consumo_combustible/domain/models/licencia_conducir.dart';
import 'package:consumo_combustible/domain/repository/licencia_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetLicenciasUseCase {
  final LicenciaRepository repository;
  
  GetLicenciasUseCase(this.repository);

  Future<Resource<LicenciasResponse>> run({
    int page = 1,
    int pageSize = 10,
  }) => repository.getLicencias(page: page, pageSize: pageSize);
}