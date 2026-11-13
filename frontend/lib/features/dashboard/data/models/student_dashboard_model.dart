import '../../domain/entities/student_dashboard.dart';

/// JSON-aware version of [StudentDashboard] used by the data layer.
class StudentDashboardModel extends StudentDashboard {
  StudentDashboardModel({
    required super.fullName,
    required super.currentlyBorrowed,
    required super.dueThisWeek,
    required super.booksReadThisYear,
  });

  factory StudentDashboardModel.fromJson(Map<String, dynamic> json) {
    return StudentDashboardModel(
      fullName: json['fullName'] ?? '',
      currentlyBorrowed: json['currentlyBorrowed'] ?? 0,
      dueThisWeek: json['dueThisWeek'] ?? 0,
      booksReadThisYear: json['booksReadThisYear'] ?? 0,
    );
  }
}
