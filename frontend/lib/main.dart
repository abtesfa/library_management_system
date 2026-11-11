import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/app_colors.dart';
import 'models/user.dart';
import 'screens/admin/admin_inventory_screen.dart';
import 'screens/admin/admin_settings_screen.dart';
import 'screens/admin/staff_management_screen.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/librarian/librarian_desk_screen.dart';
import 'screens/librarian/librarian_notifications_screen.dart';
import 'screens/reader/reader_home_screen.dart';
import 'screens/reader/reader_my_books_screen.dart';
import 'screens/reader/reader_reservations_screen.dart';
import 'services/library_service.dart';
import 'theme/app_theme.dart';
import 'widgets/header/top_header_bar.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => LibraryService(),
      child: const LibraryManagementApp(),
    ),
  );
}

class LibraryManagementApp extends StatelessWidget {
  const LibraryManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Library Management System',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainShell(),
    );
  }
}

/// Switches between the landing page and the three role portals.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  /// Nav index each portal opens on.
  static const int _adminStartIndex = 3; // Book Inventory
  static const int _defaultStartIndex = 0; // Desk / Reader Home

  bool _isLandingMode = true;
  UserRole _currentRole = UserRole.admin;
  int _selectedNavIndex = _adminStartIndex;

  void _enterPortal(UserRole role) {
    setState(() {
      _isLandingMode = false;
      _currentRole = role;
      _selectedNavIndex =
          role == UserRole.admin ? _adminStartIndex : _defaultStartIndex;
    });
  }

  void _returnToLanding() {
    setState(() => _isLandingMode = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLandingMode) {
      return LandingScreen(onEnterPortal: _enterPortal);
    }

    return Scaffold(
      body: Column(
        children: [
          TopHeaderBar(
            currentRole: _currentRole,
            selectedNavIndex: _selectedNavIndex,
            onSelectNav: (index) => setState(() => _selectedNavIndex = index),
            onReturnToLanding: _returnToLanding,
            onSwitchRole: _enterPortal,
            navItems: _navItemsForRole(),
          ),
          Expanded(
            child: Container(
              color: AppColors.background,
              width: double.infinity,
              child: _buildCurrentScreen(),
            ),
          ),
        ],
      ),
    );
  }

  /// Top navigation entries for the current role.
  List<Map<String, dynamic>> _navItemsForRole() {
    switch (_currentRole) {
      case UserRole.admin:
        return [
          {'index': 3, 'title': 'Book Inventory', 'icon': Icons.menu_book},
          {
            'index': 2,
            'title': 'Staff Management',
            'icon': Icons.people_alt_outlined,
          },
          {'index': 1, 'title': 'LMS Settings', 'icon': Icons.settings_outlined},
        ];
      case UserRole.librarian:
        return [
          {'index': 0, 'title': 'Borrow & Return', 'icon': Icons.swap_horiz},
          {
            'index': 1,
            'title': 'Notifications',
            'icon': Icons.notifications_outlined,
          },
        ];
      case UserRole.reader:
        return [
          {'index': 0, 'title': 'Reader Home', 'icon': Icons.home_outlined},
          {'index': 1, 'title': 'My Books', 'icon': Icons.bookmark_outline},
          {
            'index': 2,
            'title': 'Reservations',
            'icon': Icons.calendar_month_outlined,
          },
        ];
    }
  }

  /// Screen for the selected nav entry; unknown indexes open the portal's first screen.
  Widget _buildCurrentScreen() {
    switch (_currentRole) {
      case UserRole.admin:
        switch (_selectedNavIndex) {
          case 1:
            return const AdminSettingsScreen();
          case 2:
            return const StaffManagementScreen();
          default:
            return const AdminInventoryScreen();
        }
      case UserRole.librarian:
        switch (_selectedNavIndex) {
          case 1:
            return const LibrarianNotificationsScreen();
          default:
            return const LibrarianDeskScreen();
        }
      case UserRole.reader:
        switch (_selectedNavIndex) {
          case 1:
            return const ReaderMyBooksScreen();
          case 2:
            return const ReaderReservationsScreen();
          default:
            return ReaderHomeScreen(
              onNavigateToMyBooks: () => setState(() => _selectedNavIndex = 1),
            );
        }
    }
  }
}
