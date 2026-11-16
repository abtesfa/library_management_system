import '../entities/user.dart';

abstract class AuthRepository {
  Future<UserAccount> login({
    required String identifier,
    required String password,
    required UserRole role,
  });

  Future<void> changePassword({
    required String identifier,
    required String currentPassword,
    required String newPassword,
    required UserRole role,
  });
}
