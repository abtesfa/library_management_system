import '../repositories/book_repository.dart';

class UpdateBook {
  final BookRepository repository;

  const UpdateBook(this.repository);

  Future<void> call(String bookId, Map<String, dynamic> bookData) =>
      repository.updateBook(bookId, bookData);
}
