
import '../../domain/entities/library_notification.dart';

/// JSON-aware version of LibraryNotification used by the data layer.
class LibraryNotificationModel extends LibraryNotification {
  const LibraryNotificationModel({
    required super.notificationId,
    required super.title,
    required super.message,
    super.details,
    super.createdAt,
    required super.notificationType,
    required super.isRead,
    super.announcementPriority,
    super.validUntil,
  });

  factory LibraryNotificationModel.fromJson(Map<String, dynamic> json) {
    final readValue = json['isRead'] ?? json['is_read'];

    final bool parsedIsRead =
        readValue == true ||
        readValue == 1 ||
        readValue?.toString().toLowerCase() == 'true' ||
        readValue?.toString() == '1';

    return LibraryNotificationModel(
      notificationId:
          int.tryParse(json['notificationId']?.toString() ?? '') ??
          int.tryParse(json['notification_id']?.toString() ?? '') ??
          0,

      title: json['title']?.toString() ?? '',

      message: json['message']?.toString() ?? '',

      details: json['details']?.toString(),

      createdAt: (json['createdAt'] ?? json['created_at']) == null
          ? null
          : DateTime.tryParse(
              (json['createdAt'] ?? json['created_at']).toString(),
            ),

      notificationType:
          (json['notificationType'] ?? json['notification_type'])
                  ?.toString() ??
              'ANNOUNCEMENT',

      isRead: parsedIsRead,

      announcementPriority:
          (json['announcementPriority'] ??
                  json['announcement_priority'])
              ?.toString(),

      validUntil: (json['validUntil'] ?? json['valid_until']) == null
          ? null
          : DateTime.tryParse(
              (json['validUntil'] ?? json['valid_until']).toString(),
            ),
    );
  }
}
