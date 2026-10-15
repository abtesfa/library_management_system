enum ReservationStatus {
  active,
  readyForPickup,
  upcoming,
  completed,
  cancelled,
}

class Reservation {
  final String id;
  final String bookTitle;
  final String author;
  final String category;
  final String isbn;
  final String reservedDate;
  final String pickupByDate;
  final String pickupLocation;
  final String countdownText;
  final ReservationStatus status;
  final String? completedDate;
  final String? coverUrl;

  const Reservation({
    required this.id,
    required this.bookTitle,
    required this.author,
    required this.category,
    required this.isbn,
    required this.reservedDate,
    required this.pickupByDate,
    required this.pickupLocation,
    required this.countdownText,
    required this.status,
    this.completedDate,
    this.coverUrl,
  });
}
