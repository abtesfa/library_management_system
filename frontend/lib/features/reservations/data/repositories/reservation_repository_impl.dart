import '../../domain/entities/reservation_record.dart';
import '../../domain/repositories/reservation_repository.dart';
import '../datasources/reservation_remote_data_source.dart';

class ReservationRepositoryImpl implements ReservationRepository {
  final ReservationRemoteDataSource remoteDataSource;

  const ReservationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Map<String, dynamic>> createReservation({
    required String studentId,
    required int bookId,
  }) {
    return remoteDataSource.createReservation(
      studentId: studentId,
      bookId: bookId,
    );
  }

  @override
  Future<List<ReservationRecord>> getReservations(String studentId) =>
      remoteDataSource.getReservations(studentId);

  @override
  Future<void> cancelReservation(String studentId, String reservationId) =>
      remoteDataSource.cancelReservation(studentId, reservationId);
}
