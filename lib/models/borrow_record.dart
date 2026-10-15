
enum BorrowStatus {
  borrowed,
  returned,
  overdue,
}

class BorrowRecord {
  final String id;
  final String bookTitle;
  final String readerName;
  final DateTime borrowDate;
  final DateTime dueDate;
  final DateTime? returnDate;

  const BorrowRecord({
    required this.id,
    required this.bookTitle,
    required this.readerName,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
  });

  BorrowStatus get status {
    if (returnDate != null) {
      return BorrowStatus.returned;
    }

    if (DateTime.now().isAfter(dueDate)) {
      return BorrowStatus.overdue;
    }

    return BorrowStatus.borrowed;
  }

  BorrowRecord copyWith({
    DateTime? returnDate,
  }) {
    return BorrowRecord(
      id: id,
      bookTitle: bookTitle,
      readerName: readerName,
      borrowDate: borrowDate,
      dueDate: dueDate,
      returnDate: returnDate ?? this.returnDate,
    );
  }
}
