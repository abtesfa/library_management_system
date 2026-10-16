import 'package:flutter/material.dart';

import '../admin/admin_dashboard_screen.dart';
import '../admin/book_inventory_screen.dart';
import '../admin/ims_settings_screen.dart';
import '../admin/staff_management_screen.dart';
import '../librarian/borrow_return_desk_screen.dart';
import '../librarian/reservation_management_screen.dart';
import '../reader/notifications_screen.dart';

class MainLayoutShell extends StatefulWidget {
  const MainLayoutShell({super.key});

  @override
  State<MainLayoutShell> createState() => _MainLayoutShellState();
}

class _MainLayoutShellState extends State<MainLayoutShell> {
  int _selectedIndex = 0;

  static const Color primaryColor = Color(0xFF0052CC);
  static const Color sidebarColor = Color(0xFF172B4D);
  static const Color backgroundColor = Color(0xFFF5F7FB);

  static const List<_NavigationItem> navigationItems = [
    _NavigationItem('Dashboard', Icons.dashboard_outlined),
    _NavigationItem('Book Inventory', Icons.menu_book_outlined),
    _NavigationItem('Staff Management', Icons.people_outline),
    _NavigationItem('Borrow / Return Desk', Icons.swap_horiz),
    _NavigationItem('Reservations', Icons.bookmark_border),
    _NavigationItem('Notifications', Icons.notifications_none_outlined),
    _NavigationItem('System Settings', Icons.settings_outlined),
  ];

  late final List<Widget> screens = [
    const AdminDashboardScreen(),
    const BookInventoryScreen(),
    const StaffManagementScreen(),
    const BorrowReturnDeskScreen(),
    const ReservationManagementScreen(),
    const ReaderNotificationsScreen(),
    const ImsSettingsScreen(),
  ];

  void selectScreen(int index) {
    if (index >= 0 && index < screens.length) {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Row(
          children: [
            buildSidebar(),
            Expanded(
              child: Column(
                children: [
                  buildTopBar(),
                  Expanded(
                    child: IndexedStack(
                      index: _selectedIndex,
                      children: screens,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSidebar() {
    return Container(
      width: 250,
      color: sidebarColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 12, 28),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.local_library_outlined,
                    color: Colors.white,
                    size: 25,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Library System',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Management Portal',
                        style: TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 0, 16, 12),
            child: Text(
              'MAIN MENU',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: navigationItems.length,
              itemBuilder: (context, index) {
                final item = navigationItems[index];
                final selected = _selectedIndex == index;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Material(
                    color: selected ? primaryColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      leading: Icon(
                        item.icon,
                        color: selected ? Colors.white : Colors.white70,
                      ),
                      title: Text(
                        item.title,
                        style: TextStyle(
                          color: selected ? Colors.white : Colors.white70,
                          fontSize: 12.5,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: selected
                          ? const Icon(
                              Icons.circle,
                              size: 7,
                              color: Colors.white,
                            )
                          : null,
                      onTap: () => selectScreen(index),
                    ),
                  ),
                );
              },
            ),
          ),
          const Divider(color: Colors.white24),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 19,
                  backgroundColor: Color(0xFF344563),
                  child: Icon(Icons.person_outline, color: Colors.white),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Library Administrator',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Administrator',
                        style: TextStyle(color: Colors.white60, fontSize: 10),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'System settings',
                  onPressed: () => selectScreen(6),
                  icon: const Icon(
                    Icons.settings_outlined,
                    color: Colors.white70,
                    size: 19,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTopBar() {
    final currentItem = navigationItems[_selectedIndex];

    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE8ECF2))),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              currentItem.title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF172B4D),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => selectScreen(5),
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Color(0xFF42526E),
            ),
          ),
          const SizedBox(width: 10),
          Container(width: 1, height: 30, color: const Color(0xFFE8ECF2)),
          const SizedBox(width: 14),
          const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFE6EEFF),
            child: Icon(Icons.person_outline, color: primaryColor, size: 21),
          ),
          const SizedBox(width: 10),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Administrator',
                style: TextStyle(
                  color: Color(0xFF172B4D),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Library Management',
                style: TextStyle(color: Colors.blueGrey, fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NavigationItem {
  final String title;
  final IconData icon;

  const _NavigationItem(this.title, this.icon);
}
