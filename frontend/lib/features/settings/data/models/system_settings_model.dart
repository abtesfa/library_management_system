
import '../../domain/entities/system_settings.dart';

class SystemSettingsModel extends SystemSettings {
  SystemSettingsModel({
    required super.libraryName,
    required super.maxBooksPerStudent,
    required super.maxBorrowDays,
    required super.renewalLimit,
    required super.finePerDay,
    required super.reservationHoldMinutes,
    super.logoUrl,
    super.contactEmail,
    super.libraryAddress,
  });

  factory SystemSettingsModel.fromJson(Map<String, dynamic> json) {
    final maxBorrowingDays = json['maxBorrowingDays'];

    if (maxBorrowingDays is! num) {
      throw const FormatException(
        'Settings response is missing maxBorrowingDays.',
      );
    }

    return SystemSettingsModel(
      libraryName:
          json['libraryName'] ?? 'Central Academic Library',
      maxBooksPerStudent:
          (json['maxBooksPerStudent'] as num?)?.toInt() ?? 3,
      maxBorrowDays: maxBorrowingDays.toInt(),
      renewalLimit: (json['renewalLimit'] as num?)?.toInt() ?? 1,
      finePerDay: (json['finePerDay'] as num?)?.toDouble() ?? 0.50,
      reservationHoldMinutes:
          (json['reservationHoldMinutes'] as num?)?.toInt() ?? 1440,
      logoUrl: json['logoUrl'] as String?,
      contactEmail: json['contactEmail']?.toString() ?? '',
      libraryAddress: json['libraryAddress']?.toString() ?? '',
    );
  }
}
