import 'dart:typed_data';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  const AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<UserAccount> login({
    required String identifier,
    required String password,
    required UserRole role,
  }) {
    return remoteDataSource.login(
      identifier: identifier,
      password: password,
      role: role,
    );
  }

  @override
  Future<void> changePassword({
    required String identifier,
    required String currentPassword,
    required String newPassword,
    required UserRole role,
  }) {
    return remoteDataSource.changePassword(
      identifier: identifier,
      currentPassword: currentPassword,
      newPassword: newPassword,
      role: role,
    );
  }

  @override
  Future<void> updateProfilePhoto({
    required String accountId,
    required Uint8List photoBytes,
    required UserRole role,
  }) {
    return remoteDataSource.updateProfilePhoto(
      accountId: accountId,
      photoBytes: photoBytes,
      role: role,
    );
  }
}
