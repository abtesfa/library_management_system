enum CirculationStatus {
  active,
  dueSoon,
  overdue,
  returned,
}

class BorrowRecord {
  final String id;
  final String bookTitle;
  final String author;
  final String category;
  final String isbn;
  final String borrowedDate;
  final String dueDate;
  final String? returnedDate;
  final String dueCountdown;
  final CirculationStatus status;
  final String? coverUrl;

  const BorrowRecord({
    required this.id,
    required this.bookTitle,
    required this.author,
    required this.category,
    required this.isbn,
    required this.borrowedDate,
    required this.dueDate,
    this.returnedDate,
    required this.dueCountdown,
    required this.status,
    this.coverUrl,
  });
}