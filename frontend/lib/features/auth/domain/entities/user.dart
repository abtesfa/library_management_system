import 'dart:typed_data';

enum UserRole { admin, librarian, reader }

class UserAccount {
  final int id;
  final String name;
  final String title;
  final String email;
  final UserRole role;
  final String? avatarPath;
 final Uint8List? avatarBytes;
  final Set<String> permissions;

  const UserAccount({
    required this.id,
    required this.name,
    required this.title,
    required this.email,
    required this.role,
    this.avatarPath,
    this.avatarBytes,
    this.permissions = const {},
  });

  UserAccount copyWith({
    int? id,
    String? name,
    String? title,
    String? email,
    UserRole? role,
    String? avatarPath,
    Uint8List? avatarBytes,
    Set<String>? permissions,
  }) {
    return UserAccount(
      id: id ?? this.id,
      name: name ?? this.name,
      title: title ?? this.title,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarPath: avatarPath ?? this.avatarPath,
      avatarBytes: avatarBytes ?? this.avatarBytes,
      permissions: permissions ?? this.permissions,
    );
  }

  bool get canAddBooks => permissions.contains('ADD_BOOK');
  bool get canEditBooks => permissions.contains('EDIT_BOOK');
  bool get canDeleteBooks => permissions.contains('DELETE_BOOK');
  bool get canBorrowBooks => permissions.contains('BORROW_BOOK');
  bool get canReturnBooks => permissions.contains('RETURN_BOOK');
  bool get canConfigureSettings => permissions.contains('CONFIGURE_SETTINGS');
  bool get canManageStaff => permissions.contains('MANAGE_STAFF');
  bool get canViewNotifications => permissions.contains('VIEW_NOTIFICATIONS');

  String get roleDisplayName {
    switch (role) {
      case UserRole.admin:
        return 'Administrator';
      case UserRole.librarian:
        return 'Librarian';
      case UserRole.reader:
        return 'Reader / Student';
    }
  }
}

extension UserRoleApiRole on UserRole {
  String get apiRole {
    switch (this) {
      case UserRole.admin:
        return 'ADMIN';
      case UserRole.librarian:
        return 'LIBRARIAN';
      case UserRole.reader:
        return 'STUDENT';
    }
  }
}

