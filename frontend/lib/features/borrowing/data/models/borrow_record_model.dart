import '../../domain/entities/borrow_record.dart';

/// JSON-aware version of [BorrowRecord] used by the data layer.
class BorrowRecordModel extends BorrowRecord {
  BorrowRecordModel({
    required super.id,
    required super.studentId,
    required super.studentName,
    required super.bookId,
    required super.bookTitle,
    required super.isbn,
    required super.borrowDate,
    required super.dueDate,
    super.returnDate,
    required super.status,
    required super.fineAmount,
    required super.daysLeft,
    required super.renewalCount,
  });

  factory BorrowRecordModel.fromJson(
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

    return BorrowRecordModel(
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
}
