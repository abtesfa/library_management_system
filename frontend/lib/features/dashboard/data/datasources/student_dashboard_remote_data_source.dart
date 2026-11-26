import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../models/student_dashboard_model.dart';

class StudentDashboardRemoteDataSource {
  final String baseUrl = ApiConfig.baseUrl;

  Future<StudentDashboardModel> getDashboard(int studentId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/students/$studentId/dashboard'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return StudentDashboardModel.fromJson(data);
    } else {
      throw Exception(
        'Failed to load student dashboard: ${response.statusCode}',
      );
    }
  }
}
