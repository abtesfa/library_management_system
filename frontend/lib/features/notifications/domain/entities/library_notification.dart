enum NotificationType {
  dueSoon,
  overdue,
  reservation,
  announcement,
}

class LibraryNotification {
  final int notificationId;
  final String title;
  final String message;
  final String? details;
  final DateTime? createdAt;
  final String notificationType;
  final bool isRead;

  const LibraryNotification({
    required this.notificationId,
    required this.title,
    required this.message,
    this.details,
    this.createdAt,
    required this.notificationType,
    required this.isRead,
  });
}
