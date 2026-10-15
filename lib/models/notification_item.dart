enum NotificationCategory {
  books,
  reservations,
  general,
}

enum NotificationPriority {
  normal,
  urgent,
  info,
  success,
}

class NotificationItem {
  final String id;
  final String title;
  final String description;
  final String timeAgo;
  final NotificationCategory category;
  final NotificationPriority priority;
  final bool isUnread;

  const NotificationItem({
    required this.id,
    required this.title,
    required this.description,
    required this.timeAgo,
    required this.category,
    this.priority = NotificationPriority.normal,
    this.isUnread = false,
  });

  NotificationItem copyWith({bool? isUnread}) {
    return NotificationItem(
      id: id,
      title: title,
      description: description,
      timeAgo: timeAgo,
      category: category,
      priority: priority,
      isUnread: isUnread ?? this.isUnread,
    );
  }
}