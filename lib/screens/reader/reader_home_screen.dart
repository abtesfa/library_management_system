
import 'package:flutter/material.dart';
import 'my_books_screen.dart';
import 'reader_reservations_screen.dart';
import 'reader_notifications_screen.dart';

class ReaderHomeScreen extends StatefulWidget {
  const ReaderHomeScreen({super.key});

  @override
  State<ReaderHomeScreen> createState() => _ReaderHomeScreenState();
}

class _ReaderHomeScreenState extends State<ReaderHomeScreen> {
  int selectedIndex = 0;
  final searchController = TextEditingController();

  static const blue = Color(0xFF0755C9);
  static const darkBlue = Color(0xFF073B86);
  static const background = Color(0xFFF3F7FD);

  final books = const [
    {'title': 'Atomic Habits', 'author': 'James Clear', 'genre': 'Self-Help'},
    {'title': 'Dune', 'author': 'Frank Herbert', 'genre': 'Science Fiction'},
    {'title': 'The Great Gatsby', 'author': 'F. Scott Fitzgerald', 'genre': 'Fiction'},
    {'title': 'Clean Code', 'author': 'Robert C. Martin', 'genre': 'Computer Science'},
    {'title': 'Sapiens', 'author': 'Yuval Noah Harari', 'genre': 'History'},
  ];

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 850;

          return Column(
            children: [
              _header(),
              Expanded(
                child: Row(
                  children: [
                    if (wide) _sidebar(),
                    Expanded(
                      child: selectedIndex == 0
                          ? _homePage(wide)
                          : _simplePage(_pageTitle()),
                    ),
                  ],
                ),
              ),
              if (!wide) _bottomNavigation(),
            ],
          );
        },
      ),
    );
  }

  Widget _header() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [darkBlue, blue],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.menu_book, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Library Management System',
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Icon(Icons.notifications_none, color: Colors.white),
          const SizedBox(width: 16),
          const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: blue),
          ),
          const SizedBox(width: 8),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Abiye Tesfaye',
                  style: TextStyle(color: Colors.white, fontSize: 12)),
              Text('Reader',
                  style: TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          ),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ],
      ),
    );
  }

  Widget _sidebar() {
    return Container(
      width: 190,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [darkBlue, Color(0xFF064AAB)],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _navItem(Icons.home, 'Home', 0),
          _navItem(Icons.menu_book, 'My Books', 1),
          _navItem(Icons.calendar_month, 'Reservations', 2),
          _navItem(Icons.notifications, 'Notifications', 3),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text(
              '▤\nRead More,\nLearn More,\nGrow More.',
              style: TextStyle(
                color: Colors.white,
                height: 1.7,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String title, int index) {
    final selected = selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      child: ListTile(
        selected: selected,
        selectedTileColor: const Color(0xFF0868EF),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        leading: Icon(icon, color: Colors.white, size: 21),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        onTap: () => setState(() => selectedIndex = index),
      ),
    );
  }

  Widget _bottomNavigation() {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        setState(() => selectedIndex = index);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.menu_book), label: 'My Books'),
        NavigationDestination(
            icon: Icon(Icons.calendar_month), label: 'Reservations'),
        NavigationDestination(
            icon: Icon(Icons.notifications), label: 'Notifications'),
      ],
    );
  }

  Widget _homePage(bool wide) {
    final horizontalPadding = wide ? 22.0 : 14.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(horizontalPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back, Abiye!',
            style: TextStyle(
              fontSize: 25,
              color: darkBlue,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Discover new books, continue your reading journey, and explore the library's resources.",
            style: TextStyle(color: Color(0xFF526783), fontSize: 12),
          ),
          const SizedBox(height: 16),
          _searchBar(),
          const SizedBox(height: 18),
          _heroBanner(),
          const SizedBox(height: 24),
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 7, child: _recommendedSection()),
                const SizedBox(width: 22),
                Expanded(flex: 4, child: _rightColumn()),
              ],
            )
          else ...[
            _readingSummary(),
            const SizedBox(height: 20),
            _recommendedSection(),
            const SizedBox(height: 20),
            _upcomingDueDates(),
            const SizedBox(height: 20),
            _recentNotifications(),
          ],
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search for books, authors, or genres...',
              prefixIcon: const Icon(Icons.search, color: blue),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: Color(0xFFDCE5F2)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: Color(0xFFDCE5F2)),
              ),
            ),
            onSubmitted: (_) => setState(() {}),
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: () => setState(() {}),
          icon: const Icon(Icons.search, size: 18),
          label: const Text('Search'),
          style: ElevatedButton.styleFrom(
            backgroundColor: blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 17),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroBanner() {
    return Container(
      height: 190,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/library_hero.jpg',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: darkBlue,
              child: const Icon(
                Icons.local_library,
                size: 90,
                color: Colors.white54,
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF063B83),
                  Color(0xDD063B83),
                  Color(0x22063B83),
                ],
                stops: [0, 0.48, 1],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Good Books\nBuild Better Futures',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    height: 1.25,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Explore new worlds, gain new perspectives,\nand keep reading!',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _recommendedSection() {
    final query = searchController.text.trim().toLowerCase();
    final filteredBooks = books.where((book) {
      return book['title']!.toLowerCase().contains(query) ||
          book['author']!.toLowerCase().contains(query) ||
          book['genre']!.toLowerCase().contains(query);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('▣  Recommended Books', 'View All'),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth >= 650 ? 5 : 2;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredBooks.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: columns == 2 ? 0.75 : 0.62,
              ),
              itemBuilder: (context, index) {
                final book = filteredBooks[index];
                return _bookCard(book);
              },
            );
          },
        ),
        if (filteredBooks.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('No books match your search.'),
          ),
      ],
    );
  }

  Widget _bookCard(Map<String, String> book) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFE4EBF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF1FC),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.menu_book,
                size: 55,
                color: blue,
              ),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            book['title']!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: darkBlue,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            book['author']!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.blueGrey, fontSize: 10),
          ),
          const SizedBox(height: 6),
          Text(
            book['genre']!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: blue, fontSize: 10),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reservation requested: ${book['title']}'),
                  ),
                );
              },
              icon: const Icon(Icons.calendar_month, size: 14),
              label: const Text('Reserve', style: TextStyle(fontSize: 11)),
              style: OutlinedButton.styleFrom(
                foregroundColor: blue,
                padding: const EdgeInsets.symmetric(vertical: 8),
                side: const BorderSide(color: Color(0xFFB7CDF0)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rightColumn() {
    return Column(
      children: [
        _readingSummary(),
        const SizedBox(height: 18),
        _upcomingDueDates(),
        const SizedBox(height: 18),
        _recentNotifications(),
      ],
    );
  }

  Widget _readingSummary() {
    return _panel(
      title: 'My Reading Summary',
      child: const Column(
        children: [
          Row(
            children: [
              Expanded(child: _SummaryItem(icon: Icons.menu_book, value: '3', label: 'Books Borrowed')),
              Expanded(child: _SummaryItem(icon: Icons.access_time, value: '1', label: 'Due Soon')),
            ],
          ),
          SizedBox(height: 22),
          Row(
            children: [
              Expanded(child: _SummaryItem(icon: Icons.calendar_month, value: '1', label: 'Reservation(s)')),
              Expanded(child: _SummaryItem(icon: Icons.notifications, value: '2', label: 'Notifications')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _upcomingDueDates() {
    return _panel(
      title: 'Upcoming Due Dates',
      trailing: 'View All →',
      child: Column(
        children: const [
          _DueBook(title: 'Atomic Habits', author: 'James Clear', due: 'Due in 2 days'),
          Divider(height: 22),
          _DueBook(title: 'Dune', author: 'Frank Herbert', due: 'Due in 5 days'),
          Divider(height: 22),
          _DueBook(title: 'The Great Gatsby', author: 'F. Scott Fitzgerald', due: 'Due in 7 days'),
        ],
      ),
    );
  }

  Widget _recentNotifications() {
    return _panel(
      title: 'Recent Notifications',
      trailing: 'View All →',
      child: const Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: Color(0xFFFFE8EC),
              child: Icon(Icons.notifications, color: Colors.red),
            ),
            title: Text(
              'Your book "Atomic Habits" is due in 2 days.',
              style: TextStyle(fontSize: 12, color: darkBlue),
            ),
            subtitle: Text('2 hours ago', style: TextStyle(fontSize: 10)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: Color(0xFFE7F0FF),
              child: Icon(Icons.info_outline, color: blue),
            ),
            title: Text(
              'Your reservation is now available.',
              style: TextStyle(fontSize: 12, color: darkBlue),
            ),
            subtitle: Text('1 day ago', style: TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _panel({
    required String title,
    required Widget child,
    String? trailing,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5ECF5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: darkBlue,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (trailing != null)
                Text(trailing,
                    style: const TextStyle(color: blue, fontSize: 11)),
            ],
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }

  Widget _sectionTitle(String title, String action) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: darkBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Text(action, style: const TextStyle(color: blue, fontSize: 12)),
      ],
    );
  }

  String _pageTitle() {
    switch (selectedIndex) {
      case 1:
        return 'My Books';
      case 2:
        return 'Reservations';
      case 3:
        return 'Notifications';
      default:
        return 'Home';
    }
  }

  Widget _simplePage(String title) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selectedIndex == 1
                  ? Icons.menu_book
                  : selectedIndex == 2
                      ? Icons.calendar_month
                      : Icons.notifications,
              size: 55,
              color: blue,
            ),
            const SizedBox(height: 15),
            Text(
              title,
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: darkBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connect this page to your corresponding screen.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFEAF2FF),
          child: Icon(icon, color: const Color(0xFF0755C9), size: 20),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF073B86),
                ),
              ),
              Text(label,
                  style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DueBook extends StatelessWidget {
  final String title;
  final String author;
  final String due;

  const _DueBook({
    required this.title,
    required this.author,
    required this.due,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 43,
          height: 54,
          decoration: BoxDecoration(
            color: const Color(0xFFEAF1FC),
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Icon(Icons.menu_book, color: Color(0xFF0755C9)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFF073B86),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(author,
                  style: const TextStyle(fontSize: 10, color: Colors.blueGrey)),
            ],
          ),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            due,
            textAlign: TextAlign.end,
            style: const TextStyle(color: Colors.redAccent, fontSize: 10),
          ),
        ),
      ],
    );
  }
}
