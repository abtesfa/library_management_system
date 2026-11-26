import '../entities/staff_member.dart';
import '../repositories/staff_repository.dart';

class GetAllStaff {
  final StaffRepository repository;

  const GetAllStaff(this.repository);

  Future<List<StaffMember>> call() => repository.getAllStaff();
}
