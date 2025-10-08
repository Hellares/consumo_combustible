// lib/presentation/page/licencias/bloc/licencia_event.dart

import 'package:consumo_combustible/domain/models/create_licencia_request.dart';
import 'package:equatable/equatable.dart';

abstract class LicenciaEvent extends Equatable {
  const LicenciaEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar todas las licencias con paginación
class LoadLicencias extends LicenciaEvent {
  final int page;
  final int pageSize;

  const LoadLicencias({
    this.page = 1,
    this.pageSize = 10,
  });

  @override
  List<Object?> get props => [page, pageSize];
}

/// Cargar más licencias (paginación)
class LoadMoreLicencias extends LicenciaEvent {
  const LoadMoreLicencias();
}

/// Cargar licencia específica por ID
class LoadLicenciaById extends LicenciaEvent {
  final int licenciaId;

  const LoadLicenciaById(this.licenciaId);

  @override
  List<Object?> get props => [licenciaId];
}

/// Cargar licencias por usuario
class LoadLicenciasByUsuario extends LicenciaEvent {
  final int usuarioId;

  const LoadLicenciasByUsuario(this.usuarioId);

  @override
  List<Object?> get props => [usuarioId];
}

/// Cargar licencias vencidas
class LoadLicenciasVencidas extends LicenciaEvent {
  const LoadLicenciasVencidas();
}

/// Cargar licencias próximas a vencer
class LoadLicenciasProximasVencer extends LicenciaEvent {
  const LoadLicenciasProximasVencer();
}

/// Refrescar lista de licencias
class RefreshLicencias extends LicenciaEvent {
  const RefreshLicencias();
}

/// Filtrar licencias localmente
class FilterLicencias extends LicenciaEvent {
  final String query;

  const FilterLicencias(this.query);

  @override
  List<Object?> get props => [query];
}

/// Crear nueva licencia
class CreateLicencia extends LicenciaEvent {
  final CreateLicenciaRequest request;

  const CreateLicencia(this.request);

  @override
  List<Object?> get props => [request];
}

/// Resetear estado
class ResetLicenciaState extends LicenciaEvent {
  const ResetLicenciaState();
}