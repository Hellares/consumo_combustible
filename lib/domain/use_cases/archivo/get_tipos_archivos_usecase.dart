import 'package:consumo_combustible/domain/models/tipo_archivo.dart';
import 'package:consumo_combustible/domain/repository/archivo_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetTiposArchivoUseCase {
  final ArchivoRepository _repository;

  GetTiposArchivoUseCase(this._repository);

  Future<Resource<List<TipoArchivo>>> run() {
    return _repository.getTiposArchivo();
  }
}