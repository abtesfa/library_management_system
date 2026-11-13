import '../entities/staff_member.dart';

abstract class StaffRepository {
  /// Fetches all staff members.
  Future<List<StaffMember>> getAllStaff();

  /// Adds a new staff member.
  Future<StaffMember> addStaff(StaffMember staff);

  /// Updates an existing staff member.
  Future<StaffMember> updateStaff(String id, StaffMember staff);

  /// Changes a staff member's status.
  Future<void> updateStaffStatus(String id, String status);
}
