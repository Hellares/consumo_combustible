// lib/presentation/page/detalle_abastecimiento/bloc/archivo_state.dart

import 'dart:io';
import 'package:consumo_combustible/domain/models/archivo_ticket.dart';
import 'package:consumo_combustible/domain/models/tipo_archivo.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:equatable/equatable.dart';

class ArchivoState extends Equatable {
  // Tipos de archivo disponibles
  final Resource<List<TipoArchivo>>? tiposArchivoResponse;
  final List<TipoArchivo> tiposArchivo;
  
  // Archivos del ticket
  final Resource<List<ArchivoTicket>>? archivosResponse;
  final List<ArchivoTicket> archivos;
  
  // Archivos seleccionados para subir
  final List<File> selectedFiles;
  
  // Estado de subida
  final Resource<List<ArchivoTicket>>? uploadResponse;
  final bool isUploading;
  
  // Estado de eliminación
  final Resource<void>? deleteResponse;
  final bool isDeleting;
  final int? deletingArchivoId;
  
  // Errores
  final String? errorMessage;

  const ArchivoState({
    this.tiposArchivoResponse,
    this.tiposArchivo = const [],
    this.archivosResponse,
    this.archivos = const [],
    this.selectedFiles = const [],
    this.uploadResponse,
    this.isUploading = false,
    this.deleteResponse,
    this.isDeleting = false,
    this.deletingArchivoId,
    this.errorMessage,
  });

  ArchivoState copyWith({
    Resource<List<TipoArchivo>>? tiposArchivoResponse,
    List<TipoArchivo>? tiposArchivo,
    Resource<List<ArchivoTicket>>? archivosResponse,
    List<ArchivoTicket>? archivos,
    List<File>? selectedFiles,
    Resource<List<ArchivoTicket>>? uploadResponse,
    bool? isUploading,
    Resource<void>? deleteResponse,
    bool? isDeleting,
    int? deletingArchivoId,
    String? errorMessage,
  }) {
    return ArchivoState(
      tiposArchivoResponse: tiposArchivoResponse ?? this.tiposArchivoResponse,
      tiposArchivo: tiposArchivo ?? this.tiposArchivo,
      archivosResponse: archivosResponse ?? this.archivosResponse,
      archivos: archivos ?? this.archivos,
      selectedFiles: selectedFiles ?? this.selectedFiles,
      uploadResponse: uploadResponse ?? this.uploadResponse,
      isUploading: isUploading ?? this.isUploading,
      deleteResponse: deleteResponse ?? this.deleteResponse,
      isDeleting: isDeleting ?? this.isDeleting,
      deletingArchivoId: deletingArchivoId,
      errorMessage: errorMessage,
    );
  }

  // Método para resetear estado de subida
  ArchivoState resetUploadState() {
    return copyWith(
      uploadResponse: null,
      isUploading: false,
      selectedFiles: [],
      errorMessage: null,
    );
  }

  // Método para resetear estado de eliminación
  ArchivoState resetDeleteState() {
    return copyWith(
      deleteResponse: null,
      isDeleting: false,
      deletingArchivoId: null,
      errorMessage: null,
    );
  }

  // Getters de conveniencia
  bool get hasSelectedFiles => selectedFiles.isNotEmpty;
  
  int get selectedFilesCount => selectedFiles.length;
  
  bool get canUpload => hasSelectedFiles && !isUploading;
  
  List<TipoArchivo> get tiposArchivoActivos => 
      tiposArchivo.where((t) => t.activo).toList();
  
  List<ArchivoTicket> get archivosActivos =>
      archivos.where((a) => a.activo).toList();

  // Obtener archivos por tipo
  List<ArchivoTicket> archivosPorTipo(int tipoArchivoId) {
    return archivos
        .where((a) => a.tipoArchivo.id == tipoArchivoId && a.activo)
        .toList();
  }

  // Obtener archivos por categoría
  List<ArchivoTicket> archivosPorCategoria(String categoria) {
    return archivos
        .where((a) => a.tipoArchivo.categoria == categoria && a.activo)
        .toList();
  }

  // Verificar si hay archivos de un tipo específico
  bool tieneArchivosDeTipo(int tipoArchivoId) {
    return archivos.any((a) => a.tipoArchivo.id == tipoArchivoId && a.activo);
  }

  // Total de bytes seleccionados
  int get totalBytesSelected {
    return selectedFiles.fold(0, (sum, file) => sum + file.lengthSync());
  }

  // Validar si se puede agregar más archivos
  bool get canAddMoreFiles => selectedFiles.length < 10;

  @override
  List<Object?> get props => [
    tiposArchivoResponse,
    tiposArchivo,
    archivosResponse,
    archivos,
    selectedFiles.map((f) => f.path).toList(), // Usamos paths para comparación
    uploadResponse,
    isUploading,
    deleteResponse,
    isDeleting,
    deletingArchivoId,
    errorMessage,
  ];
}