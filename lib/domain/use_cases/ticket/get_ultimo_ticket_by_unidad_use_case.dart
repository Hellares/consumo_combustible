// lib/domain/use_cases/ticket/get_ultimo_ticket_by_unidad_use_case.dart

import 'package:consumo_combustible/domain/models/ultimo_ticket_unidad.dart';
import 'package:consumo_combustible/domain/repository/ticket_repository.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';

class GetUltimoTicketByUnidadUseCase {
  final TicketRepository repository;
  
  GetUltimoTicketByUnidadUseCase(this.repository);

  Future<Resource<UltimoTicketUnidad>> run(int unidadId) {
    return repository.getUltimoTicketByUnidad(unidadId);
  }
}