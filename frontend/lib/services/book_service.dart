
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookService {
  static const String baseUrl = 'http://localhost:8080/api/books';

  // Retrieve all books
  Future<List<Book>> getAllBooks() async {
    try {
      final response = await http
          .get(Uri.parse(baseUrl))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = jsonDecode(response.body);

        return jsonData
            .map((item) => Book.fromJson(item))
            .toList();
      }

      throw Exception(
        'Failed to load books: ${response.statusCode} ${response.body}',
      );
    } catch (e) {
      throw Exception('Unable to connect to the server: $e');
    }
  }

  // Retrieve only books that have available copies
 Future<List<Book>> getAvailableBooks() async {
  final books = await getAllBooks();

  for (final book in books) {
    print('BOOK TITLE: ${book.title}');
    print('BOOK ISBN: "${book.isbn}"');
    print('ISBN LENGTH: ${book.isbn.length}');
    print('AVAILABLE COPIES: ${book.availableCopies}');
    print('STATUS: ${book.status}');
    print('--------------------------');
  }

  return books.where((book) {
    return book.availableCopies > 0 &&
        book.status.toLowerCase() == 'available';
  }).toList();
}
  // Add a new book and its physical copies
  Future<Map<String, dynamic>> createBook(
    Map<String, dynamic> bookData,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(bookData),
          )
          .timeout(const Duration(seconds: 15));

      print('ADD BOOK STATUS: ${response.statusCode}');
      print('ADD BOOK RESPONSE: ${response.body}');

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        if (response.body.isNotEmpty) {
          return jsonDecode(response.body) as Map<String, dynamic>;
        }

        return {};
      }

      throw Exception(
        'Failed to add book (${response.statusCode}): ${response.body}',
      );
    } catch (e) {
      print('CREATE BOOK ERROR: $e');
      rethrow;
    }
  }
}
