import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class ChangePassword {
  final AuthRepository repository;

  const ChangePassword(this.repository);

  Future<void> call({
    required String identifier,
    required String currentPassword,
    required String newPassword,
    required UserRole role,
  }) {
    return repository.changePassword(
      identifier: identifier,
      currentPassword: currentPassword,
      newPassword: newPassword,
      role: role,
    );
  }
}
