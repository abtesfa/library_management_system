import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:library_management_system/features/auth/data/models/authenticated_user_model.dart';

void main() {
  test('loads the persisted profile photo from the login response', () {
    final model = AuthenticatedUserModel.fromJson({
      'accountId': '12',
      'fullName': 'Test Student',
      'email': 'student@example.com',
      'role': 'STUDENT',
      'title': 'Science',
      'permissions': <String>[],
      'profilePhoto': base64Encode([1, 2, 3]),
    });

    expect(model.avatarBytes, [1, 2, 3]);
  });

  test('allows accounts without a saved profile photo', () {
    final model = AuthenticatedUserModel.fromJson({
      'accountId': '12',
      'fullName': 'Test Student',
      'email': 'student@example.com',
      'role': 'STUDENT',
      'title': 'Science',
      'permissions': <String>[],
    });

    expect(model.avatarBytes, isNull);
  });
}
