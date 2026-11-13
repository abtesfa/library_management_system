import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../../domain/entities/staff_member.dart';
import '../models/staff_model.dart';

class StaffRemoteDataSource {
  static const String baseUrl = '${ApiConfig.baseUrl}/staff';

  // GET: Fetch all staff members
  Future<List<StaffModel>> getAllStaff() async {
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((json) => StaffModel.fromJson(json))
          .toList();
    } else {
      throw Exception(
        'Failed to load staff: ${response.statusCode} ${response.body}',
      );
    }
  }

  // POST: Add a new staff member
  Future<StaffModel> addStaff(StaffMember staff) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(StaffModel.fromEntity(staff).toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return StaffModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to add staff: ${response.statusCode} ${response.body}',
      );
    }
  }

  // PUT: Update an existing staff member
  Future<StaffModel> updateStaff(
    String id,
    StaffMember staff,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(StaffModel.fromEntity(staff).toJson()),
    );

    if (response.statusCode == 200) {
      return StaffModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
        'Failed to update staff: ${response.statusCode} ${response.body}',
      );
    }
  }

  // PATCH: Change staff status
  Future<void> updateStaffStatus(
    String id,
    String status,
  ) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': status.toUpperCase()}),
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
        'Failed to update status: ${response.statusCode} ${response.body}',
      );
    }
  }
}
