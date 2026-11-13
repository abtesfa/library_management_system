import '../entities/library_notification.dart';

abstract class NotificationRepository {
  /// Loads notifications addressed to librarians (only unread ones when
  /// [unread] is true).
  Future<List<LibraryNotification>> getNotifications({bool unread = false});

  /// Marks a notification as read.
  Future<void> markAsRead(int id);
}
