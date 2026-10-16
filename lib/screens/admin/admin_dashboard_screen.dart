
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  static const navy = Color(0xFF073D87);
  static const blue = Color(0xFF0878F9);
  static const ink = Color(0xFF06449B);
  static const muted = Color(0xFF6D8DBD);
  static const line = Color(0xFFD8E9FF);
  static const pale = Color(0xFFF3F9FF);

  int selected = 0;
  String currency = 'ETB';
  String category = 'All Categories';
  String search = '';

  final institution = TextEditingController(
    text: 'University Central Library & Information Center',
  );
  final days = TextEditingController(text: '14');
  final maxBooks = TextEditingController(text: '3');
  final fine = TextEditingController(text: '5');
  final grace = TextEditingController(text: '0');
  final hold = TextEditingController(text: '3');
  final fineCap = TextEditingController(text: '250');

  final List<StaffRow> staff = [
    StaffRow(
      'Samuel Worku',
      'samuel.w@library.univ.et',
      'EMP-7701',
      'Chief Circulation Librarian',
      true,
      true,
    ),
    StaffRow(
      'Meron Alemu',
      'meron.a@library.univ.et',
      'EMP-7708',
      'Circulation Officer',
      true,
      false,
    ),
    StaffRow(
      'Yohannes Girma',
      'yohannes.g@library.univ.et',
      'EMP-7715',
      'Assistant Librarian',
      false,
      false,
    ),
  ];

  final List<BookRow> books = [
    BookRow(
      'Introduction to Algorithms',
      '978-0262046305',
      'Computer Science',
      'Stack A · Shelf 04',
      '3 / 4',
      true,
      Icons.menu_book,
    ),
    BookRow(
      'Clean Code',
      '978-0132350884',
      'Software Engineering',
      'Stack A · Shelf 08',
      '1 / 3',
      true,
      Icons.auto_stories,
    ),
    BookRow(
      'Database System Concepts',
      '978-0078022159',
      'Databases',
      'Stack B · Shelf 02',
      '0 / 2',
      false,
      Icons.book,
    ),
  ];

  @override
  void dispose() {
    institution.dispose();
    days.dispose();
    maxBooks.dispose();
    fine.dispose();
    grace.dispose();
    hold.dispose();
    fineCap.dispose();
    super.dispose();
  }

  void toast(String message) {
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
      backgroundColor: const Color(0xFFF5FAFF),
      body: LayoutBuilder(
        builder: (context, size) {
          final compact = size.maxWidth < 950;

          return Row(
            children: [
              if (!compact) _sidebar(),
              Expanded(
                child: Column(
                  children: [
                    _topbar(compact),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(compact ? 14 : 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Administrator Dashboard',
                              style: TextStyle(
                                color: Color(0xFF073E8A),
                                fontSize: 25,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Manage staff access, library circulation rules, '
                              'and the book collection.',
                              style: TextStyle(
                                color: Color(0xFF5984C3),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _shortcuts(),
                            const SizedBox(height: 20),
                            if (compact) ...[
                              _settings(),
                              const SizedBox(height: 16),
                              _staffCard(),
                              const SizedBox(height: 16),
                              _inventory(),
                            ] else
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: constraints.maxWidth * .285,
                                        child: _settings(),
                                      ),
                                      const SizedBox(width: 14),
                                      SizedBox(
                                        width: constraints.maxWidth * .31,
                                        child: _staffCard(),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(child: _inventory()),
                                    ],
                                  );
                                },
                              ),
                          ],
                        ),
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
      width: 235,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF06438E),
            Color(0xFF06377C),
            Color(0xFF0049A9),
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Icon(Icons.menu_book, color: Colors.white, size: 34),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Library\nManagement System',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _nav(0, Icons.home, 'Dashboard'),
          _nav(1, Icons.settings, 'LMS Settings'),
          _nav(2, Icons.people_alt, 'Staff Management'),
          _nav(3, Icons.menu_book, 'Book Inventory'),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.fromLTRB(25, 0, 20, 28),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.auto_stories,
                    color: Colors.white,
                    size: 30,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Read More,\nLearn More,\nGrow More.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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

  Widget _nav(int index, IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(9),
        onTap: () {
          setState(() => selected = index);
          if (index != 0) toast('$label selected');
        },
        child: Container(
          height: 50,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: selected == index ? blue : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 25),
              const SizedBox(width: 15),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _topbar(bool compact) {
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
          const Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                Icons.notifications_none,
                color: Colors.white,
                size: 27,
              ),
              Positioned(
                right: -5,
                top: -6,
                child: CircleAvatar(
                  radius: 8,
                  backgroundColor: Colors.redAccent,
                  child: Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Container(width: 1, height: 35, color: Colors.white24),
          const SizedBox(width: 18),
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
          const SizedBox(width: 12),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        ],
      ),
    );
  }

  Widget _shortcuts() {
    final items = [
      (Icons.settings, 'LMS Settings', 1),
      (Icons.people_alt, 'Staff Management (${staff.length})', 2),
      (Icons.menu_book, 'Inventory', 3),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 650;
        final width = narrow
            ? constraints.maxWidth
            : (constraints.maxWidth - 28) / 3;

        return Wrap(
          spacing: 14,
          runSpacing: 12,
          children: items.map((item) {
            return SizedBox(
              width: width,
              child: InkWell(
                onTap: () {
                  setState(() => selected = item.$3);
                  toast('${item.$2} selected');
                },
                child: Container(
                  height: 67,
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  decoration: BoxDecoration(
                    color: selected == item.$3
                        ? const Color(0xFFEAF4FF)
                        : Colors.white,
                    border: Border.all(color: line),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: const Color(0xFFEAF4FF),
                        child: Icon(item.$1, color: blue, size: 25),
                      ),
                      const SizedBox(width: 17),
                      Expanded(
                        child: Text(
                          item.$2,
                          style: const TextStyle(
                            color: Color(0xFF0051C8),
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: blue,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _panel(Widget child) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: line),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color(0x080B5DC5),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _title(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, color: ink, size: 25),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: ink,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ),
      ],
    );
  }

  Widget _settings() {
    return _panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _title(Icons.settings, 'Circulation Rules & Fine Policy'),
          const SizedBox(height: 8),
          const Text(
            'Changes apply to borrowing calculations and return assessments.',
            style: TextStyle(color: muted, fontSize: 10.5, height: 1.4),
          ),
          const SizedBox(height: 13),
          const Divider(color: Color(0xFFE7F0FC)),
          const SizedBox(height: 10),
          _field('Institution Name', institution),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _field(
                  'Maximum Borrowing Days',
                  days,
                  numeric: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(
                  'Max Books Per Student',
                  maxBooks,
                  numeric: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _field('Fine Rate Per Day', fine, numeric: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Currency Symbol'),
                    DropdownButtonFormField<String>(
                      value: currency,
                      isExpanded: true,
                      decoration: _decoration(),
                      items: ['ETB', 'USD', 'EUR']
                          .map(
                            (value) => DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() => currency = value ?? 'ETB');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _field('Grace Period (Days)', grace, numeric: true),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _field(
                  'Max Hold Duration (Days)',
                  hold,
                  numeric: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _field('Fine Cap (0 for No Cap)', fineCap, numeric: true),
          const SizedBox(height: 14),
          const Divider(color: Color(0xFFE7F0FC)),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () => toast('Settings saved locally for this preview.'),
              icon: const Icon(Icons.save, size: 18),
              label: const Text('Save Policy Settings'),
              style: _buttonStyle(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        '$text *',
        style: const TextStyle(
          color: ink,
          fontWeight: FontWeight.w800,
          fontSize: 10.5,
        ),
      ),
    );
  }

  InputDecoration _decoration() {
    return InputDecoration(
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 12,
      ),
      filled: true,
      fillColor: Colors.white,
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
        borderSide: const BorderSide(color: blue, width: 1.4),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool numeric = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(label),
        TextField(
          controller: controller,
          keyboardType: numeric ? TextInputType.number : TextInputType.text,
          style: const TextStyle(color: ink, fontSize: 11),
          decoration: _decoration(),
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: blue,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 13),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 10,
      ),
    );
  }

  Widget _staffCard() {
    return _panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _title(
                  Icons.people_alt,
                  'Librarian Accounts & Permissions',
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addStaff,
                icon: const Icon(Icons.add, size: 15),
                label: const Text('Create Staff Account'),
                style: _buttonStyle(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Create staff accounts and control circulation permissions.',
            style: TextStyle(color: muted, fontSize: 10.5),
          ),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(pale),
              dataRowMinHeight: 78,
              dataRowMaxHeight: 92,
              headingRowHeight: 40,
              horizontalMargin: 6,
              columnSpacing: 12,
              headingTextStyle: const TextStyle(
                color: Color(0xFF0754C4),
                fontSize: 9,
                fontWeight: FontWeight.w900,
              ),
              dataTextStyle: const TextStyle(color: ink, fontSize: 9),
              columns: const [
                DataColumn(label: Text('Staff Member')),
                DataColumn(label: Text('Employee ID')),
                DataColumn(label: Text('Role')),
                DataColumn(label: Text('Permissions')),
                DataColumn(label: Text('Status')),
              ],
              rows: staff.map((s) {
                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 94,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 9,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              s.email,
                              style: const TextStyle(
                                color: muted,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(Text(s.id)),
                    DataCell(
                      SizedBox(
                        width: 105,
                        child: DropdownButtonFormField<String>(
                          value: s.role,
                          isExpanded: true,
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: pale,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 5,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(7),
                              ),
                              borderSide: BorderSide(color: line),
                            ),
                          ),
                          style: const TextStyle(color: ink, fontSize: 9),
                          items: [
                            'Chief Circulation Librarian',
                            'Circulation Officer',
                            'Assistant Librarian',
                            'Librarian',
                            'Assistant',
                            'Technician',
                          ].map((role) {
                            return DropdownMenuItem(
                              value: role,
                              child: Text(role),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => s.role = value ?? s.role);
                          },
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 105,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _permission('Add Books', s.addBooks),
                            const SizedBox(height: 5),
                            _permission('Waive Fines', s.waiveFines),
                          ],
                        ),
                      ),
                    ),
                    DataCell(_pill('Active', true)),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 15),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F7FF),
              border: Border.all(color: const Color(0xFFE0EEFF)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  radius: 15,
                  backgroundColor: blue,
                  child: Icon(Icons.shield, color: Colors.white, size: 17),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Role Management',
                        style: TextStyle(
                          color: ink,
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Administrator has full access. Librarian, Assistant, '
                        'and Technician access can be configured.',
                        style: TextStyle(
                          color: muted,
                          fontSize: 9,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _permission(String label, bool allowed) {
    return Row(
      children: [
        Icon(
          allowed ? Icons.check : Icons.close,
          color: allowed ? Colors.green : Colors.redAccent,
          size: 13,
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            '$label: ${allowed ? 'Granted' : 'Revoked'}',
            style: const TextStyle(color: muted, fontSize: 8.5),
          ),
        ),
      ],
    );
  }

  Widget _pill(String label, bool good) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      decoration: BoxDecoration(
        color: good
            ? const Color(0xFFE6FFF3)
            : const Color(0xFFFFECEC),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: good
              ? const Color(0xFFB9F1D7)
              : const Color(0xFFFFD1D1),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: good ? const Color(0xFF15935C) : Colors.redAccent,
          fontWeight: FontWeight.w800,
          fontSize: 8,
        ),
      ),
    );
  }

  Widget _inventory() {
    final filtered = books.where((book) {
      final matchesSearch =
          '${book.title} ${book.isbn} ${book.category}'
              .toLowerCase()
              .contains(search.toLowerCase());

      final matchesCategory =
          category == 'All Categories' || category == book.category;

      return matchesSearch && matchesCategory;
    }).toList();

    return _panel(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.menu_book, color: ink, size: 25),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Book Catalog & Physical Inventory',
                  style: TextStyle(
                    color: ink,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _addBook,
                icon: const Icon(Icons.add, size: 15),
                label: const Text('Add New Book Title'),
                style: _buttonStyle(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Manage book titles, physical copies, and availability status.',
            style: TextStyle(color: muted, fontSize: 10.5),
          ),
          const SizedBox(height: 15),
          LayoutBuilder(
            builder: (context, constraints) {
              final narrow = constraints.maxWidth < 430;

              final searchBox = TextField(
                onChanged: (value) => setState(() => search = value),
                style: const TextStyle(fontSize: 11, color: ink),
                decoration: _decoration().copyWith(
                  hintText: 'Search by title, author, ISBN...',
                  hintStyle: const TextStyle(
                    color: muted,
                    fontSize: 10,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: blue,
                    size: 18,
                  ),
                ),
              );

              final categoryBox = DropdownButtonFormField<String>(
                value: category,
                isExpanded: true,
                style: const TextStyle(color: muted, fontSize: 10),
                decoration: _decoration(),
                items: [
                  'All Categories',
                  ...books.map((book) => book.category).toSet(),
                ].map((value) {
                  return DropdownMenuItem(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() => category = value ?? 'All Categories');
                },
              );

              if (narrow) {
                return Column(
                  children: [
                    searchBox,
                    const SizedBox(height: 8),
                    categoryBox,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(flex: 3, child: searchBox),
                  const SizedBox(width: 8),
                  Expanded(flex: 2, child: categoryBox),
                ],
              );
            },
          ),
          const SizedBox(height: 15),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(pale),
              dataRowMinHeight: 80,
              dataRowMaxHeight: 92,
              headingRowHeight: 46,
              horizontalMargin: 6,
              columnSpacing: 10,
              headingTextStyle: const TextStyle(
                color: Color(0xFF0754C4),
                fontSize: 8.5,
                fontWeight: FontWeight.w900,
              ),
              dataTextStyle: const TextStyle(color: ink, fontSize: 8.5),
              columns: const [
                DataColumn(label: Text('Book Title')),
                DataColumn(label: Text('ISBN')),
                DataColumn(label: Text('Category')),
                DataColumn(label: Text('Location')),
                DataColumn(label: Text('Copies\n(Available/Total)')),
                DataColumn(label: Text('Status')),
                DataColumn(label: Text('Actions')),
              ],
              rows: filtered.map((book) {
                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 120,
                        child: Row(
                          children: [
                            Container(
                              width: 31,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE7F1FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                book.icon,
                                color: navy,
                                size: 21,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                book.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 8.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(width: 82, child: Text(book.isbn)),
                    ),
                    DataCell(
                      SizedBox(width: 78, child: Text(book.category)),
                    ),
                    DataCell(
                      SizedBox(width: 70, child: Text(book.location)),
                    ),
                    DataCell(Text(book.copies)),
                    DataCell(
                      _pill(
                        book.available ? 'Available' : 'Unavailable',
                        book.available,
                      ),
                    ),
                    DataCell(
                      Row(
                        children: [
                          _action(
                            Icons.edit,
                            blue,
                            () => _editBook(book),
                          ),
                          const SizedBox(width: 5),
                          _action(
                            Icons.delete_outline,
                            Colors.redAccent,
                            () {
                              setState(() => books.remove(book));
                              toast('Book removed.');
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _action(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(5),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: color.withValues(alpha: .06),
          border: Border.all(color: color.withValues(alpha: .35)),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  void _addStaff() {
    final name = TextEditingController();
    final email = TextEditingController();
    final id = TextEditingController();
    String role = 'Librarian';

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, refresh) {
            return AlertDialog(
              title: const Text('Create Staff Account'),
              content: SizedBox(
                width: 380,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: name,
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                        ),
                      ),
                      TextField(
                        controller: email,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                        ),
                      ),
                      TextField(
                        controller: id,
                        decoration: const InputDecoration(
                          labelText: 'Employee ID',
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: role,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: [
                          'Administrator',
                          'Librarian',
                          'Assistant',
                          'Technician',
                        ].map((value) {
                          return DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          refresh(() => role = value ?? role);
                        },
                      ),
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
                    if (name.text.trim().isEmpty ||
                        id.text.trim().isEmpty) {
                      toast('Name and employee ID are required.');
                      return;
                    }

                    setState(() {
                      staff.add(
                        StaffRow(
                          name.text.trim(),
                          email.text.trim(),
                          id.text.trim(),
                          role,
                          false,
                          false,
                        ),
                      );
                    });

                    Navigator.pop(dialogContext);
                    toast('Staff account added to this preview.');
                  },
                  child: const Text('Create Account'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addBook() {
    final title = TextEditingController();
    final isbn = TextEditingController();
    final cat = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Add New Book Title'),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Book title'),
                ),
                TextField(
                  controller: isbn,
                  decoration: const InputDecoration(labelText: 'ISBN'),
                ),
                TextField(
                  controller: cat,
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
              ],
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
                    isbn.text.trim().isEmpty) {
                  toast('Book title and ISBN are required.');
                  return;
                }

                setState(() {
                  books.add(
                    BookRow(
                      title.text.trim(),
                      isbn.text.trim(),
                      cat.text.trim().isEmpty
                          ? 'Uncategorized'
                          : cat.text.trim(),
                      'Not assigned',
                      '0 / 0',
                      false,
                      Icons.book,
                    ),
                  );
                });

                Navigator.pop(dialogContext);
                toast('Book added to this preview.');
              },
              child: const Text('Add Book'),
            ),
          ],
        );
      },
    );
  }

  void _editBook(BookRow book) {
    final title = TextEditingController(text: book.title);
    final isbn = TextEditingController(text: book.isbn);

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Edit Book'),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Book title'),
                ),
                TextField(
                  controller: isbn,
                  decoration: const InputDecoration(labelText: 'ISBN'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  book.title = title.text.trim();
                  book.isbn = isbn.text.trim();
                });

                Navigator.pop(dialogContext);
                toast('Book updated.');
              },
              child: const Text('Save Changes'),
            ),
          ],
        );
      },
    );
  }
}

class StaffRow {
  StaffRow(
    this.name,
    this.email,
    this.id,
    this.role,
    this.addBooks,
    this.waiveFines,
  );

  final String name;
  final String email;
  final String id;
  String role;
  final bool addBooks;
  final bool waiveFines;
}

class BookRow {
  BookRow(
    this.title,
    this.isbn,
    this.category,
    this.location,
    this.copies,
    this.available,
    this.icon,
  );

  String title;
  String isbn;
  final String category;
  final String location;
  final String copies;
  final bool available;
  final IconData icon;
}
