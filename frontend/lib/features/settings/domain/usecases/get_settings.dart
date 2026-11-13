import '../repositories/settings_repository.dart';

class GetSettings {
  final SettingsRepository repository;

  const GetSettings(this.repository);

  Future<Map<String, dynamic>> call() => repository.getSettings();
}
