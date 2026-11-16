import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../../core/error/api_exception.dart';
import '../../domain/entities/user.dart';
import '../models/authenticated_user_model.dart';

class AuthRemoteDataSource {
  static const String baseUrl = '${ApiConfig.baseUrl}/auth';
  static const Duration _requestTimeout = Duration(seconds: 45);

  Future<AuthenticatedUserModel> login({
    required String identifier,
    required String password,
    required UserRole role,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/login'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'identifier': identifier,
            'password': password,
            'role': role.apiRole,
          }),
        )
        .timeout(_requestTimeout);

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        return AuthenticatedUserModel.fromJson(decoded);
      }
      throw const ApiException(
          'The server returned an invalid login response.');
    }

    String message = 'Sign in failed (${response.statusCode}).';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        message = decoded['message']?.toString() ??
            decoded['error']?.toString() ??
            message;
      }
    } on FormatException {
      if (response.body.isNotEmpty) message = response.body;
    }

    throw ApiException(message);
  }

  Future<void> changePassword({
    required String identifier,
    required String currentPassword,
    required String newPassword,
    required UserRole role,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/change-password'),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode({
            'identifier': identifier,
            'currentPassword': currentPassword,
            'newPassword': newPassword,
            'role': role.apiRole,
          }),
        )
        .timeout(_requestTimeout);

    if (response.statusCode == 200) return;

    String message = 'Password change failed (${response.statusCode}).';
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        message = decoded['message']?.toString() ??
            decoded['error']?.toString() ??
            message;
      }
    } on FormatException {
      if (response.body.isNotEmpty) message = response.body;
    }

    throw ApiException(message);
  }
}
