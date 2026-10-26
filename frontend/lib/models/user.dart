enum UserRole { admin, librarian, reader }

class UserAccount {
  final String id;
  final String name;
  final String title;
  final String email;
  final String password;
  final UserRole role;

  const UserAccount({
    required this.id,
    required this.name,
    required this.title,
    required this.email,
    required this.password,
    required this.role,
  });

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

  String get dashboardTitle {
    switch (role) {
      case UserRole.admin:
        return 'Admin Inventory & LMS Settings Dashboard';
      case UserRole.librarian:
        return 'Circulation Desk (Borrow & Return) Dashboard';
      case UserRole.reader:
        return 'Reader Portal & My Books Dashboard';
    }
  }
}

class HardcodedCredentials {
  static const UserAccount admin = UserAccount(
    id: 'u-admin',
    name: 'System Admin',
    title: 'System Administrator',
    email: 'admin@library.com',
    password: 'admin123',
    role: UserRole.admin,
  );

  static const UserAccount librarian = UserAccount(
    id: 'u-lib-1',
    name: 'Ms. Sara Ahmed',
    title: 'Chief Circulation Librarian',
    email: 'librarian@library.com',
    password: 'librarian123',
    role: UserRole.librarian,
  );

  static const UserAccount reader = UserAccount(
    id: 'u-read-1',
    name: 'Abiye Tesfaye',
    title: 'Engineering Student',
    email: 'reader@library.com',
    password: 'reader123',
    role: UserRole.reader,
  );

  static UserAccount getForRole(UserRole role) {
    switch (role) {
      case UserRole.admin:
        return admin;
      case UserRole.librarian:
        return librarian;
      case UserRole.reader:
        return reader;
    }
  }
}
