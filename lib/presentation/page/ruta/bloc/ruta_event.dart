// lib/presentation/page/ruta/bloc/ruta_event.dart

import 'package:equatable/equatable.dart';

abstract class RutaEvent extends Equatable {
  const RutaEvent();
}

/// Evento para cargar rutas activas
class LoadRutasActivas extends RutaEvent {
  const LoadRutasActivas();

  @override
  List<Object?> get props => [];
}

/// Evento para limpiar el estado
class ClearRutas extends RutaEvent {
  const ClearRutas();

  @override
  List<Object?> get props => [];
}

/// 🔥 NUEVO: Evento para cargar una ruta por ID
class LoadRutaById extends RutaEvent {
  final int rutaId;

  const LoadRutaById(this.rutaId);

  @override
  List<Object?> get props => [rutaId];
}

/// 🔥 NUEVO: Evento para cargar una ruta por código
class LoadRutaByCodigo extends RutaEvent {
  final String codigo;

  const LoadRutaByCodigo(this.codigo);

  @override
  List<Object?> get props => [codigo];
}

/// 🔥 NUEVO: Evento para limpiar el detalle de ruta
class ClearRutaDetalle extends RutaEvent {
  const ClearRutaDetalle();

  @override
  List<Object?> get props => [];
}