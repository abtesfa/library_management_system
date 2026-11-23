import '../entities/borrowing_history_page.dart';
import '../repositories/borrowing_repository.dart';

class GetBorrowingHistory {
  final BorrowingRepository repository;

  const GetBorrowingHistory(this.repository);

  Future<BorrowingHistoryPage> call(
    String studentId,
    int page,
  ) {
    return repository.getBorrowingHistory(
      studentId,
      page,
    );
  }
}