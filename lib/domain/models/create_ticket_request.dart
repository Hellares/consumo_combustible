class CreateTicketRequest {
  final int unidadId;
  final int conductorId;
  final int grifoId;
  final double kilometrajeActual;
  final String precintoNuevo;
  final double cantidad;

  CreateTicketRequest({
    required this.unidadId,
    required this.conductorId,
    required this.grifoId,
    required this.kilometrajeActual,
    required this.precintoNuevo,
    required this.cantidad,
  });

  Map<String, dynamic> toJson() {
    return {
      'unidadId': unidadId,
      'conductorId': conductorId,
      'grifoId': grifoId,
      'kilometrajeActual': kilometrajeActual,
      'precintoNuevo': precintoNuevo,
      'cantidad': cantidad,
    };
  }
}