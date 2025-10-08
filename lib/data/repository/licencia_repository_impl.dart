import 'package:consumo_combustible/data/datasource/remote/service/licencia_service.dart';
import 'package:consumo_combustible/domain/models/create_licencia_request.dart';
import 'package:consumo_combustible/domain/models/licencia_conducir.dart';
import 'package:consumo_combustible/domain/repository/licencia_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class LicenciaRepositoryImpl implements LicenciaRepository {
  final LicenciaService service;

  LicenciaRepositoryImpl(this.service);

  @override
  Future<Resource<LicenciasResponse>> getLicencias({
    int page = 1,
    int pageSize = 10,
  }) {
    return service.getLicencias(page: page, pageSize: pageSize);
  }

  @override
  Future<Resource<LicenciaConducir>> getLicenciaById(int licenciaId) {
    return service.getLicenciaById(licenciaId);
  }

  @override
  Future<Resource<List<LicenciaConducir>>> getLicenciasByUsuario(int usuarioId) {
    return service.getLicenciasByUsuario(usuarioId);
  }

  @override
  Future<Resource<List<LicenciaConducir>>> getLicenciasVencidas() {
    return service.getLicenciasVencidas();
  }

  @override
  Future<Resource<List<LicenciaConducir>>> getLicenciasProximasVencer() {
    return service.getLicenciasProximasVencer();
  }

  @override
  Future<Resource<LicenciaConducir>> createLicencia(CreateLicenciaRequest request) {
    return service.createLicencia(request);
  }
}