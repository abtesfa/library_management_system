import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/entities/book_metadata.dart';
import '../models/book_metadata_model.dart';

class OpenLibraryRemoteDataSource {
  static const Duration _requestTimeout = Duration(seconds: 15);
  static const String _searchFields =
      'title,subtitle,author_name,publisher,first_publish_year,cover_i';

  final http.Client _client;
  final Map<String, BookMetadata?> _cache = {};

  OpenLibraryRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  Future<BookMetadata?> lookupByIsbn(String isbn) async {
    final normalizedIsbn =
        isbn.replaceAll(RegExp(r'[^0-9Xx]'), '').toUpperCase();
    if (_cache.containsKey(normalizedIsbn)) {
      return _cache[normalizedIsbn];
    }

    final response = await _client.get(
      Uri.https(
        'openlibrary.org',
        '/search.json',
        {
          'isbn': normalizedIsbn,
          'fields': _searchFields,
          'limit': '1',
        },
      ),
      headers: const {
        'Accept': 'application/json',
        'User-Agent': 'LibraryManagementSystem/1.0',
      },
    ).timeout(_requestTimeout);

    if (response.statusCode != 200) {
      throw Exception('Open Library lookup failed (${response.statusCode}).');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Open Library returned invalid data.');
    }

    final docs = decoded['docs'];
    if (docs is! List || docs.isEmpty) {
      _cache[normalizedIsbn] = null;
      return null;
    }

    final firstResult = docs.first;
    if (firstResult is! Map<String, dynamic>) {
      throw const FormatException(
          'Open Library returned invalid book details.');
    }

    final metadata = BookMetadataModel.fromOpenLibrarySearchJson(
        firstResult, normalizedIsbn);
    _cache[normalizedIsbn] = metadata;
    return metadata;
  }
}
