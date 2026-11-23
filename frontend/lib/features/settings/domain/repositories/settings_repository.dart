import '../entities/system_settings.dart';

abstract class SettingsRepository {
  /// Settings exactly as the backend sends them. The admin settings form reads the complete settings payload.
  Future<Map<String, dynamic>> getSettings();

  /// Settings in the shape the rest of the app uses.
  Future<SystemSettings> getSystemSettings();

  Future<Map<String, dynamic>> updateSettings({
    required String libraryName,
    required int maxBooksPerStudent,
    required int maxBorrowingDays,
    required int renewalLimit,
    required double finePerDay,
    required int reservationHoldMinutes,
  });
}
