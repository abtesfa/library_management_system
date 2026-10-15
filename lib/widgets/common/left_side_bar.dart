import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/autho_role.dart';

class LeftSidebar extends StatelessWidget {
  const LeftSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthRoleProvider>();
    final currentPath = GoRouterState.of(context).uri.toString();

    return Container(
      width: 240,
      decoration: const BoxDecoration(color: AppColors.sidebarBlue),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo & Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Library Management\nSystem',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Dynamic Navigation Items per Role
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                if (auth.currentRole == UserRole.reader) ...[
                  _NavItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    route: '/reader/home',
                    isActive: currentPath == '/reader/home',
                  ),
                  _NavItem(
                    icon: Icons.book_outlined,
                    label: 'My Books',
                    route: '/reader/books',
                    isActive: currentPath == '/reader/books',
                  ),
                  _NavItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Reservations',
                    route: '/reader/reservations',
                    isActive: currentPath == '/reader/reservations',
                  ),
                  _NavItem(
                    icon: Icons.notifications_none_outlined,
                    label: 'Notifications',
                    route: '/reader/notifications',
                    badgeCount: auth.unreadNotifications,
                    isActive: currentPath == '/reader/notifications',
                  ),
                ] else if (auth.currentRole == UserRole.librarian) ...[
                  _NavItem(
                    icon: Icons.home_outlined,
                    label: 'Home',
                    route: '/librarian/home',
                    isActive: currentPath == '/librarian/home',
                  ),
                  _NavItem(
                    icon: Icons.swap_horiz,
                    label: 'Borrow & Return',
                    route: '/librarian/circulation',
                    isActive: currentPath == '/librarian/circulation',
                  ),
                  _NavItem(
                    icon: Icons.notifications_none_outlined,
                    label: 'Notifications',
                    route: '/librarian/notifications',
                    badgeCount: auth.unreadNotifications,
                    isActive: currentPath == '/librarian/notifications',
                  ),
                ] else if (auth.currentRole == UserRole.admin) ...[
                  _NavItem(
                    icon: Icons.home_outlined,
                    label: 'Dashboard',
                    route: '/admin/dashboard',
                    isActive: currentPath == '/admin/dashboard',
                  ),
                  _NavItem(
                    icon: Icons.settings_outlined,
                    label: 'LMS Settings',
                    route: '/admin/settings',
                    isActive: currentPath == '/admin/settings',
                  ),
                  _NavItem(
                    icon: Icons.people_outline,
                    label: 'Staff Management',
                    route: '/admin/staff',
                    isActive: currentPath == '/admin/staff',
                  ),
                  _NavItem(
                    icon: Icons.menu_book_outlined,
                    label: 'Book Inventory',
                    route: '/admin/inventory',
                    isActive: currentPath == '/admin/inventory',
                  ),
                ],
              ],
            ),
          ),

          // Bottom Motto / Branding Footer
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(Icons.layers, color: Colors.white70, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text(
                      'Read More,',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Learn More,',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                    Text(
                      'Grow More.',
                      style: TextStyle(color: Colors.white70, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isActive;
  final int? badgeCount;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.isActive,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.white.withValues(alpha: 0.18)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: () => context.go(route),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        leading: Icon(icon, color: Colors.white, size: 20),
        title: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
          ),
        ),
        trailing: badgeCount != null && badgeCount! > 0
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
