// lib/presentation/page/user/bloc/user_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:consumo_combustible/domain/use_cases/user/user_use_cases.dart';
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/page/user/bloc/user_event.dart';
import 'package:consumo_combustible/presentation/page/user/bloc/user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserUseCases _userUseCases;

  UserBloc(this._userUseCases) : super(UserInitial()) {
    on<GetUsers>(_onGetUsers);
    on<FilterUsers>(_onFilterUsers);
    on<RegisterUser>(_onRegisterUser);
  }

  Future<void> _onGetUsers(GetUsers event, Emitter<UserState> emit) async {
    // If loading more, show loading indicator at bottom
    if (event.isLoadMore && state is UserLoaded) {
      final currentState = state as UserLoaded;
      emit(currentState.copyWith(isLoadingMore: true));
    } else {
      // First load
      emit(const UserLoading(isFirstLoad: true));
    }

    final resource = await _userUseCases.getUsers.run(
      page: event.page,
      pageSize: event.pageSize,
    );

    if (resource is Success) {
      final newUsers = resource.data.data.data;
      final meta = resource.data.data.meta;

      if (event.isLoadMore && state is UserLoaded) {
        // Append new users to existing list
        final currentState = state as UserLoaded;
        emit(UserLoaded(
          users: [...currentState.users, ...newUsers],
          meta: meta,
          isLoadingMore: false,
          searchQuery: currentState.searchQuery,
          searchType: currentState.searchType,
          currentPage: event.page,
        ));
      } else {
        // First load or refresh
        emit(UserLoaded(
          users: newUsers,
          meta: meta,
          currentPage: event.page,
        ));
      }
    } else if (resource is Error) { // ⭐ CORREGIDO
      emit(UserError(resource.message));
    }
  }

  void _onFilterUsers(FilterUsers event, Emitter<UserState> emit) {
    if (state is UserLoaded) {
      final currentState = state as UserLoaded;
      emit(currentState.copyWith(
        searchQuery: event.query,
        searchType: event.searchType,
      ));
    }
  }

  Future<void> _onRegisterUser(
    RegisterUser event,
    Emitter<UserState> emit,
  ) async {
    // Mantener el estado actual mientras registramos
    if (state is UserLoaded) {
      final currentState = state as UserLoaded;
      emit(currentState.copyWith(isRegistering: true));
    }

    final resource = await _userUseCases.registerUser.run(event.request);

    if (resource is Success) {
      // Registro exitoso - emitir estado de éxito
      final successResource = resource as Success;
      emit(UserRegisterSuccess(successResource.data));
      
      // Recargar usuarios
      add(const GetUsers(page: 1));
    } else if (resource is Error) {
      // Error en el registro
      final errorResource = resource as Error;
      if (state is UserLoaded) {
        final currentState = state as UserLoaded;
        emit(currentState.copyWith(isRegistering: false));
      }
      emit(UserRegisterError(errorResource.message));
    }
  }
}