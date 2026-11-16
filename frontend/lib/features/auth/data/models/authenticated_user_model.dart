import '../../domain/entities/user.dart';

class AuthenticatedUserModel extends UserAccount {
  const AuthenticatedUserModel({
    required super.id,
    required super.name,
    required super.title,
    required super.email,
    required super.role,
    super.permissions,
  });

  factory AuthenticatedUserModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['accountId'];
    final accountId =
        rawId is num ? rawId.toInt() : int.tryParse(rawId?.toString() ?? '');
    if (accountId == null) {
      throw const FormatException('Missing account ID in login response.');
    }

    final apiRole = json['role']?.toString().toUpperCase();
    final role = switch (apiRole) {
      'ADMIN' => UserRole.admin,
      'LIBRARIAN' => UserRole.librarian,
      'STUDENT' || 'READER' => UserRole.reader,
      _ => throw const FormatException('Unknown account role from server.'),
    };

    final permissions = (json['permissions'] as List?)
            ?.map((item) => item.toString())
            .toSet() ??
        <String>{};

    return AuthenticatedUserModel(
      id: accountId,
      name: json['fullName']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: role,
      permissions: permissions,
    );
  }
}
