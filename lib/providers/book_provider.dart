import 'package:flutter/material.dart';
import '../models/book.dart';

class BookProvider extends ChangeNotifier {
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Initial books directly matching your UI mockups
  final List<Book> _allBooks = const [
    Book(
      id: '1',
      title: 'Atomic Habits',
      author: 'James Clear',
      isbn: '978-0735211292',
      category: 'Self-Help',
      totalCopies: 5,
      availableCopies: 3,
      shelfLocation: 'Shelf A1',
    ),
    Book(
      id: '2',
      title: 'Dune',
      author: 'Frank Herbert',
      isbn: '978-0441013593',
      category: 'Science Fiction',
      totalCopies: 4,
      availableCopies: 1,
      shelfLocation: 'Shelf B2',
    ),
    Book(
      id: '3',
      title: 'The Great Gatsby',
      author: 'F. Scott Fitzgerald',
      isbn: '978-0743273567',
      category: 'Fiction',
      totalCopies: 6,
      availableCopies: 6,
      shelfLocation: 'Shelf C3',
    ),
    Book(
      id: '4',
      title: 'Clean Code',
      author: 'Robert C. Martin',
      isbn: '978-0132350884',
      category: 'Computer Science',
      totalCopies: 3,
      availableCopies: 2,
      shelfLocation: 'Shelf D1',
    ),
    Book(
      id: '5',
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      isbn: '978-0062316097',
      category: 'History',
      totalCopies: 5,
      availableCopies: 4,
      shelfLocation: 'Shelf E2',
    ),
  ];

  List<Book> get recommendedBooks {
    if (_searchQuery.isEmpty) return _allBooks;
    final query = _searchQuery.toLowerCase();
    return _allBooks.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.category.toLowerCase().contains(query) ||
          book.isbn.contains(query);
    }).toList();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void reserveBook(String bookId) {
    // Will be wired to reservation_service.dart in subsequent steps
    notifyListeners();
  }
}