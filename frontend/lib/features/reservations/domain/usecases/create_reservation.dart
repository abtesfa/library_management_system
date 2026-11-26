import '../repositories/reservation_repository.dart';

class CreateReservation {
  final ReservationRepository repository;

  const CreateReservation(this.repository);

  Future<Map<String, dynamic>> call({
    required String studentId,
    required int bookId,
  }) {
    return repository.createReservation(
      studentId: studentId,
      bookId: bookId,
    );
  }
}
