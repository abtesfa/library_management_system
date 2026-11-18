class BookMetadata {
  final String isbn;
  final String title;
  final String author;
  final String? publisher;
  final String? edition;
  final int? publicationYear;
  final String? description;
  final String? coverImage;
  final List<String> subjects;

  const BookMetadata({
    required this.isbn,
    required this.title,
    required this.author,
    this.publisher,
    this.edition,
    this.publicationYear,
    this.description,
    this.coverImage,
    this.subjects = const [],
  });
}
