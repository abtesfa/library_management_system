import 'package:flutter/material.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final List<_LibraryNotification> _notifications = [
    _LibraryNotification(
      title: 'Book Due Soon',
      message: 'Your borrowed book "Clean Code" is due in two days.',
      icon: Icons.schedule,
      color: Colors.orange,
    ),
    _LibraryNotification(
      title: 'Reservation Ready',
      message: 'Your reserved book "Computer Networks" is ready for pickup.',
      icon: Icons.bookmark_added_outlined,
      color: Colors.green,
    ),
    _LibraryNotification(
      title: 'Library Announcement',
      message: 'Welcome to the Library Management System.',
      icon: Icons.campaign_outlined,
      color: Color(0xFF0052CC),
      isRead: true,
    ),
  ];

  String _filter = 'All';

  int get _unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;

  void _markAllAsRead() {
    setState(() {
      for (final notification in _notifications) {
        notification.isRead = true;
      }
    });
  }

  void _markAsRead(_LibraryNotification notification) {
    setState(() {
      notification.isRead = true;
    });
  }

  void _deleteNotification(_LibraryNotification notification) {
    setState(() {
      _notifications.remove(notification);
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _notifications.where((notification) {
      if (_filter == 'Unread') return !notification.isRead;
      if (_filter == 'Read') return notification.isRead;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF172B4D),
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'View reminders, reservation updates, and library news.',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed:
                        _unreadCount == 0 ? null : _markAllAsRead,
                    icon: const Icon(Icons.done_all),
                    label: const Text('Mark all as read'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 8,
                children: [
                  _buildFilter('All'),
                  _buildFilter('Unread'),
                  _buildFilter('Read'),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                '$_unreadCount unread notification${_unreadCount == 1 ? '' : 's'}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF42526E),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: filteredNotifications.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.notifications_none,
                              size: 48,
                              color: Colors.blueGrey,
                            ),
                            SizedBox(height: 12),
                            Text('No notifications found.'),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: filteredNotifications.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final notification =
                              filteredNotifications[index];

                          return Card(
                            elevation: 0,
                            color: notification.isRead
                                ? Colors.white
                                : const Color(0xFFEFF5FF),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor:
                                    notification.color.withValues(alpha: 0.12),
                                child: Icon(
                                  notification.icon,
                                  color: notification.color,
                                ),
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      notification.title,
                                      style: TextStyle(
                                        fontWeight: notification.isRead
                                            ? FontWeight.w500
                                            : FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (!notification.isRead)
                                    const Icon(
                                      Icons.circle,
                                      size: 9,
                                      color: Color(0xFF0052CC),
                                    ),
                                ],
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Text(notification.message),
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'read') {
                                    _markAsRead(notification);
                                  } else if (value == 'delete') {
                                    _deleteNotification(notification);
                                  }
                                },
                                itemBuilder: (context) => [
                                  if (!notification.isRead)
                                    const PopupMenuItem(
                                      value: 'read',
                                      child: Text('Mark as read'),
                                    ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilter(String value) {
    return ChoiceChip(
      label: Text(value),
      selected: _filter == value,
      onSelected: (_) {
        setState(() {
          _filter = value;
        });
      },
    );
  }
}

class _LibraryNotification {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  bool isRead;

  _LibraryNotification({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    this.isRead = false,
  });
}