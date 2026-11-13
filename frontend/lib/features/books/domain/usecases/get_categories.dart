import '../repositories/book_repository.dart';

class GetCategories {
  final BookRepository repository;

  const GetCategories(this.repository);

  Future<List<dynamic>> call() => repository.getCategories();
}
