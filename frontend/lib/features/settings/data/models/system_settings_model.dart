import 'dart:convert';
import '../../domain/entities/system_settings.dart';

/// JSON-aware version of [SystemSettings] used by the data layer.
class SystemSettingsModel extends SystemSettings {
  SystemSettingsModel({
    required super.libraryName,
    super.libraryLogo,
    required super.openingTime,
    required super.closingTime,
    required super.maxBorrowDays,
    required super.maxBooksPerStudent,
    required super.finePerDay,
    required super.reservationHoldMinutes,
    required super.contactEmail,
    required super.contactPhone,
    required super.schoolEmail,
    required super.schoolLocation,
  });

  // Convert backend JSON into a SystemSettingsModel
  factory SystemSettingsModel.fromJson(Map<String, dynamic> json) {
    return SystemSettingsModel(
      libraryName: json['libraryName'] ?? 'Central Academic Library',
      libraryLogo: json['libraryLogo'] == null ? null : base64Decode(json['libraryLogo'].toString()),
      openingTime: json['openingTime'] ?? '08:00 AM',
      closingTime: json['closingTime'] ?? '08:00 PM',
      maxBorrowDays: (json['maxBorrowingDays'] as num?)?.toInt() ?? 14,
      maxBooksPerStudent: (json['maxBooksPerStudent'] as num?)?.toInt() ?? 5,
      finePerDay: (json['finePerDay'] as num?)?.toDouble() ?? 0.50,
      reservationHoldMinutes:
          (json['reservationHoldMinutes'] as num?)?.toInt() ?? 1440,
      contactEmail: json['contactEmail'] ?? 'info@librarysystem.com',
      contactPhone: json['contactPhone'] ?? '+251 11 123 4567',
      schoolEmail: json['schoolEmail'] ?? 'centralacademy@example.com',
      schoolLocation: json['schoolLocation'] ?? '5kilo, Addis Ababa',
    );
  }
}
