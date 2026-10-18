class StaffMember {
  final String id;
  final String name;
  final String employeeId;
  final String role;
  final String email;
  final String status; // 'Active', 'Inactive'
  final bool canAddBooks;
  final bool canWaiveFines;
  final bool canManageStaff;

  StaffMember({
    required this.id,
    required this.name,
    required this.employeeId,
    required this.role,
    required this.email,
    required this.status,
    this.canAddBooks = true,
    this.canWaiveFines = false,
    this.canManageStaff = false,
  });
}

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
}
