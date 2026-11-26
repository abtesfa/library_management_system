import '../entities/borrow_record.dart';

abstract class BorrowingRepository {
  /// Creates a borrowing record. Throws an `ApiException` when the server
  /// rejects the request.
  Future<void> borrowBook({
    required String studentId,
    required String bookQuery,
    required DateTime borrowDate,
  });

  /// Finds a student's active borrowing by ISBN or book title. Throws an
  /// `ApiException` when the server rejects the request.
  Future<BorrowRecord> findActiveBorrowing({
    required String studentId,
    required String bookQuery,
  });

  /// Returns a book and gives back the server's response (fine details, ...)
  /// when it sent one. Throws an `ApiException` when the server rejects it.
  Future<Map<String, dynamic>?> returnBook({
    required String studentId,
    required String bookQuery,
    required String condition,
  });

  /// Loans a student currently has.
  Future<List<BorrowRecord>> getMyBooks(String studentId);

  /// Renews a loan and returns its new due date (`yyyy-MM-dd`).
  Future<String> renewBook(String studentId, String borrowingId);
}
