import 'package:flutter/material.dart';

import '../../domain/entities/library_notification.dart';
import '../../../../core/di/injector.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/mark_notification_as_read.dart';

class LibrarianNotificationsScreen extends StatefulWidget {
  const LibrarianNotificationsScreen({super.key});

  @override
  State<LibrarianNotificationsScreen> createState() =>
      _LibrarianNotificationsScreenState();
}

class _LibrarianNotificationsScreenState
    extends State<LibrarianNotificationsScreen> {
  static const Color primaryBlue = Color(0xFFF25635);
  static const Color filterColor = Color(0xFF514746);
  static const Color pageBackground = Color(0xFFFBF1E4);

  final GetNotifications _getNotificationsUseCase = injector.getNotifications;

  final MarkNotificationAsRead _markNotificationAsReadUseCase =
      injector.markNotificationAsRead;

  String _selectedFilter = 'All';
  List<LibraryNotification> _notifications = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final notifications = await _getNotificationsUseCase();

      if (!mounted) return;

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  String _typeForFilter(String filter) {
    switch (filter) {
      case 'Due Soon':
        return 'DUE_SOON';
      case 'Overdue':
        return 'OVERDUE';
      case 'Reservations':
        return 'RESERVATION';
      case 'Announcements':
        return 'ANNOUNCEMENT';
      default:
        return '';
    }
  }

  List<LibraryNotification> get _filteredNotifications {
    if (_selectedFilter == 'All') return _notifications;

    final type = _typeForFilter(_selectedFilter);

    return _notifications
        .where((notification) => notification.notificationType == type)
        .toList();
  }

  int _countFor(String filter) {
    if (filter == 'All') return _notifications.length;

    final type = _typeForFilter(filter);

    return _notifications
        .where((notification) => notification.notificationType == type)
        .length;
  }

  NotificationType _notificationType(LibraryNotification notification) {
    switch (notification.notificationType) {
      case 'OVERDUE':
        return NotificationType.overdue;
      case 'DUE_SOON':
        return NotificationType.dueSoon;
      case 'RESERVATION':
        return NotificationType.reservation;
      default:
        return NotificationType.announcement;
    }
  }

  IconData _notificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.overdue:
        return Icons.notifications_active;
      case NotificationType.dueSoon:
        return Icons.access_time_filled;
      case NotificationType.reservation:
        return Icons.calendar_month;
      case NotificationType.announcement:
        return Icons.campaign;
    }
  }

  Color _notificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.overdue:
        return const Color(0xFFEF4444);
      case NotificationType.dueSoon:
        return const Color(0xFFF25635);
      case NotificationType.reservation:
        return const Color(0xFF059E83);
      case NotificationType.announcement:
        return const Color(0xFFF25635);
    }
  }

  Color _notificationBackground(NotificationType type) {
    switch (type) {
      case NotificationType.overdue:
        return const Color(0xFFFFECEF);
      case NotificationType.dueSoon:
        return const Color(0xFFFBE2D9);
      case NotificationType.reservation:
        return const Color(0xFFE0F7F0);
      case NotificationType.announcement:
        return const Color(0xFFFBE2D9);
    }
  }

  String _statusLabel(NotificationType type) {
    switch (type) {
      case NotificationType.overdue:
        return 'Overdue';
      case NotificationType.dueSoon:
        return 'Due Soon';
      case NotificationType.reservation:
        return 'Reservation';
      case NotificationType.announcement:
        return 'Announcement';
    }
  }

  String _timeAgo(DateTime? date) {
    if (date == null) return '';

    final difference = DateTime.now().difference(date.toLocal());

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) {
      return '${difference.inMinutes} min ago';
    }
    if (difference.inDays < 1) {
      return '${difference.inHours} hours ago';
    }
    if (difference.inDays == 1) return '1 day ago';

    return '${difference.inDays} days ago';
  }

  Future<void> _openNotification(LibraryNotification notification) async {
    if (!notification.isRead) {
      try {
        await _markNotificationAsReadUseCase(notification.notificationId);

        if (!mounted) return;

        setState(() {
          final index = _notifications.indexWhere(
            (item) => item.notificationId == notification.notificationId,
          );

          if (index != -1) {
            final old = _notifications[index];

            _notifications[index] = LibraryNotification(
              notificationId: old.notificationId,
              title: old.title,
              message: old.message,
              details: old.details,
              createdAt: old.createdAt,
              notificationType: old.notificationType,
              isRead: true,
            );
          }
        });
      } catch (e) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not mark as read: $e')),
        );
      }
    }

    if (!mounted) return;

    final type = _notificationType(notification);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final color = _notificationColor(type);

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Icon(_notificationIcon(type), color: color),
              const SizedBox(width: 12),
              Expanded(child: Text(notification.title)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(notification.message),
              if (notification.details != null) ...[
                const SizedBox(height: 12),
                Text(
                  notification.details!,
                  style: const TextStyle(
                    color: Colors.black54,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text(
                _timeAgo(notification.createdAt),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filters = [
      ('All', Icons.notifications_none),
      ('Due Soon', Icons.access_time),
      ('Overdue', Icons.warning_amber_rounded),
      ('Reservations', Icons.calendar_month),
      ('Announcements', Icons.campaign_outlined),
    ];

    return Container(
      color: pageBackground,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 700;

            if (_isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryBlue,
                ),
              );
            }

            if (_error != null) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_off,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Unable to load notifications',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _loadNotifications,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              padding: EdgeInsets.all(compact ? 16 : 24),
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Notifications',
                        style: TextStyle(
                          color: Color(0xFF514746),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Refresh notifications',
                      onPressed: _loadNotifications,
                      icon: const Icon(
                        Icons.refresh,
                        color: primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Stay updated with upcoming due dates, overdue books, '
                  'reservations, and library announcements.',
                  style: TextStyle(
                    color: Color(0xFFF25635),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 22),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: filters.map((filter) {
                      final selected = _selectedFilter == filter.$1;

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Material(
                          color: selected ? filterColor : Colors.white,
                          borderRadius: BorderRadius.circular(9),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(9),
                            onTap: () {
                              setState(() {
                                _selectedFilter = filter.$1;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(
                                  color: selected
                                      ? filterColor
                                      : filterColor.withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    filter.$2,
                                    size: 17,
                                    color:
                                        selected ? Colors.white : filterColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${filter.$1} (${_countFor(filter.$1)})',
                                    style: TextStyle(
                                      color:
                                          selected ? Colors.white : filterColor,
                                      fontWeight: selected
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                if (_filteredNotifications.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.notifications_off_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text('No notifications in this category.'),
                      ],
                    ),
                  )
                else
                  ..._filteredNotifications.map((notification) {
                    final type = _notificationType(notification);
                    final color = _notificationColor(type);
                    final background = _notificationBackground(type);

                    // The bottom spacing is outside the hover widget
                    // so the blue border only wraps the card itself.
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _HoverLift(
                        radius: 12,
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Color(0xFFFBE2D9),
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () => _openNotification(notification),
                            child: Padding(
                              padding: EdgeInsets.all(compact ? 12 : 16),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: compact ? 23 : 28,
                                    backgroundColor: background,
                                    child: Icon(
                                      _notificationIcon(type),
                                      color: color,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notification.title,
                                          style: TextStyle(
                                            color: primaryBlue,
                                            fontSize: 14,
                                            fontWeight: notification.isRead
                                                ? FontWeight.w500
                                                : FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 7),
                                        Text(
                                          notification.message,
                                          style: const TextStyle(
                                            color: Color(0xFFF25635),
                                            fontSize: 13,
                                            height: 1.4,
                                          ),
                                        ),
                                        if (notification.details != null) ...[
                                          const SizedBox(height: 5),
                                          Text(
                                            notification.details!,
                                            style: const TextStyle(
                                              color: Color(0xFFF25635),
                                              fontSize: 12,
                                              height: 1.4,
                                            ),
                                          ),
                                        ],
                                        const SizedBox(height: 10),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: background,
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            _statusLabel(type),
                                            style: TextStyle(
                                              color: color,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _timeAgo(notification.createdAt),
                                        style: const TextStyle(
                                          color: Color(0xFFF25635),
                                          fontSize: 11,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Icon(
                                        Icons.chevron_right,
                                        color: primaryBlue,
                                        size: 22,
                                      ),
                                      if (!notification.isRead)
                                        Container(
                                          width: 7,
                                          height: 7,
                                          margin: const EdgeInsets.only(top: 8),
                                          decoration: const BoxDecoration(
                                            color: primaryBlue,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}

// =============================================================
// HOVER ANIMATION (lift + shadow + blue border)
// Used by the notification cards.
// =============================================================

class _HoverLift extends StatefulWidget {
  final Widget child;
  final double radius;

  const _HoverLift({
    required this.child,
    this.radius = 14,
  });

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          0,
          _isHovered ? -4 : 0,
          0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : const [],
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(
            color: _isHovered ? Colors.white : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
