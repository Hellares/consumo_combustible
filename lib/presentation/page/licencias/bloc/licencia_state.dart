// lib/presentation/page/licencias/bloc/licencia_state.dart

import 'package:consumo_combustible/domain/models/licencia_conducir.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:equatable/equatable.dart';

class LicenciaState extends Equatable {
  // Response principal
  final Resource? response;
  
  // Licencias cargadas
  final List<LicenciaConducir> licencias;
  
  // Licencias filtradas (para búsqueda local)
  final List<LicenciaConducir>? licenciasFiltradas;
  
  // Paginación
  final int currentPage;
  final int totalPages;
  final int totalLicencias;
  final bool hasMore;
  
  // Estados de carga
  final bool isLoading;
  final bool isLoadingMore;
  final bool isRefreshing;
  
  // Licencia seleccionada
  final LicenciaConducir? selectedLicencia;
  
  // Filtros activos
  final String? searchQuery;
  final String? estadoFiltro; // 'TODAS', 'VIGENTES', 'VENCIDAS', 'PROXIMAS'

  const LicenciaState({
    this.response,
    this.licencias = const [],
    this.licenciasFiltradas,
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalLicencias = 0,
    this.hasMore = false,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isRefreshing = false,
    this.selectedLicencia,
    this.searchQuery,
    this.estadoFiltro = 'TODAS',
  });

  // Getters útiles
  List<LicenciaConducir> get displayLicencias => 
      licenciasFiltradas ?? licencias;
  
  int get licenciasCount => displayLicencias.length;
  
  bool get hasLicencias => displayLicencias.isNotEmpty;
  
  bool get isEmpty => displayLicencias.isEmpty && !isLoading;

  // Estadísticas
  int get vigentesCount => licencias.where((l) => l.esVigente).length;
  int get vencidasCount => licencias.where((l) => l.estaVencida).length;
  int get proximasCount => licencias.where((l) => l.proximaVencimiento).length;

  LicenciaState copyWith({
    Resource? response,
    List<LicenciaConducir>? licencias,
    List<LicenciaConducir>? licenciasFiltradas,
    int? currentPage,
    int? totalPages,
    int? totalLicencias,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isRefreshing,
    LicenciaConducir? selectedLicencia,
    String? searchQuery,
    String? estadoFiltro,
  }) {
    return LicenciaState(
      response: response ?? this.response,
      licencias: licencias ?? this.licencias,
      licenciasFiltradas: licenciasFiltradas ?? this.licenciasFiltradas,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalLicencias: totalLicencias ?? this.totalLicencias,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      selectedLicencia: selectedLicencia ?? this.selectedLicencia,
      searchQuery: searchQuery ?? this.searchQuery,
      estadoFiltro: estadoFiltro ?? this.estadoFiltro,
    );
  }

  // Métodos helper para resetear campos opcionales
  LicenciaState clearFilter() {
    return LicenciaState(
      response: response,
      licencias: licencias,
      licenciasFiltradas: null,
      currentPage: currentPage,
      totalPages: totalPages,
      totalLicencias: totalLicencias,
      hasMore: hasMore,
      isLoading: isLoading,
      isLoadingMore: isLoadingMore,
      isRefreshing: isRefreshing,
      selectedLicencia: selectedLicencia,
      searchQuery: null,
      estadoFiltro: estadoFiltro,
    );
  }

  LicenciaState clearSelection() {
    return copyWith(
      selectedLicencia: null,
    );
  }

  @override
  List<Object?> get props => [
    response,
    licencias,
    licenciasFiltradas,
    currentPage,
    totalPages,
    totalLicencias,
    hasMore,
    isLoading,
    isLoadingMore,
    isRefreshing,
    selectedLicencia,
    searchQuery,
    estadoFiltro,
  ];
}