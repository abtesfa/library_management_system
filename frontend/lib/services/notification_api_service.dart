import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';

class NotificationApiService {
  static const String baseUrl =
      'http://localhost:8080/api/notifications';

  // Load notifications addressed to librarians.
  Future<List<LibraryNotification>> getNotifications({
    String? type,
    bool unread = false,
  }) async {
    final endpoint = unread ? '$baseUrl/librarian/unread' : '$baseUrl/librarian';

    final response = await http.get(Uri.parse(endpoint));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);

      List<LibraryNotification> notifications = data
          .map((item) => LibraryNotification.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList();

      // Apply an optional type filter on the Flutter side.
      if (type != null && type.isNotEmpty) {
        notifications = notifications
            .where((item) => item.notificationType == type)
            .toList();
      }

      return notifications;
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

  // Delete a notification.
  Future<void> deleteNotification(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/$id'),
    );

    if (response.statusCode != 204) {
      throw Exception(
        'Failed to delete notification: ${response.body}',
      );
    }
  }
}