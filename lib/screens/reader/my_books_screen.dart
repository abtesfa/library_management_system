import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/app_theme.dart';
import '../../models/borrow_record.dart';
import '../../providers/circulation_provider.dart';
import '../../widgets/charts/circular_progress_gauge.dart';
import '../../widgets/common/book_cover_thumb.dart';
import '../../widgets/common/category_badge.dart';
import '../../widgets/common/kpi_stat_card.dart';
import '../../widgets/common/status_badge.dart';

class MyBooksScreen extends StatelessWidget {
  const MyBooksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final circulation = context.watch<CirculationProvider>();

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
                  'My Books',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Manage your borrowed books, due dates, and reading history.',
                  style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),

                // Search & Filter/Sort bar
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
                            hintText: 'Search my books...',
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
                      label: const Text('Filter & Sort'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        backgroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Top 4 Metric KPI Cards Row
                Row(
                  children: [
                    Expanded(
                      child: KpiStatCard(
                        icon: Icons.menu_book,
                        value: '${circulation.currentlyBorrowedCount}',
                        title: 'Currently Borrowed',
                        subtitle: 'Books',
                        iconBgColor: AppColors.infoBg,
                        iconColor: AppColors.info,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KpiStatCard(
                        icon: Icons.access_time,
                        value: '${circulation.dueSoonCount}',
                        title: 'Due Soon',
                        subtitle: 'Book',
                        iconBgColor: AppColors.warningBg,
                        iconColor: AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KpiStatCard(
                        icon: Icons.warning_amber_rounded,
                        value: '${circulation.overdueCount}',
                        title: 'Overdue',
                        subtitle: 'Books',
                        iconBgColor: AppColors.errorBg,
                        iconColor: AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: KpiStatCard(
                        icon: Icons.check_circle_outline,
                        value: '${circulation.completedCount}',
                        title: 'Completed',
                        subtitle: 'Books',
                        iconBgColor: AppColors.successBg,
                        iconColor: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Currently Borrowed List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.menu_book, color: AppColors.sidebarBlue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Currently Borrowed',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
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
                const SizedBox(height: 12),

                // Active Borrowed Cards List
                ...circulation.activeBorrows.map((record) => _buildActiveBorrowCard(record)),
                const SizedBox(height: 28),

                // Borrowing History Table Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.history, color: AppColors.sidebarBlue, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Borrowing History',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Row(
                        children: [
                          Text('View All History'),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 14),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // History Table Container
                _buildHistoryTable(circulation.borrowingHistory),
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
                _buildReadingProgressCard(),
                const SizedBox(height: 24),
                _buildRecentlyReturnedCard(),
                const SizedBox(height: 24),
                _buildRecommendationBanner(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Active loan item card matching mockup
  Widget _buildActiveBorrowCard(BorrowRecord record) {
    Color chipBg = AppColors.infoBg;
    Color chipText = AppColors.infoText;
    if (record.dueCountdown.contains('2 days')) {
      chipBg = AppColors.warningBg;
      chipText = AppColors.warningText;
    } else if (record.dueCountdown.contains('5 days')) {
      chipBg = const Color(0xFFFFFBEB);
      chipText = const Color(0xFFB45309);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BookCoverThumb(title: record.bookTitle, width: 50, height: 70),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.bookTitle,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(
                  record.author,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                CategoryBadge(category: record.category),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Borrowed', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(record.borrowedDate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Due', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: AppColors.textSecondary),
                    const SizedBox(width: 4),
                    Text(record.dueDate, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(12)),
                child: Text(
                  record.dueCountdown,
                  style: TextStyle(color: chipText, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('View Details', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('Renew', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Borrowing history table
  Widget _buildHistoryTable(List<BorrowRecord> history) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.tableHeaderBg,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10)),
            ),
            child: Row(
              children: const [
                Expanded(flex: 3, child: Text('Book Title', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('Borrowed Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary))),
                Expanded(flex: 2, child: Text('Returned / Due Date', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary))),
                Expanded(flex: 1, child: Text('Status', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.textSecondary))),
              ],
            ),
          ),
          ...history.map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderSubtle)),
              ),
              child: Row(
                children: [
                  Expanded(flex: 3, child: Text(item.bookTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary))),
                  Expanded(flex: 2, child: Text(item.borrowedDate, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                  Expanded(flex: 2, child: Text(item.returnedDate ?? item.dueDate, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary))),
                  const Expanded(
                    flex: 1,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: StatusBadge(label: 'Returned', type: StatusBadgeType.completed),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Pagination footer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _pageBtn(icon: Icons.chevron_left, onPressed: null),
                const SizedBox(width: 4),
                _pageNumber(1, isActive: true),
                const SizedBox(width: 4),
                _pageNumber(2),
                const SizedBox(width: 4),
                _pageNumber(3),
                const SizedBox(width: 4),
                _pageBtn(icon: Icons.chevron_right, onPressed: () {}),
              ],
            ),
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

  // Reading progress card with circular gauge
  Widget _buildReadingProgressCard() {
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
              Icon(Icons.trending_up, color: AppColors.sidebarBlue, size: 18),
              SizedBox(width: 8),
              Text('Reading Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const CircularProgressGauge(current: 8, target: 12),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Books completed\nthis month', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, height: 1.2)),
                    SizedBox(height: 6),
                    Text('Keep going, Abiye!\nYou\'re on a great pace.', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.borderSubtle),
          const SizedBox(height: 12),
          InkWell(
            onTap: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('View Reading History', style: TextStyle(color: AppColors.primaryBlue, fontSize: 12, fontWeight: FontWeight.w600)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 14, color: AppColors.primaryBlue),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Recently returned list
  Widget _buildRecentlyReturnedCard() {
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
                  Icon(Icons.history, color: AppColors.sidebarBlue, size: 18),
                  SizedBox(width: 8),
                  Text('Recently Returned', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              const Text('View All →', style: TextStyle(fontSize: 12, color: AppColors.primaryBlue)),
            ],
          ),
          const SizedBox(height: 14),
          _returnedItem('Clean Code', 'Robert C. Martin', 'Oct 1, 2026'),
          const Divider(height: 20, color: AppColors.borderSubtle),
          _returnedItem('Sapiens', 'Yuval Noah Harari', 'Sep 27, 2026'),
          const Divider(height: 20, color: AppColors.borderSubtle),
          _returnedItem('1984', 'George Orwell', 'Sep 20, 2026'),
        ],
      ),
    );
  }

  Widget _returnedItem(String title, String author, String returnDate) {
    return Row(
      children: [
        BookCoverThumb(title: title, width: 40, height: 48),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              Text(author, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            const Text('Returned', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
            Text(returnDate, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  // Book recommendation prompt box
  Widget _buildRecommendationBanner() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: AppColors.infoBg, shape: BoxShape.circle),
                child: const Icon(Icons.lightbulb_outline, color: AppColors.info, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text('Need a book recommendation?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Discover books tailored to your interests and reading history.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 38),
            ),
            child: const Text('Explore Recommendations'),
          ),
        ],
      ),
    );
  }
}