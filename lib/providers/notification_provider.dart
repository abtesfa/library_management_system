import 'package:flutter/material.dart';
import '../models/notification_item.dart';

class NotificationProvider extends ChangeNotifier {
  String _selectedFilter = 'All';
  String get selectedFilter => _selectedFilter;

  // Toggle switch preferences matching readerhom4
  bool bookDueReminders = true;
  bool reservationAlerts = true;
  bool generalAnnouncements = true;
  bool overdueAlerts = true;

  // Notifications matching mockup readerhom4
  final List<NotificationItem> _notifications = [
    const NotificationItem(
      id: 'n1',
      title: 'Your book "Atomic Habits" is due in 2 days.',
      description: 'Please return or renew it to avoid late fees.',
      timeAgo: '2 hours ago',
      category: NotificationCategory.books,
      priority: NotificationPriority.urgent,
      isUnread: true,
    ),
    const NotificationItem(
      id: 'n2',
      title: 'Your reservation for "The Martian" is now available.',
      description: 'Please pick it up by May 20, 2026.',
      timeAgo: '1 day ago',
      category: NotificationCategory.reservations,
      priority: NotificationPriority.info,
      isUnread: true,
    ),
    const NotificationItem(
      id: 'n3',
      title: 'Reservation ready for pickup',
      description: '"The Great Gatsby" is ready for pickup at Central Library.',
      timeAgo: '2 days ago',
      category: NotificationCategory.reservations,
      priority: NotificationPriority.info,
      isUnread: true,
    ),
    const NotificationItem(
      id: 'n4',
      title: '"Dune" has been renewed successfully.',
      description: 'New due date: May 20, 2026.',
      timeAgo: '3 days ago',
      category: NotificationCategory.books,
      priority: NotificationPriority.success,
      isUnread: false,
    ),
    const NotificationItem(
      id: 'n5',
      title: 'Library will be closed on May 26, 2026.',
      description: 'Memorial Day - All branches will remain closed.',
      timeAgo: '5 days ago',
      category: NotificationCategory.general,
      priority: NotificationPriority.normal,
      isUnread: false,
    ),
    const NotificationItem(
      id: 'n6',
      title: 'Welcome to the Library!',
      description: 'Thank for being a valued member. Explore, read, and grow.',
      timeAgo: 'May 5, 2026',
      category: NotificationCategory.general,
      priority: NotificationPriority.normal,
      isUnread: false,
    ),
  ];

  List<NotificationItem> get filteredNotifications {
    if (_selectedFilter == 'All') return _notifications;
    if (_selectedFilter.startsWith('Unread')) {
      return _notifications.where((n) => n.isUnread).toList();
    }
    if (_selectedFilter.startsWith('Books')) {
      return _notifications.where((n) => n.category == NotificationCategory.books).toList();
    }
    if (_selectedFilter.startsWith('Reservations')) {
      return _notifications.where((n) => n.category == NotificationCategory.reservations).toList();
    }
    if (_selectedFilter.startsWith('General')) {
      return _notifications.where((n) => n.category == NotificationCategory.general).toList();
    }
    return _notifications;
  }

  int get unreadCount => _notifications.where((n) => n.isUnread).length;
  int get booksCount => _notifications.where((n) => n.category == NotificationCategory.books).length;
  int get reservationsCount => _notifications.where((n) => n.category == NotificationCategory.reservations).length;
  int get generalCount => _notifications.where((n) => n.category == NotificationCategory.general).length;

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      _notifications[i] = _notifications[i].copyWith(isUnread: false);
    }
    notifyListeners();
  }

  void toggleBookDue(bool val) {
    bookDueReminders = val;
    notifyListeners();
  }

  void toggleReservationAlerts(bool val) {
    reservationAlerts = val;
    notifyListeners();
  }

  void toggleAnnouncements(bool val) {
    generalAnnouncements = val;
    notifyListeners();
  }

  void toggleOverdue(bool val) {
    overdueAlerts = val;
    notifyListeners();
  }
}