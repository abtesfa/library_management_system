import '../entities/borrow_record.dart';
import 'calculate_overdue_days.dart';

/// Fine for a loan: overdue days multiplied by the daily fine.
class CalculateFine {
  final CalculateOverdueDays calculateOverdueDays;

  const CalculateFine(this.calculateOverdueDays);

  double call(
    BorrowRecord record, {
    required double finePerDay,
    DateTime? asOf,
  }) {
    return calculateOverdueDays(record, asOf: asOf) * finePerDay;
  }
}
