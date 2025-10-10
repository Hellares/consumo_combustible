// lib/presentation/page/detalle_abastecimiento/bloc/archivo_bloc.dart

import 'package:consumo_combustible/domain/models/archivo_ticket.dart';
import 'package:consumo_combustible/domain/models/tipo_archivo.dart';
import 'package:consumo_combustible/domain/use_cases/archivo/archivo_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/archivo/bloc/archivo_event.dart';
import 'package:consumo_combustible/presentation/page/archivo/bloc/archivo_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ArchivoBloc extends Bloc<ArchivoEvent, ArchivoState> {
  final ArchivoUseCases _archivoUseCases;

  ArchivoBloc(this._archivoUseCases) : super(const ArchivoState()) {
    on<LoadTiposArchivo>(_onLoadTiposArchivo);
    on<LoadArchivosByTicket>(_onLoadArchivosByTicket);
    on<SelectArchivos>(_onSelectArchivos);
    on<RemoveSelectedArchivo>(_onRemoveSelectedArchivo);
    on<ClearSelection>(_onClearSelection);
    on<UploadArchivos>(_onUploadArchivos);
    on<DeleteArchivo>(_onDeleteArchivo);
    on<ResetArchivoState>(_onResetArchivoState);
  }

  // ===== CARGAR TIPOS DE ARCHIVO =====
  Future<void> _onLoadTiposArchivo(
    LoadTiposArchivo event,
    Emitter<ArchivoState> emit,
  ) async {
    if (kDebugMode) {
      print('🎬 [ArchivoBloc] Cargando tipos de archivo...');
    }

    emit(state.copyWith(
      tiposArchivoResponse: Loading(),
    ));

    final result = await _archivoUseCases.getTiposArchivo.run();

    if (result is Success<List<TipoArchivo>>) {
      if (kDebugMode) {
        print('✅ [ArchivoBloc] ${result.data.length} tipos cargados');
      }
      emit(state.copyWith(
        tiposArchivoResponse: result,
        tiposArchivo: result.data,
      ));
    } else if (result is Error<List<TipoArchivo>>) {
      
      if (kDebugMode) {
        print('❌ [ArchivoBloc] Error: ${result.message}');
      }
      emit(state.copyWith(
        tiposArchivoResponse: result,
        errorMessage: result.message,
      ));
    }
  }

  // ===== CARGAR ARCHIVOS DE UN TICKET =====
  Future<void> _onLoadArchivosByTicket(
    LoadArchivosByTicket event,
    Emitter<ArchivoState> emit,
  ) async {
    if (kDebugMode) {
      print('🎬 [ArchivoBloc] Cargando archivos del ticket ${event.ticketId}...');
    }

    emit(state.copyWith(
      archivosResponse: Loading(),
    ));

    final result = await _archivoUseCases.getArchivosByTicket.run(event.ticketId);

    if (result is Success<List<ArchivoTicket>>) {
      if (kDebugMode) {
        print('✅ [ArchivoBloc] ${result.data.length} archivos cargados');
      }
      emit(state.copyWith(
        archivosResponse: result,
        archivos: result.data,
      ));
    } else if (result is Error<List<ArchivoTicket>>) {
      if (kDebugMode) {
        print('❌ [ArchivoBloc] Error: ${result.message}');
      }
      emit(state.copyWith(
        archivosResponse: result,
        errorMessage: result.message,
      ));
    }
  }

  // ===== SELECCIONAR ARCHIVOS =====
  void _onSelectArchivos(
    SelectArchivos event,
    Emitter<ArchivoState> emit,
  ) {
    if (kDebugMode) {
      print('📎 [ArchivoBloc] Seleccionando ${event.files.length} archivo(s)...');
    }

    // Agregar solo archivos que no estén ya seleccionados
    final newFiles = event.files.where((file) {
      return !state.selectedFiles.any((selected) => selected.path == file.path);
    }).toList();

    final updatedFiles = [...state.selectedFiles, ...newFiles];

    // Limitar a 10 archivos
    if (updatedFiles.length > 10) {
      if (kDebugMode) {
        print('⚠️ [ArchivoBloc] Se limita a 10 archivos');
      }
      emit(state.copyWith(
        selectedFiles: updatedFiles.take(10).toList(),
        errorMessage: 'Máximo 10 archivos permitidos. Se seleccionaron los primeros 10.',
      ));
      return;
    }

    if (kDebugMode) {
      print('✅ [ArchivoBloc] ${updatedFiles.length} archivo(s) seleccionado(s)');
    }

    emit(state.copyWith(
      selectedFiles: updatedFiles,
      errorMessage: null,
    ));
  }

  // ===== REMOVER ARCHIVO DE SELECCIÓN =====
  void _onRemoveSelectedArchivo(
    RemoveSelectedArchivo event,
    Emitter<ArchivoState> emit,
  ) {
    if (kDebugMode) {
      print('🗑️ [ArchivoBloc] Removiendo archivo de selección...');
    }

    final updatedFiles = state.selectedFiles
        .where((file) => file.path != event.file.path)
        .toList();

    if (kDebugMode) {
      print('✅ [ArchivoBloc] Archivo removido. Quedan ${updatedFiles.length}');
    }

    emit(state.copyWith(
      selectedFiles: updatedFiles,
      errorMessage: null,
    ));
  }

  // ===== LIMPIAR SELECCIÓN =====
  void _onClearSelection(
    ClearSelection event,
    Emitter<ArchivoState> emit,
  ) {
    if (kDebugMode) {
      print('🧹 [ArchivoBloc] Limpiando selección...');
    }

    emit(state.copyWith(
      selectedFiles: [],
      errorMessage: null,
    ));
  }

  // ===== SUBIR ARCHIVOS =====
  Future<void> _onUploadArchivos(
    UploadArchivos event,
    Emitter<ArchivoState> emit,
  ) async {
    if (state.selectedFiles.isEmpty) {
      if (kDebugMode) {
        print('⚠️ [ArchivoBloc] No hay archivos seleccionados');
      }
      emit(state.copyWith(
        errorMessage: 'Debe seleccionar al menos un archivo',
      ));
      return;
    }

    if (kDebugMode) {
      print('📤 [ArchivoBloc] Subiendo ${state.selectedFiles.length} archivo(s)...');
      print('   Ticket ID: ${event.ticketId}');
      print('   Tipo Archivo ID: ${event.tipoArchivoId}');
      if (event.descripcion != null) {
        print('   Descripción: ${event.descripcion}');
      }
    }

    emit(state.copyWith(
      uploadResponse: Loading(),
      isUploading: true,
      errorMessage: null,
    ));

    final result = await _archivoUseCases.uploadArchivos.run(
      ticketId: event.ticketId,
      tipoArchivoId: event.tipoArchivoId,
      files: state.selectedFiles,
      descripcion: event.descripcion,
      esPrincipal: false,
    );

    if (result is Success<List<ArchivoTicket>>) {
      if (kDebugMode) {
        print('✅ [ArchivoBloc] ${result.data.length} archivo(s) subido(s) exitosamente');
      }

      // Actualizar lista de archivos
      final updatedArchivos = [...state.archivos, ...result.data];

      emit(state.copyWith(
        uploadResponse: result,
        isUploading: false,
        archivos: updatedArchivos,
        selectedFiles: [], // Limpiar selección
        errorMessage: null,
      ));
    } else if (result is Error<List<ArchivoTicket>>) {
      if (kDebugMode) {
        print('❌ [ArchivoBloc] Error al subir: ${result.message}');
      }
      emit(state.copyWith(
        uploadResponse: result,
        isUploading: false,
        errorMessage: result.message,
      ));
    }
  }

  // ===== ELIMINAR ARCHIVO =====
  Future<void> _onDeleteArchivo(
    DeleteArchivo event,
    Emitter<ArchivoState> emit,
  ) async {
    if (kDebugMode) {
      print('🗑️ [ArchivoBloc] Eliminando archivo ${event.archivoId} del ticket ${event.ticketId}...');
    }

    emit(state.copyWith(
      deleteResponse: Loading(),
      isDeleting: true,
      deletingArchivoId: event.archivoId,
      errorMessage: null,
    ));

    final result = await _archivoUseCases.deleteArchivo.run(event.archivoId, event.ticketId);

    if (result is Success) {
      if (kDebugMode) {
        print('✅ [ArchivoBloc] Archivo ${event.archivoId} eliminado exitosamente');
      }

      // Remover archivo de la lista localmente
      final updatedArchivos = state.archivos
          .where((archivo) => archivo.id != event.archivoId)
          .toList();

      if (kDebugMode) {
        print('   Archivos restantes: ${updatedArchivos.length}');
      }

      emit(state.copyWith(
        deleteResponse: result,
        isDeleting: false,
        deletingArchivoId: null,
        archivos: updatedArchivos,
        errorMessage: null,
      ));

      // No necesitamos recargar desde el servidor porque ya actualizamos la lista localmente
    } else if (result is Error) {
      if (kDebugMode) {
        print('❌ [ArchivoBloc] Error al eliminar: ${result.message}');
      }
      emit(state.copyWith(
        deleteResponse: result,
        isDeleting: false,
        deletingArchivoId: null,
        errorMessage: result.message,
      ));
    }
  }

  // ===== RESETEAR ESTADO =====
  void _onResetArchivoState(
    ResetArchivoState event,
    Emitter<ArchivoState> emit,
  ) {
    if (kDebugMode) {
      print('🔄 [ArchivoBloc] Reseteando estado del ArchivoBloc...');
    }
    emit(const ArchivoState());
  }
}