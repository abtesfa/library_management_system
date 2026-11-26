import '../entities/book.dart';

/// Finds a book by exact ISBN, exact title, or partial title.
class FindBook {
  const FindBook();

  Book? call(List<Book> books, String query) {
    final search = query.trim().toLowerCase();

    if (search.isEmpty) return null;

    final matchers = <bool Function(Book)>[
      (book) => book.isbn.trim().toLowerCase() == search,
      (book) => book.title.trim().toLowerCase() == search,
      (book) => book.title.toLowerCase().contains(search),
    ];

    for (final matches in matchers) {
      for (final book in books) {
        if (matches(book)) {
          return book;
        }
      }
    }

    return null;
  }
}
