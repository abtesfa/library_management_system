enum ReservationStatus { pending, ready, cancelled, fulfilled }

class Reservation {
  final String id;
  final String bookTitle;
  final String readerName;
  final DateTime reservationDate;
  final DateTime? expirationDate;
  final ReservationStatus status;

  const Reservation({
    required this.id,
    required this.bookTitle,
    required this.readerName,
    required this.reservationDate,
    this.expirationDate,
    this.status = ReservationStatus.pending,
  });

  Reservation copyWith({
    ReservationStatus? status,
    DateTime? expirationDate,
  }) {
    return Reservation(
      id: id,
      bookTitle: bookTitle,
      readerName: readerName,
      reservationDate: reservationDate,
      expirationDate: expirationDate ?? this.expirationDate,
      status: status ?? this.status,
    );
  }
}