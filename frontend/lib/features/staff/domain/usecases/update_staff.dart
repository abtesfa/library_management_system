import '../entities/staff_member.dart';
import '../repositories/staff_repository.dart';

class UpdateStaff {
  final StaffRepository repository;

  const UpdateStaff(this.repository);

  Future<StaffMember> call(String id, StaffMember staff) =>
      repository.updateStaff(id, staff);
}
