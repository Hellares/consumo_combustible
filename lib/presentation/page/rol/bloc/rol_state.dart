// lib/presentation/page/roles/bloc/rol_state.dart

import 'package:consumo_combustible/domain/models/rol.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:equatable/equatable.dart';

class RolState extends Equatable {
  // Estado de la lista de roles
  final Resource<RolesResponse>? rolesResponse;
  
  // Estado de un rol individual
  final Resource<Rol>? rolResponse;
  
  // Estado de creación
  final Resource<Rol>? createResponse;
  
  // Estado de actualización
  final Resource<Rol>? updateResponse;
  
  // Estado de eliminación
  final Resource<void>? deleteResponse;
  
  // Estado de activación
  final Resource<Rol>? activarResponse;

  // Lista acumulada de roles (para paginación)
  final List<Rol> roles;
  
  // Metadata de paginación
  final int currentPage;
  final int totalPages;
  final int totalRoles;
  final bool hasMorePages;
  final bool isLoadingMore;

  const RolState({
    this.rolesResponse,
    this.rolResponse,
    this.createResponse,
    this.updateResponse,
    this.deleteResponse,
    this.activarResponse,
    this.roles = const [],
    this.currentPage = 1,
    this.totalPages = 1,
    this.totalRoles = 0,
    this.hasMorePages = false,
    this.isLoadingMore = false,
  });

  // Factory para estado inicial
  factory RolState.initial() => const RolState();

  // CopyWith para actualizaciones inmutables
  RolState copyWith({
    Resource<RolesResponse>? rolesResponse,
    Resource<Rol>? rolResponse,
    Resource<Rol>? createResponse,
    Resource<Rol>? updateResponse,
    Resource<void>? deleteResponse,
    Resource<Rol>? activarResponse,
    List<Rol>? roles,
    int? currentPage,
    int? totalPages,
    int? totalRoles,
    bool? hasMorePages,
    bool? isLoadingMore,
  }) {
    return RolState(
      rolesResponse: rolesResponse ?? this.rolesResponse,
      rolResponse: rolResponse ?? this.rolResponse,
      createResponse: createResponse ?? this.createResponse,
      updateResponse: updateResponse ?? this.updateResponse,
      deleteResponse: deleteResponse ?? this.deleteResponse,
      activarResponse: activarResponse ?? this.activarResponse,
      roles: roles ?? this.roles,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      totalRoles: totalRoles ?? this.totalRoles,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  // Método para resetear estados específicos
  RolState resetResponses() {
    return copyWith(
      createResponse: null,
      updateResponse: null,
      deleteResponse: null,
      activarResponse: null,
      rolResponse: null,
    );
  }

  // Método para limpiar solo los mensajes
  RolState clearMessages() {
    return copyWith(
      rolesResponse: rolesResponse is Success ? rolesResponse : null,
      createResponse: null,
      updateResponse: null,
      deleteResponse: null,
      activarResponse: null,
    );
  }

  @override
  List<Object?> get props => [
        rolesResponse,
        rolResponse,
        createResponse,
        updateResponse,
        deleteResponse,
        activarResponse,
        roles,
        currentPage,
        totalPages,
        totalRoles,
        hasMorePages,
        isLoadingMore,
      ];
}