class ReservationRecord {
  final String id;
  final String bookId;
  final String bookTitle;
  final String author;
  final String reservedDate;
  final String? holdUntil;
  final String? pickupLocation;
  final String status;
  final int queuePosition;

  ReservationRecord({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.author,
    required this.reservedDate,
    this.holdUntil,
    this.pickupLocation,
    required this.status,
    this.queuePosition = 1,
  });
}
