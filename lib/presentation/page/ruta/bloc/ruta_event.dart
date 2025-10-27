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