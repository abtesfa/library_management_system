import '../entities/reservation_record.dart';
import '../repositories/reservation_repository.dart';

class GetReservations {
  final ReservationRepository repository;

  const GetReservations(this.repository);

  Future<List<ReservationRecord>> call(String studentId) =>
      repository.getReservations(studentId);
}
