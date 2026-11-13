import '../entities/system_settings.dart';

abstract class SettingsRepository {
  /// Settings exactly as the backend sends them. The admin settings form
  /// needs fields (daily limit, renewal limit) that [SystemSettings] does not
  /// carry yet.
  Future<Map<String, dynamic>> getSettings();

  /// Settings in the shape the rest of the app uses.
  Future<SystemSettings> getSystemSettings();

  Future<Map<String, dynamic>> updateSettings({
    required String libraryName,
    required int maxBooksPerDay,
    required int maxBorrowingDays,
    required int renewalLimit,
    required double finePerDay,
    required int reservationHoldMinutes,
  });
}
