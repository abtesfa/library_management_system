import 'package:flutter/material.dart';

class LibrarianDashboard extends StatefulWidget {
  const LibrarianDashboard({super.key});

  @override
  State<LibrarianDashboard> createState() => _LibrarianDashboardState();
}

class _LibrarianDashboardState extends State<LibrarianDashboard> {
  static const Color primary = Color(0xFF0066F5);
  static const Color navy = Color(0xFF073A83);
  static const Color background = Color(0xFFF3F9FF);
  static const Color borderColor = Color(0xFFD8EAFE);

  int selectedMenu = 0;
  final TextEditingController searchController = TextEditingController();

  final List<Map<String, dynamic>> borrowingActivity = [
    {
      'date': '2025-06-08',
      'id': 'S-00123',
      'student': 'Abebe Kebede',
      'book': 'Clean Code',
      'isbn': '978-0132357059',
      'due': '2025-06-22',
      'status': 'Active',
    },
    {
      'date': '2025-06-07',
      'id': 'S-00145',
      'student': 'Selam Tesfaye',
      'book': 'The Great Gatsby',
      'isbn': '978-0743273567',
      'due': '2025-06-21',
      'status': 'Active',
    },
    {
      'date': '2025-06-06',
      'id': 'S-00167',
      'student': 'Mekdes Alemu',
      'book': 'Atomic Habits',
      'isbn': '978-0735211292',
      'due': '2025-06-20',
      'status': 'Active',
    },
    {
      'date': '2025-06-05',
      'id': 'S-00102',
      'student': 'Yonas Tadesse',
      'book': 'Dune',
      'isbn': '978-0441013593',
      'due': '2025-06-19',
      'status': 'Overdue',
    },
    {
      'date': '2025-06-03',
      'id': 'S-00178',
      'student': 'Hana Girma',
      'book': 'Sapiens',
      'isbn': '978-0062316097',
      'due': '2025-06-17',
      'status': 'Returned',
    },
  ];

  final List<Map<String, dynamic>> dueBooks = [
    {
      'title': 'Atomic Habits',
      'author': 'James Clear',
      'due': 'Due in 2 days',
      'color': Color(0xFFFFE9E9),
      'textColor': Color(0xFFFF4141),
      'icon': Icons.menu_book_rounded,
    },
    {
      'title': 'Dune',
      'author': 'Frank Herbert',
      'due': 'Due in 5 days',
      'color': Color(0xFFFFF3E0),
      'textColor': Color(0xFFFF9800),
      'icon': Icons.auto_stories_rounded,
    },
    {
      'title': 'The Great Gatsby',
      'author': 'F. Scott Fitzgerald',
      'due': 'Due in 7 days',
      'color': Color(0xFFE7F2FF),
      'textColor': Color(0xFF0875F5),
      'icon': Icons.book_rounded,
    },
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void searchLibrary() {
    final query = searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      showMessage('Enter a student name, book title, or ISBN.');
      return;
    }

    final results = borrowingActivity.where((item) {
      return item['student'].toString().toLowerCase().contains(query) ||
          item['book'].toString().toLowerCase().contains(query) ||
          item['isbn'].toString().toLowerCase().contains(query) ||
          item['id'].toString().toLowerCase().contains(query);
    }).toList();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Search Results'),
        content: SizedBox(
          width: 420,
          child: results.isEmpty
              ? const Text('No matching borrowing records were found.')
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: results.map((item) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(item['book']),
                      subtitle: Text(
                        '${item['student']} • ${item['id']}',
                      ),
                      trailing: Text(item['status']),
                    );
                  }).toList(),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Row(
                children: [
                  _buildSidebar(),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 1100;

                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16),
                          child: isWide
                              ? _buildWideDashboard()
                              : _buildCompactDashboard(),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HEADER
  // ------------------------------------------------------------

  Widget _buildHeader() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF073779), Color(0xFF0066D9)],
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 44,
            width: 44,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 31,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text(
              'Library Management System',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => showMessage('You have 3 notifications.'),
                icon: const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              Positioned(
                right: 5,
                top: 3,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const CircleAvatar(
            radius: 19,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: primary,
              size: 27,
            ),
          ),
          const SizedBox(width: 10),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ms. Sara Ahmed',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Librarian',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
            onSelected: (value) {
              if (value == 'Logout') {
                showMessage('Connect this action to your logout logic.');
              } else {
                showMessage('Profile selected.');
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'Profile',
                child: Text('My Profile'),
              ),
              PopupMenuItem(
                value: 'Logout',
                child: Text('Logout'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // SIDEBAR
  // ------------------------------------------------------------

  Widget _buildSidebar() {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF073779),
            Color(0xFF00458E),
            Color(0xFF0754AE),
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _sidebarItem(Icons.home_rounded, 'Home', 0),
          _sidebarItem(Icons.swap_horiz_rounded, 'Borrow & Return', 1),
          _sidebarItem(Icons.notifications_active_rounded, 'Notifications', 2),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 16, 28),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.layers_rounded,
                    color: Colors.white,
                    size: 35,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Read More,\nLearn More,\nGrow More.',
                    style: TextStyle(
                      color: Colors.white,
                      height: 1.4,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String title, int index) {
    final selected = selectedMenu == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      child: Material(
        color: selected ? primary : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: () {
            setState(() => selectedMenu = index);

            if (index == 1) {
              showMessage('Connect this menu to your Borrow & Return page.');
            } else if (index == 2) {
              showMessage('Connect this menu to your Notifications page.');
            }
          },
          child: SizedBox(
            height: 53,
            child: Row(
              children: [
                const SizedBox(width: 13),
                Icon(icon, color: Colors.white, size: 27),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (index == 2)
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // DASHBOARD LAYOUTS
  // ------------------------------------------------------------

  Widget _buildWideDashboard() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _buildWelcome(),
              const SizedBox(height: 18),
              _buildStatistics(),
              const SizedBox(height: 14),
              _buildBorrowingActivity(),
            ],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildReadingSummary(),
              const SizedBox(height: 14),
              _buildUpcomingDueDates(),
              const SizedBox(height: 14),
              _buildRecentNotifications(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactDashboard() {
    return Column(
      children: [
        _buildWelcome(),
        const SizedBox(height: 16),
        _buildStatistics(),
        const SizedBox(height: 16),
        _buildReadingSummary(),
        const SizedBox(height: 16),
        _buildUpcomingDueDates(),
        const SizedBox(height: 16),
        _buildBorrowingActivity(),
        const SizedBox(height: 16),
        _buildRecentNotifications(),
      ],
    );
  }

  // ------------------------------------------------------------
  // WELCOME, SEARCH AND BANNER
  // ------------------------------------------------------------

  Widget _buildWelcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back, Sara!',
                style: TextStyle(
                  fontSize: 28,
                  color: navy,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Manage book loans, process returns, track borrowing records, '
                'and keep the library running smoothly.',
                style: TextStyle(
                  color: Color(0xFF4C8AF5),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: borderColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: searchController,
                  onSubmitted: (_) => searchLibrary(),
                  decoration: const InputDecoration(
                    hintText: 'Search for students, books (title or ISBN)...',
                    hintStyle: TextStyle(
                      color: Color(0xFF6993D4),
                      fontSize: 13,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: primary,
                      size: 25,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: searchLibrary,
                icon: const Icon(Icons.search, size: 21),
                label: const Text('Search'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        _buildBanner(),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      height: 180,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(9),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF06377B),
            Color(0xFF0759A7),
            Color(0xFF3182C4),
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -15,
            top: -35,
            child: Icon(
              Icons.menu_book_rounded,
              size: 240,
              color: Colors.white.withValues(alpha: 0.07),
            ),
          ),
          Positioned(
            right: 100,
            bottom: -40,
            child: Icon(
              Icons.auto_stories_rounded,
              size: 190,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 18, 20, 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Library Operations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                  'Made Simple',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 33,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),
                const SizedBox(
                  width: 320,
                  child: Text(
                    'Borrow, return, manage books and keep track of your library activities.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // STATISTICS
  // ------------------------------------------------------------

  Widget _buildStatistics() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 650;
        final cards = [
          _statCard(
            icon: Icons.menu_book_rounded,
            title: 'Total Books',
            value: '1,248',
            subtitle: 'in collection',
            color: primary,
          ),
          _statCard(
            icon: Icons.swap_horiz_rounded,
            title: 'Active Borrowings',
            value: '186',
            subtitle: 'currently borrowed',
            color: const Color(0xFF00A99D),
          ),
          _statCard(
            icon: Icons.calendar_month_rounded,
            title: 'Due Today',
            value: '23',
            subtitle: 'books due',
            color: const Color(0xFFFFA21A),
          ),
          _statCard(
            icon: Icons.warning_rounded,
            title: 'Overdue Returns',
            value: '12',
            subtitle: 'need attention',
            color: const Color(0xFFFF4545),
          ),
        ];

        if (compact) {
          return GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.8,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: cards,
          );
        }

        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i != 0) const SizedBox(width: 10),
              Expanded(child: cards[i]),
            ],
          ],
        );
      },
    );
  }

  Widget _statCard({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 123),
      padding: const EdgeInsets.all(13),
      decoration: _panelDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 54,
            width: 54,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: navy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 25,
                    height: 1.05,
                    color: navy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF5488D6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // READING SUMMARY
  // ------------------------------------------------------------

  Widget _buildReadingSummary() {
    return _panel(
      child: Column(
        children: [
          _panelHeading(
            Icons.menu_book_rounded,
            'My Reading Summary',
            action: 'View All',
            onAction: () => showMessage('Open the complete reading summary.'),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _summaryTile(
                  Icons.menu_book_rounded,
                  '3',
                  'Books Borrowed',
                  const Color(0xFF0875F5),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryTile(
                  Icons.access_time_filled_rounded,
                  '1',
                  'Due Soon',
                  const Color(0xFF7656F8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _summaryTile(
                  Icons.calendar_month_rounded,
                  '1',
                  'Reservation(s)',
                  const Color(0xFF00A99D),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _summaryTile(
                  Icons.notifications_active_rounded,
                  '2',
                  'Notifications',
                  const Color(0xFFFF4141),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryTile(
    IconData icon,
    String number,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 25),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 23,
                    color: navy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF4F81CE),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // UPCOMING DUE DATES
  // ------------------------------------------------------------

  Widget _buildUpcomingDueDates() {
    return _panel(
      child: Column(
        children: [
          _panelHeading(
            Icons.calendar_month_rounded,
            'Upcoming Due Dates',
            action: 'View All',
            onAction: () => showMessage('Open all upcoming due dates.'),
          ),
          const SizedBox(height: 8),
          for (final book in dueBooks) ...[
            const Divider(height: 1, color: borderColor),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 13),
              child: Row(
                children: [
                  _bookCover(book['title'], book['icon'], book['textColor']),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book['title'],
                          style: const TextStyle(
                            fontSize: 13,
                            color: navy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          book['author'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5084D2),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: book['color'],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        book['due'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: book['textColor'],
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _bookCover(String title, IconData icon, Color color) {
    return Container(
      height: 58,
      width: 43,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.07),
          ],
        ),
        border: Border.all(color: borderColor),
      ),
      child: Icon(icon, color: color, size: 27),
    );
  }

  // ------------------------------------------------------------
  // BORROWING ACTIVITY TABLE
  // ------------------------------------------------------------

  Widget _buildBorrowingActivity() {
    return _panel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _panelHeading(
            Icons.menu_book_rounded,
            'Recent Borrowing Activity',
            action: 'View All',
            onAction: () => showMessage('Open all borrowing records.'),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: const WidgetStatePropertyAll(
                Color(0xFFEDF6FF),
              ),
              dataRowMinHeight: 46,
              dataRowMaxHeight: 53,
              headingRowHeight: 42,
              horizontalMargin: 10,
              columnSpacing: 18,
              border: const TableBorder(
                horizontalInside: BorderSide(color: borderColor),
              ),
              columns: const [
                DataColumn(label: Text('Date')),
                DataColumn(label: Text('Student ID')),
                DataColumn(label: Text('Student Name')),
                DataColumn(label: Text('Book Title')),
                DataColumn(label: Text('ISBN')),
                DataColumn(label: Text('Due Date')),
                DataColumn(label: Text('Status')),
              ],
              rows: borrowingActivity.map((item) {
                return DataRow(
                  cells: [
                    DataCell(_tableText(item['date'])),
                    DataCell(_tableText(item['id'])),
                    DataCell(_tableText(item['student'])),
                    DataCell(_tableText(item['book'])),
                    DataCell(_tableText(item['isbn'])),
                    DataCell(_tableText(item['due'])),
                    DataCell(_statusBadge(item['status'])),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableText(String value) {
    return Text(
      value,
      style: const TextStyle(
        fontSize: 11,
        color: Color(0xFF3876D4),
      ),
    );
  }

  Widget _statusBadge(String status) {
    Color color;
    Color foreground;

    switch (status) {
      case 'Overdue':
        color = const Color(0xFFFFE9E9);
        foreground = const Color(0xFFE92727);
        break;
      case 'Returned':
        color = const Color(0xFFE5F1FF);
        foreground = const Color(0xFF0875F5);
        break;
      default:
        color = const Color(0xFFE0F9ED);
        foreground = const Color(0xFF008D59);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // RECENT NOTIFICATIONS
  // ------------------------------------------------------------

  Widget _buildRecentNotifications() {
    return _panel(
      child: Column(
        children: [
          _panelHeading(
            Icons.notifications_active_rounded,
            'Recent Notifications',
            action: 'View All',
            onAction: () => showMessage('Open all notifications.'),
          ),
          const SizedBox(height: 10),
          _notificationItem(
            Icons.notifications_active_rounded,
            const Color(0xFFFFE8EF),
            const Color(0xFFFF3D62),
            'Your book “Atomic Habits” is due in 2 days.',
            '2 hours ago',
          ),
          const Divider(color: borderColor, height: 1),
          _notificationItem(
            Icons.info_rounded,
            const Color(0xFFE7F2FF),
            const Color(0xFF0875F5),
            'New reservation for “The Martian” is now available.',
            '1 day ago',
          ),
          const Divider(color: borderColor, height: 1),
          _notificationItem(
            Icons.check_circle_rounded,
            const Color(0xFFE2F8EC),
            const Color(0xFF00A86B),
            'Book returned: “Clean Code” by Selam Tesfaye.',
            '1 day ago',
          ),
        ],
      ),
    );
  }

  Widget _notificationItem(
    IconData icon,
    Color backgroundColor,
    Color iconColor,
    String message,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF5688D3),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------------------
  // REUSABLE PANEL WIDGETS
  // ------------------------------------------------------------

  BoxDecoration _panelDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: borderColor),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF6CA8EA).withValues(alpha: 0.04),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  Widget _panel({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: _panelDecoration(),
      child: child,
    );
  }

  Widget _panelHeading(
    IconData icon,
    String title, {
    String? action,
    VoidCallback? onAction,
  }) {
    return Row(
      children: [
        Icon(icon, color: primary, size: 25),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              color: navy,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: primary,
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  action,
                  style: const TextStyle(fontSize: 11),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 14),
              ],
            ),
          ),
      ],
    );
  }
}
