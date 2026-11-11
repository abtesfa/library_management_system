import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/book.dart';

class BookService {
  static const String baseUrl = '${ApiConfig.baseUrl}/books';
  static const Duration _requestTimeout = Duration(seconds: 15);

  /// Loads every book from the backend.
  Future<List<Book>> getAllBooks() async {
    try {
      final response =
          await http.get(Uri.parse(baseUrl)).timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((item) => Book.fromJson(item)).toList();
      }

      throw Exception(
        'Failed to load books: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      throw Exception('Unable to connect to the server: $e');
    }
  }

  /// Loads only the books a student can still borrow or reserve.
  Future<List<Book>> getAvailableBooks() async {
    final books = await getAllBooks();

    return books.where((book) {
      return book.availableCopies > 0 &&
          book.status.toLowerCase() == 'available';
    }).toList();
  }

  /// Adds a new book and its physical copies.
  Future<Map<String, dynamic>> createBook(
    Map<String, dynamic> bookData,
  ) async {
    final response = await http
        .post(
          Uri.parse(baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(bookData),
        )
        .timeout(_requestTimeout);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isNotEmpty) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
      return {};
    }

    throw Exception(
      'Failed to add book (${response.statusCode}): ${response.body}',
    );
  }
}
