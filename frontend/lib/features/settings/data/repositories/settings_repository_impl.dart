import '../../domain/entities/system_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_remote_data_source.dart';
import '../models/system_settings_model.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsRemoteDataSource remoteDataSource;

  const SettingsRepositoryImpl(this.remoteDataSource);

  @override
  Future<Map<String, dynamic>> getSettings() => remoteDataSource.getSettings();

  @override
  Future<SystemSettings> getSystemSettings() async {
    final json = await remoteDataSource.getSettings();
    return SystemSettingsModel.fromJson(json);
  }

  @override
  Future<Map<String, dynamic>> updateSettings({
    required String libraryName,
    required int maxBooksPerDay,
    required int maxBorrowingDays,
    required int renewalLimit,
    required double finePerDay,
    required int reservationHoldMinutes,
  }) {
    return remoteDataSource.updateSettings(
      libraryName: libraryName,
      maxBooksPerDay: maxBooksPerDay,
      maxBorrowingDays: maxBorrowingDays,
      renewalLimit: renewalLimit,
      finePerDay: finePerDay,
      reservationHoldMinutes: reservationHoldMinutes,
    );
  }
}
