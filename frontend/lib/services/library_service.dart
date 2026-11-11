
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/book.dart';
import '../models/borrow_record.dart';
import '../models/system_settings.dart';
import 'book_service.dart';
import 'settings_api_service.dart';

/// Manages the book catalogue, system settings,
/// and librarian borrowing and returning operations.
class LibraryService extends ChangeNotifier {
  static const Duration _requestTimeout = Duration(seconds: 15);

  static const Set<String> _allowedConditions = {
    'GOOD',
    'MINOR_DAMAGE',
    'LOST',
  };

  final BookService _bookService = BookService();
  final SettingsApiService _settingsApiService = SettingsApiService();

  // System settings
  SystemSettings _settings = SystemSettings.defaultSettings();

  // Book catalogue
  List<Book> _books = [];

  // Cached active borrowing records
  final List<BorrowRecord> _borrowRecords = [];

  // Loading states
  bool _isLoadingBooks = false;
  bool _isLoadingSettings = false;
  bool _isProcessingBorrow = false;
  bool _isProcessingReturn = false;

  // Error messages
  String? _booksError;
  String? _settingsError;
  String? _operationError;

  // Last return response
  Map<String, dynamic>? _lastReturnResponse;

  // Constructor
  LibraryService() {
    loadBooksFromApi();
    loadSettingsFromApi();
  }

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  List<Book> get books => List.unmodifiable(_books);

  SystemSettings get settings => _settings;

  bool get isLoadingBooks => _isLoadingBooks;

  bool get isLoadingSettings => _isLoadingSettings;

  bool get isProcessingBorrow => _isProcessingBorrow;

  bool get isProcessingReturn => _isProcessingReturn;

  String? get booksError => _booksError;

  String? get settingsError => _settingsError;

  String? get operationError => _operationError;

  Map<String, dynamic>? get lastReturnResponse =>
      _lastReturnResponse;

  // ---------------------------------------------------------------------------
  // System Settings
  // ---------------------------------------------------------------------------

  /// Loads system settings from the Spring Boot backend.
  Future<void> loadSettingsFromApi() async {
    _isLoadingSettings = true;
    _settingsError = null;
    notifyListeners();

    try {
      final response = await _settingsApiService
          .getSettings()
          .timeout(_requestTimeout);

      _settings = SystemSettings.fromJson(response);
    } catch (error) {
      _settingsError = 'Unable to load system settings: $error';
    } finally {
      _isLoadingSettings = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Catalogue
  // ---------------------------------------------------------------------------

  /// Loads all books from the backend.
  Future<void> loadBooksFromApi() async {
    _isLoadingBooks = true;
    _booksError = null;
    notifyListeners();

    try {
      _books = await _bookService.getAllBooks();
    } catch (error) {
      _booksError = error.toString();
    } finally {
      _isLoadingBooks = false;
      notifyListeners();
    }
  }

  /// Finds a book by exact ISBN, exact title, or partial title.
  Book? findBook(String query) {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) return null;

    final matchers = <bool Function(Book)>[
      (book) => book.isbn.trim().toLowerCase() == search,
      (book) => book.title.trim().toLowerCase() == search,
      (book) => book.title.toLowerCase().contains(search),
    ];

    for (final matches in matchers) {
      for (final book in _books) {
        if (matches(book)) {
          return book;
        }
      }
    }

    return null;
  }

  // ---------------------------------------------------------------------------
  // Borrowing
  // ---------------------------------------------------------------------------

  /// Creates a borrowing record through the backend.
  ///
  /// The book is identified by ISBN, or by title if it has no ISBN.
  Future<bool> borrowBook(
    String bookId,
    String studentId, {
    DateTime? borrowDate,
  }) async {
    _operationError = null;

    final id = studentId.trim();

    if (id.isEmpty) {
      _operationError = 'Please enter a student ID.';
      notifyListeners();
      return false;
    }

    final book = _books.cast<Book?>().firstWhere(
          (item) => item?.id == bookId,
          orElse: () => null,
        );

    if (book == null) {
      _operationError = 'Book not found.';
      notifyListeners();
      return false;
    }

    final bookQuery = book.isbn.trim().isNotEmpty
        ? book.isbn.trim()
        : book.title.trim();

    _isProcessingBorrow = true;
    notifyListeners();

    try {
      final response = await http
          .post(
            Uri.parse(
              '${ApiConfig.baseUrl}/librarian/borrow',
            ),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'studentId': id,
              'bookQuery': bookQuery,
              'borrowDate': _formatIsoDate(
                borrowDate ?? DateTime.now(),
              ),
            }),
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        await loadBooksFromApi();
        return true;
      }

      _operationError = _extractErrorMessage(response);
      return false;
    } catch (error) {
      _operationError = 'Unable to borrow book: $error';
      return false;
    } finally {
      _isProcessingBorrow = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Find Active Borrowing
  // ---------------------------------------------------------------------------

  /// Finds a student's active borrowing by ISBN or book title.
  ///
  /// The result is cached for the return workflow.
  Future<BorrowRecord?> findActiveBorrowing(
    String studentId,
    String bookQuery,
  ) async {
    _operationError = null;

    final id = studentId.trim();
    final query = bookQuery.trim();

    if (id.isEmpty || query.isEmpty) {
      _operationError =
          'Enter a student ID and book ISBN or title.';
      notifyListeners();
      return null;
    }

    try {
      final uri = Uri.parse(
        '${ApiConfig.baseUrl}/librarian/active-borrowing',
      ).replace(
        queryParameters: {
          'studentId': id,
          'bookQuery': query,
        },
      );

      final response = await http
          .get(uri)
          .timeout(_requestTimeout);

      if (response.statusCode == 200) {
        final record = BorrowRecord.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>,
          studentId: id,
        );

        _borrowRecords.removeWhere(
          (item) => item.id == record.id,
        );

        _borrowRecords.insert(0, record);

        notifyListeners();
        return record;
      }

      _operationError = _extractErrorMessage(response);
      notifyListeners();
      return null;
    } catch (error) {
      _operationError =
          'Unable to search active borrowing: $error';
      notifyListeners();
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Returning and Fines
  // ---------------------------------------------------------------------------

  /// Calculates the number of overdue days.
  ///
  /// Returns zero when the book is not overdue.
  int overdueDays(
    BorrowRecord record, {
    DateTime? asOf,
  }) {
    final dueDate = DateTime.tryParse(record.dueDate);

    if (dueDate == null) return 0;

    final current = asOf ?? DateTime.now();

    final dueDay = DateTime(
      dueDate.year,
      dueDate.month,
      dueDate.day,
    );

    final currentDay = DateTime(
      current.year,
      current.month,
      current.day,
    );

    final difference = currentDay.difference(dueDay).inDays;

    return difference > 0 ? difference : 0;
  }

  /// Calculates the fine using the loaded system settings.
  double calculateFine(
    BorrowRecord record, {
    DateTime? asOf,
  }) {
    return overdueDays(record, asOf: asOf) *
        _settings.finePerDay;
  }

  /// Returns a book through the backend.
  ///
  /// Student ID and book query can be retrieved from the
  /// cached borrowing record when not supplied.
  Future<bool> returnBookWithFine(
    String recordId, {
    String? studentId,
    String? bookQuery,
    String condition = 'GOOD',
  }) async {
    _operationError = null;
    _lastReturnResponse = null;

    final cachedRecord = _borrowRecords
        .cast<BorrowRecord?>()
        .firstWhere(
          (record) => record?.id == recordId,
          orElse: () => null,
        );

    final resolvedStudentId =
        (studentId ?? cachedRecord?.studentId ?? '').trim();

    final resolvedBookQuery =
        (bookQuery ?? cachedRecord?.isbn ?? '').trim();

    if (resolvedStudentId.isEmpty ||
        resolvedBookQuery.isEmpty) {
      _operationError =
          'Student ID and book ISBN are required to return this book.';
      notifyListeners();
      return false;
    }

    final normalizedCondition =
        condition.toUpperCase().replaceAll(' ', '_');

    if (!_allowedConditions.contains(normalizedCondition)) {
      _operationError = 'Invalid book condition.';
      notifyListeners();
      return false;
    }

    _isProcessingReturn = true;
    notifyListeners();

    try {
      final response = await http
          .post(
            Uri.parse(
              '${ApiConfig.baseUrl}/librarian/return',
            ),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'studentId': resolvedStudentId,
              'bookQuery': resolvedBookQuery,
              'condition': normalizedCondition,
            }),
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200 ||
          response.statusCode == 201) {
        if (response.body.isNotEmpty) {
          final decoded = jsonDecode(response.body);

          if (decoded is Map<String, dynamic>) {
            _lastReturnResponse = decoded;
          }
        }

        await loadBooksFromApi();

        _borrowRecords.removeWhere(
          (record) => record.id == recordId,
        );

        notifyListeners();
        return true;
      }

      _operationError = _extractErrorMessage(response);
      return false;
    } catch (error) {
      _operationError = 'Unable to return book: $error';
      return false;
    } finally {
      _isProcessingReturn = false;
      notifyListeners();
    }
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

  /// Extracts an error message from an HTTP response.
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
}
