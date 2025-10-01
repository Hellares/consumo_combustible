
import 'package:consumo_combustible/domain/utils/resource.dart';
import 'package:consumo_combustible/presentation/utils/bloc_form_item.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';


class LoginState extends Equatable{

  final BlocFormItem dni;
  final BlocFormItem password;
  final Resource? response;
  final GlobalKey<FormState>? formKey;

  const LoginState({
    this.dni = const BlocFormItem(value: '', error: null), // ← Sin error inicial
    this.password = const BlocFormItem(value: '', error: null), // ← Sin error inicial
    this.response,
    this.formKey,
  });

  LoginState copyWith({
    BlocFormItem? dni,
    BlocFormItem? password,
    Resource? response,
    GlobalKey<FormState>? formKey,
  }) {
    return LoginState(
      dni: dni ?? this.dni,
      password: password ?? this.password,
      response: response,
      formKey: formKey
    ); 
  }
  
  @override
  List<Object?> get props => [dni, password, response];
}