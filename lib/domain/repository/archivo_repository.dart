import 'dart:io';
import 'package:consumo_combustible/domain/models/archivo_ticket.dart';
import 'package:consumo_combustible/domain/models/tipo_archivo.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

abstract class ArchivoRepository {
  /// Obtiene la lista de tipos de archivo disponibles
  Future<Resource<List<TipoArchivo>>> getTiposArchivo();
  
  /// Sube uno o varios archivos asociados a un ticket
  Future<Resource<List<ArchivoTicket>>> uploadArchivos({
    required int ticketId,
    required int tipoArchivoId,
    required List<File> files,
    String? descripcion,
    int? orden,
    bool esPrincipal = false,
  });
  
  /// Obtiene todos los archivos de un ticket específico
  Future<Resource<List<ArchivoTicket>>> getArchivosByTicket(int ticketId);
  
  /// Elimina un archivo por su ID
  Future<Resource<void>> deleteArchivo(int archivoId, int ticketId);
}