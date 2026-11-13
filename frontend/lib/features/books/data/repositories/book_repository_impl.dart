import '../../domain/entities/book.dart';
import '../../domain/entities/book_metadata.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/google_books_remote_data_source.dart';
import '../datasources/book_remote_data_source.dart';

class BookRepositoryImpl implements BookRepository {
  final BookRemoteDataSource remoteDataSource;
  final GoogleBooksRemoteDataSource googleBooksDataSource;

  const BookRepositoryImpl(
    this.remoteDataSource,
    this.googleBooksDataSource,
  );

  @override
  Future<List<Book>> getAllBooks() => remoteDataSource.getAllBooks();

  @override
  Future<Map<String, dynamic>> createBook(Map<String, dynamic> bookData) =>
      remoteDataSource.createBook(bookData);

  @override
  Future<void> updateBook(String bookId, Map<String, dynamic> bookData) =>
      remoteDataSource.updateBook(bookId, bookData);

  @override
  Future<void> deleteBook(String bookId) => remoteDataSource.deleteBook(bookId);

  @override
  Future<List<dynamic>> getCategories() => remoteDataSource.getCategories();

  @override
  Future<BookMetadata?> lookupBookByIsbn(String isbn) =>
      googleBooksDataSource.lookupByIsbn(isbn);
}
