
import 'dart:convert';
import 'package:http/http.dart' as http;

class SettingsApiService {
  // Android emulator: use http://10.0.2.2:8080/api/settings
  // Chrome or Windows desktop: use http://localhost:8080/api/settings
  static const String baseUrl = 'http://localhost:8080/api/settings';

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
