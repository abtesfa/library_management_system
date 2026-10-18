import 'package:flutter/material.dart';
import '../models/book.dart';
import '../models/borrow_record.dart';
import '../models/staff.dart'  hide SystemSettings;
import '../data/mock_library_data.dart';
import '../models/system_settings.dart';

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

  List<Book> get books => _books;
  List<BorrowRecord> get borrowRecords => _borrowRecords;
  List<ReservationRecord> get reservations => _reservations;
  List<StaffMember> get staff => _staff;
  SystemSettings get settings => _settings;

  void addBook(Book book) {
    _books.insert(0, book);
    notifyListeners();
  }

  void updateBook(Book updated) {
    final index = _books.indexWhere((b) => b.id == updated.id);
    if (index != -1) {
      _books[index] = updated;
      notifyListeners();
    }
  }

  void deleteBook(String id) {
    _books.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  void borrowBook(String bookId, String studentId, String studentName) {
    final index = _books.indexWhere((b) => b.id == bookId);
    if (index != -1 && _books[index].availableCopies > 0) {
      final book = _books[index];
      final now = DateTime.now();
      final due = now.add(const Duration(days: 14));
      _books[index] = book.copyWith(
        availableCopies: book.availableCopies - 1,
        status: (book.availableCopies - 1) == 0 ? 'Borrowed' : 'Available',
      );
      _borrowRecords.insert(
        0,
        BorrowRecord(
          id: 'br-${DateTime.now().millisecondsSinceEpoch}',
          studentId: studentId,
          studentName: studentName,
          bookId: book.id,
          bookTitle: book.title,
          isbn: book.isbn,
          borrowDate: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
          dueDate: '${due.year}-${due.month.toString().padLeft(2, '0')}-${due.day.toString().padLeft(2, '0')}',
          status: 'Active',
          fineAmount: 0.0,
        ),
      );
      notifyListeners();
    }
  }

  void returnBook(String recordId) {
    final recordIndex = _borrowRecords.indexWhere((r) => r.id == recordId);
    if (recordIndex != -1) {
      final record = _borrowRecords[recordIndex];
      final bookIndex = _books.indexWhere((b) => b.id == record.bookId);
      if (bookIndex != -1) {
        _books[bookIndex] = _books[bookIndex].copyWith(
          availableCopies: _books[bookIndex].availableCopies + 1,
          status: 'Available',
        );
      }
      final now = DateTime.now();
      _borrowRecords[recordIndex] = record.copyWith(
        status: 'Returned',
        returnDate: '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
      );
      notifyListeners();
    }
  }

  
void reserveBook(String bookId, String studentId, String studentName) {
  final bookIndex = _books.indexWhere((b) => b.id == bookId);

  // Stop if the book does not exist.
  if (bookIndex == -1) return;

  final book = _books[bookIndex];
  final now = DateTime.now();
  final holdDate = now.add(const Duration(days: 2));

  _reservations.insert(
    0,
    ReservationRecord(
      id: 'res-${now.millisecondsSinceEpoch}',
      bookId: book.id,
      bookTitle: book.title,
      author: book.author,
      reservedDate: _formatDate(now),
      holdUntil: _formatDate(holdDate),
      pickupLocation: book.location,
      status: 'In Queue',
      queuePosition: 1,
    ),
  );

  notifyListeners();
}

String _formatDate(DateTime date) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}


  void updateSettings(SystemSettings newSettings) {
    _settings = newSettings;
    notifyListeners();
  }
}
