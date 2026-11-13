import '../repositories/book_repository.dart';

class DeleteBook {
  final BookRepository repository;

  const DeleteBook(this.repository);

  Future<void> call(String bookId) => repository.deleteBook(bookId);
}
