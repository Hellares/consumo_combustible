import 'package:consumo_combustible/domain/models/ultimo_ticket_unidad.dart';
import 'package:consumo_combustible/domain/models/unidad.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:equatable/equatable.dart';

// class TicketState extends Equatable {
//   /// Estado de la respuesta al crear ticket
//   final Resource? createResponse;
  
//   /// ✅ NUEVO: Estado de la respuesta al cargar unidades
//   final Resource? unidadesResponse; // ✅ Cambio: Resource sin genérico
  
//   /// ✅ NUEVO: Lista de unidades cargadas
//   final List<Unidad> unidades;

//   const TicketState({
//     this.createResponse,
//     this.unidadesResponse,
//     this.unidades = const [],
//   });

//   /// Método para copiar el estado con nuevos valores
//   TicketState copyWith({
//     Resource? createResponse,
//     Resource? unidadesResponse, // ✅ Cambio aquí también
//     List<Unidad>? unidades,
//   }) {
//     return TicketState(
//       createResponse: createResponse ?? this.createResponse,
//       unidadesResponse: unidadesResponse ?? this.unidadesResponse,
//       unidades: unidades ?? this.unidades,
//     );
//   }

//   @override
//   List<Object?> get props => [
//         createResponse,
//         unidadesResponse,
//         unidades,
//       ];

//   /// ✅ Helper: Verificar si está cargando unidades
//   bool get isLoadingUnidades => unidadesResponse is Loading;

//   /// ✅ Helper: Verificar si hay error al cargar unidades
//   bool get hasUnidadesError => unidadesResponse is Error;

//   /// ✅ Helper: Verificar si las unidades están cargadas
//   bool get hasUnidades => unidades.isNotEmpty;

//   /// ✅ Helper: Verificar si está creando ticket
//   bool get isCreatingTicket => createResponse is Loading;

//   /// ✅ Helper: Verificar si el ticket fue creado exitosamente
//   bool get ticketCreated => createResponse is Success;
  
//   /// ✅ Helper: Obtener mensaje de error de unidades
//   String? get unidadesErrorMessage {
//     if (unidadesResponse is Error) {
//       return (unidadesResponse as Error).message;
//     }
//     return null;
//   }
// }

// lib/presentation/page/ticket_abastecimiento/bloc/ticket_state.dart

class TicketState extends Equatable {
  final Resource? createResponse;
  final Resource? unidadesResponse;
  final List<Unidad> unidades;

  final Resource? ultimoTicketResponse;
  final UltimoTicketUnidad? ultimoTicket;

  const TicketState({
    this.createResponse,
    this.unidadesResponse,
    this.unidades = const [],
    this.ultimoTicketResponse,
    this.ultimoTicket,
  });

  TicketState copyWith({
    Resource? createResponse,
    Resource? unidadesResponse,
    List<Unidad>? unidades,
    Resource? ultimoTicketResponse,
    UltimoTicketUnidad? ultimoTicket,
    bool clearUltimoTicket = false,
  }) {
    return TicketState(
      createResponse: createResponse ?? this.createResponse,
      unidadesResponse: unidadesResponse ?? this.unidadesResponse,
      unidades: unidades ?? this.unidades,
      ultimoTicketResponse: clearUltimoTicket ? null : (ultimoTicketResponse ?? this.ultimoTicketResponse),
      ultimoTicket: clearUltimoTicket ? null : (ultimoTicket ?? this.ultimoTicket),
    );
  }

  @override
  List<Object?> get props => [
        createResponse,
        unidadesResponse,
        unidades,
        ultimoTicketResponse,
        ultimoTicket,
      ];

  // ✅ Helpers existentes
  bool get isLoadingUnidades => unidadesResponse is Loading;
  bool get hasUnidadesError => unidadesResponse is Error;
  bool get hasUnidades => unidades.isNotEmpty;
  bool get isCreatingTicket => createResponse is Loading;
  bool get ticketCreated => createResponse is Success;
  bool get isLoading => isCreatingTicket || isLoadingUnidades;
  Resource? get resource => createResponse;
  
  String? get unidadesErrorMessage {
    if (unidadesResponse is Error) {
      return (unidadesResponse as Error).message;
    }
    return null;
  }
  /// Verificar si está cargando el último ticket
  bool get isLoadingUltimoTicket => ultimoTicketResponse is Loading;

  /// Verificar si hay error al cargar el último ticket
  bool get hasUltimoTicketError => ultimoTicketResponse is Error;

  /// Verificar si el último ticket está cargado
  bool get hasUltimoTicket => ultimoTicket != null;

  /// Obtener mensaje de error del último ticket
  String? get ultimoTicketErrorMessage {
    if (ultimoTicketResponse is Error) {
      return (ultimoTicketResponse as Error).message;
    }
    return null;
  }

  /// Obtener el kilometraje sugerido (si existe)
  double? get kilometrajeSugerido => ultimoTicket?.sugerencias.kilometrajeAnteriorSugerido;

  /// Obtener el precinto sugerido (si existe)
  String? get precintoSugerido => ultimoTicket?.sugerencias.precintoAnteriorSugerido;
}