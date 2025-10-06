// lib/data/datasource/remote/service/ticket_aprobacion_service.dart

import 'package:consumo_combustible/domain/models/ticket_abastecimiento.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TicketAprobacionService {
  final Dio _dio;

  TicketAprobacionService(this._dio);

  /// Obtener tickets solicitados (pendientes)
  Future<Resource<List<TicketAbastecimiento>>> getTicketsSolicitados() async {
    try {
      if (kDebugMode) {
        print('📋 Obteniendo tickets solicitados...');
      }

      final response = await _dio.get(
        '/api/tickets-abastecimiento/estado/solicitado',
      );

      if (kDebugMode) {
        print('✅ Response: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && 
            responseData['data'] != null &&
            responseData['data']['data'] != null) {
          
          final tickets = (responseData['data']['data'] as List)
              .map((json) => TicketAbastecimiento.fromJson(json))
              .toList();

          if (kDebugMode) {
            print('✅ ${tickets.length} tickets solicitados obtenidos');
          }

          return Success(tickets);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode}');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException: ${e.message}');
      }
      return Error('Error de conexión: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// Aprobar ticket
  Future<Resource<TicketAbastecimiento>> aprobarTicket({
    required int ticketId,
    required int aprobadoPorId,
  }) async {
    try {
      if (kDebugMode) {
        print('✅ Aprobando ticket: $ticketId por usuario: $aprobadoPorId');
      }

      final response = await _dio.patch(
        '/api/tickets-abastecimiento/$ticketId/aprobar',
        data: {'aprobadoPorId': aprobadoPorId},
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final ticket = TicketAbastecimiento.fromJson(responseData['data']);

          if (kDebugMode) {
            print('✅ Ticket aprobado: ${ticket.numeroTicket}');
          }

          return Success(ticket);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode}');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException: ${e.message}');
        print('❌ Response: ${e.response?.data}');
      }

      final errorMsg = e.response?.data['message'] ?? 'Error al aprobar ticket';
      return Error(errorMsg);

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  /// Rechazar ticket
  Future<Resource<TicketAbastecimiento>> rechazarTicket({
    required int ticketId,
    required int rechazadoPorId, // Ya no se usa pero mantener por compatibilidad
    required String motivo,
  }) async {
    try {
      if (kDebugMode) {
        print('❌ Rechazando ticket: $ticketId');
      }

      final response = await _dio.patch(
        '/api/tickets-abastecimiento/$ticketId/rechazar',
        data: {
          'motivoRechazo': motivo,
        },
      );

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final ticket = TicketAbastecimiento.fromJson(responseData['data']);

          if (kDebugMode) {
            print('✅ Ticket rechazado: ${ticket.numeroTicket}');
          }

          return Success(ticket);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode}');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException: ${e.message}');
      }

      final errorMsg = e.response?.data['message'] ?? 'Error al rechazar ticket';
      return Error(errorMsg);

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  Future<Resource<Map<String, dynamic>>> aprobarTicketsLote({
  required List<int> ticketIds,
  required int aprobadoPorId,
}) async {
  try {
    if (kDebugMode) {
      print('✅ Aprobando ${ticketIds.length} tickets en lote');
    }

    final response = await _dio.post(
      '/api/tickets-abastecimiento/admin/aprobar-lote',
      data: {'ids': ticketIds},
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = response.data['data'];
      
      if (kDebugMode) {
        print('✅ Resultado: ${data['exitosos']} exitosos, ${data['fallidos']} fallidos');
      }

      return Success(data);
    }

    return Error('Error ${response.statusCode}');

  } on DioException catch (e) {
    if (kDebugMode) {
      print('❌ Error en aprobación lote: ${e.message}');
    }
    return Error(e.response?.data['message'] ?? 'Error al aprobar tickets');
  } catch (e) {
    return Error('Error inesperado: $e');
  }
}
}