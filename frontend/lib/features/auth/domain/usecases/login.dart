import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class Login {
  final AuthRepository repository;

  const Login(this.repository);

  Future<UserAccount> call({
    required String identifier,
    required String password,
    required UserRole role,
  }) {
    return repository.login(
      identifier: identifier,
      password: password,
      role: role,
    );
  }
}
