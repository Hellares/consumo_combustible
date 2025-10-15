
import 'package:consumo_combustible/domain/models/register_user_request.dart';
import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();
  
  @override
  List<Object?> get props => [];
}

class GetUsers extends UserEvent {
  final int page;
  final int pageSize;
  final bool isLoadMore;

  const GetUsers({
    this.page = 1,
    this.pageSize = 10,
    this.isLoadMore = false,
  });
  
  @override
  List<Object?> get props => [page, pageSize, isLoadMore];
}

class FilterUsers extends UserEvent {
  final String query;
  final String searchType; // 'nombre' o 'dni'

  const FilterUsers(this.query, {this.searchType = 'nombre'});
  
  @override
  List<Object?> get props => [query, searchType];
}

class RegisterUser extends UserEvent {
  final RegisterUserRequest request;

  const RegisterUser(this.request);
  
  @override
  List<Object?> get props => [request];
}


/*
  ***************************************************************************************
  Metodo: Asignar rol 
  Fecha: 14-10-2025
  Descripcion: 
  Autor: James Torres
  ***************************************************************************************
*/
class AssignRolToUser extends UserEvent {
  final int userId;
  final int rolId;
  final int asignadoPorId;

  const AssignRolToUser({
    required this.userId,
    required this.rolId,
    required this.asignadoPorId,
  });
  
  @override
  List<Object?> get props => [userId, rolId, asignadoPorId];
}