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
  final String status; // 'Active', 'Returned', 'Overdue'
  final double fineAmount;
  final int daysLeft;

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
  );
}

}

class ReservationRecord {
  final String id;
  final String bookId;
  final String bookTitle;
  final String author;
  final String reservedDate;
  final String holdUntil;
  final String pickupLocation;
  final String status; // 'Ready for Pickup', 'In Queue', 'Completed', 'Cancelled'
  final int queuePosition;

  ReservationRecord({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.author,
    required this.reservedDate,
    required this.holdUntil,
    required this.pickupLocation,
    required this.status,
    this.queuePosition = 1,
  });
}
