import 'package:consumo_combustible/domain/models/selected_role.dart';
import 'package:consumo_combustible/domain/repository/auth_repository.dart';

class SaveSelectedRoleUseCase {
  final AuthRepository authRepository;
  
  SaveSelectedRoleUseCase(this.authRepository);
  
  Future<void> run(SelectedRole selectedRole) => 
      authRepository.saveSelectedRole(selectedRole);
}