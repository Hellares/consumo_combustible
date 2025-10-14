// lib/presentation/bloc/unidad/unidad_state.dart

import 'package:consumo_combustible/domain/models/unidad.dart';
import 'package:equatable/equatable.dart';

enum UnidadStatus {
  initial,      // Estado inicial
  loading,      // Cargando datos
  loadingMore,  // Cargando más datos (paginación)
  success,      // Datos cargados exitosamente
  error,        // Error al cargar datos
  creating,     // Creando unidad
  created,      // Unidad creada exitosamente
  createError,  // Error al crear unidad
}

class UnidadState extends Equatable {
  final UnidadStatus status;
  final List<Unidad> unidades;
  final Unidad? selectedUnidad;
  final String? errorMessage;
  
  // Metadata de paginación
  final int currentPage;
  final int totalPages;
  final int total;
  final bool hasMore;
  
  // Estado de creación
  final Unidad? createdUnidad;
  final String? createErrorMessage;

  const UnidadState({
    this.status = UnidadStatus.initial,
    this.unidades = const [],
    this.selectedUnidad,
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 1,
    this.total = 0,
    this.hasMore = false,
    this.createdUnidad,
    this.createErrorMessage,
  });

  // Estado inicial
  factory UnidadState.initial() {
    return const UnidadState(
      status: UnidadStatus.initial,
      unidades: [],
      currentPage: 1,
      totalPages: 1,
      total: 0,
      hasMore: false,
    );
  }

  // CopyWith para crear nuevos estados
  UnidadState copyWith({
    UnidadStatus? status,
    List<Unidad>? unidades,
    Unidad? selectedUnidad,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
    int? total,
    bool? hasMore,
    Unidad? createdUnidad,
    String? createErrorMessage,
  }) {
    return UnidadState(
      status: status ?? this.status,
      unidades: unidades ?? this.unidades,
      selectedUnidad: selectedUnidad ?? this.selectedUnidad,
      errorMessage: errorMessage ?? this.errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      total: total ?? this.total,
      hasMore: hasMore ?? this.hasMore,
      createdUnidad: createdUnidad ?? this.createdUnidad,
      createErrorMessage: createErrorMessage ?? this.createErrorMessage,
    );
  }

  // Para limpiar errores de creación
  UnidadState clearCreateError() {
    return copyWith(
      status: UnidadStatus.success,
      createErrorMessage: null,
      createdUnidad: null,
    );
  }

  // Para limpiar la unidad seleccionada
  UnidadState clearSelected() {
    return copyWith(
      selectedUnidad: null,
    );
  }

  @override
  List<Object?> get props => [
        status,
        unidades,
        selectedUnidad,
        errorMessage,
        currentPage,
        totalPages,
        total,
        hasMore,
        createdUnidad,
        createErrorMessage,
      ];
}