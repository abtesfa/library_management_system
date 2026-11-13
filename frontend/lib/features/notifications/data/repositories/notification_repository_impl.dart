import '../../domain/entities/library_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  const NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<LibraryNotification>> getNotifications({bool unread = false}) =>
      remoteDataSource.getNotifications(unread: unread);

  @override
  Future<void> markAsRead(int id) => remoteDataSource.markAsRead(id);
}
