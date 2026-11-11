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

  factory LibraryNotification.fromJson(
      Map<String, dynamic> json) {
    return LibraryNotification(
      notificationId:
          int.tryParse(json['notificationId']?.toString() ?? '') ?? 0,

      title: json['title']?.toString() ?? '',

      message: json['message']?.toString() ?? '',

      details: json['details']?.toString(),

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,

      notificationType:
          json['notificationType']?.toString() ?? 'ANNOUNCEMENT',

      isRead: json['isRead'] == true,
    );
  }
}