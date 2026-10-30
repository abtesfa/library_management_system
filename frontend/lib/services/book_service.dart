
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class BookService {
  static const String baseUrl =
      'http://localhost:8080/api/books';

  // Retrieve all books
  Future<List<Book>> getAllBooks() async {
    final response = await http.get(
      Uri.parse(baseUrl),
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData =
          jsonDecode(response.body);

      return jsonData
          .map((item) => Book.fromJson(item))
          .toList();
    } else {
      throw Exception(
        'Failed to load books: ${response.statusCode}',
      );
    }
  }
}
