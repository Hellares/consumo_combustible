// lib/domain/use_cases/licencia/create_licencia_use_case.dart

import 'package:consumo_combustible/domain/models/create_licencia_request.dart';
import 'package:consumo_combustible/domain/models/licencia_conducir.dart';
import 'package:consumo_combustible/domain/repository/licencia_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class CreateLicenciaUseCase {
  final LicenciaRepository repository;

  CreateLicenciaUseCase(this.repository);

  Future<Resource<LicenciaConducir>> run(CreateLicenciaRequest request) {
    return repository.createLicencia(request);
  }
}