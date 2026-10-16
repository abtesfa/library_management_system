
import 'package:flutter/material.dart';

class ReaderNotificationsScreen extends StatefulWidget {
  const ReaderNotificationsScreen({super.key});

  @override
  State<ReaderNotificationsScreen> createState() =>
      _ReaderNotificationsScreenState();
}

class _ReaderNotificationsScreenState
    extends State<ReaderNotificationsScreen> {
  static const blue = Color(0xFF0755C9);
  static const darkBlue = Color(0xFF073B86);

  String selectedFilter = 'All';

  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'Your book "Atomic Habits" is due in 2 days.',
      'message': 'Please return or renew it to avoid late fees.',
      'time': '2 hours ago',
      'category': 'Books',
      'icon': Icons.notifications,
      'color': Colors.red,
      'unread': true,
    },
    {
      'title': 'Your reservation is now available.',
      'message': 'Please pick up your reserved book.',
      'time': '1 day ago',
      'category': 'Reservations',
      'icon': Icons.event_available,
      'color': blue,
      'unread': true,
    },
    {
      'title': 'Reservation ready for pickup',
      'message': 'Your book is ready at the library desk.',
      'time': '2 days ago',
      'category': 'Reservations',
      'icon': Icons.hourglass_top,
      'color': Colors.orange,
      'unread': true,
    },
    {
      'title': '"Dune" has been renewed successfully.',
      'message': 'Your new due date has been updated.',
      'time': '3 days ago',
      'category': 'Books',
      'icon': Icons.menu_book,
      'color': Colors.green,
      'unread': false,
    },
    {
      'title': 'Library announcement',
      'message': 'Please check the library opening hours.',
      'time': '5 days ago',
      'category': 'General',
      'icon': Icons.campaign,
      'color': Colors.deepPurple,
      'unread': false,
    },
    {
      'title': 'Welcome to the Library!',
      'message': 'Explore books and enjoy your reading journey.',
      'time': 'May 5, 2026',
      'category': 'General',
      'icon': Icons.info,
      'color': blue,
      'unread': false,
    },
  ];

  List<Map<String, dynamic>> get filteredNotifications {
    return notifications.where((notification) {
      if (selectedFilter == 'Unread') {
        return notification['unread'] == true;
      }
      if (selectedFilter == 'All') return true;
      return notification['category'] == selectedFilter;
    }).toList();
  }

  void markAllRead() {
    setState(() {
      for (final notification in notifications) {
        notification['unread'] = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final unreadCount =
        notifications.where((item) => item['unread'] == true).length;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Stay updated with important alerts and library updates.',
                style: TextStyle(color: Colors.blueGrey),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _filterButton('All'),
                  _filterButton('Unread'),
                  _filterButton('Books'),
                  _filterButton('Reservations'),
                  _filterButton('General'),
                ],
              ),
              const SizedBox(height: 15),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: markAllRead,
                  icon: const Icon(Icons.done_all),
                  label: const Text('Mark All as Read'),
                ),
              ),
              const SizedBox(height: 12),
              _panel(
                title: 'Notifications ($unreadCount unread)',
                child: Column(
                  children: filteredNotifications.map((notification) {
                    final unread = notification['unread'] as bool;
                    final color = notification['color'] as Color;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: unread
                            ? const Color(0xFFF0F6FF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFE5ECF5),
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: CircleAvatar(
                          backgroundColor: color.withValues(alpha: 0.12),
                          child: Icon(
                            notification['icon'] as IconData,
                            color: color,
                          ),
                        ),
                        title: Text(
                          notification['title'] as String,
                          style: TextStyle(
                            color: darkBlue,
                            fontSize: 13,
                            fontWeight:
                                unread ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(notification['message'] as String),
                              const SizedBox(height: 6),
                              Text(
                                '${notification['category']} • ${notification['time']}',
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        trailing: unread
                            ? IconButton(
                                tooltip: 'Mark as read',
                                icon: const Icon(
                                  Icons.circle,
                                  color: blue,
                                  size: 12,
                                ),
                                onPressed: () {
                                  setState(() {
                                    notification['unread'] = false;
                                  });
                                },
                              )
                            : const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 18,
                              ),
                        onTap: () {
                          setState(() {
                            notification['unread'] = false;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 18),
              _panel(
                title: 'Notification Preferences',
                child: Column(
                  children: [
                    _preference('Book Due Reminders', 'Reminders before books are due'),
                    _preference('Reservation Alerts', 'Updates when reservations are ready'),
                    _preference('General Announcements', 'Library news and announcements'),
                    _preference('Overdue Alerts', 'Alerts for overdue books'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _filterButton(String label) {
    final selected = selectedFilter == label;

    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: const Color(0xFFDCEAFF),
      onSelected: (_) {
        setState(() {
          selectedFilter = label;
        });
      },
    );
  }

  Widget _panel({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: darkBlue,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _preference(String title, String description) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(
          color: darkBlue,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(description, style: const TextStyle(fontSize: 11)),
      value: true,
      activeThumbColor: blue,
      onChanged: (value) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$title preference: ${value ? 'on' : 'off'}'),
          ),
        );
      },
    );
  }
}
