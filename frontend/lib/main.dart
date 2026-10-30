import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/user.dart';
import 'theme/app_theme.dart';
import 'services/library_service.dart';
import 'services/auth_service.dart';
import 'widgets/header/top_header_bar.dart';
import 'screens/landing/landing_screen.dart';
import 'screens/admin/admin_inventory_screen.dart';
import 'screens/admin/admin_settings_screen.dart';
import 'screens/admin/staff_management_screen.dart';
import 'screens/librarian/librarian_desk_screen.dart';
import 'screens/reader/reader_home_screen.dart';
import 'screens/reader/reader_my_books_screen.dart';
import 'screens/reader/reader_reservations_screen.dart';
import 'screens/librarian/librarian_notifications_screen.dart';
import 'api_test_page.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LibraryService()),
        ChangeNotifierProvider(create: (_) => AuthService()),
      ],
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
     home: const ApiTestPage(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  bool _isLandingMode = true;
  UserRole _currentRole = UserRole.admin;
  int _selectedNavIndex = 3; // Default to inventory for admin

  void _enterPortal(UserRole role) {
    setState(() {
      _isLandingMode = false;
      _currentRole = role;
      if (role == UserRole.admin) {
        _selectedNavIndex = 3; // Inventory
      } else if (role == UserRole.librarian) {
        _selectedNavIndex = 0; // Desk
      } else {
        _selectedNavIndex = 0; // Reader Home
      }
    });
  }

  void _returnToLanding() {
    setState(() {
      _isLandingMode = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLandingMode) {
      return LandingScreen(
        onEnterPortal: _enterPortal,
      );
    }

    final navItems = _getNavItemsForRole();

    return Scaffold(
      body: Column(
        children: [
          // Top Header Only (No sidebar, each section of its own)
          TopHeaderBar(
            currentRole: _currentRole,
            selectedNavIndex: _selectedNavIndex,
            onSelectNav: (idx) {
              setState(() => _selectedNavIndex = idx);
            },
            onReturnToLanding: _returnToLanding,
            onSwitchRole: (role) => _enterPortal(role),
            navItems: navItems,
          ),

          // Main Body: Full Screen Viewport for each section of its own
          Expanded(
            child: Container(
              color: const Color(0xFFF4F7FC),
              width: double.infinity,
              child: _buildCurrentScreen(),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getNavItemsForRole() {
    if (_currentRole == UserRole.admin) {
      return [
        {'index': 3, 'title': 'Book Inventory', 'icon': Icons.menu_book},
        {
          'index': 2,
          'title': 'Staff Management',
          'icon': Icons.people_alt_outlined
        },
        {'index': 1, 'title': 'LMS Settings', 'icon': Icons.settings_outlined},
      ];
    } else if (_currentRole == UserRole.librarian) {
      return [
        {
          'index': 0,
          'title': 'Borrow & Return',
          'icon': Icons.swap_horiz,
        },
        {
          'index': 1,
          'title': 'Notifications',
          'icon': Icons.notifications_outlined,
        },
      ];
    } else {
      return [
        {'index': 0, 'title': 'Reader Home', 'icon': Icons.home_outlined},
        {'index': 1, 'title': 'My Books', 'icon': Icons.bookmark_outline},
        {
          'index': 2,
          'title': 'Reservations',
          'icon': Icons.calendar_month_outlined
        },
      ];
    }
  }

  Widget _buildCurrentScreen() {
    if (_currentRole == UserRole.admin) {
      switch (_selectedNavIndex) {
        case 1:
          return const AdminSettingsScreen();
        case 2:
          return const StaffManagementScreen();
        case 3:
        default:
          return const AdminInventoryScreen();
      }
    } else if (_currentRole == UserRole.librarian) {
  switch (_selectedNavIndex) {
    case 1:
      return const LibrarianNotificationsScreen();
    case 0:
    default:
      return const LibrarianDeskScreen();
  }
}else {
      switch (_selectedNavIndex) {
        case 1:
          return const ReaderMyBooksScreen();
        case 2:
          return const ReaderReservationsScreen();
        case 0:
        default:
          return ReaderHomeScreen(
            onNavigateToMyBooks: () {
              setState(() => _selectedNavIndex = 1);
            },
          );
      }
    }
  }
}
