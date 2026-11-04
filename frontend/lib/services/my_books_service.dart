
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/borrow_record.dart';

class MyBooksService {
  static const String baseUrl = 'http://localhost:8080/api';

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
}
