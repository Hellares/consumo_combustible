
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
