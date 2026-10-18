import 'package:flutter/material.dart';
import '../../models/user.dart';

class TopHeaderBar extends StatelessWidget {
  final UserRole currentRole;
  final int selectedNavIndex;
  final ValueChanged<int> onSelectNav;
  final VoidCallback onReturnToLanding;
  final ValueChanged<UserRole> onSwitchRole;
  final List<Map<String, dynamic>> navItems;

  const TopHeaderBar({
    super.key,
    required this.currentRole,
    required this.selectedNavIndex,
    required this.onSelectNav,
    required this.onReturnToLanding,
    required this.onSwitchRole,
    required this.navItems,
  });

  @override
  Widget build(BuildContext context) {
    final activeUser = HardcodedCredentials.getForRole(currentRole);

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: const Color(0xFF0052CC),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Brand Logo & System Title
          InkWell(
            onTap: onReturnToLanding,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.menu_book, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Library Management System',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        currentRole == UserRole.admin
                            ? 'Admin Portal'
                            : currentRole == UserRole.librarian
                                ? 'Librarian Desk'
                                : 'Reader Portal',
                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Center: Section Navigation Tabs (Only top header with each section of its own)
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: navItems.map((item) {
                    final isSelected = selectedNavIndex == item['index'];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(8),
                        onTap: () => onSelectNav(item['index'] as int),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item['icon'] as IconData,
                                size: 16,
                                color: isSelected ? const Color(0xFF0052CC) : Colors.white.withValues(alpha: 0.85),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item['title'] as String,
                                style: TextStyle(
                                  color: isSelected ? const Color(0xFF0052CC) : Colors.white.withValues(alpha: 0.9),
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),

          // Right Controls: Public Website button, notifications bell, user role dropdown
          Row(
            children: [
              TextButton.icon(
                onPressed: onReturnToLanding,
                icon: const Icon(Icons.public, size: 15, color: Colors.white70),
                label: const Text('Public Website', style: TextStyle(color: Colors.white, fontSize: 11)),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Badge(
                  label: Text('3'),
                  child: Icon(Icons.notifications_none, color: Colors.white, size: 20),
                ),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 12),
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'admin') {
                    onSwitchRole(UserRole.admin);
                  } else if (val == 'librarian') {
                    onSwitchRole(UserRole.librarian);
                  } else if (val == 'reader') {
                    onSwitchRole(UserRole.reader);
                  } else if (val == 'logout') {
                    onReturnToLanding();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'admin',
                    child: Row(
                      children: [
                        Icon(Icons.security, size: 18, color: Color(0xFF0052CC)),
                        SizedBox(width: 10),
                        Text('Admin (System Administrator)'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'librarian',
                    child: Row(
                      children: [
                        Icon(Icons.assignment_turned_in, size: 18, color: Color(0xFF059669)),
                        SizedBox(width: 10),
                        Text('Ms. Sara Ahmed (Librarian)'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'reader',
                    child: Row(
                      children: [
                        Icon(Icons.person, size: 18, color: Color(0xFF7C3AED)),
                        SizedBox(width: 10),
                        Text('Abiye Tesfaye (Reader)'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 18, color: Color(0xFFDC2626)),
                        SizedBox(width: 10),
                        Text('Sign Out / Public Landing', style: TextStyle(color: Color(0xFFDC2626))),
                      ],
                    ),
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: Colors.white,
                        child: Icon(
                          currentRole == UserRole.admin
                              ? Icons.security
                              : currentRole == UserRole.librarian
                                  ? Icons.assignment_ind
                                  : Icons.person,
                          size: 16,
                          color: const Color(0xFF0052CC),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            activeUser.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                          Text(
                            activeUser.title,
                            style: const TextStyle(color: Color(0xFFBFDBFE), fontSize: 10),
                          ),
                        ],
                      ),
                      const Icon(Icons.arrow_drop_down, color: Colors.white70, size: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
