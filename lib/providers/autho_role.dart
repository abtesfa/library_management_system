import 'package:flutter/material.dart';

enum UserRole { reader, librarian, admin }

class AuthRoleProvider extends ChangeNotifier {
  UserRole _currentRole = UserRole.reader;
  String _userName = 'Abiye Tesfaye';
  int _unreadNotifications = 2;

  UserRole get currentRole => _currentRole;
  String get userName => _userName;
  int get unreadNotifications => _unreadNotifications;

  String get roleDisplayName {
    switch (_currentRole) {
      case UserRole.reader:
        return 'Reader';
      case UserRole.librarian:
        return 'Librarian';
      case UserRole.admin:
        return 'System Administrator';
    }
  }

  void switchRole(UserRole role) {
    _currentRole = role;
    switch (role) {
      case UserRole.reader:
        _userName = 'Abiye Tesfaye';
        _unreadNotifications = 2;
        break;
      case UserRole.librarian:
        _userName = 'Sara Ahmed';
        _unreadNotifications = 3;
        break;
      case UserRole.admin:
        _userName = 'Sara Ahmed';
        _unreadNotifications = 3;
        break;
    }
    notifyListeners();
  }

  void setUnreadCount(int count) {
    _unreadNotifications = count;
    notifyListeners();
  }
}
