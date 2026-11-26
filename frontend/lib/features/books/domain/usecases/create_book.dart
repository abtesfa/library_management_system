import '../repositories/book_repository.dart';

class CreateBook {
  final BookRepository repository;

  const CreateBook(this.repository);

  Future<Map<String, dynamic>> call(Map<String, dynamic> bookData) =>
      repository.createBook(bookData);
}
