import 'package:consumo_combustible/domain/models/grifo.dart';
import 'package:consumo_combustible/domain/models/sede.dart';
import 'package:consumo_combustible/domain/models/zona.dart';

class SelectedLocation {
  final Zona zona;
  final Sede sede;
  final Grifo grifo;
  final DateTime selectedAt;

  SelectedLocation({
    required this.zona,
    required this.sede,
    required this.grifo,
    required this.selectedAt,
  });

  factory SelectedLocation.fromJson(Map<String, dynamic> json) {
    return SelectedLocation(
      zona: Zona.fromJson(json['zona']),
      sede: Sede.fromJson(json['sede']),
      grifo: Grifo.fromJson(json['grifo']),
      selectedAt: DateTime.parse(json['selectedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zona': zona.toJson(),
      'sede': sede.toJson(),
      'grifo': grifo.toJson(),
      'selectedAt': selectedAt.toIso8601String(),
    };
  }

  // ✅ Método para crear ticket con los datos necesarios
  Map<String, dynamic> toTicketData({
    required int unidadId,
    required int conductorId,
    required double kilometrajeActual,
    required String precintoNuevo,
    required double cantidad,
  }) {
    return {
      'unidadId': unidadId,
      'conductorId': conductorId,
      'grifoId': grifo.id,
      'kilometrajeActual': kilometrajeActual,
      'precintoNuevo': precintoNuevo,
      'cantidad': cantidad,
    };
  }
}