import '../repositories/settings_repository.dart';

class UpdateSettings {
  final SettingsRepository repository;

  const UpdateSettings(this.repository);

  Future<Map<String, dynamic>> call({
    required String libraryName,
    required int maxBooksPerDay,
    required int maxBorrowingDays,
    required int renewalLimit,
    required double finePerDay,
    required int reservationHoldMinutes,
  }) {
    return repository.updateSettings(
      libraryName: libraryName,
      maxBooksPerDay: maxBooksPerDay,
      maxBorrowingDays: maxBorrowingDays,
      renewalLimit: renewalLimit,
      finePerDay: finePerDay,
      reservationHoldMinutes: reservationHoldMinutes,
    );
  }
}
