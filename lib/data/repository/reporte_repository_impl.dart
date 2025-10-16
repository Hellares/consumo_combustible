// lib/data/repositories/reporte_repository_impl.dart
import 'package:consumo_combustible/data/datasource/remote/service/reporte_service.dart';
import 'package:consumo_combustible/domain/models/filtros_reporte.dart';
import 'package:consumo_combustible/domain/models/reporte_response.dart';
import 'package:consumo_combustible/domain/repository/reporte_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:flutter/foundation.dart';

/// Implementación del repositorio de reportes
/// Delega las llamadas al servicio API y maneja errores
class ReporteRepositoryImpl implements ReporteRepository {
  final ReporteService _service;

  ReporteRepositoryImpl(this._service);

  @override
  Future<Resource<DescargaArchivoResponse>> exportarReporte(
    FiltrosReporte filtros,
  ) async {
    try {
      if (kDebugMode) {
        print('📦 [ReporteRepository] Exportando reporte...');
        print('   Tipo: ${filtros.tipoReporte}');
        print('   Formato: ${filtros.formato}');
      }

      final result = await _service.exportarReporte(filtros);

      if (kDebugMode) {
        if (result is Success<DescargaArchivoResponse>) {
          print('✅ [ReporteRepository] Reporte exportado exitosamente');
          print('   Archivo: ${result.data.nombreArchivo}');
          print('   Tamaño: ${result.data.tamanioFormateado}');
          print('   Ruta: ${result.data.rutaArchivo}');
        } else if (result is Error<DescargaArchivoResponse>) {
          print('❌ [ReporteRepository] Error: ${result.message}');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ReporteRepository] Excepción en exportarReporte: $e');
      }
      return Error('Error inesperado al exportar reporte: $e');
    }
  }

  @override
  Future<Resource<ReporteResponse>> obtenerDatosReporte(
    FiltrosReporte filtros,
  ) async {
    try {
      if (kDebugMode) {
        print('📦 [ReporteRepository] Obteniendo datos del reporte...');
        print('   Tipo: ${filtros.tipoReporte}');
      }

      final result = await _service.obtenerDatosReporte(filtros);

      if (kDebugMode) {
        if (result is Success<ReporteResponse>) {
          print('✅ [ReporteRepository] Datos obtenidos');
          print('   Total registros: ${result.data.totalRegistros}');
        } else if (result is Error<ReporteResponse>) {
          print('❌ [ReporteRepository] Error: ${result.message}');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ReporteRepository] Excepción en obtenerDatosReporte: $e');
      }
      return Error('Error inesperado al obtener datos: $e');
    }
  }

  @override
  Future<Resource<ResumenReporteResponse>> obtenerResumen() async {
    try {
      if (kDebugMode) {
        print('📦 [ReporteRepository] Obteniendo resumen...');
      }

      final result = await _service.obtenerResumen();

      if (kDebugMode) {
        if (result is Success<ResumenReporteResponse>) {
          print('✅ [ReporteRepository] Resumen obtenido');
          print('   Total abastecimientos: ${result.data.resumen.totalAbastecimientos}');
          print('   Total unidades: ${result.data.resumen.totalUnidades}');
          print('   Total grifos: ${result.data.resumen.totalGrifos}');
        } else if (result is Error<ResumenReporteResponse>) {
          print('❌ [ReporteRepository] Error: ${result.message}');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ReporteRepository] Excepción en obtenerResumen: $e');
      }
      return Error('Error inesperado al obtener resumen: $e');
    }
  }

  @override
  Future<Resource<DescargaArchivoResponse>> exportarAbastecimientos(
    FiltrosReporte filtros,
  ) async {
    try {
      if (kDebugMode) {
        print('📦 [ReporteRepository] Exportando reporte de abastecimientos...');
      }

      // Forzar el tipo de reporte a abastecimientos
      final filtrosAjustados = filtros.copyWith(
        tipoReporte: TipoReporte.abastecimientos,
      );

      final result = await _service.exportarReporte(filtrosAjustados);

      if (kDebugMode) {
        if (result is Success<DescargaArchivoResponse>) {
          print('✅ [ReporteRepository] Reporte de abastecimientos exportado');
        } else if (result is Error<DescargaArchivoResponse>) {
          print('❌ [ReporteRepository] Error: ${result.message}');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ReporteRepository] Excepción en exportarAbastecimientos: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  @override
  Future<Resource<DescargaArchivoResponse>> exportarConsumoPorUnidad(
    FiltrosReporte filtros,
  ) async {
    try {
      if (kDebugMode) {
        print('📦 [ReporteRepository] Exportando reporte de consumo por unidad...');
      }

      // Forzar el tipo de reporte a consumo por unidad
      final filtrosAjustados = filtros.copyWith(
        tipoReporte: TipoReporte.consumoPorUnidad,
      );

      final result = await _service.exportarReporte(filtrosAjustados);

      if (kDebugMode) {
        if (result is Success<DescargaArchivoResponse>) {
          print('✅ [ReporteRepository] Reporte de consumo exportado');
        } else if (result is Error<DescargaArchivoResponse>) {
          print('❌ [ReporteRepository] Error: ${result.message}');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ReporteRepository] Excepción en exportarConsumoPorUnidad: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  @override
  Future<Resource<DescargaArchivoResponse>> exportarEstadisticasGrifo(
    FiltrosReporte filtros,
  ) async {
    try {
      if (kDebugMode) {
        print('📦 [ReporteRepository] Exportando estadísticas de grifo...');
      }

      // Forzar el tipo de reporte a estadísticas grifo
      final filtrosAjustados = filtros.copyWith(
        tipoReporte: TipoReporte.estadisticasGrifo,
      );

      final result = await _service.exportarReporte(filtrosAjustados);

      if (kDebugMode) {
        if (result is Success<DescargaArchivoResponse>) {
          print('✅ [ReporteRepository] Estadísticas de grifo exportadas');
        } else if (result is Error<DescargaArchivoResponse>) {
          print('❌ [ReporteRepository] Error: ${result.message}');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ReporteRepository] Excepción en exportarEstadisticasGrifo: $e');
      }
      return Error('Error inesperado: $e');
    }
  }

  @override
  Future<Resource<DescargaArchivoResponse>> exportarRendimiento(
    FiltrosReporte filtros,
  ) async {
    try {
      if (kDebugMode) {
        print('📦 [ReporteRepository] Exportando reporte de rendimiento...');
      }

      // Forzar el tipo de reporte a rendimiento
      final filtrosAjustados = filtros.copyWith(
        tipoReporte: TipoReporte.rendimiento,
      );

      final result = await _service.exportarReporte(filtrosAjustados);

      if (kDebugMode) {
        if (result is Success<DescargaArchivoResponse>) {
          print('✅ [ReporteRepository] Reporte de rendimiento exportado');
        } else if (result is Error<DescargaArchivoResponse>) {
          print('❌ [ReporteRepository] Error: ${result.message}');
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        print('❌ [ReporteRepository] Excepción en exportarRendimiento: $e');
      }
      return Error('Error inesperado: $e');
    }
  }
}