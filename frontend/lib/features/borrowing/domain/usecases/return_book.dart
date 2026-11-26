import '../repositories/borrowing_repository.dart';

class ReturnBook {
  final BorrowingRepository repository;

  const ReturnBook(this.repository);

  Future<Map<String, dynamic>?> call({
    required String studentId,
    required String bookQuery,
    required String condition,
  }) {
    return repository.returnBook(
      studentId: studentId,
      bookQuery: bookQuery,
      condition: condition,
    );
  }
}
