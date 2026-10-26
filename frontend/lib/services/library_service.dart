
import 'package:flutter/material.dart';

import '../models/book.dart';
import '../models/borrow_record.dart';
import '../models/staff.dart' hide SystemSettings;
import '../models/system_settings.dart';
import '../data/mock_library_data.dart';


class LibraryService extends ChangeNotifier {
  List<Book> _books = [];
  List<BorrowRecord> _borrowRecords = [];
  List<ReservationRecord> _reservations = [];
  List<StaffMember> _staff = [];

  SystemSettings _settings = SystemSettings.defaultSettings();

  LibraryService() {
    _initData();
  }

  void _initData() {
    _books = MockLibraryData.getInitialBooks();
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

  /// Searches by exact ISBN first, then by exact title,
  /// and finally by a title containing the search text.
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

  /// Borrows a book using the selected date and configured
  /// maximum borrowing duration.
  ///
  /// Returns false if the book does not exist, the student ID
  /// is empty, or no copies are available.
  bool borrowBook(
    String bookId,
    String studentId,
    String studentName, {
    DateTime? borrowDate,
  }) {
    
    final id = studentId.trim();

    if (id.isEmpty) return false;
       //Update the available copies
    final bookIndex = _books.indexWhere(
      (book) => book.id == bookId,
    );

    if (bookIndex == -1) return false;

    final book = _books[bookIndex];

    if (book.availableCopies <= 0) return false;

    final selectedDate = borrowDate ?? DateTime.now();

    final startDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final dueDate = startDate.add(
      Duration(days: _settings.maxBorrowDays),
    );

    final remainingCopies = book.availableCopies - 1;

    _books[bookIndex] = book.copyWith(
      availableCopies: remainingCopies,
      status: remainingCopies == 0 ? 'Borrowed' : 'Available',
    );

    _borrowRecords.insert(
      0,
      BorrowRecord(
        id: 'br-${DateTime.now().microsecondsSinceEpoch}',
        studentId: id,
        studentName: studentName.trim().isEmpty
            ? id
            : studentName.trim(),
        bookId: book.id,
        bookTitle: book.title,
        isbn: book.isbn,
        borrowDate: _formatIsoDate(startDate),
        dueDate: _formatIsoDate(dueDate),
        status: 'Active',
        fineAmount: 0.0,
        daysLeft: _settings.maxBorrowDays,
      ),
    );

    notifyListeners();
    return true;
  }

  /// Finds a student's active borrowing by ISBN or title.
  BorrowRecord? findActiveBorrowing(
    String studentId,
    String bookQuery,
  ) {
    final id = studentId.trim().toLowerCase();
    final query = bookQuery.trim().toLowerCase();

    if (id.isEmpty || query.isEmpty) return null;

    // Prefer exact ISBN or exact title matches.
    for (final record in _borrowRecords) {
      final active = record.status == 'Active' ||
          record.status == 'Overdue';

      if (!active) continue;

      final matchesStudent =
          record.studentId.trim().toLowerCase() == id;

      final matchesBook =
          record.isbn.trim().toLowerCase() == query ||
          record.bookTitle.trim().toLowerCase() == query;

      if (matchesStudent && matchesBook) {
        return record;
      }
    }

    // If the user typed part of a title, allow title matching.
    for (final record in _borrowRecords) {
      final active = record.status == 'Active' ||
          record.status == 'Overdue';

      if (!active) continue;

      final matchesStudent =
          record.studentId.trim().toLowerCase() == id;

      final matchesTitle =
          record.bookTitle.toLowerCase().contains(query);

      if (matchesStudent && matchesTitle) {
        return record;
      }
    }

    return null;
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

  /// Counts calendar days past the due date.
  /// A book returned on its due date has zero overdue days.
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

  /// Fine = overdue days multiplied by the configured daily rate.
  double calculateFine(
    BorrowRecord record, {
    DateTime? asOf,
  }) {
    return overdueDays(record, asOf: asOf) *
        _settings.finePerDay;
  }

  /// Marks a borrowing as returned, stores the return date and
  /// the calculated fine, and increases available book copies.
  bool returnBookWithFine(
    String recordId, {
    DateTime? returnDate,
  }) {
    final recordIndex = _borrowRecords.indexWhere(
      (record) => record.id == recordId,
    );

    if (recordIndex == -1) return false;

    final record = _borrowRecords[recordIndex];

    if (record.status != 'Active' &&
        record.status != 'Overdue') {
      return false;
    }

    final selectedReturnDate = returnDate ?? DateTime.now();

    final daysLate = overdueDays(
      record,
      asOf: selectedReturnDate,
    );

    final fine = daysLate * _settings.finePerDay;

    final bookIndex = _books.indexWhere(
      (book) => book.id == record.bookId,
    );

    if (bookIndex != -1) {
      final book = _books[bookIndex];

      final newAvailableCopies =
          (book.availableCopies + 1).clamp(0, book.totalCopies);

      _books[bookIndex] = book.copyWith(
        availableCopies: newAvailableCopies,
        status: newAvailableCopies > 0
            ? 'Available'
            : 'Borrowed',
      );
    }

    _borrowRecords[recordIndex] = record.copyWith(
      status: 'Returned',
      returnDate: _formatIsoDate(selectedReturnDate),
      fineAmount: fine,
      daysLeft: 0,
    );

    notifyListeners();
    return true;
  }

  /// Backwards-compatible method for existing screens.
  /// New return workflows should use returnBookWithFine().
  void returnBook(String recordId) {
    returnBookWithFine(recordId);
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
