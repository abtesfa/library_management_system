import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';

class SettingsRemoteDataSource {
  static const String baseUrl = '${ApiConfig.baseUrl}/settings';

  // GET: Load settings from Spring Boot
  Future<Map<String, dynamic>> getSettings() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to load settings: ${response.statusCode} ${response.body}',
    );
  }

  // PUT: Update settings in Spring Boot
  Future<Map<String, dynamic>> updateSettings({
    required String libraryName,
    required int maxBooksPerDay,
    required int maxBorrowingDays,
    required int renewalLimit,
    required double finePerDay,
    required int reservationHoldMinutes,
  }) async {
    final response = await http.put(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'libraryName': libraryName,
        'maxBooksPerDay': maxBooksPerDay,
        'maxBorrowingDays': maxBorrowingDays,
        'renewalLimit': renewalLimit,
        'finePerDay': finePerDay,
        'reservationHoldMinutes': reservationHoldMinutes,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Failed to save settings: ${response.statusCode} ${response.body}',
    );
  }
}
