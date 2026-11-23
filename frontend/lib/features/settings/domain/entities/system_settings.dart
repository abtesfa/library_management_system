import 'dart:typed_data';

class SystemSettings {
  final String libraryName;
  final Uint8List? libraryLogo;
  final String openingTime;
  final String closingTime;
  final int maxBorrowDays;
  final int maxBooksPerStudent;
  final double finePerDay;
  final int reservationHoldMinutes;
  final String contactEmail;
  final String contactPhone;
  final String schoolEmail;
  final String schoolLocation;

  SystemSettings({
    this.libraryName = 'Central Academic Library',
    this.libraryLogo,
    this.openingTime = '08:00 AM',
    this.closingTime = '08:00 PM',
    this.maxBorrowDays = 14,
    this.maxBooksPerStudent = 5,
    this.finePerDay = 0.50,
    this.reservationHoldMinutes = 1440,
    this.contactEmail = 'info@librarysystem.com',
    this.contactPhone = '+251 11 123 4567',
    this.schoolEmail = 'centralacademy@example.com',
    this.schoolLocation = '5kilo, Addis Ababa',
  });

  // Default settings
  factory SystemSettings.defaultSettings() {
    return SystemSettings();
  }

  // Create a copy with updated values
  SystemSettings copyWith({
    String? libraryName,
    Uint8List? libraryLogo,
    String? openingTime,
    String? closingTime,
    int? maxBorrowDays,
    int? maxBooksPerStudent,
    double? finePerDay,
    int? reservationHoldMinutes,
    String? contactEmail,
    String? contactPhone,
    String? schoolEmail,
    String? schoolLocation,
  }) {
    return SystemSettings(
      libraryName: libraryName ?? this.libraryName,
      libraryLogo: libraryLogo ?? this.libraryLogo,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      maxBorrowDays: maxBorrowDays ?? this.maxBorrowDays,
      maxBooksPerStudent: maxBooksPerStudent ?? this.maxBooksPerStudent,
      finePerDay: finePerDay ?? this.finePerDay,
      reservationHoldMinutes:
          reservationHoldMinutes ?? this.reservationHoldMinutes,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      schoolEmail: schoolEmail ?? this.schoolEmail,
      schoolLocation: schoolLocation ?? this.schoolLocation,
    );
  }
}
