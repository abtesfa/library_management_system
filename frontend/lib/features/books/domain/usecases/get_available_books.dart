import '../entities/book.dart';
import '../repositories/book_repository.dart';

/// Loads the complete active catalogue. Unavailable titles remain visible
/// because students are allowed to reserve them.
class GetAvailableBooks {
  final BookRepository repository;

  const GetAvailableBooks(this.repository);

  Future<List<Book>> call() async {
    final books = await repository.getAllBooks();

    return books;
  }
}
