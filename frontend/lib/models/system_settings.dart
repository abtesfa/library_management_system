class SystemSettings {
  final String libraryName;
  final String openingTime;
  final String closingTime;
  final int maxBorrowDays;
  final int maxBooksPerUser;
  final double finePerDay;
  final String contactEmail;
  final String contactPhone;
  

  SystemSettings({
    this.libraryName = 'Central Academic Library',
    this.openingTime = '08:00 AM',
    this.closingTime = '08:00 PM',
    this.maxBorrowDays = 14,
    this.maxBooksPerUser = 5,
    this.finePerDay = 0.50,
    this.contactEmail = 'info@librarysystem.com',
    this.contactPhone = '+251 11 123 4567',
    
  });

  factory SystemSettings.defaultSettings() {
    return SystemSettings();
  }

  SystemSettings copyWith({
    String? libraryName,
    String? openingTime,
    String? closingTime,
    int? maxBorrowDays,
    int? maxBooksPerUser,
    double? finePerDay,
    String? contactEmail,
    String? contactPhone,
  }) {
    return SystemSettings(
      libraryName: libraryName ?? this.libraryName,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      maxBorrowDays: maxBorrowDays ?? this.maxBorrowDays,
      maxBooksPerUser: maxBooksPerUser ?? this.maxBooksPerUser,
      finePerDay: finePerDay ?? this.finePerDay,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
    );
  }
}
