import '../entities/system_settings.dart';
import '../repositories/settings_repository.dart';

class GetSystemSettings {
  final SettingsRepository repository;

  const GetSystemSettings(this.repository);

  Future<SystemSettings> call() => repository.getSystemSettings();
}
