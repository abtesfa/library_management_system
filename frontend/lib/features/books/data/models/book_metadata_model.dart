import '../../domain/entities/book_metadata.dart';

class BookMetadataModel extends BookMetadata {
  const BookMetadataModel({
    required super.isbn,
    required super.title,
    required super.author,
    super.publisher,
    super.edition,
    super.publicationYear,
    super.description,
    super.coverImage,
  });

  factory BookMetadataModel.fromGoogleBooksJson(
    Map<String, dynamic> json,
    String isbn,
  ) {
    final volumeInfo = json['volumeInfo'];
    if (volumeInfo is! Map<String, dynamic>) {
      throw const FormatException('Book lookup returned invalid details.');
    }

    final authors = volumeInfo['authors'];
    final publishedDate = volumeInfo['publishedDate']?.toString();
    final yearMatch = publishedDate == null
        ? null
        : RegExp(r'\d{4}').firstMatch(publishedDate);
    final imageLinks = volumeInfo['imageLinks'];
    final rawImage = imageLinks is Map<String, dynamic>
        ? (imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'])
        : null;

    return BookMetadataModel(
      isbn: isbn,
      title: volumeInfo['title']?.toString() ?? '',
      author: authors is List && authors.isNotEmpty ? authors.join(', ') : '',
      publisher: volumeInfo['publisher']?.toString(),
      publicationYear:
          yearMatch == null ? null : int.tryParse(yearMatch.group(0)!),
      description: volumeInfo['description']?.toString(),
      coverImage: rawImage?.toString().replaceFirst('http://', 'https://'),
    );
  }
}
