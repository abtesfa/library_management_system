class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String category;
  final int totalCopies;
  final int availableCopies;
  final String? imageUrl;
  final String? shelfLocation;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.category,
    this.totalCopies = 1,
    this.availableCopies = 1,
    this.imageUrl,
    this.shelfLocation,
  });

  bool get isAvailable => availableCopies > 0;
}