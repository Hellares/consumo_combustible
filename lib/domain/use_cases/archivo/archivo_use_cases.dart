import 'package:consumo_combustible/domain/use_cases/archivo/delete_archivo_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/archivo/get_archivos_byticket_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/archivo/get_tipos_archivos_usecase.dart';
import 'package:consumo_combustible/domain/use_cases/archivo/upload_archivos_usecase.dart';

class ArchivoUseCases {
  final GetTiposArchivoUseCase getTiposArchivo;
  final UploadArchivosUseCase uploadArchivos;
  final GetArchivosByTicketUseCase getArchivosByTicket;
  final DeleteArchivoUseCase deleteArchivo;

  ArchivoUseCases({
    required this.getTiposArchivo,
    required this.uploadArchivos,
    required this.getArchivosByTicket,
    required this.deleteArchivo,
  });
}