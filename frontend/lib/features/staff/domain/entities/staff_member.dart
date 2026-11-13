class StaffMember {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? position;
  final String status;
  final String phoneNumber;
  final Set<String> permissions;

  StaffMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    this.position,
    this.phoneNumber = '',
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

  bool get canAddBooks => permissions.contains('ADD_BOOK');

  bool get canWaiveFines => permissions.contains('WAIVE_FINE');

  bool get canManageStaff => permissions.contains('MANAGE_STAFF');
}
