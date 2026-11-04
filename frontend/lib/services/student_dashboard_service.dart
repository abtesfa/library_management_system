
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/student_dashboard.dart';

class StudentDashboardService {
  final String baseUrl = 'http://localhost:8080/api';

  Future<StudentDashboard> getDashboard(int studentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/students/$studentId/dashboard'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return StudentDashboard.fromJson(data);
    } else {
      throw Exception(
        'Failed to load student dashboard: ${response.statusCode}',
      );
    }
  }
}
