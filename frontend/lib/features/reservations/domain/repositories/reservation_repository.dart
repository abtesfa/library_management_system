import '../entities/reservation_record.dart';

abstract class ReservationRepository {
  Future<Map<String, dynamic>> createReservation({
    required String studentId,
    required int bookId,
  });

  Future<List<ReservationRecord>> getReservations(String studentId);

  Future<void> cancelReservation(String studentId, String reservationId);
}
