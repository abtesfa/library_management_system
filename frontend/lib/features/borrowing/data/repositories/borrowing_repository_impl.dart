import '../../domain/entities/borrow_record.dart';
import '../../domain/repositories/borrowing_repository.dart';
import '../datasources/borrowing_remote_data_source.dart';

class BorrowingRepositoryImpl implements BorrowingRepository {
  final BorrowingRemoteDataSource remoteDataSource;

  const BorrowingRepositoryImpl(this.remoteDataSource);

  @override
  Future<void> borrowBook({
    required String studentId,
    required String bookQuery,
    required DateTime borrowDate,
  }) {
    return remoteDataSource.borrowBook(
      studentId: studentId,
      bookQuery: bookQuery,
      borrowDate: borrowDate,
    );
  }

  @override
  Future<BorrowRecord> findActiveBorrowing({
    required String studentId,
    required String bookQuery,
  }) {
    return remoteDataSource.findActiveBorrowing(
      studentId: studentId,
      bookQuery: bookQuery,
    );
  }

  @override
  Future<Map<String, dynamic>?> returnBook({
    required String studentId,
    required String bookQuery,
    required String condition,
  }) {
    return remoteDataSource.returnBook(
      studentId: studentId,
      bookQuery: bookQuery,
      condition: condition,
    );
  }

  @override
  Future<List<BorrowRecord>> getMyBooks(String studentId) =>
      remoteDataSource.getMyBooks(studentId);

  @override
  Future<String> renewBook(String studentId, String borrowingId) =>
      remoteDataSource.renewBook(studentId, borrowingId);
}
