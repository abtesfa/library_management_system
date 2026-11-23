
class SystemSettings {
  final String libraryName;
  final int maxBooksPerStudent;
  final int maxBorrowDays;
  final int renewalLimit;
  final double finePerDay;
  final int reservationHoldMinutes;
  final String? logoUrl;

  SystemSettings({
    this.libraryName = 'Central Academic Library',
    this.maxBooksPerStudent = 3,
    this.maxBorrowDays = 0,
    this.renewalLimit = 1,
    this.finePerDay = 0.50,
    this.reservationHoldMinutes = 1440,
    this.logoUrl,
  });

  factory SystemSettings.defaultSettings() {
    return SystemSettings();
  }

  SystemSettings copyWith({
    String? libraryName,
    int? maxBooksPerStudent,
    int? maxBorrowDays,
    int? renewalLimit,
    double? finePerDay,
    int? reservationHoldMinutes,
    String? logoUrl,
    bool clearLogo = false,
  }) {
    return SystemSettings(
      libraryName: libraryName ?? this.libraryName,
      maxBooksPerStudent:
          maxBooksPerStudent ?? this.maxBooksPerStudent,
      maxBorrowDays: maxBorrowDays ?? this.maxBorrowDays,
      renewalLimit: renewalLimit ?? this.renewalLimit,
      finePerDay: finePerDay ?? this.finePerDay,
      reservationHoldMinutes:
          reservationHoldMinutes ?? this.reservationHoldMinutes,
      logoUrl: clearLogo ? null : (logoUrl ?? this.logoUrl),
    );
  }
}
