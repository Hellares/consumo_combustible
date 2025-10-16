
import 'package:flutter/material.dart';
import 'package:consumo_combustible/core/widgets/custom_dropdown/custom_dropdown2.dart';
import 'package:consumo_combustible/domain/models/zona.dart';
import 'package:consumo_combustible/domain/models/sede.dart';
import 'package:consumo_combustible/domain/models/grifo.dart';
import 'package:consumo_combustible/domain/models/filtros_reporte.dart';

/// Adapter para Zona
class ZonaDropdownItem extends DropdownItem {
  final Zona zona;

  ZonaDropdownItem(this.zona);

  @override
  int get id => zona.id;

  @override
  String get displayText => zona.nombre;

  @override
  String get code => zona.codigo;

  @override
  bool get isActive => zona.activo;
}

/// Adapter para Sede
class SedeDropdownItem extends DropdownItem {
  final Sede sede;

  SedeDropdownItem(this.sede);

  @override
  int get id => sede.id;

  @override
  String get displayText => sede.nombre;

  @override
  String get code => sede.codigo;

  @override
  bool get isActive => sede.activo ?? true;
}
/// Adapter para Grifo
class GrifoDropdownItem extends DropdownItem {
  final Grifo grifo;

  GrifoDropdownItem(this.grifo);

  @override
  int get id => grifo.id;

  @override
  String get displayText => grifo.nombre;

  @override
  String get code => grifo.codigo ?? 'N/A';

  @override
  bool get isActive => grifo.activo ?? true;
}

/// Adapter para TipoReporte
class TipoReporteDropdownItem extends DropdownItem {
  final TipoReporte tipoReporte;

  TipoReporteDropdownItem(this.tipoReporte);

  @override
  int get id => tipoReporte.index;

  @override
  String get displayText => _getTipoReporteLabel(tipoReporte);

  @override
  String get code => tipoReporte.value;

  @override
  bool get isActive => true;

  @override
  IconData? get icon => Icons.article;

  String _getTipoReporteLabel(TipoReporte tipo) {
    switch (tipo) {
      case TipoReporte.abastecimientos:
        return 'Reporte de Abastecimientos';
      case TipoReporte.consumoPorUnidad:
        return 'Consumo por Unidad';
      case TipoReporte.estadisticasGrifo:
        return 'Estadísticas por Grifo';
      case TipoReporte.rendimiento:
        return 'Reporte de Rendimiento';
    }
  }
}

/// Adapter para FormatoExportacion
class FormatoExportacionDropdownItem extends DropdownItem {
  final FormatoExportacion formato;

  FormatoExportacionDropdownItem(this.formato);

  @override
  int get id => formato.index;

  @override
  String get displayText => _getFormatoLabel(formato);

  @override
  String get code => formato.value;

  @override
  bool get isActive => true;

  @override
  IconData? get icon => _getFormatoIcon(formato);

  String _getFormatoLabel(FormatoExportacion formato) {
    switch (formato) {
      case FormatoExportacion.excel:
        return 'Excel (.xlsx)';
      case FormatoExportacion.csv:
        return 'CSV (.csv)';
      case FormatoExportacion.json:
        return 'JSON (.json)';
    }
  }

  IconData _getFormatoIcon(FormatoExportacion formato) {
    switch (formato) {
      case FormatoExportacion.excel:
        return Icons.table_chart;
      case FormatoExportacion.csv:
        return Icons.text_snippet;
      case FormatoExportacion.json:
        return Icons.code;
    }
  }
}




