import '../entities/borrow_record.dart';
import '../repositories/borrowing_repository.dart';

class GetMyBooks {
  final BorrowingRepository repository;

  const GetMyBooks(this.repository);

  Future<List<BorrowRecord>> call(String studentId) =>
      repository.getMyBooks(studentId);
}
