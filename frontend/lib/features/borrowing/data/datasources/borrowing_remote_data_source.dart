import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../../../core/error/api_exception.dart';
import '../models/borrow_record_model.dart';

/// Talks to the librarian borrow/return endpoints and to the student's
/// "my books" endpoints.
class BorrowingRemoteDataSource {
  static const String baseUrl = ApiConfig.baseUrl;
  static const Duration _requestTimeout = Duration(seconds: 15);

  // ---------------------------------------------------------------------------
  // Librarian desk
  // ---------------------------------------------------------------------------

  Future<void> borrowBook({
    required String studentId,
    required String bookQuery,
    required DateTime borrowDate,
  }) async {
    final response = await http
        .post(
          Uri.parse(
            '${ApiConfig.baseUrl}/librarian/borrow',
          ),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'studentId': studentId,
            'bookQuery': bookQuery,
            'borrowDate': _formatIsoDate(borrowDate),
          }),
        )
        .timeout(_requestTimeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    }

    throw ApiException(_extractErrorMessage(response));
  }

  Future<BorrowRecordModel> findActiveBorrowing({
    required String studentId,
    required String bookQuery,
  }) async {
    final uri = Uri.parse(
      '${ApiConfig.baseUrl}/librarian/active-borrowing',
    ).replace(
      queryParameters: {
        'studentId': studentId,
        'bookQuery': bookQuery,
      },
    );

    final response = await http.get(uri).timeout(_requestTimeout);

    if (response.statusCode == 200) {
      return BorrowRecordModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
        studentId: studentId,
      );
    }

    throw ApiException(_extractErrorMessage(response));
  }

  Future<Map<String, dynamic>?> returnBook({
    required String studentId,
    required String bookQuery,
    required String condition,
  }) async {
    final response = await http
        .post(
          Uri.parse(
            '${ApiConfig.baseUrl}/librarian/return',
          ),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'studentId': studentId,
            'bookQuery': bookQuery,
            'condition': condition,
          }),
        )
        .timeout(_requestTimeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isNotEmpty) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }

      return null;
    }

    throw ApiException(_extractErrorMessage(response));
  }

  // ---------------------------------------------------------------------------
  // Student "my books"
  // ---------------------------------------------------------------------------

  Future<List<BorrowRecordModel>> getMyBooks(String studentId) async {
    final url = Uri.parse('$baseUrl/students/$studentId/borrowings');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map((item) {
        return BorrowRecordModel.fromJson(
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

    throw Exception(_renewErrorMessage(response));
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Formats a date as yyyy-MM-dd for the backend.
  String _formatIsoDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Extracts an error message from a librarian-desk response.
  String _extractErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded['message']?.toString() ??
            decoded['error']?.toString() ??
            'Request failed (${response.statusCode}).';
      }
    } catch (_) {
      // Response body is not JSON.
    }

    return 'Request failed (${response.statusCode}): '
        '${response.body}';
  }

  /// Reads the `message` field the backend sends with a rejected renewal.
  String _renewErrorMessage(http.Response response) {
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
