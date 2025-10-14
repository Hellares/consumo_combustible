// lib/presentation/page/roles/bloc/rol_bloc.dart

import 'package:consumo_combustible/domain/models/rol.dart';
import 'package:consumo_combustible/domain/use_cases/rol/rol_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/rol/bloc/rol_event.dart';
import 'package:consumo_combustible/presentation/page/rol/bloc/rol_state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RolBloc extends Bloc<RolEvent, RolState> {
  final RolUseCases rolUseCases;

  RolBloc(this.rolUseCases) : super(RolState.initial()) {
    on<GetRolesEvent>(_onGetRoles);
    on<GetRolByIdEvent>(_onGetRolById);
    on<CreateRolEvent>(_onCreateRol);
    on<UpdateRolEvent>(_onUpdateRol);
    on<DeleteRolEvent>(_onDeleteRol);
    on<ActivarRolEvent>(_onActivarRol);
    on<ResetRolStateEvent>(_onResetState);
    on<ClearRolMessagesEvent>(_onClearMessages);
  }

  /// Obtener roles con soporte de paginación
  Future<void> _onGetRoles(
    GetRolesEvent event,
    Emitter<RolState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🔄 [RolBloc] Obteniendo roles - page: ${event.page}');
      }

      // Si es load more, mostrar loading en el footer
      if (event.isLoadMore) {
        emit(state.copyWith(
          isLoadingMore: true,
          rolesResponse: null,
        ));
      } else {
        // Si es carga inicial, mostrar loading normal
        emit(state.copyWith(
          rolesResponse: Loading(),
          roles: [], // Limpiar la lista anterior
          currentPage: 1,
        ));
      }

      final result = await rolUseCases.getRoles.run(
        page: event.page,
        limit: event.limit,
      );

      if (result is Success<RolesResponse>) {
        final response = result.data;
        final newRoles = response.data;

        // Calcular metadata de paginación
        final totalPages = (response.total / event.limit).ceil();
        final hasMore = event.page < totalPages;

        // Si es load more, agregar a la lista existente
        final updatedRoles = event.isLoadMore
            ? [...state.roles, ...newRoles]
            : newRoles;

        if (kDebugMode) {
          print('✅ [RolBloc] Roles obtenidos: ${newRoles.length}');
          print('📊 [RolBloc] Total roles: ${updatedRoles.length}');
        }

        emit(state.copyWith(
          rolesResponse: result,
          roles: updatedRoles,
          currentPage: event.page,
          totalPages: totalPages,
          totalRoles: response.total,
          hasMorePages: hasMore,
          isLoadingMore: false,
        ));
      } else if (result is Error<RolesResponse>) {
        if (kDebugMode) {
          print('❌ [RolBloc] Error: ${result.message}');
        }

        emit(state.copyWith(
          rolesResponse: result,
          isLoadingMore: false,
        ));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RolBloc] Exception: $e');
      }

      emit(state.copyWith(
        rolesResponse: Error('Error inesperado: $e'),
        isLoadingMore: false,
      ));
    }
  }

  /// Obtener rol por ID
  Future<void> _onGetRolById(
    GetRolByIdEvent event,
    Emitter<RolState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🔄 [RolBloc] Obteniendo rol ID: ${event.rolId}');
      }

      emit(state.copyWith(rolResponse: Loading()));

      final result = await rolUseCases.getRolById.run(event.rolId);

      if (kDebugMode) {
        if (result is Success<Rol>) {
          print('✅ [RolBloc] Rol obtenido: ${result.data.nombre}');
        } else if (result is Error<Rol>) {
          print('❌ [RolBloc] Error: ${result.message}');
        }
      }

      emit(state.copyWith(rolResponse: result));
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RolBloc] Exception: $e');
      }

      emit(state.copyWith(
        rolResponse: Error('Error inesperado: $e'),
      ));
    }
  }

  /// Crear nuevo rol
  Future<void> _onCreateRol(
    CreateRolEvent event,
    Emitter<RolState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🔄 [RolBloc] Creando rol: ${event.request.nombre}');
      }

      emit(state.copyWith(createResponse: Loading()));

      final result = await rolUseCases.createRol.run(event.request);

      if (result is Success<Rol>) {
        if (kDebugMode) {
          print('✅ [RolBloc] Rol creado exitosamente: ${result.data.nombre}');
        }

        // Agregar el nuevo rol a la lista local
        final updatedRoles = [result.data, ...state.roles];

        emit(state.copyWith(
          createResponse: result,
          roles: updatedRoles,
          totalRoles: state.totalRoles + 1,
        ));
      } else if (result is Error<Rol>) {
        if (kDebugMode) {
          print('❌ [RolBloc] Error al crear: ${result.message}');
        }

        emit(state.copyWith(createResponse: result));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RolBloc] Exception: $e');
      }

      emit(state.copyWith(
        createResponse: Error('Error inesperado: $e'),
      ));
    }
  }

  /// Actualizar rol existente
  Future<void> _onUpdateRol(
    UpdateRolEvent event,
    Emitter<RolState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🔄 [RolBloc] Actualizando rol ID: ${event.rolId}');
      }

      emit(state.copyWith(updateResponse: Loading()));

      final result = await rolUseCases.updateRol.run(
        event.rolId,
        event.request,
      );

      if (result is Success<Rol>) {
        if (kDebugMode) {
          print('✅ [RolBloc] Rol actualizado: ${result.data.nombre}');
        }

        // Actualizar el rol en la lista local
        final updatedRoles = state.roles.map((rol) {
          return rol.id == event.rolId ? result.data : rol;
        }).toList();

        emit(state.copyWith(
          updateResponse: result,
          roles: updatedRoles,
        ));
      } else if (result is Error<Rol>) {
        if (kDebugMode) {
          print('❌ [RolBloc] Error al actualizar: ${result.message}');
        }

        emit(state.copyWith(updateResponse: result));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RolBloc] Exception: $e');
      }

      emit(state.copyWith(
        updateResponse: Error('Error inesperado: $e'),
      ));
    }
  }

  /// Eliminar (desactivar) rol
  Future<void> _onDeleteRol(
    DeleteRolEvent event,
    Emitter<RolState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🔄 [RolBloc] Eliminando rol ID: ${event.rolId}');
      }

      emit(state.copyWith(deleteResponse: Loading()));

      final result = await rolUseCases.deleteRol.run(event.rolId);

      if (result is Success) {
        if (kDebugMode) {
          print('✅ [RolBloc] Rol eliminado exitosamente');
        }

        // Remover el rol de la lista local
        final updatedRoles = state.roles.where((rol) {
          return rol.id != event.rolId;
        }).toList();

        emit(state.copyWith(
          deleteResponse: result,
          roles: updatedRoles,
          totalRoles: state.totalRoles - 1,
        ));
      } else if (result is Error) {
        if (kDebugMode) {
          print('❌ [RolBloc] Error al eliminar: ${result.message}');
        }

        emit(state.copyWith(deleteResponse: result));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RolBloc] Exception: $e');
      }

      emit(state.copyWith(
        deleteResponse: Error('Error inesperado: $e'),
      ));
    }
  }

  /// Activar rol
  Future<void> _onActivarRol(
    ActivarRolEvent event,
    Emitter<RolState> emit,
  ) async {
    try {
      if (kDebugMode) {
        print('🔄 [RolBloc] Activando rol ID: ${event.rolId}');
      }

      emit(state.copyWith(activarResponse: Loading()));

      final result = await rolUseCases.activarRol.run(event.rolId);

      if (result is Success<Rol>) {
        if (kDebugMode) {
          print('✅ [RolBloc] Rol activado: ${result.data.nombre}');
        }

        // Actualizar el rol en la lista local
        final updatedRoles = state.roles.map((rol) {
          return rol.id == event.rolId ? result.data : rol;
        }).toList();

        emit(state.copyWith(
          activarResponse: result,
          roles: updatedRoles,
        ));
      } else if (result is Error<Rol>) {
        if (kDebugMode) {
          print('❌ [RolBloc] Error al activar: ${result.message}');
        }

        emit(state.copyWith(activarResponse: result));
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ [RolBloc] Exception: $e');
      }

      emit(state.copyWith(
        activarResponse: Error('Error inesperado: $e'),
      ));
    }
  }

  /// Resetear estado completo
  void _onResetState(
    ResetRolStateEvent event,
    Emitter<RolState> emit,
  ) {
    if (kDebugMode) {
      print('🔄 [RolBloc] Reseteando estado');
    }

    emit(state.resetResponses());
  }

  /// Limpiar mensajes
  void _onClearMessages(
    ClearRolMessagesEvent event,
    Emitter<RolState> emit,
  ) {
    if (kDebugMode) {
      print('🔄 [RolBloc] Limpiando mensajes');
    }

    emit(state.clearMessages());
  }
}