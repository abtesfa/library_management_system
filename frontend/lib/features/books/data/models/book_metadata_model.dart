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

  factory BookMetadataModel.fromOpenLibrarySearchJson(
    Map<String, dynamic> json,
    String isbn,
  ) {
    final authors = json['author_name'];
    final publishers = json['publisher'];
    final coverId = json['cover_i'];
    final title = json['title']?.toString() ?? '';
    final subtitle = json['subtitle']?.toString();

    return BookMetadataModel(
      isbn: isbn,
      title: subtitle == null || subtitle.isEmpty ? title : '$title: $subtitle',
      author: authors is List ? authors.join(', ') : '',
      publisher: publishers is List && publishers.isNotEmpty
          ? publishers.first.toString()
          : null,
      publicationYear:
          int.tryParse(json['first_publish_year']?.toString() ?? ''),
      coverImage: coverId == null
          ? null
          : 'https://covers.openlibrary.org/b/id/$coverId-L.jpg',
    );
  }
}
