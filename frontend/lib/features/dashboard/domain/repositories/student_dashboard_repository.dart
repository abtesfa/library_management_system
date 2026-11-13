import '../entities/student_dashboard.dart';

abstract class StudentDashboardRepository {
  Future<StudentDashboard> getDashboard(int studentId);
}
