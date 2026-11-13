import '../entities/book.dart';
import '../repositories/book_repository.dart';

/// Loads only the books a student can still borrow or reserve.
class GetAvailableBooks {
  final BookRepository repository;

  const GetAvailableBooks(this.repository);

  Future<List<Book>> call() async {
    final books = await repository.getAllBooks();

    return books.where((book) {
      return book.availableCopies > 0 &&
          book.status.toLowerCase() == 'available';
    }).toList();
  }
}
