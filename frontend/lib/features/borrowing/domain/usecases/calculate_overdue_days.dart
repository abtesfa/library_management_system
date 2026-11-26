import '../entities/borrow_record.dart';

/// Number of days a loan is overdue; zero when it is not overdue.
class CalculateOverdueDays {
  const CalculateOverdueDays();

  int call(
    BorrowRecord record, {
    DateTime? asOf,
  }) {
    final dueDate = DateTime.tryParse(record.dueDate);

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
}
