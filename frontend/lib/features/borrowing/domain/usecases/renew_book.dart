import '../repositories/borrowing_repository.dart';

class RenewBook {
  final BorrowingRepository repository;

  const RenewBook(this.repository);

  /// Returns the loan's new due date (`yyyy-MM-dd`).
  Future<String> call(String studentId, String borrowingId) =>
      repository.renewBook(studentId, borrowingId);
}
