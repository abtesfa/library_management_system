import '../../domain/entities/system_settings.dart';

/// JSON-aware version of [SystemSettings] used by the data layer.
class SystemSettingsModel extends SystemSettings {
  SystemSettingsModel({
    required super.libraryName,
    required super.maxBorrowDays,
    required super.finePerDay,
    required super.reservationHoldMinutes,
  });

  // Convert backend JSON into a SystemSettingsModel
  factory SystemSettingsModel.fromJson(Map<String, dynamic> json) {
    final maxBorrowingDays = json['maxBorrowingDays'];
    if (maxBorrowingDays is! num) {
      throw const FormatException(
        'Settings response is missing maxBorrowingDays.',
      );
    }

    return SystemSettingsModel(
      libraryName: json['libraryName'] ?? 'Central Academic Library',
      maxBorrowDays: maxBorrowingDays.toInt(),
      finePerDay: (json['finePerDay'] as num?)?.toDouble() ?? 0.50,
      reservationHoldMinutes:
          (json['reservationHoldMinutes'] as num?)?.toInt() ?? 1440,
    );
  }
}
