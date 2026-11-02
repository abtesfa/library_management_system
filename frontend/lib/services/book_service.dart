import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';
import '../models/inventory_summary.dart';

class BookService {
  static const String baseUrl = 'http://localhost:8080/api/books';

  // Retrieve all books
  Future<List<Book>> getAllBooks() async {
    final response = await http
        .get(
          Uri.parse(baseUrl),
        )
        .timeout(const Duration(seconds: 5));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);

      return jsonData.map((item) => Book.fromJson(item)).toList();
    } else {
      throw Exception(
        'Failed to load books: ${response.statusCode}',
      );
    }
  }

  static Future<bool> addBook({
    required String title,
    required String author,
    required String category,
    required int totalCopies,
    required String location,
  }) async {
    try {
      final uri = Uri.parse(baseUrl);
      final response = await http
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'title': title,
              'author': author,
              'category': category,
              'totalCopies': totalCopies,
              'location': location,
            }),
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('DEBUG addBook error: $e');
      return false;
    }
  }

  static Future<List<Book>> fetchBooks() async {
    try {
      final uri = Uri.parse('http://localhost:8080/api/books');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      print('DEBUG fetchBooks status: ${response.statusCode}');
      print('DEBUG fetchBooks body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) {
          try {
            return Book.fromJson(item as Map<String, dynamic>);
          } catch (parseError) {
            print('DEBUG Book parse error on item: $item');
            print('DEBUG Error details: $parseError');
            rethrow;
          }
        }).toList();
      } else {
        print('DEBUG Server responded with code: ${response.statusCode}');
        return [];
      }
    } catch (e, stack) {
      print('DEBUG fetchBooks error: $e');
      print('DEBUG stack trace: $stack');
      return [];
    }
  }

  static Future<InventorySummary> fetchInventorySummary() async {
    try {
      // Make sure your URL matches your target device runtime (see Step 2)
      final uri =
          Uri.parse('http://localhost:8080/api/books/inventory-summary');
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      print('DEBUG Status Code: ${response.statusCode}');
      print('DEBUG Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return InventorySummary.fromJson(data);
      } else {
        print('Server error with status: ${response.statusCode}');
        return InventorySummary.empty();
      }
    } catch (e, stackTrace) {
      print('DEBUG CATCH ERROR: $e');
      print('DEBUG STACK: $stackTrace');
      return InventorySummary.empty();
    }
  }
}
