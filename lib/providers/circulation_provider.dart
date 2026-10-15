import 'package:flutter/material.dart';
import '../models/borrow_record.dart';

class CirculationProvider extends ChangeNotifier {
  // Currently active borrowed books matching Readerhom2 mockup
  final List<BorrowRecord> _activeBorrows = [
    const BorrowRecord(
      id: 'b1',
      bookTitle: 'Atomic Habits',
      author: 'James Clear',
      category: 'Self-Help',
      isbn: '978-0735211292',
      borrowedDate: 'Oct 2, 2026',
      dueDate: 'Oct 10, 2026',
      dueCountdown: 'Due in 2 days',
      status: CirculationStatus.dueSoon,
    ),
    const BorrowRecord(
      id: 'b2',
      bookTitle: 'Dune',
      author: 'Frank Herbert',
      category: 'Science Fiction',
      isbn: '978-0441013593',
      borrowedDate: 'Sep 28, 2026',
      dueDate: 'Oct 13, 2026',
      dueCountdown: 'Due in 5 days',
      status: CirculationStatus.active,
    ),
    const BorrowRecord(
      id: 'b3',
      bookTitle: 'The Great Gatsby',
      author: 'F. Scott Fitzgerald',
      category: 'Fiction',
      isbn: '978-0743273567',
      borrowedDate: 'Sep 25, 2026',
      dueDate: 'Oct 15, 2026',
      dueCountdown: 'Due in 7 days',
      status: CirculationStatus.active,
    ),
  ];

  // Borrowing history entries matching Readerhom2 table
  final List<BorrowRecord> _borrowingHistory = [
    const BorrowRecord(
      id: 'h1',
      bookTitle: 'Clean Code',
      author: 'Robert C. Martin',
      category: 'Computer Science',
      isbn: '978-0132350884',
      borrowedDate: 'Sep 15, 2026',
      dueDate: 'Oct 1, 2026',
      returnedDate: 'Oct 1, 2026',
      dueCountdown: '',
      status: CirculationStatus.returned,
    ),
    const BorrowRecord(
      id: 'h2',
      bookTitle: 'Sapiens',
      author: 'Yuval Noah Harari',
      category: 'History',
      isbn: '978-0062316097',
      borrowedDate: 'Sep 10, 2026',
      dueDate: 'Sep 27, 2026',
      returnedDate: 'Sep 27, 2026',
      dueCountdown: '',
      status: CirculationStatus.returned,
    ),
    const BorrowRecord(
      id: 'h3',
      bookTitle: '1984',
      author: 'George Orwell',
      category: 'Dystopian',
      isbn: '978-0451524935',
      borrowedDate: 'Sep 5, 2026',
      dueDate: 'Sep 20, 2026',
      returnedDate: 'Sep 20, 2026',
      dueCountdown: '',
      status: CirculationStatus.returned,
    ),
    const BorrowRecord(
      id: 'h4',
      bookTitle: 'The Pragmatic Programmer',
      author: 'David Thomas',
      category: 'Computer Science',
      isbn: '978-0135957059',
      borrowedDate: 'Aug 20, 2026',
      dueDate: 'Sep 3, 2026',
      returnedDate: 'Sep 3, 2026',
      dueCountdown: '',
      status: CirculationStatus.returned,
    ),
    const BorrowRecord(
      id: 'h5',
      bookTitle: 'Thinking, Fast and Slow',
      author: 'Daniel Kahneman',
      category: 'Psychology',
      isbn: '978-0374533557',
      borrowedDate: 'Aug 5, 2026',
      dueDate: 'Aug 19, 2026',
      returnedDate: 'Aug 19, 2026',
      dueCountdown: '',
      status: CirculationStatus.returned,
    ),
  ];

  List<BorrowRecord> get activeBorrows => _activeBorrows;
  List<BorrowRecord> get borrowingHistory => _borrowingHistory;

  int get currentlyBorrowedCount => _activeBorrows.length;
  int get dueSoonCount => 1;
  int get overdueCount => 0;
  int get completedCount => 8;

  void renewBook(String recordId) {
    // Will be wired to Spring Boot endpoint POST /api/v1/circulations/{id}/renew
    notifyListeners();
  }
}