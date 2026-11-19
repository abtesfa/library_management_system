
import '../entities/book.dart';
import '../repositories/book_repository.dart';

class GetAvailableBooks {
  final BookRepository repository;

  const GetAvailableBooks(this.repository);

  Future<List<Book>> call() async {
    // Return all books, including unavailable books.
    return await repository.getAllBooks();
  }
}
