import '../../domain/entities/student_dashboard.dart';
import '../../domain/repositories/student_dashboard_repository.dart';
import '../datasources/student_dashboard_remote_data_source.dart';

class StudentDashboardRepositoryImpl implements StudentDashboardRepository {
  final StudentDashboardRemoteDataSource remoteDataSource;

  const StudentDashboardRepositoryImpl(this.remoteDataSource);

  @override
  Future<StudentDashboard> getDashboard(int studentId) =>
      remoteDataSource.getDashboard(studentId);
}
