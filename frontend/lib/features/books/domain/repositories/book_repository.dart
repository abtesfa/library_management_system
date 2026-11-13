import '../entities/book.dart';
import '../entities/book_metadata.dart';

abstract class BookRepository {
  /// Loads every book from the backend.
  Future<List<Book>> getAllBooks();

  /// Adds a new book and its physical copies.
  Future<Map<String, dynamic>> createBook(Map<String, dynamic> bookData);

  /// Updates a book's details.
  Future<void> updateBook(String bookId, Map<String, dynamic> bookData);

  /// Permanently deletes a book, its copies, and related circulation history.
  Future<void> deleteBook(String bookId);

  /// Loads the categories a new book can be filed under.
  Future<List<dynamic>> getCategories();

  /// Looks up book details from a public ISBN metadata provider.
  Future<BookMetadata?> lookupBookByIsbn(String isbn);
}
