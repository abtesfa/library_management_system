import '../entities/student_dashboard.dart';
import '../repositories/student_dashboard_repository.dart';

class GetStudentDashboard {
  final StudentDashboardRepository repository;

  const GetStudentDashboard(this.repository);

  Future<StudentDashboard> call(int studentId) =>
      repository.getDashboard(studentId);
}
