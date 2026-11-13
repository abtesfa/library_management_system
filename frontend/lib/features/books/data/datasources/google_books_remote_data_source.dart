import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/book_metadata.dart';
import '../models/book_metadata_model.dart';

class GoogleBooksRemoteDataSource {
  static const Duration _requestTimeout = Duration(seconds: 15);

  final http.Client _client;

  GoogleBooksRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  Future<BookMetadata?> lookupByIsbn(String isbn) async {
    final response = await _client.get(
      Uri.https(
        'www.googleapis.com',
        '/books/v1/volumes',
        {'q': 'isbn:$isbn', 'maxResults': '1'},
      ),
      headers: const {'Accept': 'application/json'},
    ).timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw Exception(
        'Book lookup failed (${response.statusCode}): ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Book lookup returned invalid data.');
    }

    final items = decoded['items'];
    if (items is! List || items.isEmpty) return null;

    final firstItem = items.first;
    if (firstItem is! Map<String, dynamic>) {
      throw const FormatException('Book lookup returned invalid details.');
    }

    return BookMetadataModel.fromGoogleBooksJson(firstItem, isbn);
  }
}
