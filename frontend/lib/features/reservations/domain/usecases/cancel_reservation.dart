import '../repositories/reservation_repository.dart';

class CancelReservation {
  final ReservationRepository repository;

  const CancelReservation(this.repository);

  Future<void> call(String studentId, String reservationId) =>
      repository.cancelReservation(studentId, reservationId);
}
