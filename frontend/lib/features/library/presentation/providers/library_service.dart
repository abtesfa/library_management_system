
import 'package:flutter/material.dart';

import '../../../../core/di/injector.dart';
import '../../../../core/error/api_exception.dart';
import '../../../books/domain/entities/book.dart';
import '../../../books/domain/usecases/find_book.dart';
import '../../../books/domain/usecases/get_all_books.dart';
import '../../../borrowing/domain/entities/book_condition.dart';
import '../../../borrowing/domain/entities/borrow_record.dart';
import '../../../borrowing/domain/usecases/borrow_book.dart';
import '../../../borrowing/domain/usecases/calculate_fine.dart';
import '../../../borrowing/domain/usecases/calculate_overdue_days.dart';
import '../../../borrowing/domain/usecases/find_active_borrowing.dart';
import '../../../borrowing/domain/usecases/return_book.dart';
import '../../../settings/domain/entities/system_settings.dart';
import '../../../settings/domain/usecases/get_system_settings.dart';

/// Manages the book catalogue, system settings,
/// and librarian borrowing and returning operations.
///
/// This is the presentation-layer state holder (a [ChangeNotifier] exposed
/// with Provider). It only talks to use cases; HTTP and business rules live in
/// the data and domain layers.
class LibraryService extends ChangeNotifier {
  static const Duration _requestTimeout = Duration(seconds: 15);

  // Use cases
  final GetAllBooks _getAllBooks = injector.getAllBooks;
  final FindBook _findBook = injector.findBook;
  final GetSystemSettings _getSystemSettings = injector.getSystemSettings;
  final BorrowBook _borrowBook = injector.borrowBook;
  final FindActiveBorrowing _findActiveBorrowing =
      injector.findActiveBorrowing;
  final ReturnBook _returnBook = injector.returnBook;
  final CalculateOverdueDays _calculateOverdueDays =
      injector.calculateOverdueDays;
  final CalculateFine _calculateFine = injector.calculateFine;

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
      _settings = await _getSystemSettings().timeout(_requestTimeout);
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
      _books = await _getAllBooks();
    } catch (error) {
      _booksError = error.toString();
    } finally {
      _isLoadingBooks = false;
      notifyListeners();
    }
  }

  /// Finds a book by exact ISBN, exact title, or partial title.
  Book? findBook(String query) => _findBook(_books, query);

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
      await _borrowBook(
        studentId: id,
        bookQuery: bookQuery,
        borrowDate: borrowDate ?? DateTime.now(),
      );

      await loadBooksFromApi();
      return true;
    } on ApiException catch (error) {
      _operationError = error.message;
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
      final record = await _findActiveBorrowing(
        studentId: id,
        bookQuery: query,
      );

      _borrowRecords.removeWhere(
        (item) => item.id == record.id,
      );

      _borrowRecords.insert(0, record);

      notifyListeners();
      return record;
    } on ApiException catch (error) {
      _operationError = error.message;
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
    return _calculateOverdueDays(record, asOf: asOf);
  }

  /// Calculates the fine using the loaded system settings.
  double calculateFine(
    BorrowRecord record, {
    DateTime? asOf,
  }) {
    return _calculateFine(
      record,
      finePerDay: _settings.finePerDay,
      asOf: asOf,
    );
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

    final normalizedCondition = BookCondition.normalize(condition);

    if (!BookCondition.isValid(normalizedCondition)) {
      _operationError = 'Invalid book condition.';
      notifyListeners();
      return false;
    }

    _isProcessingReturn = true;
    notifyListeners();

    try {
      _lastReturnResponse = await _returnBook(
        studentId: resolvedStudentId,
        bookQuery: resolvedBookQuery,
        condition: normalizedCondition,
      );

      await loadBooksFromApi();

      _borrowRecords.removeWhere(
        (record) => record.id == recordId,
      );

      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _operationError = error.message;
      return false;
    } catch (error) {
      _operationError = 'Unable to return book: $error';
      return false;
    } finally {
      _isProcessingReturn = false;
      notifyListeners();
    }
  }
}
