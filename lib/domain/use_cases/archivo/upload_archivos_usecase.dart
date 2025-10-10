import 'dart:io';

import 'package:consumo_combustible/domain/models/archivo_ticket.dart';
import 'package:consumo_combustible/domain/repository/archivo_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class UploadArchivosUseCase {
  final ArchivoRepository _repository;

  UploadArchivosUseCase(this._repository);

  Future<Resource<List<ArchivoTicket>>> run({
    required int ticketId,
    required int tipoArchivoId,
    required List<File> files,
    String? descripcion,
    int? orden,
    bool esPrincipal = false,
  }) {
    // Validaciones
    if (files.isEmpty) {
      return Future.value(Error('Debe seleccionar al menos un archivo'));
    }

    if (files.length > 10) {
      return Future.value(Error('Máximo 10 archivos permitidos'));
    }

    // Validar tamaño (10MB por archivo)
    const maxSize = 10 * 1024 * 1024; // 10MB
    for (var file in files) {
      final size = file.lengthSync();
      if (size > maxSize) {
        final fileName = file.path.split('/').last;
        return Future.value(
          Error('El archivo "$fileName" supera el tamaño máximo de 10MB'),
        );
      }
    }

    // Validar extensiones permitidas
    final allowedExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'pdf'];
    for (var file in files) {
      final extension = file.path.split('.').last.toLowerCase();
      if (!allowedExtensions.contains(extension)) {
        final fileName = file.path.split('/').last;
        return Future.value(
          Error('El archivo "$fileName" tiene una extensión no permitida'),
        );
      }
    }

    return _repository.uploadArchivos(
      ticketId: ticketId,
      tipoArchivoId: tipoArchivoId,
      files: files,
      descripcion: descripcion,
      orden: orden,
      esPrincipal: esPrincipal,
    );
  }
}