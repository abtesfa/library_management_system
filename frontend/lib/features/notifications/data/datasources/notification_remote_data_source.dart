import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/api_config.dart';
import '../models/library_notification_model.dart';

class NotificationRemoteDataSource {
  static const String baseUrl = '${ApiConfig.baseUrl}/notifications';

  // Load notifications addressed to librarians.
  Future<List<LibraryNotificationModel>> getNotifications({
    bool unread = false,
  }) async {
    final endpoint = unread ? '$baseUrl/librarian/unread' : '$baseUrl/librarian';

    final response = await http.get(Uri.parse(endpoint));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      return data
          .map((item) => LibraryNotificationModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();
    }

    throw Exception(
      'Failed to load librarian notifications: '
      '${response.statusCode} ${response.body}',
    );
  }

  // Mark a notification as read.
  Future<void> markAsRead(int id) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/$id/read'),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to mark notification as read: ${response.body}',
      );
    }
  }
}
