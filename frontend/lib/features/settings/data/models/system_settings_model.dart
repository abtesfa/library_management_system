import '../../domain/entities/system_settings.dart';

/// JSON-aware version of [SystemSettings] used by the data layer.
class SystemSettingsModel extends SystemSettings {
  SystemSettingsModel({
    required super.libraryName,
    required super.openingTime,
    required super.closingTime,
    required super.maxBorrowDays,
    required super.maxBooksPerUser,
    required super.finePerDay,
    required super.reservationHoldMinutes,
    required super.contactEmail,
    required super.contactPhone,
  });

  // Convert backend JSON into a SystemSettingsModel
  factory SystemSettingsModel.fromJson(Map<String, dynamic> json) {
    return SystemSettingsModel(
      libraryName: json['libraryName'] ?? 'Central Academic Library',
      openingTime: json['openingTime'] ?? '08:00 AM',
      closingTime: json['closingTime'] ?? '08:00 PM',
      maxBorrowDays: (json['maxBorrowingDays'] as num?)?.toInt() ?? 14,
      maxBooksPerUser: (json['maxBooksPerUser'] as num?)?.toInt() ?? 5,
      finePerDay: (json['finePerDay'] as num?)?.toDouble() ?? 0.50,
      reservationHoldMinutes:
          (json['reservationHoldMinutes'] as num?)?.toInt() ?? 1440,
      contactEmail: json['contactEmail'] ?? 'info@librarysystem.com',
      contactPhone: json['contactPhone'] ?? '+251 11 123 4567',
    );
  }
}
