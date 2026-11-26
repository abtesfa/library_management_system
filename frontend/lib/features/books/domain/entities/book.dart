class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String category;
  final int totalCopies;
  final int availableCopies;

  /// Shelf copies held for students who reserved them.
  final int reservedCopies;
  final String status;
  final String location;
  final String? coverTheme;
  final String? publisher;
  final String? edition;
  final int? publicationYear;
  final String? description;
  final String? coverImage;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.category,
    required this.totalCopies,
    required this.availableCopies,
    this.reservedCopies = 0,
    required this.status,
    required this.location,
    this.coverTheme,
    this.publisher,
    this.edition,
    this.publicationYear,
    this.description,
    this.coverImage,
  });

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    String? category,
    int? totalCopies,
    int? availableCopies,
    int? reservedCopies,
    String? status,
    String? location,
    String? coverTheme,
    String? publisher,
    String? edition,
    int? publicationYear,
    String? description,
    String? coverImage,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      category: category ?? this.category,
      totalCopies: totalCopies ?? this.totalCopies,
      availableCopies: availableCopies ?? this.availableCopies,
      reservedCopies: reservedCopies ?? this.reservedCopies,
      status: status ?? this.status,
      location: location ?? this.location,
      coverTheme: coverTheme ?? this.coverTheme,
      publisher: publisher ?? this.publisher,
      edition: edition ?? this.edition,
      publicationYear: publicationYear ?? this.publicationYear,
      description: description ?? this.description,
      coverImage: coverImage ?? this.coverImage,
    );
  }
}
