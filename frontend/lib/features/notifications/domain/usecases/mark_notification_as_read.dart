import '../repositories/notification_repository.dart';

class MarkNotificationAsRead {
  final NotificationRepository repository;

  const MarkNotificationAsRead(this.repository);

  Future<void> call(int id) => repository.markAsRead(id);
}
