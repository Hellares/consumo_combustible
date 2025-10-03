import 'package:consumo_combustible/domain/models/grifo.dart';
import 'package:consumo_combustible/domain/models/sede.dart';
import 'package:consumo_combustible/domain/models/selected_location.dart';
import 'package:consumo_combustible/domain/models/zona.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:equatable/equatable.dart';

class LocationState extends Equatable {
  final Resource? zonasResponse;
  final Resource? sedesResponse;
  final Resource? grifosResponse;
  final Resource? saveResponse;
  
  final Zona? selectedZona;
  final Sede? selectedSede;
  final Grifo? selectedGrifo;
  final SelectedLocation? savedLocation;

  const LocationState({
    this.zonasResponse,
    this.sedesResponse,
    this.grifosResponse,
    this.saveResponse,
    this.selectedZona,
    this.selectedSede,
    this.selectedGrifo,
    this.savedLocation,
  });

  LocationState copyWith({
    Resource? zonasResponse,
    Resource? sedesResponse,
    Resource? grifosResponse,
    Resource? saveResponse,
    Zona? selectedZona,
    Sede? selectedSede,
    Grifo? selectedGrifo,
    SelectedLocation? savedLocation,
  }) {
    return LocationState(
      zonasResponse: zonasResponse ?? this.zonasResponse,
      sedesResponse: sedesResponse ?? this.sedesResponse,
      grifosResponse: grifosResponse ?? this.grifosResponse,
      saveResponse: saveResponse ?? this.saveResponse,
      selectedZona: selectedZona ?? this.selectedZona,
      selectedSede: selectedSede ?? this.selectedSede,
      selectedGrifo: selectedGrifo ?? this.selectedGrifo,
      savedLocation: savedLocation ?? this.savedLocation,
    );
  }

  @override
  List<Object?> get props => [
    zonasResponse,
    sedesResponse,
    grifosResponse,
    saveResponse,
    selectedZona,
    selectedSede,
    selectedGrifo,
    savedLocation,
  ];
}