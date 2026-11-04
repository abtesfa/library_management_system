class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String category;
  final int totalCopies;
  final int availableCopies;
  final String status;
  final String location;
  final String? coverTheme;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.isbn,
    required this.category,
    required this.totalCopies,
    required this.availableCopies,
    required this.status,
    required this.location,
    this.coverTheme,
  });

 factory Book.fromJson(Map<String, dynamic> json) {
  return Book(
    id: (json['id'] ?? json['bookId'] ?? json['Book_ID'])
            ?.toString() ??
        '',
    title: json['title']?.toString() ??
        json['Title']?.toString() ??
        '',
    author: json['author']?.toString() ??
        'Unknown Author',

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
    availableCopies:
        (json['availableCopies'] as num?)?.toInt() ?? 0,
    status: json['status']?.toString() ?? 'Unknown',
    location: json['location']?.toString() ?? 'Not assigned',
    coverTheme: json['coverTheme']?.toString(),
  );
}
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    String? category,
    int? totalCopies,
    int? availableCopies,
    String? status,
    String? location,
    String? coverTheme,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      category: category ?? this.category,
      totalCopies: totalCopies ?? this.totalCopies,
      availableCopies: availableCopies ?? this.availableCopies,
      status: status ?? this.status,
      location: location ?? this.location,
      coverTheme: coverTheme ?? this.coverTheme,
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
      'status': status,
      'location': location,
      'coverTheme': coverTheme,
    };
  }
}