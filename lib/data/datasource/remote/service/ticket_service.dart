import 'package:consumo_combustible/domain/models/create_ticket_request.dart';
import 'package:consumo_combustible/domain/models/itinerario_detectado.dart';
import 'package:consumo_combustible/domain/models/ticket_abastecimiento.dart';
import 'package:consumo_combustible/domain/models/ultimo_ticket_unidad.dart';
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

  Future<Resource<UltimoTicketUnidad>> getUltimoTicketByUnidad(
    int unidadId,
  ) async {
    try {
      if (kDebugMode) {
        print('🎫 Obteniendo último ticket de la unidad: $unidadId...');
      }

      final response = await _dio.get(
        '/api/tickets-abastecimiento/unidad/$unidadId/ultimo',
      );

      if (kDebugMode) {
        print('✅ Response: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final ultimoTicket = UltimoTicketUnidad.fromJson(responseData['data']);

          if (kDebugMode) {
            print('✅ Último ticket obtenido exitosamente');
            print('   Unidad: ${ultimoTicket.unidad.placa}');
            print('   Último km: ${ultimoTicket.sugerencias.kilometrajeAnteriorSugerido}');
            print('   Precinto anterior: ${ultimoTicket.sugerencias.precintoAnteriorSugerido}');
          }

          return Success(ultimoTicket);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode} obteniendo último ticket');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException en getUltimoTicketByUnidad: ${e.message}');
        print('❌ Response: ${e.response?.data}');
      }

      if (e.response?.statusCode == 404) {
        // La unidad no tiene tickets previos, esto NO es un error
        if (kDebugMode) {
          print('ℹ️ La unidad no tiene tickets previos');
        }
        return Error('Esta unidad no tiene tickets previos');
      } else if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data['message'] ?? 'Unidad inválida';
        return Error(errorMsg);
      } else if (e.response?.statusCode == 500) {
        return Error('Error en el servidor');
      }

      return Error('Error de conexión: ${e.message}');

    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error general en getUltimoTicketByUnidad: $e');
        print('❌ StackTrace: $stackTrace');
      }
      return Error('Error inesperado: $e');
    }
  }

  Future<Resource<ItinerarioDetectado>> detectarItinerario({
    required int unidadId,
    String? fecha,
  }) async {
    try {
      if (kDebugMode) {
        print('🔍 Detectando itinerario para unidad: $unidadId');
        if (fecha != null) print('   Fecha: $fecha');
      }

      // Construir query parameters
      final queryParams = <String, dynamic>{
        'unidadId': unidadId,
      };
      
      if (fecha != null) {
        queryParams['fecha'] = fecha;
      }

      final response = await _dio.get(
        '/api/tickets-abastecimiento/detectar-itinerario',
        queryParameters: queryParams,
      );

      if (kDebugMode) {
        print('✅ Response detección: ${response.statusCode}');
      }

      if (response.statusCode == 200) {
        final responseData = response.data;

        if (responseData['success'] == true && responseData['data'] != null) {
          final deteccion = ItinerarioDetectado.fromJson(responseData['data']);

          if (kDebugMode) {
            print('✅ Detección exitosa');
            print('   Origen: ${deteccion.origen}');
            print('   Detectado: ${deteccion.detectado}');
            print('   Mensaje: ${deteccion.mensaje}');
            
            if (deteccion.tieneItinerario) {
              print('   Itinerario: ${deteccion.itinerario!.nombre} (${deteccion.itinerario!.codigo})');
            }
            
            if (deteccion.tieneRuta) {
              print('   Ruta: ${deteccion.ruta!.nombre}');
            }
          }

          return Success(deteccion);
        }

        return Error('Formato de respuesta inválido');
      }

      return Error('Error ${response.statusCode} detectando itinerario');

    } on DioException catch (e) {
      if (kDebugMode) {
        print('❌ DioException en detectarItinerario: ${e.message}');
        print('❌ Response: ${e.response?.data}');
      }

      if (e.response?.statusCode == 400) {
        final errorMsg = e.response?.data['message'] ?? 'Parámetros inválidos';
        return Error(errorMsg);
      } else if (e.response?.statusCode == 404) {
        return Error('Unidad no encontrada');
      } else if (e.response?.statusCode == 500) {
        return Error('Error en el servidor');
      }

      return Error('Error de conexión: ${e.message}');

    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error general en detectarItinerario: $e');
        print('❌ StackTrace: $stackTrace');
      }
      return Error('Error inesperado: $e');
    }
  }
}