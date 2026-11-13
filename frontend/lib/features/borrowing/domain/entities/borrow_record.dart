class BorrowRecord {
  final String id;
  final String studentId;
  final String studentName;
  final String bookId;
  final String bookTitle;
  final String isbn;
  final String borrowDate;
  final String dueDate;
  final String? returnDate;
  final String status;
  final double fineAmount;
  final int daysLeft;

  /// How many times this loan has been renewed.
  final int renewalCount;

  BorrowRecord({
    required this.id,
    required this.studentId,
    required this.studentName,
    required this.bookId,
    required this.bookTitle,
    required this.isbn,
    required this.borrowDate,
    required this.dueDate,
    this.returnDate,
    required this.status,
    this.fineAmount = 0.0,
    this.daysLeft = 0,
    this.renewalCount = 0,
  });

  BorrowRecord copyWith({
    String? id,
    String? studentId,
    String? studentName,
    String? bookId,
    String? bookTitle,
    String? isbn,
    String? borrowDate,
    String? dueDate,
    String? returnDate,
    String? status,
    double? fineAmount,
    int? daysLeft,
    int? renewalCount,
  }) {
    return BorrowRecord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      isbn: isbn ?? this.isbn,
      borrowDate: borrowDate ?? this.borrowDate,
      dueDate: dueDate ?? this.dueDate,
      returnDate: returnDate ?? this.returnDate,
      status: status ?? this.status,
      fineAmount: fineAmount ?? this.fineAmount,
      daysLeft: daysLeft ?? this.daysLeft,
      renewalCount: renewalCount ?? this.renewalCount,
    );
  }
}
