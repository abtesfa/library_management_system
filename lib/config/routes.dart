import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/reader/reader_notification_screen.dart';
import '../screens/reader/reader_reservation_screen.dart';
import '../screens/reader/my_books_screen.dart';
import '../screens/shell/main_layout_shell.dart';
import '../screens/reader/reader_home_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/reader/home',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainLayoutShell(child: child),
      routes: [
        // Reader routes
        GoRoute(
          path: '/reader/home',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ReaderHomeScreen()),
        ),
        GoRoute(
          path: '/reader/books',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: MyBooksScreen()),
        ),
        GoRoute(
          path: '/reader/reservations',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ReaderReservationsScreen()),
        ),
        GoRoute(
          path: '/reader/notifications',
          pageBuilder: (context, state) =>
              const NoTransitionPage(child: ReaderNotificationsScreen()),
        ),

        // Librarian routes
        GoRoute(
          path: '/librarian/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: _PlaceholderScreen(title: 'Librarian Dashboard'),
          ),
        ),
        GoRoute(
          path: '/librarian/circulation',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: _PlaceholderScreen(title: 'Borrow & Return Desk'),
          ),
        ),
        GoRoute(
          path: '/librarian/notifications',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: _PlaceholderScreen(title: 'Librarian Notifications'),
          ),
        ),

        // Admin routes
        GoRoute(
          path: '/admin/dashboard',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: _PlaceholderScreen(title: 'Admin Dashboard'),
          ),
        ),
        GoRoute(
          path: '/admin/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: _PlaceholderScreen(title: 'LMS Settings'),
          ),
        ),
        GoRoute(
          path: '/admin/staff',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: _PlaceholderScreen(title: 'Staff Management'),
          ),
        ),
        GoRoute(
          path: '/admin/inventory',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: _PlaceholderScreen(title: 'Book Inventory'),
          ),
        ),
      ],
    ),
  ],
);

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
      ),
    );
  }
}
