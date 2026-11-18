class SystemSettings {
  final String libraryName;
  final int maxBorrowDays;
  final double finePerDay;
  final int reservationHoldMinutes;

  SystemSettings({
    this.libraryName = 'Central Academic Library',
    this.maxBorrowDays = 0,
    this.finePerDay = 0.50,
    this.reservationHoldMinutes = 1440,
  });

  // Default settings
  factory SystemSettings.defaultSettings() {
    return SystemSettings();
  }

  // Create a copy with updated values
  SystemSettings copyWith({
    String? libraryName,
    int? maxBorrowDays,
    double? finePerDay,
    int? reservationHoldMinutes,
  }) {
    return SystemSettings(
      libraryName: libraryName ?? this.libraryName,
      maxBorrowDays: maxBorrowDays ?? this.maxBorrowDays,
      finePerDay: finePerDay ?? this.finePerDay,
      reservationHoldMinutes:
          reservationHoldMinutes ?? this.reservationHoldMinutes,
    );
  }
}
