import '../../domain/entities/library_notification.dart';

/// JSON-aware version of [LibraryNotification] used by the data layer.
class LibraryNotificationModel extends LibraryNotification {
  const LibraryNotificationModel({
    required super.notificationId,
    required super.title,
    required super.message,
    super.details,
    super.createdAt,
    required super.notificationType,
    required super.isRead,
  });

  factory LibraryNotificationModel.fromJson(Map<String, dynamic> json) {
    return LibraryNotificationModel(
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
