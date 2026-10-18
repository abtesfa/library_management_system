import 'package:flutter/material.dart';
import '../models/user.dart';

class AuthService extends ChangeNotifier {
  UserRole _currentRole = UserRole.admin;
  bool _isAuthenticated = false;

  UserRole get currentRole => _currentRole;
  bool get isAuthenticated => _isAuthenticated;
  UserAccount get currentUser => HardcodedCredentials.getForRole(_currentRole);

  void login(UserRole role) {
    _currentRole = role;
    _isAuthenticated = true;
    notifyListeners();
  }

  void switchRole(UserRole role) {
    _currentRole = role;
    notifyListeners();
  }

  void logout() {
    _isAuthenticated = false;
    notifyListeners();
  }
}
