import 'package:consumo_combustible/domain/models/create_ticket_request.dart';
import 'package:consumo_combustible/domain/models/ticket_abastecimiento.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class TicketService {
  final Dio _dio;

  TicketService(this._dio);

  Future<Resource<TicketAbastecimiento>> createTicket(
    CreateTicketRequest request,
  ) async {
    try {
      if (kDebugMode) {
        print('🎫 Creando ticket de abastecimiento...');
        print('📦 Request: ${request.toJson()}');
      }

      final response = await _dio.post(
        '/api/tickets-abastecimiento',
        data: request.toJson(),
      );

      if (kDebugMode) {
        print('✅ Response ticket: ${response.statusCode}');
        print('📦 Data: ${response.data}');
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final ticket = TicketAbastecimiento.fromJson(responseData['data']);

          if (kDebugMode) {
            print('✅ Ticket creado exitosamente');
            print('   ID: ${ticket.id}');
            print('   Número: ${ticket.numeroTicket}');
            print('   Estado: ${ticket.estado.nombre}');
            print('   Cantidad: ${ticket.cantidad} gal');
          }

          return Success(ticket);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode} creando ticket');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException en createTicket: ${e.message}');
        print('❌ Response: ${e.response?.data}');
      }

      if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data['message'] ?? 'Datos inválidos';
        return Error(errorMsg);
      } else if (e.response?.statusCode == 404) {
        return Error('Recurso no encontrado');
      } else if (e.response?.statusCode == 500) {
        return Error('Error en el servidor');
      }

      return Error('Error de conexión: ${e.message}');

    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error general en createTicket: $e');
        print('❌ StackTrace: $stackTrace');
      }
      return Error('Error inesperado: $e');
    }
  }
}