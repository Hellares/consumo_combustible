// lib/domain/repository/licencia_repository.dart

import 'package:consumo_combustible/domain/models/create_licencia_request.dart';
import 'package:consumo_combustible/domain/models/licencia_conducir.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

abstract class LicenciaRepository {
  Future<Resource<LicenciasResponse>> getLicencias({
    int page = 1,
    int pageSize = 10,
  });
  
  Future<Resource<LicenciaConducir>> getLicenciaById(int licenciaId);
  
  Future<Resource<List<LicenciaConducir>>> getLicenciasByUsuario(int usuarioId);
  
  Future<Resource<List<LicenciaConducir>>> getLicenciasVencidas();
  
  Future<Resource<List<LicenciaConducir>>> getLicenciasProximasVencer();
  
  Future<Resource<LicenciaConducir>> createLicencia(CreateLicenciaRequest request);
}