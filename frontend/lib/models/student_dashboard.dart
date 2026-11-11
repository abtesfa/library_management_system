
class StudentDashboard {
  final String fullName;
  final int currentlyBorrowed;
  final int dueThisWeek;
  final int booksReadThisYear;

  StudentDashboard({
    required this.fullName,
    required this.currentlyBorrowed,
    required this.dueThisWeek,
    required this.booksReadThisYear,
  });

  factory StudentDashboard.fromJson(Map<String, dynamic> json) {
    return StudentDashboard(
      fullName: json['fullName'] ?? '',
      currentlyBorrowed: json['currentlyBorrowed'] ?? 0,
      dueThisWeek: json['dueThisWeek'] ?? 0,
      booksReadThisYear: json['booksReadThisYear'] ?? 0,
    );
  }
}
