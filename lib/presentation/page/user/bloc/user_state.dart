import 'package:consumo_combustible/domain/models/auth_response.dart';
import 'package:consumo_combustible/domain/models/user.dart';
import 'package:consumo_combustible/domain/models/user_response.dart';
import 'package:equatable/equatable.dart';

abstract class UserState extends Equatable {
  const UserState();
  
  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {}

class UserLoading extends UserState {
  final bool isFirstLoad;
  
  const UserLoading({this.isFirstLoad = true});
  
  @override
  List<Object?> get props => [isFirstLoad];
}

class UserLoaded extends UserState {
  final List<User> users;
  final Meta meta;
  final bool isLoadingMore;
  final bool isRegistering; // ⭐ AGREGADO
  final String searchQuery;
  final String searchType;
  final int currentPage;

  const UserLoaded({
    required this.users,
    required this.meta,
    this.isLoadingMore = false,
    this.isRegistering = false, // ⭐ AGREGADO
    this.searchQuery = '',
    this.searchType = 'nombre',
    this.currentPage = 1,
  });
  
  // Lista filtrada localmente
  List<User> get displayUsers {
    if (searchQuery.isEmpty) return users;
    
    final query = searchQuery.toLowerCase();
    return users.where((user) {
      if (searchType == 'dni') {
        return user.dni.toLowerCase().contains(query);
      } else {
        final fullName = '${user.nombres} ${user.apellidos}'.toLowerCase();
        return fullName.contains(query) || user.nombres.toLowerCase().contains(query);
      }
    }).toList();
  }
  
  bool get isSearching => searchQuery.isNotEmpty;
  
  @override
  List<Object?> get props => [
    users, 
    meta, 
    isLoadingMore, 
    isRegistering, // ⭐ AGREGADO
    searchQuery, 
    searchType, 
    currentPage
  ];
  
  UserLoaded copyWith({
    List<User>? users,
    Meta? meta,
    bool? isLoadingMore,
    bool? isRegistering, // ⭐ AGREGADO
    String? searchQuery,
    String? searchType,
    int? currentPage,
  }) {
    return UserLoaded(
      users: users ?? this.users,
      meta: meta ?? this.meta,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRegistering: isRegistering ?? this.isRegistering, // ⭐ AGREGADO
      searchQuery: searchQuery ?? this.searchQuery,
      searchType: searchType ?? this.searchType,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class UserError extends UserState {
  final String message;

  const UserError(this.message);
  
  @override
  List<Object?> get props => [message];
}

class UserRegisterSuccess extends UserState {
  final AuthResponse response;

  const UserRegisterSuccess(this.response);
  
  @override
  List<Object?> get props => [response];
}

class UserRegisterError extends UserState {
  final String message;

  const UserRegisterError(this.message);
  
  @override
  List<Object?> get props => [message];
}

//  Estado de éxito al asignar rol
class UserRolAssignSuccess extends UserState {
  final String message;
  final int userId;

  const UserRolAssignSuccess({
    required this.message,
    required this.userId,
  });
  
  @override
  List<Object?> get props => [message, userId];
}

// Estado de error al asignar rol
class UserRolAssignError extends UserState {
  final String message;

  const UserRolAssignError(this.message);
  
  @override
  List<Object?> get props => [message];
}

// Estado mientras se asigna rol
class UserRolAssigning extends UserState {
  final int userId;

  const UserRolAssigning(this.userId);
  
  @override
  List<Object?> get props => [userId];
}