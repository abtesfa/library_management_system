import '../../domain/entities/staff_member.dart';
import '../../domain/repositories/staff_repository.dart';
import '../datasources/staff_remote_data_source.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffRemoteDataSource remoteDataSource;

  const StaffRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<StaffMember>> getAllStaff() => remoteDataSource.getAllStaff();

  @override
  Future<StaffMember> addStaff(StaffMember staff) =>
      remoteDataSource.addStaff(staff);

  @override
  Future<StaffMember> updateStaff(String id, StaffMember staff) =>
      remoteDataSource.updateStaff(id, staff);

  @override
  Future<void> updateStaffStatus(String id, String status) =>
      remoteDataSource.updateStaffStatus(id, status);
}
