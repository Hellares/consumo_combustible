import 'package:consumo_combustible/domain/models/licencia_conducir.dart';
import 'package:consumo_combustible/domain/repository/licencia_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetLicenciasByUsuarioUseCase {
  final LicenciaRepository repository;
  
  GetLicenciasByUsuarioUseCase(this.repository);

  Future<Resource<List<LicenciaConducir>>> run(int usuarioId) =>
      repository.getLicenciasByUsuario(usuarioId);
}