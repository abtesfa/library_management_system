import '../repositories/settings_repository.dart';

class UpdateSettings {
  final SettingsRepository repository;

  const UpdateSettings(this.repository);

  Future<Map<String, dynamic>> call({
    required String libraryName,
    required int maxBooksPerStudent,
    required int maxBorrowingDays,
    required int renewalLimit,
    required double finePerDay,
    required int reservationHoldMinutes,
    required String schoolEmail,
    required String schoolLocation,
  }) {
    return repository.updateSettings(
      libraryName: libraryName,
      maxBooksPerStudent: maxBooksPerStudent,
      maxBorrowingDays: maxBorrowingDays,
      renewalLimit: renewalLimit,
      finePerDay: finePerDay,
      reservationHoldMinutes: reservationHoldMinutes,
      schoolEmail: schoolEmail,
      schoolLocation: schoolLocation,
    );
  }
}
