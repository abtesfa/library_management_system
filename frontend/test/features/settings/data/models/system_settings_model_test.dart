import 'package:flutter_test/flutter_test.dart';
import 'package:library_management_system/features/settings/data/models/system_settings_model.dart';

void main() {
  test('uses the configured loan duration even when it exceeds 14 days', () {
    final settings = SystemSettingsModel.fromJson({
      'libraryName': 'North Campus Library',
      'maxBorrowingDays': 30,
      'finePerDay': 2.5,
      'reservationHoldMinutes': 120,
    });

    expect(settings.maxBorrowDays, 30);
    expect(settings.libraryName, 'North Campus Library');
  });

  test('fails when the backend omits the configured loan duration', () {
    expect(
      () => SystemSettingsModel.fromJson({'libraryName': 'Test Library'}),
      throwsFormatException,
    );
  });
}
