import '../entities/library_notification.dart';
import '../repositories/notification_repository.dart';

class GetNotifications {
  final NotificationRepository repository;

  const GetNotifications(this.repository);

  Future<List<LibraryNotification>> call({
    String? type,
    bool unread = false,
    String? position,
  }) async {
    var notifications = await repository.getNotifications(unread: unread, position: position);

    // Apply an optional type filter.
    if (type != null && type.isNotEmpty) {
      notifications = notifications
          .where((item) => item.notificationType == type)
          .toList();
    }

    return notifications;
  }
}
