// import 'package:consumo_combustible/domain/utils/resource.dart';
// import 'package:equatable/equatable.dart';

// class TicketState extends Equatable {
//   final Resource? createResponse;

//   const TicketState({this.createResponse});

//   TicketState copyWith({Resource? createResponse}) {
//     return TicketState(
//       createResponse: createResponse ?? this.createResponse,
//     );
//   }

//   @override
//   List<Object?> get props => [createResponse];
// }

// lib/presentation/page/ticket_abastecimiento/bloc/ticket_state.dart

// lib/presentation/page/ticket_abastecimiento/bloc/ticket_state.dart

import 'package:consumo_combustible/domain/models/unidad.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:equatable/equatable.dart';

class TicketState extends Equatable {
  /// Estado de la respuesta al crear ticket
  final Resource? createResponse;
  
  /// ✅ NUEVO: Estado de la respuesta al cargar unidades
  final Resource? unidadesResponse; // ✅ Cambio: Resource sin genérico
  
  /// ✅ NUEVO: Lista de unidades cargadas
  final List<Unidad> unidades;

  const TicketState({
    this.createResponse,
    this.unidadesResponse,
    this.unidades = const [],
  });

  /// Método para copiar el estado con nuevos valores
  TicketState copyWith({
    Resource? createResponse,
    Resource? unidadesResponse, // ✅ Cambio aquí también
    List<Unidad>? unidades,
  }) {
    return TicketState(
      createResponse: createResponse ?? this.createResponse,
      unidadesResponse: unidadesResponse ?? this.unidadesResponse,
      unidades: unidades ?? this.unidades,
    );
  }

  @override
  List<Object?> get props => [
        createResponse,
        unidadesResponse,
        unidades,
      ];

  /// ✅ Helper: Verificar si está cargando unidades
  bool get isLoadingUnidades => unidadesResponse is Loading;

  /// ✅ Helper: Verificar si hay error al cargar unidades
  bool get hasUnidadesError => unidadesResponse is Error;

  /// ✅ Helper: Verificar si las unidades están cargadas
  bool get hasUnidades => unidades.isNotEmpty;

  /// ✅ Helper: Verificar si está creando ticket
  bool get isCreatingTicket => createResponse is Loading;

  /// ✅ Helper: Verificar si el ticket fue creado exitosamente
  bool get ticketCreated => createResponse is Success;
  
  /// ✅ Helper: Obtener mensaje de error de unidades
  String? get unidadesErrorMessage {
    if (unidadesResponse is Error) {
      return (unidadesResponse as Error).message;
    }
    return null;
  }
}