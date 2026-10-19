
import 'package:flutter/material.dart';

enum NotificationType {
  dueSoon,
  overdue,
  reservation,
  announcement,
}

class LibraryNotification {
  final String title;
  final String message;
  final String? details;
  final String time;
  final NotificationType type;
  final IconData icon;

  const LibraryNotification({
    required this.title,
    required this.message,
    this.details,
    required this.time,
    required this.type,
    required this.icon,
  });
}

class LibrarianNotificationsScreen extends StatefulWidget {
  const LibrarianNotificationsScreen({super.key});

  @override
  State<LibrarianNotificationsScreen> createState() =>
      _LibrarianNotificationsScreenState();
}

class _LibrarianNotificationsScreenState
    extends State<LibrarianNotificationsScreen> {
  static const Color primaryBlue = Color(0xFF0052CC);
  static const Color pageBackground = Color(0xFFF4F7FC);

  String _selectedFilter = 'All';
  final Set<int> _readNotifications = {};

  final List<LibraryNotification> _notifications = const [
    LibraryNotification(
      title: 'Overdue Book',
      message: "The book 'Atomic Habits' is overdue.",
      details: 'Due date: 2025-06-22 · Student: S-00123 (Abebe Kebede)',
      time: '2 hours ago',
      type: NotificationType.overdue,
      icon: Icons.notifications_active,
    ),
    LibraryNotification(
      title: 'Due Soon',
      message: "'The Great Gatsby' will be due in 2 days.",
      details: 'Due date: 2025-06-25 · Student: S-00145 (Selam Tesfaye)',
      time: '4 hours ago',
      type: NotificationType.dueSoon,
      icon: Icons.access_time_filled,
    ),
    LibraryNotification(
      title: 'Reservation Available',
      message: "A reserved copy of 'Dune' is now available.",
      details: 'Book ID: B-00127',
      time: '6 hours ago',
      type: NotificationType.reservation,
      icon: Icons.calendar_month,
    ),
    LibraryNotification(
      title: 'Overdue Book',
      message: "The book 'Clean Code' is overdue.",
      details: 'Due date: 2025-06-19 · Student: S-00102 (Yonas Tadesse)',
      time: '1 day ago',
      type: NotificationType.overdue,
      icon: Icons.notifications_active,
    ),
    LibraryNotification(
      title: 'New Reservation',
      message: "A new reservation was made for 'The Martian'.",
      details: 'Student: S-00167 (Mekdes Alemu)',
      time: '1 day ago',
      type: NotificationType.reservation,
      icon: Icons.info,
    ),
    LibraryNotification(
      title: 'Library Announcement',
      message: 'The library will be closed for maintenance.',
      details: 'Please check the official library schedule for updates.',
      time: '2 days ago',
      type: NotificationType.announcement,
      icon: Icons.campaign,
    ),
    LibraryNotification(
      title: 'Due Soon',
      message: "'Sapiens' will be due in 3 days.",
      details: 'Student: S-00178 (Hana Girma)',
      time: '2 days ago',
      type: NotificationType.dueSoon,
      icon: Icons.calendar_month,
    ),
    LibraryNotification(
      title: 'Library Announcement',
      message: 'New books have been added to the collection.',
      details: 'Check the latest titles in the library catalog.',
      time: '3 days ago',
      type: NotificationType.announcement,
      icon: Icons.campaign,
    ),
  ];

  List<LibraryNotification> get _filteredNotifications {
    if (_selectedFilter == 'All') {
      return _notifications;
    }

    final type = switch (_selectedFilter) {
      'Due Soon' => NotificationType.dueSoon,
      'Overdue' => NotificationType.overdue,
      'Reservations' => NotificationType.reservation,
      'Announcements' => NotificationType.announcement,
      _ => null,
    };

    return _notifications
        .where((notification) => notification.type == type)
        .toList();
  }

  int _countFor(String filter) {
    if (filter == 'All') return _notifications.length;

    final type = switch (filter) {
      'Due Soon' => NotificationType.dueSoon,
      'Overdue' => NotificationType.overdue,
      'Reservations' => NotificationType.reservation,
      'Announcements' => NotificationType.announcement,
      _ => null,
    };

    return _notifications
        .where((notification) => notification.type == type)
        .length;
  }

  Color _notificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.overdue:
        return const Color(0xFFEF4444);
      case NotificationType.dueSoon:
        return const Color(0xFF1683F8);
      case NotificationType.reservation:
        return const Color(0xFF059E83);
      case NotificationType.announcement:
        return const Color(0xFF7538E8);
    }
  }

  Color _notificationBackground(NotificationType type) {
    switch (type) {
      case NotificationType.overdue:
        return const Color(0xFFFFECEF);
      case NotificationType.dueSoon:
        return const Color(0xFFE7F2FF);
      case NotificationType.reservation:
        return const Color(0xFFE0F7F0);
      case NotificationType.announcement:
        return const Color(0xFFF0E9FF);
    }
  }

  String _statusLabel(NotificationType type) {
    switch (type) {
      case NotificationType.overdue:
        return 'Overdue';
      case NotificationType.dueSoon:
        return 'Due Soon';
      case NotificationType.reservation:
        return 'Reservation';
      case NotificationType.announcement:
        return 'Announcement';
    }
  }

  void _openNotification(
    LibraryNotification notification,
    int originalIndex,
  ) {
    setState(() {
      _readNotifications.add(originalIndex);
    });

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final color = _notificationColor(notification.type);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Icon(notification.icon, color: color),
              const SizedBox(width: 12),
              Expanded(child: Text(notification.title)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.message),
              if (notification.details != null) ...[
                const SizedBox(height: 12),
                Text(
                  notification.details!,
                  style: const TextStyle(
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                notification.time,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filters = [
      ('All', Icons.notifications_none),
      ('Due Soon', Icons.access_time),
      ('Overdue', Icons.warning_amber_rounded),
      ('Reservations', Icons.calendar_month),
      ('Announcements', Icons.campaign_outlined),
    ];

    return Container(
      color: pageBackground,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 700;

            return ListView(
              padding: EdgeInsets.all(compact ? 16 : 24),
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    color: Color(0xFF103E91),
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Stay updated with upcoming due dates, overdue books, '
                  'reservations, and library announcements.',
                  style: TextStyle(
                    color: Color(0xFF3678D8),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 22),

                // Filter tabs
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filters.map((filter) {
                      final selected = _selectedFilter == filter.$1;

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Material(
                          color: selected
                              ? primaryBlue
                              : Colors.white,
                          borderRadius: BorderRadius.circular(9),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(9),
                            onTap: () {
                              setState(() {
                                _selectedFilter = filter.$1;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(
                                  color: selected
                                      ? primaryBlue
                                      : const Color(0xFFD9E8FC),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    filter.$2,
                                    size: 17,
                                    color: selected
                                        ? Colors.white
                                        : primaryBlue,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${filter.$1} (${_countFor(filter.$1)})',
                                    style: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : primaryBlue,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),

                // Notification list
                if (_filteredNotifications.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text('No notifications in this category.'),
                      ],
                    ),
                  )
                else
                  ..._filteredNotifications.map((notification) {
                    final originalIndex =
                        _notifications.indexOf(notification);
                    final color = _notificationColor(notification.type);
                    final background =
                        _notificationBackground(notification.type);
                    final isRead =
                        _readNotifications.contains(originalIndex);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: Color(0xFFE1EDFC),
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _openNotification(
                          notification,
                          originalIndex,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(compact ? 12 : 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: compact ? 23 : 28,
                                backgroundColor: background,
                                child: Icon(
                                  notification.icon,
                                  color: color,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notification.title,
                                      style: TextStyle(
                                        color: primaryBlue,
                                        fontSize: 14,
                                        fontWeight: isRead
                                            ? FontWeight.w500
                                            : FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 7),
                                    Text(
                                      notification.message,
                                      style: const TextStyle(
                                        color: Color(0xFF3678D8),
                                        fontSize: 13,
                                        height: 1.4,
                                      ),
                                    ),
                                    if (notification.details != null) ...[
                                      const SizedBox(height: 5),
                                      Text(
                                        notification.details!,
                                        style: const TextStyle(
                                          color: Color(0xFF3678D8),
                                          fontSize: 12,
                                          height: 1.4,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: background,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        _statusLabel(notification.type),
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    notification.time,
                                    style: const TextStyle(
                                      color: Color(0xFF3678D8),
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Icon(
                                    Icons.chevron_right,
                                    color: primaryBlue,
                                    size: 22,
                                  ),
                                  if (!isRead)
                                    Container(
                                      width: 7,
                                      height: 7,
                                      margin: const EdgeInsets.only(top: 8),
                                      decoration: const BoxDecoration(
                                        color: primaryBlue,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}
