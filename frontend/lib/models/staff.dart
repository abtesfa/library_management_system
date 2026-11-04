
class StaffMember {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? position;
  final String status;
  final String phoneNumber;
  final Set<String> permissions;

  // Kept for compatibility with existing mock data.
  final String? employeeId;

  StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.position,
    this.phoneNumber = '',
    this.employeeId,
    Set<String>? permissions,
    bool canAddBooks = true,
    bool canWaiveFines = false,
    bool canManageStaff = false,
  }) : permissions = permissions ??
            {
              if (canAddBooks) 'ADD_BOOK',
              if (canWaiveFines) 'WAIVE_FINE',
              if (canManageStaff) 'MANAGE_STAFF',
            };

  // Convert backend JSON into a Flutter StaffMember.
  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['staffId']?.toString() ?? '',
      name: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      role: json['role'] ?? 'LIBRARIAN',
      position: json['position'],
      status: json['status'] ?? 'ACTIVE',
      permissions: Set<String>.from(
        json['permissions'] ?? [],
      ),
    );
  }

  // Convert Flutter StaffMember into backend JSON.
  Map<String, dynamic> toJson() {
    return {
      'fullName': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'role': role,
      'position': role == 'LIBRARIAN' ? position : null,
      'status': status.toUpperCase(),
      'permissions': role == 'LIBRARIAN'
          ? permissions.toList()
          : <String>[],
    };
  }

  bool get canAddBooks => permissions.contains('ADD_BOOK');

  bool get canWaiveFines => permissions.contains('WAIVE_FINE');

  bool get canManageStaff => permissions.contains('MANAGE_STAFF');
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
