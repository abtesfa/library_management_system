
import 'package:flutter/material.dart';

class BookInventoryScreen extends StatefulWidget {
  const BookInventoryScreen({super.key});

  @override
  State<BookInventoryScreen> createState() => _BookInventoryScreenState();
}

class _BookInventoryScreenState extends State<BookInventoryScreen> {
  static const blue = Color(0xFF0878F9);
  static const navy = Color(0xFF073E8A);
  static const ink = Color(0xFF0751B8);
  static const muted = Color(0xFF6590CA);
  static const line = Color(0xFFD9EBFF);
  static const background = Color(0xFFF4FAFF);

  int selectedMenu = 3;
  int currentPage = 1;
  String searchText = '';
  String selectedCategory = 'All Categories';
  String selectedStatus = 'All Statuses';

  final TextEditingController searchController = TextEditingController();

  final List<InventoryBook> books = [
    InventoryBook(
      title: 'Atomic Habits',
      author: 'James Clear',
      isbn: '978-0735211292',
      category: 'Self-Help',
      total: 5,
      available: 3,
      location: 'Shelf A1',
      coverColor: const Color(0xFFF5EBDD),
      coverIcon: Icons.auto_stories,
    ),
    InventoryBook(
      title: 'Dune',
      author: 'Frank Herbert',
      isbn: '978-0441013593',
      category: 'Science Fiction',
      total: 4,
      available: 1,
      location: 'Shelf B2',
      coverColor: const Color(0xFF30271F),
      coverIcon: Icons.public,
    ),
    InventoryBook(
      title: 'The Great Gatsby',
      author: 'F. Scott Fitzgerald',
      isbn: '978-0743273567',
      category: 'Fiction',
      total: 6,
      available: 6,
      location: 'Shelf C3',
      coverColor: const Color(0xFF183D80),
      coverIcon: Icons.auto_stories,
    ),
    InventoryBook(
      title: 'Clean Code',
      author: 'Robert C. Martin',
      isbn: '978-0132350884',
      category: 'Computer Science',
      total: 3,
      available: 2,
      location: 'Shelf D1',
      coverColor: const Color(0xFF172C45),
      coverIcon: Icons.code,
    ),
    InventoryBook(
      title: 'Sapiens',
      author: 'Yuval Noah Harari',
      isbn: '978-0062316097',
      category: 'History',
      total: 5,
      available: 4,
      location: 'Shelf E2',
      coverColor: const Color(0xFFF8E9D7),
      coverIcon: Icons.history_edu,
    ),
    InventoryBook(
      title: 'Harry Potter and the Sorcerer’s Stone',
      author: 'J.K. Rowling',
      isbn: '978-0545582885',
      category: 'Fantasy',
      total: 7,
      available: 5,
      location: 'Shelf F1',
      coverColor: const Color(0xFF6A2C91),
      coverIcon: Icons.auto_stories,
    ),
    InventoryBook(
      title: '1984',
      author: 'George Orwell',
      isbn: '978-0451524935',
      category: 'Dystopian',
      total: 4,
      available: 2,
      location: 'Shelf F3',
      coverColor: const Color(0xFF351D20),
      coverIcon: Icons.visibility,
    ),
    InventoryBook(
      title: 'To Kill a Mockingbird',
      author: 'Harper Lee',
      isbn: '978-0061120084',
      category: 'Classic',
      total: 6,
      available: 5,
      location: 'Shelf G1',
      coverColor: const Color(0xFF182C44),
      coverIcon: Icons.menu_book,
    ),
    InventoryBook(
      title: 'The Martian',
      author: 'Andy Weir',
      isbn: '978-0553418026',
      category: 'Science Fiction',
      total: 4,
      available: 1,
      location: 'Shelf B1',
      coverColor: const Color(0xFFD95A20),
      coverIcon: Icons.rocket_launch,
    ),
    InventoryBook(
      title: 'Data Structures and Algorithms',
      author: 'Goodrich & Tamassia',
      isbn: '978-0132647904',
      category: 'Computer Science',
      total: 5,
      available: 4,
      location: 'Shelf D3',
      coverColor: const Color(0xFF173A63),
      coverIcon: Icons.account_tree,
    ),
  ];

  final List<InventoryActivity> activities = [
    InventoryActivity(
      title: 'New book added',
      book: 'Clean Code',
      author: 'Robert C. Martin',
      time: '2 hours ago',
      icon: Icons.code,
      color: const Color(0xFF172C45),
    ),
    InventoryActivity(
      title: 'Book updated',
      book: 'Atomic Habits',
      author: 'James Clear',
      time: '4 hours ago',
      icon: Icons.auto_stories,
      color: const Color(0xFFF5EBDD),
    ),
    InventoryActivity(
      title: 'Copy checked in',
      book: 'Dune (Copy #3)',
      author: 'Frank Herbert',
      time: '1 day ago',
      icon: Icons.public,
      color: const Color(0xFF30271F),
    ),
    InventoryActivity(
      title: 'Book marked as reserved',
      book: 'The Martian',
      author: 'Andy Weir',
      time: '1 day ago',
      icon: Icons.rocket_launch,
      color: const Color(0xFFD95A20),
    ),
  ];

  List<InventoryBook> get filteredBooks {
    return books.where((book) {
      final query = searchText.toLowerCase();

      final matchesSearch =
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.isbn.toLowerCase().contains(query);

      final matchesCategory = selectedCategory == 'All Categories' ||
          book.category == selectedCategory;

      final status = book.available == 0
          ? 'Unavailable'
          : book.available == 1
              ? 'Low Stock'
              : 'Available';

      final matchesStatus =
          selectedStatus == 'All Statuses' || status == selectedStatus;

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  int get totalCopies =>
      books.fold(0, (sum, book) => sum + book.total);

  int get availableCopies =>
      books.fold(0, (sum, book) => sum + book.available);

  int get loanCopies => totalCopies - availableCopies;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 1050;

          return Row(
            children: [
              if (!compact) _sidebar(),
              Expanded(
                child: Column(
                  children: [
                    _topBar(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(compact ? 12 : 18),
                        child: compact
                            ? _compactLayout()
                            : _desktopLayout(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _sidebar() {
    return Container(
      width: 210,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF073F87),
            Color(0xFF063675),
            Color(0xFF0049A9),
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 23,
                  backgroundColor: Color(0xFF0878F9),
                  child: Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 31,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Library Management System',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _navItem(0, Icons.home, 'Dashboard'),
          _navItem(1, Icons.settings, 'LMS Settings'),
          _navItem(2, Icons.people_alt, 'Staff Management'),
          _navItem(3, Icons.menu_book, 'Book Inventory'),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 28),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.layers,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Read More,\nLearn More,\nGrow More.',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
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

  Widget _navItem(int index, IconData icon, String label) {
    final active = selectedMenu == index;

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 7),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: () {
          setState(() => selectedMenu = index);
          if (index != 3) showMessage('$label selected');
        },
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: active ? blue : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 25),
              const SizedBox(width: 14),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topBar() {
    return Container(
      height: 63,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF06469C), Color(0xFF0753B4)],
        ),
      ),
      child: Row(
        children: [
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(
                Icons.notifications,
                color: Colors.white,
                size: 26,
              ),
              Positioned(
                right: -5,
                top: -6,
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
                      fontSize: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 22),
          const CircleAvatar(
            radius: 19,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: blue, size: 25),
          ),
          const SizedBox(width: 12),
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Admin',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'System Administrator',
                style: TextStyle(
                  color: Color(0xFFD6E7FF),
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(width: 14),
          const Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _desktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 7,
          child: Column(
            children: [
              _pageHeading(),
              const SizedBox(height: 18),
              _searchPanel(),
              const SizedBox(height: 12),
              _statistics(),
              const SizedBox(height: 15),
              _inventoryTable(),
            ],
          ),
        ),
        const SizedBox(width: 17),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _overviewCard(),
              const SizedBox(height: 13),
              _quickActions(),
              const SizedBox(height: 13),
              _recentActivity(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _compactLayout() {
    return Column(
      children: [
        _pageHeading(),
        const SizedBox(height: 15),
        _searchPanel(),
        const SizedBox(height: 12),
        _statistics(),
        const SizedBox(height: 15),
        _inventoryTable(),
        const SizedBox(height: 15),
        _overviewCard(),
        const SizedBox(height: 13),
        _quickActions(),
        const SizedBox(height: 13),
        _recentActivity(),
      ],
    );
  }

  Widget _pageHeading() {
    return Row(
      children: [
        const Icon(
          Icons.library_books,
          color: blue,
          size: 34,
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Book Inventory',
                style: TextStyle(
                  color: Color(0xFF0755BE),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                'Manage book titles, authors, categories, physical copies, '
                'shelf locations, and availability status.',
                style: TextStyle(
                  color: muted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        ElevatedButton.icon(
          onPressed: _addBook,
          icon: const Icon(Icons.add, size: 17),
          label: const Text('Add New Book'),
          style: _primaryButton(),
        ),
      ],
    );
  }

  Widget _card(Widget child, {EdgeInsets padding = const EdgeInsets.all(13)}) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: line),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080B5DC5),
            blurRadius: 9,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _searchPanel() {
    return _card(
      LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 700;

          final searchField = TextField(
            controller: searchController,
            onChanged: (value) {
              setState(() {
                searchText = value;
                currentPage = 1;
              });
            },
            style: const TextStyle(color: ink, fontSize: 12),
            decoration: _inputDecoration(
              hint: 'Search by title, author, ISBN, or accession number...',
              icon: Icons.search,
            ),
          );

          final categoryField = _filterDropdown(
            label: 'Category',
            value: selectedCategory,
            values: [
              'All Categories',
              ...books.map((book) => book.category).toSet(),
            ],
            onChanged: (value) {
              setState(() {
                selectedCategory = value;
                currentPage = 1;
              });
            },
          );

          final statusField = _filterDropdown(
            label: 'Status',
            value: selectedStatus,
            values: [
              'All Statuses',
              'Available',
              'Low Stock',
              'Unavailable',
            ],
            onChanged: (value) {
              setState(() {
                selectedStatus = value;
                currentPage = 1;
              });
            },
          );

          final searchButton = ElevatedButton.icon(
            onPressed: () {
              setState(() => searchText = searchController.text);
            },
            icon: const Icon(Icons.search, size: 17),
            label: const Text('Search'),
            style: _primaryButton(),
          );

          if (narrow) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                searchField,
                const SizedBox(height: 10),
                categoryField,
                const SizedBox(height: 10),
                statusField,
                const SizedBox(height: 10),
                searchButton,
              ],
            );
          }

          return Row(
            children: [
              Expanded(flex: 3, child: searchField),
              const SizedBox(width: 20),
              Expanded(flex: 1, child: categoryField),
              const SizedBox(width: 20),
              Expanded(flex: 1, child: statusField),
              const SizedBox(width: 18),
              searchButton,
            ],
          );
        },
      ),
    );
  }

  Widget _filterDropdown({
    required String label,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: ink,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        DropdownButtonFormField<String>(
          value: value,
          isExpanded: true,
          decoration: _inputDecoration(),
          style: const TextStyle(color: ink, fontSize: 11),
          items: values.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration({
    String? hint,
    IconData? icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: muted, fontSize: 10),
      prefixIcon: icon == null
          ? null
          : Icon(icon, color: blue, size: 19),
      isDense: true,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: blue, width: 1.3),
      ),
    );
  }

  ButtonStyle _primaryButton() {
    return ElevatedButton.styleFrom(
      backgroundColor: blue,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _statistics() {
    final stats = [
      (
        'Total Books',
        '1,248',
        'titles in collection',
        Icons.menu_book,
        const Color(0xFF1681FF),
        const Color(0xFFE0F0FF),
      ),
      (
        'Total Copies',
        _format(totalCopies),
        'physical copies',
        Icons.library_books,
        const Color(0xFF555FF0),
        const Color(0xFFE7E8FF),
      ),
      (
        'Available Copies',
        _format(availableCopies),
        'available for loan',
        Icons.check_circle,
        const Color(0xFF16A66A),
        const Color(0xFFDBF8EA),
      ),
      (
        'On Loan',
        _format(loanCopies),
        'currently borrowed',
        Icons.shopping_bag,
        const Color(0xFFFFAA13),
        const Color(0xFFFFF0D2),
      ),
      (
        'Reserved',
        '32',
        'awaiting availability',
        Icons.access_time_filled,
        const Color(0xFFEF5360),
        const Color(0xFFFFE1E4),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth < 600 ? 2 : 5;
        final width =
            (constraints.maxWidth - (columns - 1) * 10) / columns;

        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: stats.map((stat) {
            return SizedBox(
              width: width,
              child: Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: line),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 19,
                      backgroundColor: stat.$6,
                      child: Icon(
                        stat.$4,
                        color: stat.$5,
                        size: 19,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            stat.$1,
                            style: const TextStyle(
                              color: ink,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stat.$2,
                            style: const TextStyle(
                              color: blue,
                              fontSize: 19,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            stat.$3,
                            style: const TextStyle(
                              color: muted,
                              fontSize: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  String _format(int value) {
    return value.toString().replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (match) => '${match[1]},',
        );
  }

  Widget _inventoryTable() {
    final results = filteredBooks;
    const pageSize = 10;
    final pageCount = results.isEmpty
        ? 1
        : (results.length / pageSize).ceil();

    if (currentPage > pageCount) currentPage = pageCount;

    final start = (currentPage - 1) * pageSize;
    final end = (start + pageSize).clamp(0, results.length);
    final visible = results.sublist(start.clamp(0, results.length), end);

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2, color: blue, size: 21),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Book Inventory List',
                  style: TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              Text(
                results.isEmpty
                    ? 'No books found'
                    : 'Showing ${start + 1}–$end of ${results.length}',
                style: const TextStyle(
                  color: ink,
                  fontSize: 9,
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                tooltip: 'Previous page',
                onPressed: currentPage > 1
                    ? () => setState(() => currentPage--)
                    : null,
                icon: const Icon(Icons.chevron_left),
                visualDensity: VisualDensity.compact,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: blue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$currentPage',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Next page',
                onPressed: currentPage < pageCount
                    ? () => setState(() => currentPage++)
                    : null,
                icon: const Icon(Icons.chevron_right),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const Divider(color: line),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(
                const Color(0xFFF0F7FF),
              ),
              headingRowHeight: 40,
              dataRowMinHeight: 54,
              dataRowMaxHeight: 62,
              horizontalMargin: 8,
              columnSpacing: 14,
              headingTextStyle: const TextStyle(
                color: ink,
                fontWeight: FontWeight.w900,
                fontSize: 9,
              ),
              dataTextStyle: const TextStyle(
                color: ink,
                fontSize: 9,
              ),
              columns: const [
                DataColumn(label: Text('Cover')),
                DataColumn(label: Text('Title')),
                DataColumn(label: Text('Author')),
                DataColumn(label: Text('ISBN')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Total\nCopies')),
                DataColumn(label: Text('Available')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Location')),
                DataColumn(label: Text('Actions')),
              ],
              rows: visible.map((book) {
                return DataRow(
                  cells: [
                    DataCell(_bookCover(book)),
                    DataCell(
                      SizedBox(
                        width: 105,
                        child: Text(
                          book.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 100,
                        child: Text(book.author),
                      ),
                    ),
                    DataCell(Text(book.isbn)),
                    DataCell(_categoryPill(book.category)),
                    DataCell(Text('${book.total}')),
                    DataCell(Text('${book.available}')),
                    DataCell(_statusPill(book)),
                    DataCell(Text(book.location)),
                    DataCell(
                      Row(
                        children: [
                          _iconAction(
                            Icons.edit,
                            blue,
                            () => _editBook(book),
                          ),
                          const SizedBox(width: 5),
                          _iconAction(
                            Icons.delete,
                            Colors.redAccent,
                            () => _deleteBook(book),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          if (visible.isEmpty)
            const Padding(
              padding: EdgeInsets.all(25),
              child: Center(
                child: Text(
                  'No books match your search.',
                  style: TextStyle(color: muted),
                ),
              ),
            ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
    );
  }

  Widget _bookCover(InventoryBook book) {
    return Container(
      width: 38,
      height: 45,
      decoration: BoxDecoration(
        color: book.coverColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.black12),
      ),
      child: Icon(
        book.coverIcon,
        color: Colors.white.withValues(alpha: .95),
        size: 25,
      ),
    );
  }

  Widget _categoryPill(String category) {
    final colors = <String, Color>{
      'Self-Help': const Color(0xFF1681FF),
      'Science Fiction': const Color(0xFF8B5CF6),
      'Fiction': const Color(0xFF1681FF),
      'Computer Science': const Color(0xFF0891B2),
      'History': const Color(0xFFC026D3),
      'Fantasy': const Color(0xFFEA580C),
      'Dystopian': Colors.red,
      'Classic': const Color(0xFF8B5CF6),
    };

    final color = colors[category] ?? blue;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        border: Border.all(color: color.withValues(alpha: .25)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: color,
          fontSize: 8.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _statusPill(InventoryBook book) {
    final label = book.available == 0
        ? 'Unavailable'
        : book.available == 1
            ? 'Low Stock'
            : 'Available';

    final color = book.available == 0
        ? Colors.red
        : book.available == 1
            ? const Color(0xFFEA8A00)
            : const Color(0xFF159B68);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .09),
        border: Border.all(color: color.withValues(alpha: .25)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 8.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _iconAction(
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .09),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: color, size: 15),
      ),
    );
  }

  Widget _overviewCard() {
    final total = totalCopies == 0 ? 1 : totalCopies;
    final available = availableCopies;
    final loan = loanCopies;
    const reserved = 32;

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart, color: navy, size: 23),
              SizedBox(width: 10),
              Text(
                'Inventory Overview',
                style: TextStyle(
                  color: ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 150,
                  child: CustomPaint(
                    painter: InventoryDonutPainter(
                      available: available.toDouble(),
                      loan: loan.toDouble(),
                      reserved: reserved.toDouble(),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _format(totalCopies),
                            style: const TextStyle(
                              color: ink,
                              fontSize: 21,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const Text(
                            'Total Copies',
                            style: TextStyle(
                              color: muted,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _legend(
                      const Color(0xFF26B982),
                      'Available',
                      '$available (${(available / total * 100).toStringAsFixed(1)}%)',
                    ),
                    const SizedBox(height: 13),
                    _legend(
                      const Color(0xFFFFB51B),
                      'On Loan',
                      '$loan (${(loan / total * 100).toStringAsFixed(1)}%)',
                    ),
                    const SizedBox(height: 13),
                    _legend(
                      Colors.redAccent,
                      'Reserved',
                      '$reserved (${(reserved / (total + reserved) * 100).toStringAsFixed(1)}%)',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: const EdgeInsets.only(top: 3),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: muted,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _quickActions() {
    final actions = [
      (
        Icons.add_circle,
        'Add New Book',
        'Add a new book title',
        _addBook,
      ),
      (
        Icons.upload,
        'Import Books',
        'Bulk import from file',
        _importBooks,
      ),
      (
        Icons.sell,
        'Manage Categories',
        'View and edit categories',
        _manageCategories,
      ),
      (
        Icons.location_on,
        'Manage Locations',
        'Edit shelf locations',
        _manageLocations,
      ),
    ];

    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt, color: blue, size: 24),
              SizedBox(width: 9),
              Text(
                'Quick Actions',
                style: TextStyle(
                  color: ink,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.18,
            children: actions.map((action) {
              return InkWell(
                onTap: action.$4,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    border: Border.all(color: line),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        action.$1,
                        color: blue,
                        size: 24,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        action.$2,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: ink,
                          fontWeight: FontWeight.w800,
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        action.$3,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: muted,
                          fontSize: 8,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _recentActivity() {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time,
                color: blue,
                size: 23,
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Recent Book Activity',
                  style: TextStyle(
                    color: ink,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => _showAllActivity(),
                child: const Text(
                  'View All →',
                  style: TextStyle(
                    color: blue,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: line),
          ...activities.map((activity) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 43,
                    height: 55,
                    decoration: BoxDecoration(
                      color: activity.color,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Icon(
                      activity.icon,
                      color: Colors.white,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          activity.title,
                          style: const TextStyle(
                            color: ink,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          activity.book,
                          style: const TextStyle(
                            color: blue,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'by ${activity.author}',
                          style: const TextStyle(
                            color: muted,
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          activity.time,
                          style: const TextStyle(
                            color: muted,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _addBook() {
    final title = TextEditingController();
    final author = TextEditingController();
    final isbn = TextEditingController();
    final categoryController = TextEditingController();
    final total = TextEditingController(text: '1');
    final available = TextEditingController(text: '1');
    final location = TextEditingController(text: 'Shelf A1');

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add New Book'),
          content: SizedBox(
            width: 430,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(title, 'Book Title'),
                  _dialogField(author, 'Author'),
                  _dialogField(isbn, 'ISBN'),
                  _dialogField(categoryController, 'Category'),
                  Row(
                    children: [
                      Expanded(
                        child: _dialogField(
                          total,
                          'Total Copies',
                          numeric: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _dialogField(
                          available,
                          'Available Copies',
                          numeric: true,
                        ),
                      ),
                    ],
                  ),
                  _dialogField(location, 'Shelf Location'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (title.text.trim().isEmpty ||
                    author.text.trim().isEmpty ||
                    isbn.text.trim().isEmpty) {
                  showMessage('Title, author, and ISBN are required.');
                  return;
                }

                final totalCount = int.tryParse(total.text) ?? 1;
                final availableCount =
                    int.tryParse(available.text) ?? 0;

                if (totalCount < 0 ||
                    availableCount < 0 ||
                    availableCount > totalCount) {
                  showMessage(
                    'Check the total and available copy counts.',
                  );
                  return;
                }

                setState(() {
                  books.add(
                    InventoryBook(
                      title: title.text.trim(),
                      author: author.text.trim(),
                      isbn: isbn.text.trim(),
                      category: categoryController.text.trim().isEmpty
                          ? 'Uncategorized'
                          : categoryController.text.trim(),
                      total: totalCount,
                      available: availableCount,
                      location: location.text.trim().isEmpty
                          ? 'Not assigned'
                          : location.text.trim(),
                      coverColor: const Color(0xFF173A63),
                      coverIcon: Icons.menu_book,
                    ),
                  );

                  currentPage = 1;

                  activities.insert(
                    0,
                    InventoryActivity(
                      title: 'New book added',
                      book: title.text.trim(),
                      author: author.text.trim(),
                      time: 'Just now',
                      icon: Icons.menu_book,
                      color: const Color(0xFF173A63),
                    ),
                  );
                });

                Navigator.pop(dialogContext);
                showMessage('Book added to this preview.');
              },
              child: const Text('Add Book'),
            ),
          ],
        );
      },
    );
  }

  Widget _dialogField(
    TextEditingController controller,
    String label, {
    bool numeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: controller,
        keyboardType:
            numeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  void _editBook(InventoryBook book) {
    final title = TextEditingController(text: book.title);
    final author = TextEditingController(text: book.author);
    final isbn = TextEditingController(text: book.isbn);
    final categoryController =
        TextEditingController(text: book.category);
    final total = TextEditingController(text: '${book.total}');
    final available =
        TextEditingController(text: '${book.available}');
    final location = TextEditingController(text: book.location);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Book'),
          content: SizedBox(
            width: 430,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _dialogField(title, 'Book Title'),
                  _dialogField(author, 'Author'),
                  _dialogField(isbn, 'ISBN'),
                  _dialogField(categoryController, 'Category'),
                  Row(
                    children: [
                      Expanded(
                        child: _dialogField(
                          total,
                          'Total Copies',
                          numeric: true,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _dialogField(
                          available,
                          'Available Copies',
                          numeric: true,
                        ),
                      ),
                    ],
                  ),
                  _dialogField(location, 'Shelf Location'),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final totalCount = int.tryParse(total.text) ?? 0;
                final availableCount =
                    int.tryParse(available.text) ?? 0;

                if (title.text.trim().isEmpty ||
                    isbn.text.trim().isEmpty ||
                    totalCount < 0 ||
                    availableCount < 0 ||
                    availableCount > totalCount) {
                  showMessage('Please check the book details.');
                  return;
                }

                setState(() {
                  book.title = title.text.trim();
                  book.author = author.text.trim();
                  book.isbn = isbn.text.trim();
                  book.category = categoryController.text.trim().isEmpty
                      ? 'Uncategorized'
                      : categoryController.text.trim();
                  book.total = totalCount;
                  book.available = availableCount;
                  book.location = location.text.trim().isEmpty
                      ? 'Not assigned'
                      : location.text.trim();
                });

                Navigator.pop(dialogContext);
                showMessage('Book updated in this preview.');
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }

  void _deleteBook(InventoryBook book) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Book'),
          content: Text(
            'Are you sure you want to remove "${book.title}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() => books.remove(book));
                Navigator.pop(dialogContext);
                showMessage('Book removed from this preview.');
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _importBooks() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Import Books'),
        content: const Text(
          'Connect a CSV or Excel file picker here to import books '
          'in bulk. This preview does not import files yet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _manageCategories() {
    final controller = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Manage Categories'),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Current book categories:'),
              const SizedBox(height: 10),
              ...books.map((book) => Text('• ${book.category}')).toSet(),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'New category name',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  selectedCategory = controller.text.trim();
                });
                Navigator.pop(dialogContext);
                showMessage(
                  'Category filter updated. Assign it to a book when editing.',
                );
              }
            },
            child: const Text('Use Category'),
          ),
        ],
      ),
    );
  }

  void _manageLocations() {
    final locations = books.map((book) => book.location).toSet();

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Manage Shelf Locations'),
        content: SizedBox(
          width: 350,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: locations.map((location) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: blue,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(location),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAllActivity() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Recent Book Activity'),
        content: SizedBox(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: activities.map((activity) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(activity.icon, color: blue),
                title: Text(activity.title),
                subtitle: Text(
                  '${activity.book}\n${activity.author} · ${activity.time}',
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class InventoryBook {
  InventoryBook({
    required this.title,
    required this.author,
    required this.isbn,
    required this.category,
    required this.total,
    required this.available,
    required this.location,
    required this.coverColor,
    required this.coverIcon,
  });

  String title;
  String author;
  String isbn;
  String category;
  int total;
  int available;
  String location;
  Color coverColor;
  IconData coverIcon;
}

class InventoryActivity {
  InventoryActivity({
    required this.title,
    required this.book,
    required this.author,
    required this.time,
    required this.icon,
    required this.color,
  });

  String title;
  String book;
  String author;
  String time;
  IconData icon;
  Color color;
}

class InventoryDonutPainter extends CustomPainter {
  InventoryDonutPainter({
    required this.available,
    required this.loan,
    required this.reserved,
  });

  final double available;
  final double loan;
  final double reserved;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 9;
    final rect = Rect.fromCircle(center: center, radius: radius);

    const strokeWidth = 16.0;
    const gap = .035;

    final values = [available, loan, reserved];
    final colors = [
      const Color(0xFF26B982),
      const Color(0xFFFFB51B),
      Colors.redAccent,
    ];

    final total = values.fold<double>(0, (sum, value) => sum + value);

    if (total <= 0) return;

    double startAngle = -1.5708;

    for (int i = 0; i < values.length; i++) {
      final sweep = (values[i] / total) * 6.28318;

      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;

      canvas.drawArc(
        rect,
        startAngle + gap / 2,
        (sweep - gap).clamp(0.0, 6.28318),
        false,
        paint,
      );

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant InventoryDonutPainter oldDelegate) {
    return oldDelegate.available != available ||
        oldDelegate.loan != loan ||
        oldDelegate.reserved != reserved;
  }
}




     
          