import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/book.dart';
import '../../providers/autho_role.dart';
import '../../providers/book_provider.dart';
import '../../widgets/common/book_cover_thumb.dart';
import '../../widgets/common/category_badge.dart';
import '../../widgets/common/kpi_stat_card.dart';

class ReaderHomeScreen extends StatefulWidget {
  const ReaderHomeScreen({super.key});

  @override
  State<ReaderHomeScreen> createState() => _ReaderHomeScreenState();
}

class _ReaderHomeScreenState extends State<ReaderHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthRoleProvider>();
    final bookProvider = context.watch<BookProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------------------------------------------
          // LEFT / MAIN COLUMN (~70% width)
          // ---------------------------------------------
          Expanded(
            flex: 7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Welcome Title
                Text(
                  'Welcome back, ${auth.userName.split(' ').first}!',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Discover new books, continue your reading journey, and explore the library\'s resources.',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Search Bar with Integrated Blue Button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Icon(Icons.search, color: AppColors.textMuted),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => bookProvider.setSearchQuery(val),
                          decoration: const InputDecoration(
                            hintText: 'Search for books, authors, or genres...',
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: ElevatedButton.icon(
                          onPressed: () => bookProvider.setSearchQuery(_searchController.text),
                          icon: const Icon(Icons.search, size: 16),
                          label: const Text('Search'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Hero Banner
                Container(
                  height: 190,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F3274), Color(0xFF1E5BB5)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        width: 340,
                        child: ShaderMask(
                          shaderCallback: (rect) {
                            return const LinearGradient(
                              colors: [Colors.transparent, Colors.black],
                              stops: [0.0, 0.4],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Image.network(
                            'https://images.unsplash.com/photo-1521587760476-6c12a4b040da?auto=format&fit=crop&w=900&q=80',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text(
                              'Good Books\nBuild Better Futures',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                height: 1.25,
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Explore new worlds, gain new perspectives,\nand keep reading!',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Recommended Books Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.menu_book, color: AppColors.sidebarBlue, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'Recommended Books',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Row(
                        children: [
                          Text('View All'),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Recommended Books Grid / Horizontal Row
                LayoutBuilder(
                  builder: (context, constraints) {
                    final books = bookProvider.recommendedBooks;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: books.map((book) => _buildBookCard(book)).toList(),
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // ---------------------------------------------
          // RIGHT RAIL (~30% width)
          // ---------------------------------------------
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reading Summary Title
                Row(
                  children: const [
                    Icon(Icons.menu_book, color: AppColors.sidebarBlue, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'My Reading Summary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 2x2 Metric Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                  children: const [
                    KpiStatCard(
                      icon: Icons.menu_book,
                      title: 'Books Borrowed',
                      value: '3',
                      iconBgColor: AppColors.infoBg,
                      iconColor: AppColors.info,
                    ),
                    KpiStatCard(
                      icon: Icons.access_time,
                      title: 'Due Soon',
                      value: '1',
                      iconBgColor: AppColors.infoBg,
                      iconColor: AppColors.info,
                    ),
                    KpiStatCard(
                      icon: Icons.calendar_today,
                      title: 'Reservation(s)',
                      value: '1',
                      iconBgColor: AppColors.infoBg,
                      iconColor: AppColors.info,
                    ),
                    KpiStatCard(
                      icon: Icons.notifications,
                      title: 'Notifications',
                      value: '2',
                      iconBgColor: AppColors.errorBg,
                      iconColor: AppColors.error,
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Upcoming Due Dates Section
                _buildUpcomingDueCard(),
                const SizedBox(height: 24),

                // Recent Notifications Section
                _buildRecentNotificationsCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Book Card Widget (matching Readerhom1)
  Widget _buildBookCard(Book book) {
    return Container(
      width: 155,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: BookCoverThumb(
              title: book.title,
              width: 110,
              height: 150,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            book.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            book.author,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          CategoryBadge(category: book.category),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.calendar_today, size: 12),
              label: const Text('Reserve', style: TextStyle(fontSize: 12)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Upcoming Due Dates Box
  Widget _buildUpcomingDueCard() {
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
            children: [
              Row(
                children: const [
                  Icon(Icons.calendar_month_outlined, color: AppColors.sidebarBlue, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Upcoming Due Dates',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              const Row(
                children: [
                  Text('View All', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue)),
                  Icon(Icons.arrow_forward, size: 12, color: AppColors.primaryBlue),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          _dueItem('Atomic Habits', 'James Clear', 'Due in 2 days', AppColors.errorBg, AppColors.errorText),
          const Divider(height: 20, color: AppColors.borderSubtle),
          _dueItem('Dune', 'Frank Herbert', 'Due in 5 days', AppColors.warningBg, AppColors.warningText),
          const Divider(height: 20, color: AppColors.borderSubtle),
          _dueItem('The Great Gatsby', 'F. Scott Fitzgerald', 'Due in 7 days', AppColors.infoBg, AppColors.infoText),
        ],
      ),
    );
  }

  Widget _dueItem(String title, String author, String chipLabel, Color chipBg, Color chipText) {
    return Row(
      children: [
        BookCoverThumb(title: title, width: 34, height: 48),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              Text(
                author,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(12)),
          child: Text(
            chipLabel,
            style: TextStyle(color: chipText, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  // Recent Notifications Box
  Widget _buildRecentNotificationsCard() {
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
            children: [
              Row(
                children: const [
                  Icon(Icons.notifications_none, color: AppColors.sidebarBlue, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Recent Notifications',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ],
              ),
              const Row(
                children: [
                  Text('View All', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue)),
                  Icon(Icons.arrow_forward, size: 12, color: AppColors.primaryBlue),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          _notificationRow(
            Icons.notifications,
            AppColors.errorBg,
            AppColors.error,
            'Your book "Atomic Habits" is due in 2 days.',
            '2 hours ago',
          ),
          const Divider(height: 20, color: AppColors.borderSubtle),
          _notificationRow(
            Icons.info,
            AppColors.infoBg,
            AppColors.info,
            'Your reservation for "The Martian" is now available.',
            '1 day ago',
          ),
        ],
      ),
    );
  }

  Widget _notificationRow(IconData icon, Color iconBg, Color iconColor, String title, String time) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}