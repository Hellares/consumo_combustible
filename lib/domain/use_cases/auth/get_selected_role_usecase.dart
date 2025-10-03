import 'package:consumo_combustible/domain/models/selected_role.dart';
import 'package:consumo_combustible/domain/repository/auth_repository.dart';

class GetSelectedRoleUseCase {
  final AuthRepository authRepository;
  
  GetSelectedRoleUseCase(this.authRepository);
  
  Future<SelectedRole?> run() => 
      authRepository.getSelectedRole();
}