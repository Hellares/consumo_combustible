import 'package:consumo_combustible/domain/models/grifo.dart';
import 'package:consumo_combustible/domain/models/sede.dart';
import 'package:consumo_combustible/domain/models/zona.dart';
import 'package:equatable/equatable.dart';

abstract class LocationEvent extends Equatable {
  const LocationEvent();
}

class LoadZonas extends LocationEvent {
  const LoadZonas();
  @override
  List<Object?> get props => [];
}

class SelectZona extends LocationEvent {
  final Zona zona;
  const SelectZona(this.zona);
  @override
  List<Object?> get props => [zona];
}

class LoadSedesByZona extends LocationEvent {
  final int zonaId;
  const LoadSedesByZona(this.zonaId);
  @override
  List<Object?> get props => [zonaId];
}

class SelectSede extends LocationEvent {
  final Sede sede;
  const SelectSede(this.sede);
  @override
  List<Object?> get props => [sede];
}

class LoadGrifosBySede extends LocationEvent {
  final int sedeId;
  const LoadGrifosBySede(this.sedeId);
  @override
  List<Object?> get props => [sedeId];
}

class SelectGrifo extends LocationEvent {
  final Grifo grifo;
  const SelectGrifo(this.grifo);
  @override
  List<Object?> get props => [grifo];
}

class SaveLocation extends LocationEvent {
  const SaveLocation();
  @override
  List<Object?> get props => [];
}

class LoadSavedLocation extends LocationEvent {
  const LoadSavedLocation();
  @override
  List<Object?> get props => [];
}

class ClearLocation extends LocationEvent {
  const ClearLocation();
  @override
  List<Object?> get props => [];
}