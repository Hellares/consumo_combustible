
import 'package:consumo_combustible/core/widgets/custom_dropdown/custom_dropdown2.dart';
import 'package:consumo_combustible/domain/models/zona.dart';
import 'package:consumo_combustible/domain/models/sede.dart';
import 'package:consumo_combustible/domain/models/grifo.dart';

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



