import '../repositories/borrowing_repository.dart';

class BorrowBook {
  final BorrowingRepository repository;

  const BorrowBook(this.repository);

  Future<void> call({
    required String studentId,
    required String bookQuery,
    required DateTime borrowDate,
  }) {
    return repository.borrowBook(
      studentId: studentId,
      bookQuery: bookQuery,
      borrowDate: borrowDate,
    );
  }
}
