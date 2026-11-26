import '../../domain/entities/book.dart';

/// JSON-aware version of [Book] used by the data layer.
class BookModel extends Book {
  BookModel({
    required super.id,
    required super.title,
    required super.author,
    required super.isbn,
    required super.category,
    required super.totalCopies,
    required super.availableCopies,
    required super.reservedCopies,
    required super.status,
    required super.location,
    super.coverTheme,
    super.publisher,
    super.edition,
    super.publicationYear,
    super.description,
    super.coverImage,
  });

  factory BookModel.fromJson(Map<String, dynamic> json) {
    return BookModel(
      id: (json['id'] ?? json['bookId'] ?? json['Book_ID'])?.toString() ?? '',
      title: json['title']?.toString() ?? json['Title']?.toString() ?? '',
      author: json['author']?.toString() ?? 'Unknown Author',

      // Support different ISBN field names from the backend.
      isbn: (json['isbn'] ??
              json['ISBN'] ??
              json['iSBN'] ??
              json['bookIsbn'] ??
              '')
          .toString()
          .trim(),

      category: json['category']?.toString() ?? 'General',
      totalCopies: (json['totalCopies'] as num?)?.toInt() ?? 0,
      availableCopies: (json['availableCopies'] as num?)?.toInt() ?? 0,
      reservedCopies: (json['reservedCopies'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString() ?? 'Unknown',
      location: json['location']?.toString() ?? 'Not assigned',
      coverTheme: json['coverTheme']?.toString(),
      publisher: json['publisher']?.toString(),
      edition: json['edition']?.toString(),
      publicationYear: (json['publicationYear'] as num?)?.toInt(),
      description: json['description']?.toString(),
      coverImage:
          json['coverImage']?.toString() ?? json['coverTheme']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'isbn': isbn,
      'category': category,
      'totalCopies': totalCopies,
      'availableCopies': availableCopies,
      'reservedCopies': reservedCopies,
      'status': status,
      'location': location,
      'coverTheme': coverTheme,
      'publisher': publisher,
      'edition': edition,
      'publicationYear': publicationYear,
      'description': description,
      'coverImage': coverImage,
    };
  }
}
