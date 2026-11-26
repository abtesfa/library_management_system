import '../entities/book.dart';
import '../repositories/book_repository.dart';

class GetAllBooks {
  final BookRepository repository;

  const GetAllBooks(this.repository);

  Future<List<Book>> call() => repository.getAllBooks();
}
