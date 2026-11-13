import '../entities/book.dart';
import '../entities/book_metadata.dart';

abstract class BookRepository {
  /// Loads every book from the backend.
  Future<List<Book>> getAllBooks();

  /// Adds a new book and its physical copies.
  Future<Map<String, dynamic>> createBook(Map<String, dynamic> bookData);

  /// Loads the categories a new book can be filed under.
  Future<List<dynamic>> getCategories();

  /// Looks up book details from a public ISBN metadata provider.
  Future<BookMetadata?> lookupBookByIsbn(String isbn);
}
