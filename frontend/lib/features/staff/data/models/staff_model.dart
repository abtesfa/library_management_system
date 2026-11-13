import '../../domain/entities/staff_member.dart';

/// JSON-aware version of [StaffMember] used by the data layer.
class StaffModel extends StaffMember {
  StaffModel({
    required super.id,
    required super.name,
    required super.email,
    required super.role,
    required super.status,
    super.position,
    super.phoneNumber,
    super.permissions,
  });

  /// Copies a domain [StaffMember] so it can be sent to the backend.
  factory StaffModel.fromEntity(StaffMember staff) {
    return StaffModel(
      id: staff.id,
      name: staff.name,
      email: staff.email,
      role: staff.role,
      status: staff.status,
      position: staff.position,
      phoneNumber: staff.phoneNumber,
      permissions: staff.permissions,
    );
  }

  // Convert backend JSON into a StaffModel.
  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
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

  // Convert the staff member into backend JSON.
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
}
