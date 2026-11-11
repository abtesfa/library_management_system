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

  factory BorrowRecord.fromJson(
    Map<String, dynamic> json, {
    required String studentId,
  }) {
    final dueDateValue = DateTime.tryParse(
      json['dueDate']?.toString() ?? '',
    );

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final daysRemaining = dueDateValue == null
        ? 0
        : DateTime(
            dueDateValue.year,
            dueDateValue.month,
            dueDateValue.day,
          ).difference(todayDate).inDays;

    final apiStatus =
        json['status']?.toString().toUpperCase() ?? 'BORROWED';

    return BorrowRecord(
      id: json['borrowingId']?.toString() ?? '',
      studentId: studentId,
      studentName: '',
      bookId: '',
      bookTitle: json['bookTitle']?.toString() ?? 'Unknown Book',
      isbn: json['isbn']?.toString() ?? '',
      borrowDate: json['borrowDate']?.toString() ?? '',
      dueDate: json['dueDate']?.toString() ?? '',
      returnDate: json['returnDate']?.toString(),
      status: apiStatus == 'OVERDUE' || daysRemaining < 0
          ? 'Overdue'
          : 'Active',
      fineAmount: 0.0,
      daysLeft: daysRemaining,
      renewalCount: (json['renewalCount'] as num?)?.toInt() ?? 0,
    );
  }

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

// RESERVATION MODEL
class ReservationRecord {
  final String id;
  final String bookId;
  final String bookTitle;
  final String author;
  final String reservedDate;
  final String? holdUntil;
  final String? pickupLocation;
  final String status;
  final int queuePosition;

  ReservationRecord({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.author,
    required this.reservedDate,
    this.holdUntil,
    this.pickupLocation,
    required this.status,
    this.queuePosition = 1,
  });

  factory ReservationRecord.fromJson(Map<String, dynamic> json) {
    return ReservationRecord(
      id: json['reservationId']?.toString() ?? '',
      bookId: json['bookId']?.toString() ?? '',
      bookTitle: json['bookTitle']?.toString() ?? 'Unknown Book',
      author: json['author']?.toString() ?? 'Unknown Author',
      reservedDate: json['reservedDate']?.toString() ?? '',
      holdUntil: json['holdUntil']?.toString(),
      pickupLocation: json['pickupLocation']?.toString(),
      status: json['status']?.toString() ?? 'WAITING',
      queuePosition: (json['queuePosition'] as num?)?.toInt() ?? 1,
    );
  }
}