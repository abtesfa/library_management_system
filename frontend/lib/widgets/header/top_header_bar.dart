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
                  child: const Icon(Icons.menu_book,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Library Management System',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 1),
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
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold),
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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                isSelected ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color:
                                          Colors.black.withValues(alpha: 0.1),
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
                                color: isSelected
                                    ? const Color(0xFF0052CC)
                                    : Colors.white.withValues(alpha: 0.85),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                item['title'] as String,
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF0052CC)
                                      : Colors.white.withValues(alpha: 0.9),
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
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

          // Right Controls: Sign Out only
          Row(
            children: [
              TextButton.icon(
                onPressed: onReturnToLanding,
                icon: const Icon(
                  Icons.logout,
                  size: 16,
                  color: Colors.white,
                ),
                label: const Text(
                  'Sign Out',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
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
