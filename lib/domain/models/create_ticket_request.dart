class CreateTicketRequest {
  final int unidadId;
  final int conductorId;
  final int grifoId;
  final double? kilometrajeAnterior;
  final double kilometrajeActual;
  final String precintoNuevo;
  final double cantidad;
  final String tipoCombustible;

  CreateTicketRequest({
    required this.unidadId,
    required this.conductorId,
    required this.grifoId,
    this.kilometrajeAnterior,
    required this.kilometrajeActual,
    required this.precintoNuevo,
    required this.cantidad,
    required this.tipoCombustible,
  });

  Map<String, dynamic> toJson() {
    return {
      'unidadId': unidadId,
      'conductorId': conductorId,
      'grifoId': grifoId,
      'kilometrajeAnterior': kilometrajeAnterior,
      'kilometrajeActual': kilometrajeActual,
      'precintoNuevo': precintoNuevo,
      'cantidad': cantidad,
      'tipoCombustible': tipoCombustible,
    };
  }
}