
import 'package:flutter/foundation.dart';

import '../models/borrow_record.dart';

class CirculationProvider extends ChangeNotifier {
  final List<BorrowRecord> _records = [
    BorrowRecord(
      id: 'BR001',
      bookTitle: 'Clean Code',
      readerName: 'Abebe Kebede',
      borrowDate: DateTime.now().subtract(const Duration(days: 3)),
      dueDate: DateTime.now().add(const Duration(days: 11)),
    ),
    BorrowRecord(
      id: 'BR002',
      bookTitle: 'Introduction to Algorithms',
      readerName: 'Sara Tesfaye',
      borrowDate: DateTime.now().subtract(const Duration(days: 20)),
      dueDate: DateTime.now().subtract(const Duration(days: 6)),
    ),
  ];

  List<BorrowRecord> get records => List.unmodifiable(_records);

  int get activeCount =>
      _records.where((r) => r.returnDate == null).length;

  int get overdueCount =>
      _records.where((r) => r.status == BorrowStatus.overdue).length;

  int get returnedCount =>
      _records.where((r) => r.returnDate != null).length;

  void issueBook({
    required String bookTitle,
    required String readerName,
    required DateTime dueDate,
  }) {
    final now = DateTime.now();

    _records.insert(
      0,
      BorrowRecord(
        id: 'BR${DateTime.now().microsecondsSinceEpoch}',
        bookTitle: bookTitle.trim(),
        readerName: readerName.trim(),
        borrowDate: now,
        dueDate: dueDate,
      ),
    );

    notifyListeners();
  }

  void returnBook(String id) {
    final index = _records.indexWhere((record) => record.id == id);

    if (index == -1 || _records[index].returnDate != null) {
      return;
    }

    _records[index] = BorrowRecord(
      id: _records[index].id,
      bookTitle: _records[index].bookTitle,
      readerName: _records[index].readerName,
      borrowDate: _records[index].borrowDate,
      dueDate: _records[index].dueDate,
      returnDate: DateTime.now(),
    );

    notifyListeners();
  }
}
