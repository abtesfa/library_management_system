import '../repositories/staff_repository.dart';

class UpdateStaffStatus {
  final StaffRepository repository;

  const UpdateStaffStatus(this.repository);

  Future<void> call(String id, String status) =>
      repository.updateStaffStatus(id, status);
}
