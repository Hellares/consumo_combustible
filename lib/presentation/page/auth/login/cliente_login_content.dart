
import 'package:consumo_combustible/core/fonts/app_fonts.dart';
import 'package:consumo_combustible/core/theme/app_colors.dart';
import 'package:consumo_combustible/core/widgets/custom_date_textfiels_container/custom_textfield.dart';
import 'package:consumo_combustible/core/widgets/cutom_button/custom_button.dart';
import 'package:consumo_combustible/core/widgets/divider_line.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_bloc.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_event.dart';
import 'package:consumo_combustible/presentation/page/auth/login/bloc/login_state.dart';
import 'package:consumo_combustible/presentation/utils/bloc_form_item.dart';
import 'package:flutter/material.dart';


class ClienteLoginContent extends StatefulWidget {
  final LoginBloc? bloc;
  final LoginState state;

  const ClienteLoginContent(this.bloc, this.state, {super.key});

  @override
  State<ClienteLoginContent> createState() => _ClienteLoginContentState();
}

class _ClienteLoginContentState extends State<ClienteLoginContent> {
  // ✅ FIX: Proper controller initialization
  late final TextEditingController _dniController;
  late final TextEditingController _passwordController;
  
  // ✅ OPTIMIZATION: Static FormKey to prevent recreation
  static final GlobalKey<FormState> _staticFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // ✅ FIX: Initialize controllers in initState
    _dniController = TextEditingController(text: widget.state.dni.value);
    _passwordController = TextEditingController(text: widget.state.password.value);
  }

  @override
  void dispose() {
    // ✅ CRITICAL FIX: Dispose controllers to prevent memory leaks
    _dniController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ClienteLoginContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // ✅ OPTIMIZATION: Only update controllers if values actually changed
    // if (oldWidget.state.dni.value != widget.state.dni.value) {
    //   _dniController.text = widget.state.dni.value;
    // }
    // if (oldWidget.state.password.value != widget.state.password.value) {
    //   _passwordController.text = widget.state.password.value;
    // }
    // ✅ Solo actualizar si el cursor NO está en el campo
  if (!_dniController.selection.isValid &&
      oldWidget.state.dni.value != widget.state.dni.value) {
    _dniController.text = widget.state.dni.value;
  }
  
  // Igual para password
  if (!_passwordController.selection.isValid &&
      oldWidget.state.password.value != widget.state.password.value) {
    _passwordController.text = widget.state.password.value;
  }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.state.formKey ?? _staticFormKey, // Use static as fallback
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDniField(),
          const SizedBox(height: 20),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildForgotPasswordLink(),
          const SizedBox(height: 32),
          _buildLoginButton(),
          const SizedBox(height: 24),
          const DividerLine(),
          const SizedBox(height: 24),
          _buildRegisterSection(),
        ],
      ),
    );
  }

  // ✅ OPTIMIZATION: Granular widgets with RepaintBoundary
  Widget _buildDniField() {
    return RepaintBoundary(
      child: Column(
        children: [
          CustomTextField(
            controller: _dniController,
            fieldType: FieldType.dni,            
            hintText: '12345678',
            label: 'DNI',
            labelStyle: TextStyle( color: AppColors.blue3, fontSize: 9),
            borderColor: widget.state.dni.error != null 
                ? Colors.red 
                : AppColors.blue3,
            onChanged: (text){
              if(text != widget.state.dni.value){
                widget.bloc?.add(DniChanged(dni: BlocFormItem(value: text)));

              }
            },
            
          ),
          // 
          
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return RepaintBoundary(
      child: Column(
        children: [
          CustomTextField(
            controller: _passwordController,
            fieldType:FieldType.password,
            label: 'Contraseña',
            labelStyle: TextStyle( color: AppColors.blue3, fontSize: 10),
            hintText: 'Mínimo 6 caracteres',
            borderColor: widget.state.password.error != null 
                ? Colors.red 
                : AppColors.blue3, 
            onChanged: (text){
              if(text != widget.state.password.value){
                widget.bloc?.add(PasswordChanged(password: BlocFormItem(value: text)));
              }
            },         
            onSubmitted: (_) => _handleSubmitIfValid(),
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
           // TODO: Implement forgot password
        },
        child: Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(
            color: AppColors.blue3,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return RepaintBoundary(
      child: CustomButton(
        text: 'Iniciar Sesión',
        borderWidth: 0.5,
        textStyle: AppFont.pirulentBold.style(fontSize: 12),
        backgroundColor: AppColors.blue3,
        borderRadius: 28,
        onPressed: _canSubmit() ? _handleSubmit : null,
      ),
    );
  }

  Widget _buildRegisterSection() {
    return RepaintBoundary(
      child: Column(
        children: [
          Text(
            '¿No tienes cuenta?',
            style: TextStyle(fontSize: 11, color: AppColors.blueGrey),
          ),
          const SizedBox(height: 16),
          CustomButton(
            text: 'Crear Cuenta',
            textStyle: AppFont.pirulentBold.style(fontSize: 12),
            backgroundColor: AppColors.orange,
            enableShadows: false,
            borderColor: AppColors.orange,
            textColor: AppColors.white,
            borderRadius: 28,
            // onPressed: _navigateToRegister,
          ),
        ],
      ),
    );
  }

  // ✅ OPTIMIZATION: Event handlers
  // void _onDniChanged(String text) {
  //   widget.bloc?.add(DniChanged(dni: BlocFormItem(value: text)));
  // }

  // void _onPasswordChanged(String text) {
  //   widget.bloc?.add(PasswordChanged(password: BlocFormItem(value: text)));
  // }

  void _handleSubmit() {
    widget.bloc?.add(const LoginSubmit());
  }

  void _handleSubmitIfValid() {
    if (_canSubmit()) {
      _handleSubmit();
    }
  }

  

  bool _canSubmit() {
    return widget.state.dni.value.isNotEmpty &&
           widget.state.password.value.isNotEmpty &&
           widget.state.dni.error == null &&
           widget.state.password.error == null;
  }
}