import 'dart:typed_data';

import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class UpdateProfilePhoto {
  final AuthRepository repository;

  const UpdateProfilePhoto(this.repository);

  Future<void> call({
    required String accountId,
    required Uint8List photoBytes,
    required UserRole role,
  }) {
    return repository.updateProfilePhoto(
      accountId: accountId,
      photoBytes: photoBytes,
      role: role,
    );
  }
}
