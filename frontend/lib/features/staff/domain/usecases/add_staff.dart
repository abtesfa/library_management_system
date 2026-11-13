import '../entities/staff_member.dart';
import '../repositories/staff_repository.dart';

class AddStaff {
  final StaffRepository repository;

  const AddStaff(this.repository);

  Future<StaffMember> call(StaffMember staff) => repository.addStaff(staff);
}
