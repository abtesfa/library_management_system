import '../entities/borrow_record.dart';
import '../repositories/borrowing_repository.dart';

class FindActiveBorrowing {
  final BorrowingRepository repository;

  const FindActiveBorrowing(this.repository);

  Future<BorrowRecord> call({
    required String studentId,
    required String bookQuery,
  }) {
    return repository.findActiveBorrowing(
      studentId: studentId,
      bookQuery: bookQuery,
    );
  }
}
