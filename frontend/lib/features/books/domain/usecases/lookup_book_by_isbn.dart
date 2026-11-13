import '../entities/book_metadata.dart';
import '../repositories/book_repository.dart';

class LookupBookByIsbn {
  final BookRepository repository;

  const LookupBookByIsbn(this.repository);

  Future<BookMetadata?> call(String isbn) => repository.lookupBookByIsbn(isbn);
}
