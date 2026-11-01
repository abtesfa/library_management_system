
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookService {
  static const String baseUrl = 'http://localhost:8080/api/books';

  // Retrieve all books
  Future<List<Book>> getAllBooks() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);

      return jsonData
          .map((item) => Book.fromJson(item))
          .toList();
    } else {
      throw Exception(
        'Failed to load books: ${response.statusCode} ${response.body}',
      );
    }
  }

  // Add a new book and its physical copies
  Future<void> createBook(Map<String, dynamic> bookData) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(bookData),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        'Failed to add book (${response.statusCode}): ${response.body}',
      );
    }
  }
}
