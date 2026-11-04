
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/borrow_record.dart';

class ReservationService {
  final String baseUrl = 'http://localhost:8080/api';

  // 1. CREATE RESERVATION
  Future<void> createReservation({
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
      throw Exception(
        'Reservation failed: ${response.body}',
      );
    }
  }

  // 2. GET STUDENT RESERVATIONS
  Future<List<ReservationRecord>> getReservations(
    String studentId,
  ) async {
    final url = Uri.parse(
      '$baseUrl/students/$studentId/reservations',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data.map<ReservationRecord>((item) {
        return ReservationRecord.fromJson(
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

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to cancel reservation: ${response.body}',
      );
    }
  }
}
