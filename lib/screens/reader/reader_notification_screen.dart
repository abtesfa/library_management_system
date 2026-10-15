import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/notification_item.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/common/kpi_stat_card.dart';

class ReaderNotificationsScreen extends StatelessWidget {
  const ReaderNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------
          // LEFT MAIN COLUMN (~70%)
          // ----------------------------------------------------
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Stay updated with important alerts and library updates.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                // Top Search & Actions Bar
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: const TextField(
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.search, size: 20, color: AppColors.textMuted),
                            hintText: 'Search notifications...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.filter_list, size: 16),
                      label: const Text('Filter'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () => notifProvider.markAllAsRead(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        backgroundColor: Colors.white,
                      ),
                      child: const Text('Mark All as Read'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Segmented Tabs Filter Bar
                Row(
                  children: [
                    _filterTab(context, 'All', notifProvider.selectedFilter == 'All'),
                    _filterTab(context, 'Unread (${notifProvider.unreadCount})', notifProvider.selectedFilter.startsWith('Unread')),
                    _filterTab(context, 'Books (${notifProvider.booksCount})', notifProvider.selectedFilter.startsWith('Books')),
                    _filterTab(context, 'Reservations (${notifProvider.reservationsCount})', notifProvider.selectedFilter.startsWith('Reservations')),
                    _filterTab(context, 'General (${notifProvider.generalCount})', notifProvider.selectedFilter.startsWith('General')),
                  ],
                ),
                const SizedBox(height: 20),

                // Notification Feed List Container
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      ...notifProvider.filteredNotifications.map((item) => _buildNotificationTile(item)),
                      // Pagination Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _pageBtn(icon: Icons.chevron_left, onPressed: null),
                            const SizedBox(width: 6),
                            _pageNumber(1, isActive: true),
                            const SizedBox(width: 4),
                            _pageNumber(2),
                            const SizedBox(width: 4),
                            _pageNumber(3),
                            const SizedBox(width: 6),
                            _pageBtn(icon: Icons.chevron_right, onPressed: () {}),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // ----------------------------------------------------
          // RIGHT COLUMN (~30%)
          // ----------------------------------------------------
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section Title
                Row(
                  children: const [
                    Icon(Icons.notifications_none, color: AppColors.sidebarBlue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Notification Summary',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 2x2 Notification Metric Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: [
                    KpiStatCard(
                      icon: Icons.notifications,
                      title: 'Unread',
                      value: '${notifProvider.unreadCount}',
                      iconBgColor: AppColors.infoBg,
                      iconColor: AppColors.info,
                    ),
                    const KpiStatCard(
                      icon: Icons.mark_email_read_outlined,
                      title: 'This Week',
                      value: '4',
                      iconBgColor: AppColors.successBg,
                      iconColor: AppColors.success,
                    ),
                    const KpiStatCard(
                      icon: Icons.chat_bubble_outline,
                      title: 'This Month',
                      value: '12',
                      iconBgColor: Color(0xFFF3E8FF),
                      iconColor: Color(0xFF7E22CE),
                    ),
                    const KpiStatCard(
                      icon: Icons.campaign_outlined,
                      title: 'All Notifications',
                      value: '28',
                      iconBgColor: AppColors.warningBg,
                      iconColor: AppColors.warning,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Recent Unread Preview Box
                _buildRecentUnreadCard(notifProvider),
                const SizedBox(height: 24),

                // Notification Preferences Box
                _buildPreferencesCard(notifProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterTab(BuildContext context, String title, bool isSelected) {
    return InkWell(
      onTap: () => context.read<NotificationProvider>().setFilter(title),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.infoBg : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(NotificationItem item) {
    Color iconBg = AppColors.infoBg;
    Color iconColor = AppColors.info;
    IconData icon = Icons.notifications;

    if (item.priority == NotificationPriority.urgent) {
      iconBg = AppColors.errorBg;
      iconColor = AppColors.error;
      icon = Icons.notifications_active;
    } else if (item.priority == NotificationPriority.success) {
      iconBg = AppColors.successBg;
      iconColor = AppColors.success;
      icon = Icons.menu_book;
    } else if (item.category == NotificationCategory.reservations) {
      iconBg = const Color(0xFFFFFBEB);
      iconColor = const Color(0xFFD97706);
      icon = Icons.hourglass_empty;
    } else if (item.category == NotificationCategory.general) {
      iconBg = const Color(0xFFF3E8FF);
      iconColor = const Color(0xFF7E22CE);
      icon = Icons.campaign;
    }

    String categoryLabel = 'General';
    if (item.category == NotificationCategory.books) categoryLabel = 'Books';
    if (item.category == NotificationCategory.reservations) categoryLabel = 'Reservations';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderSubtle)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.borderSubtle,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    categoryLabel,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(item.timeAgo, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
              const SizedBox(height: 12),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: item.isUnread ? AppColors.primaryBlue : Colors.transparent,
                  border: !item.isUnread ? Border.all(color: AppColors.textMuted, width: 1.5) : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pageNumber(int number, {bool isActive = false}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Text(
          '$number',
          style: TextStyle(
            color: isActive ? Colors.white : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _pageBtn({required IconData icon, VoidCallback? onPressed}) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(icon, size: 16, color: onPressed != null ? AppColors.textPrimary : AppColors.textMuted),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildRecentUnreadCard(NotificationProvider notifProvider) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Recent Unread', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('View All →', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue)),
            ],
          ),
          const SizedBox(height: 14),
          _unreadItem(
            Icons.notifications,
            AppColors.errorBg,
            AppColors.error,
            'Your book "Atomic Habits" is due in 2 days.',
            '2 hours ago',
          ),
          const Divider(height: 20, color: AppColors.borderSubtle),
          _unreadItem(
            Icons.calendar_today,
            AppColors.infoBg,
            AppColors.info,
            'Your reservation for "The Martian" is now available.',
            '1 day ago',
          ),
        ],
      ),
    );
  }

  Widget _unreadItem(IconData icon, Color bg, Color iconColor, String title, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreferencesCard(NotificationProvider notif) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.settings_outlined, color: AppColors.sidebarBlue, size: 18),
              SizedBox(width: 8),
              Text('Notification Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          _toggleRow('Book Due Reminders', 'Get reminded before books are due.', notif.bookDueReminders, notif.toggleBookDue),
          const SizedBox(height: 12),
          _toggleRow('Reservation Alerts', 'Get notified when reservations are ready.', notif.reservationAlerts, notif.toggleReservationAlerts),
          const SizedBox(height: 12),
          _toggleRow('General Announcements', 'News and updates from the library.', notif.generalAnnouncements, notif.toggleAnnouncements),
          const SizedBox(height: 12),
          _toggleRow('Overdue Alerts', 'Alerts for overdue books.', notif.overdueAlerts, notif.toggleOverdue),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Manage Preferences', style: TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.w600)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 14, color: AppColors.primaryBlue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleRow(String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            ],
          ),
        ),
        Transform.scale(
          scale: 0.75,
          child: Switch(
            value: value,
            activeColor: AppColors.primaryBlue,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}