import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../models/reservation_record_model.dart';

class ReservationRemoteDataSource {
  final String baseUrl = ApiConfig.baseUrl;

  // 1. CREATE RESERVATION
  Future<Map<String, dynamic>> createReservation({
    required String studentId,
    required int bookId,
  }) async {
    final url = Uri.parse(
      '$baseUrl/students/$studentId/reservations',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'bookId': bookId,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception(_errorMessage(response.body));
    }

    final decoded = jsonDecode(response.body);
    if (decoded is Map<String, dynamic>) return decoded;
    throw const FormatException(
      'Reservation response did not contain a JSON object.',
    );
  }

  // 2. GET STUDENT RESERVATIONS
  Future<List<ReservationRecordModel>> getReservations(
    String studentId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/students/$studentId/reservations',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map<ReservationRecordModel>((item) {
        return ReservationRecordModel.fromJson(
          Map<String, dynamic>.from(item as Map),
        );
      }).toList();
    }

    throw Exception(
      'Failed to load reservations: ${response.body}',
    );
  }

  // 3. CANCEL RESERVATION
  Future<void> cancelReservation(
    String studentId,
    String reservationId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/students/$studentId/reservations/$reservationId/cancel',
    );

    final response = await http.patch(url);

    // The backend answers 204 No Content on success.
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_errorMessage(response.body));
    }
  }

  // Pull the "message" field out of a backend error response.
  String _errorMessage(String body) {
    try {
      final data = jsonDecode(body);
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    } catch (_) {}
    return body;
  }
}
