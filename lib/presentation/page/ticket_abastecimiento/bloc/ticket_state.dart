import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:equatable/equatable.dart';

class TicketState extends Equatable {
  final Resource? createResponse;

  const TicketState({this.createResponse});

  TicketState copyWith({Resource? createResponse}) {
    return TicketState(
      createResponse: createResponse ?? this.createResponse,
    );
  }

  @override
  List<Object?> get props => [createResponse];
}