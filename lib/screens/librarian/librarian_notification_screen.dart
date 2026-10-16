
import 'package:flutter/material.dart';

const Color primaryBlue = Color(0xFF0668F9);
const Color darkBlue = Color(0xFF063B83);
const Color pageBackground = Color(0xFFF3F9FF);
const Color borderBlue = Color(0xFFD8E9FF);
const Color textBlue = Color(0xFF063F9E);

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  int selectedFilter = 0;

  final List<Map<String, dynamic>> notifications = [
    {
      'type': 'Overdue Book',
      'message': "The book 'Atomic Habits' is overdue. It was due on 2025-06-22.",
      'detail': 'Student: S-00123 (Abebe Kebede)',
      'time': '2 hours ago',
      'status': 'Overdue',
      'icon': Icons.notifications_active,
      'color': Colors.red,
      'category': 2,
    },
    {
      'type': 'Due Soon',
      'message': "'The Great Gatsby' will be due in 2 days (2025-06-25).",
      'detail': 'Student: S-00145 (Selam Tesfaye)',
      'time': '4 hours ago',
      'status': 'Due Soon',
      'icon': Icons.access_time_filled,
      'color': Colors.blue,
      'category': 1,
    },
    {
      'type': 'Reservation Available',
      'message': "Your reservation for 'Dune' is now available.",
      'detail': 'Book ID: B-00127',
      'time': '6 hours ago',
      'status': 'Reservation',
      'icon': Icons.calendar_month,
      'color': Colors.teal,
      'category': 3,
    },
    {
      'type': 'Overdue Book',
      'message': "The book 'Clean Code' is overdue. It was due on 2025-06-19.",
      'detail': 'Student: S-00102 (Yonas Tadesse)',
      'time': '1 day ago',
      'status': 'Overdue',
      'icon': Icons.notifications_active,
      'color': Colors.red,
      'category': 2,
    },
    {
      'type': 'New Reservation',
      'message': "A new reservation has been made for 'The Martian'.",
      'detail': 'Student: S-00167 (Mekdes Alemu)',
      'time': '1 day ago',
      'status': 'Reservation',
      'icon': Icons.info,
      'color': Colors.blue,
      'category': 3,
    },
    {
      'type': 'Library Announcement',
      'message': 'The library will be closed on June 28, 2025 for maintenance.',
      'detail': 'All services will resume on June 29, 2025.',
      'time': '2 days ago',
      'status': 'Announcement',
      'icon': Icons.campaign,
      'color': Colors.deepPurple,
      'category': 4,
    },
    {
      'type': 'Due Soon',
      'message': "'Sapiens' will be due in 3 days (2025-06-27).",
      'detail': 'Student: S-00178 (Hana Girma)',
      'time': '2 days ago',
      'status': 'Due Soon',
      'icon': Icons.calendar_month,
      'color': Colors.teal,
      'category': 1,
    },
    {
      'type': 'Library Announcement',
      'message': 'New books have been added to the collection. Check the latest titles in the catalog.',
      'detail': '',
      'time': '3 days ago',
      'status': 'Announcement',
      'icon': Icons.campaign,
      'color': Colors.deepPurple,
      'category': 4,
    },
  ];

  List<Map<String, dynamic>> get filteredNotifications {
    if (selectedFilter == 0) return notifications;
    return notifications
        .where((item) => item['category'] == selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: Row(
              children: [
                _buildSidebar(),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final bool wide = constraints.maxWidth >= 1050;

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 7,
                                    child: _buildNotificationList(),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    flex: 3,
                                    child: _buildRightPanel(),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  _buildNotificationList(),
                                  const SizedBox(height: 18),
                                  _buildRightPanel(),
                                ],
                              ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF06377D), Color(0xFF075EC9)],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.menu_book,
              size: 35,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Text(
              'Library Management System',
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications, color: Colors.white, size: 29),
              Positioned(
                right: -5,
                top: -5,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 28),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: primaryBlue, size: 29),
          ),
          const SizedBox(width: 12),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ms. Sara Ahmed',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Librarian',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 15),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF063B83), Color(0xFF032D68)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 24),
          _sidebarItem(Icons.home, 'Home', false),
          _sidebarItem(Icons.swap_horiz, 'Borrow & Return', false),
          _sidebarItem(Icons.notifications, 'Notifications', true),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.only(left: 20, bottom: 28),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.layers, color: Colors.white, size: 38),
                  SizedBox(height: 12),
                  Text(
                    'Read More,\nLearn More,\nGrow More.',
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.4,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, bool active) {
    return Container(
      height: 50,
      margin: const EdgeInsets.fromLTRB(9, 0, 9, 10),
      decoration: BoxDecoration(
        color: active ? primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(icon, color: Colors.white, size: 27),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
          if (active)
            Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Text(
                '3',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNotificationList() {
    final items = filteredNotifications;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notifications',
          style: TextStyle(
            color: textBlue,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Stay updated with upcoming due dates, overdue books, reservations, and library announcements.',
          style: TextStyle(color: Color(0xFF3778D8), fontSize: 13),
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _filterButton('All (8)', 0, Icons.notifications),
              _filterButton('Due Soon (2)', 1, Icons.access_time),
              _filterButton('Overdue (2)', 2, Icons.warning),
              _filterButton('Reservations (2)', 3, Icons.calendar_month),
              _filterButton('Announcements (2)', 4, Icons.campaign),
            ],
          ),
        ),
        const SizedBox(height: 15),
        ...items.map(_notificationCard),
      ],
    );
  }

  Widget _filterButton(String title, int index, IconData icon) {
    final active = selectedFilter == index;

    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: () => setState(() => selectedFilter = index),
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 14),
          decoration: BoxDecoration(
            color: active ? primaryBlue : Colors.white,
            border: Border.all(color: borderBlue),
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: active ? Colors.white : primaryBlue,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: active ? Colors.white : const Color(0xFF2767C7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _notificationCard(Map<String, dynamic> item) {
    final Color color = item['color'] as Color;
    final IconData icon = item['icon'] as IconData;

    return Container(
      margin: const EdgeInsets.only(bottom: 5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE4F0FF)),
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.035),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['type'] as String,
                  style: const TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  item['message'] as String,
                  style: const TextStyle(
                    color: Color(0xFF3778D8),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                if ((item['detail'] as String).isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    item['detail'] as String,
                    style: const TextStyle(
                      color: Color(0xFF3778D8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['time'] as String,
                  style: const TextStyle(
                    color: Color(0xFF3778D8),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    item['status'] as String,
                    style: TextStyle(color: color, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 5),
          const Padding(
            padding: EdgeInsets.only(top: 20),
            child: Icon(
              Icons.chevron_right,
              color: primaryBlue,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightPanel() {
    return Column(
      children: [
        _summaryCard(),
        const SizedBox(height: 15),
        _quickActionsCard(),
      ],
    );
  }

  Widget _summaryCard() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.notifications, color: primaryBlue, size: 26),
              SizedBox(width: 12),
              Text(
                'Notification Summary',
                style: TextStyle(
                  color: textBlue,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _summaryTile(
                  Icons.notifications_active,
                  '2',
                  'Overdue Books',
                  Colors.red,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryTile(
                  Icons.access_time_filled,
                  '3',
                  'Due Soon',
                  Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _summaryTile(
                  Icons.calendar_month,
                  '1',
                  'Reservation(s)',
                  Colors.teal,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryTile(
                  Icons.campaign,
                  '2',
                  'Announcements',
                  Colors.deepPurple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryTile(
    IconData icon,
    String count,
    String label,
    Color color,
  ) {
    return Container(
      constraints: const BoxConstraints(minHeight: 88),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderBlue),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    color: textBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF3778D8),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickActionsCard() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: primaryBlue, size: 27),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: textBlue,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _showMessage('All quick actions'),
                child: const Text(
                  'View All →',
                  style: TextStyle(color: primaryBlue, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          _quickAction(
            Icons.calendar_month,
            'View Due Dates',
            'Check upcoming due dates',
            Colors.blue,
          ),
          _quickAction(
            Icons.menu_book,
            'Check Overdue Books',
            'See all overdue items',
            Colors.deepPurple,
          ),
          _quickAction(
            Icons.calendar_month,
            'Manage Reservations',
            'View and manage reservations',
            Colors.teal,
          ),
          _quickAction(
            Icons.notifications,
            'Library Announcements',
            'Read latest updates',
            Colors.blue,
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF4FF),
              border: Border.all(color: borderBlue),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.info, color: primaryBlue, size: 27),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'We keep you informed so you can make the most of your library resources.',
                    style: TextStyle(
                      color: Color(0xFF3778D8),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.menu_book, color: primaryBlue, size: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickAction(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return InkWell(
      onTap: () => _showMessage(title),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: borderBlue),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 47,
              height: 47,
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 25),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: textBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF3778D8),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: borderBlue),
        borderRadius: BorderRadius.circular(13),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.035),
            blurRadius: 8,
          ),
        ],
      ),
      child: child,
    );
  }

  void _showMessage(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title selected'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
