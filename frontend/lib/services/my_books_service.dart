import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/borrow_record.dart';
import '../config/api_config.dart';

class MyBooksService {
  static const String baseUrl = ApiConfig.baseUrl;

  Future<List<BorrowRecord>> getMyBooks(String studentId) async {
    final url = Uri.parse('$baseUrl/students/$studentId/borrowings');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((item) {
        return BorrowRecord.fromJson(
          item as Map<String, dynamic>,
          studentId: studentId,
        );
      }).toList();
    }

    throw Exception(
      'Failed to load borrowed books: ${response.statusCode} ${response.body}',
    );
  }

  /// Renews a loan and returns its new due date (`yyyy-MM-dd`).
  ///
  /// Throws an [Exception] carrying the server's reason when the renewal is
  /// rejected (already renewed, overdue, ...).
  Future<String> renewBook(String studentId, String borrowingId) async {
    final url = Uri.parse(
      '$baseUrl/students/$studentId/borrowings/$borrowingId/renew',
    );

    final response = await http.post(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['dueDate']?.toString() ?? '';
    }

    throw Exception(_errorMessage(response));
  }

  /// Reads the `message` field the backend sends with an error response.
  String _errorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> && decoded['message'] != null) {
        return decoded['message'].toString();
      }
    } catch (_) {
      // Not JSON; fall through to the generic message.
    }
    return 'Request failed (${response.statusCode}).';
  }
}
