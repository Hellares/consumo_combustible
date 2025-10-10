// lib/presentation/page/detalle_abastecimiento/bloc/archivo_event.dart

import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ArchivoEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

// Cargar tipos de archivo disponibles
class LoadTiposArchivo extends ArchivoEvent {}

// Cargar archivos de un ticket
class LoadArchivosByTicket extends ArchivoEvent {
  final int ticketId;
  
  LoadArchivosByTicket(this.ticketId);
  
  @override
  List<Object?> get props => [ticketId];
}

// Seleccionar archivos desde el dispositivo
class SelectArchivos extends ArchivoEvent {
  final List<File> files;
  
  SelectArchivos(this.files);
  
  @override
  List<Object?> get props => [files];
}

// Remover archivo de la selección
class RemoveSelectedArchivo extends ArchivoEvent {
  final File file;
  
  RemoveSelectedArchivo(this.file);
  
  @override
  List<Object?> get props => [file.path]; // Usamos path porque File no es comparable
}

// Limpiar selección
class ClearSelection extends ArchivoEvent {}

// Subir archivos seleccionados
class UploadArchivos extends ArchivoEvent {
  final int ticketId;
  final int tipoArchivoId;
  final String? descripcion;
  
  UploadArchivos({
    required this.ticketId,
    required this.tipoArchivoId,
    this.descripcion,
  });
  
  @override
  List<Object?> get props => [ticketId, tipoArchivoId, descripcion];
}

// Eliminar archivo del servidor
class DeleteArchivo extends ArchivoEvent {
  final int archivoId;
  final int ticketId;
  
  DeleteArchivo({
    required this.archivoId,
    required this.ticketId,
  });
  
  @override
  List<Object?> get props => [archivoId, ticketId];
}

// Reset del estado
class ResetArchivoState extends ArchivoEvent {}