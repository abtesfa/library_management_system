
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/book.dart';
import '../models/borrow_record.dart';
import '../models/staff.dart' hide SystemSettings;
import '../models/system_settings.dart';
import '../data/mock_library_data.dart';
import 'book_service.dart';

class LibraryService extends ChangeNotifier {
  static const String _apiBaseUrl = 'http://localhost:8080/api';

  List<Book> _books = [];
  List<BorrowRecord> _borrowRecords = [];
  List<ReservationRecord> _reservations = [];
  List<StaffMember> _staff = [];

  final BookService _bookService = BookService();

  SystemSettings _settings = SystemSettings.defaultSettings();

  bool _isLoadingBooks = false;
  String? _booksError;
  String? _operationError;
  bool _isProcessingBorrow = false;
  bool _isProcessingReturn = false;

  Map<String, dynamic>? _lastReturnResponse;

  LibraryService() {
    _initData();
    loadBooksFromApi();
  }

  void _initData() {
    // Keep mock data for reservations and staff.
    // Borrowing operations now use the Spring Boot API.
    _borrowRecords = MockLibraryData.getReaderBorrowedBooks();
    _reservations = MockLibraryData.getReaderReservations();
    _staff = MockLibraryData.getInitialStaff();
  }

  // -------------------- GETTERS --------------------

  List<Book> get books => List.unmodifiable(_books);

  List<BorrowRecord> get borrowRecords =>
      List.unmodifiable(_borrowRecords);

  List<ReservationRecord> get reservations =>
      List.unmodifiable(_reservations);

  List<StaffMember> get staff => List.unmodifiable(_staff);

  SystemSettings get settings => _settings;

  bool get isLoadingBooks => _isLoadingBooks;

  String? get booksError => _booksError;

  String? get operationError => _operationError;

  bool get isProcessingBorrow => _isProcessingBorrow;

  bool get isProcessingReturn => _isProcessingReturn;

  Map<String, dynamic>? get lastReturnResponse => _lastReturnResponse;

  // -------------------- BOOK LOADING --------------------

  Future<void> loadBooksFromApi() async {
    _isLoadingBooks = true;
    _booksError = null;
    notifyListeners();

    try {
      _books = await _bookService.getAllBooks();
      _booksError = null;
    } catch (error) {
      _booksError = error.toString();
    } finally {
      _isLoadingBooks = false;
      notifyListeners();
    }
  }

  // -------------------- BOOK MANAGEMENT --------------------

  void addBook(Book book) {
    _books.insert(0, book);
    notifyListeners();
  }

  void updateBook(Book updated) {
    final index = _books.indexWhere((book) => book.id == updated.id);

    if (index == -1) return;

    _books[index] = updated;
    notifyListeners();
  }

  void deleteBook(String id) {
    _books.removeWhere((book) => book.id == id);
    notifyListeners();
  }

  Book? findBook(String query) {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) return null;

    for (final book in _books) {
      if (book.isbn.trim().toLowerCase() == search) {
        return book;
      }
    }

    for (final book in _books) {
      if (book.title.trim().toLowerCase() == search) {
        return book;
      }
    }

    for (final book in _books) {
      if (book.title.toLowerCase().contains(search)) {
        return book;
      }
    }

    return null;
  }

  // -------------------- BORROWING --------------------

  /// Creates a borrowing record through the Spring Boot API.
  ///
  /// The book is identified by its ISBN. If no ISBN is available,
  /// its title is sent instead.
  Future<bool> borrowBook(
    String bookId,
    String studentId,
    String studentName, {
    DateTime? borrowDate,
  }) async {
    _operationError = null;

    final id = studentId.trim();

    if (id.isEmpty) {
      _operationError = 'Please enter a student ID.';
      return false;
    }

    final book = _books.cast<Book?>().firstWhere(
      (item) => item?.id == bookId,
      orElse: () => null,
    );

    if (book == null) {
      _operationError = 'Book not found.';
      return false;
    }

    if (book.availableCopies <= 0) {
      _operationError = 'No copies of this book are available.';
      return false;
    }

    final bookQuery =
        book.isbn.trim().isNotEmpty ? book.isbn.trim() : book.title.trim();

    final selectedDate = borrowDate ?? DateTime.now();

    final dateString = _formatIsoDate(selectedDate);

    _isProcessingBorrow = true;
    notifyListeners();

    try {
      final response = await http
          .post(
            Uri.parse('$_apiBaseUrl/librarian/borrow'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'studentId': id,
              'bookQuery': bookQuery,
              'borrowDate': dateString,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        // Refresh the real copy counts and availability from the database.
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

  // -------------------- ACTIVE BORROWING SEARCH --------------------

  /// Finds a student's active borrowing through the backend.
  ///
  /// Search can use an ISBN or book title.
  Future<BorrowRecord?> findActiveBorrowing(
    String studentId,
    String bookQuery,
  ) async {
    _operationError = null;

    final id = studentId.trim();
    final query = bookQuery.trim();

    if (id.isEmpty || query.isEmpty) {
      _operationError = 'Enter a student ID and book ISBN or title.';
      return null;
    }

    try {
      final uri = Uri.parse(
        '$_apiBaseUrl/librarian/active-borrowing',
      ).replace(
        queryParameters: {
          'studentId': id,
          'bookQuery': query,
        },
      );

      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> json =
            jsonDecode(response.body) as Map<String, dynamic>;

        final record = BorrowRecord.fromJson(
          json,
          studentId: id,
        );

        // Keep the record in memory for the return workflow.
        _borrowRecords.removeWhere(
          (item) => item.id == record.id,
        );
        _borrowRecords.insert(0, record);

        notifyListeners();
        return record;
      }

      _operationError = _extractErrorMessage(response);
      return null;
    } catch (error) {
      _operationError = 'Unable to search active borrowing: $error';
      return null;
    }
  }

  // -------------------- DATES AND FINES --------------------

  String _formatIsoDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  DateTime? _parseDate(String value) {
    return DateTime.tryParse(value);
  }

  int overdueDays(
    BorrowRecord record, {
    DateTime? asOf,
  }) {
    final dueDate = _parseDate(record.dueDate);

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

  double calculateFine(
    BorrowRecord record, {
    DateTime? asOf,
  }) {
    return overdueDays(record, asOf: asOf) * _settings.finePerDay;
  }

  // -------------------- RETURN BOOK --------------------

  /// Returns a book through the Spring Boot API.
  ///
  /// If studentId and bookQuery are not supplied, the method
  /// tries to obtain them from the cached borrowing record.
  Future<bool> returnBookWithFine(
    String recordId, {
    String? studentId,
    String? bookQuery,
    String condition = 'GOOD',
    DateTime? returnDate,
  }) async {
    _operationError = null;
    _lastReturnResponse = null;

    final cachedRecord = _borrowRecords.cast<BorrowRecord?>().firstWhere(
      (record) => record?.id == recordId,
      orElse: () => null,
    );

    final resolvedStudentId =
        studentId ?? cachedRecord?.studentId ?? '';

    final resolvedBookQuery =
        bookQuery ??
        cachedRecord?.isbn ??
        '';

    if (resolvedStudentId.trim().isEmpty ||
        resolvedBookQuery.trim().isEmpty) {
      _operationError =
          'Student ID and book ISBN are required to return this book.';
      return false;
    }

    final normalizedCondition = condition.toUpperCase().replaceAll(
      ' ',
      '_',
    );

    const allowedConditions = {
      'GOOD',
      'MINOR_DAMAGE',
      'LOST',
    };

    if (!allowedConditions.contains(normalizedCondition)) {
      _operationError = 'Invalid book condition.';
      return false;
    }

    _isProcessingReturn = true;
    notifyListeners();

    try {
      final response = await http
          .post(
            Uri.parse('$_apiBaseUrl/librarian/return'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'studentId': resolvedStudentId.trim(),
              'bookQuery': resolvedBookQuery.trim(),
              'condition': normalizedCondition,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.body.isNotEmpty) {
          final decoded = jsonDecode(response.body);

          if (decoded is Map<String, dynamic>) {
            _lastReturnResponse = decoded;
          }
        }

        // Refresh the real copy counts after the return.
        await loadBooksFromApi();

        // Remove the cached active borrowing.
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

  /// Backwards-compatible wrapper for older screens.
  Future<void> returnBook(String recordId) async {
    await returnBookWithFine(recordId);
  }

  // -------------------- ERROR HANDLING --------------------

  String _extractErrorMessage(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);

      if (decoded is Map<String, dynamic>) {
        return decoded['message']?.toString() ??
            decoded['error']?.toString() ??
            'Request failed (${response.statusCode}).';
      }
    } catch (_) {
      // The response may not contain JSON.
    }

    return 'Request failed (${response.statusCode}): ${response.body}';
  }

  // -------------------- RESERVATIONS --------------------

  void reserveBook(
    String bookId,
    String studentId,
    String studentName,
  ) {
    final bookIndex = _books.indexWhere(
      (book) => book.id == bookId,
    );

    if (bookIndex == -1) return;

    final book = _books[bookIndex];
    final now = DateTime.now();
    final holdDate = now.add(const Duration(days: 2));

    _reservations.insert(
      0,
      ReservationRecord(
        id: 'res-${now.microsecondsSinceEpoch}',
        bookId: book.id,
        bookTitle: book.title,
        author: book.author,
        reservedDate: _formatDisplayDate(now),
        holdUntil: _formatDisplayDate(holdDate),
        pickupLocation: book.location,
        status: 'In Queue',
        queuePosition: 1,
      ),
    );

    notifyListeners();
  }

  String _formatDisplayDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  // -------------------- SETTINGS --------------------

  void updateSettings(SystemSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }
}
