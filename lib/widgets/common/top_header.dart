import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../providers/autho_role.dart';

class TopHeader extends StatelessWidget {
  const TopHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthRoleProvider>();

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(color: AppColors.sidebarBlue),
      child: Row(
        children: [
          const Icon(Icons.auto_stories, color: Colors.white, size: 26),
          const SizedBox(width: 12),
          const Text(
            'Library Management System',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),

          // Notification Bell
          IconButton(
            onPressed: () {
              if (auth.currentRole == UserRole.reader) {
                context.go('/reader/notifications');
              } else if (auth.currentRole == UserRole.librarian) {
                context.go('/librarian/notifications');
              }
            },
            icon: Badge(
              label: Text('${auth.unreadNotifications}'),
              backgroundColor: AppColors.error,
              isLabelVisible: auth.unreadNotifications > 0,
              child: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User Profile Dropdown / Role Switcher
          PopupMenuButton<UserRole>(
            tooltip: 'Switch Portal Role',
            onSelected: (UserRole selectedRole) {
              auth.switchRole(selectedRole);
              switch (selectedRole) {
                case UserRole.reader:
                  context.go('/reader/home');
                  break;
                case UserRole.librarian:
                  context.go('/librarian/home');
                  break;
                case UserRole.admin:
                  context.go('/admin/dashboard');
                  break;
              }
            },
            offset: const Offset(0, 50),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: UserRole.reader,
                child: Text('Reader Portal (Abiye)'),
              ),
              const PopupMenuItem(
                value: UserRole.librarian,
                child: Text('Librarian Portal (Sara)'),
              ),
              const PopupMenuItem(
                value: UserRole.admin,
                child: Text('Admin Portal (Sara Ahmed)'),
              ),
            ],
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.white24,
                  child: Icon(Icons.person, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      auth.roleDisplayName,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
