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
      id: json['id'].toString(),
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      isbn: json['isbn'] ?? '',
      category: json['category'] ?? 'General',
      totalCopies: json['totalCopies'] ?? 1,
      availableCopies: json['availableCopies'] ?? 1,
      status: json['status'] ?? 'Available',
      location: json['location'] ?? 'Shelf A1',
      coverTheme: json['coverTheme'],
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
