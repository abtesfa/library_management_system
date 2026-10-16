
import 'package:flutter/material.dart';

import '../../models/borrow_record.dart';
import '../../providers/circulation_provider.dart';


class BorrowReturnPage extends StatefulWidget {
  const BorrowReturnPage({super.key});

  @override
  State<BorrowReturnPage> createState() => _BorrowReturnPageState();
}

class _BorrowReturnPageState extends State<BorrowReturnPage> {
  static const Color blue = Color(0xFF0668F9);
  static const Color navy = Color(0xFF073C8E);
  static const Color bg = Color(0xFFF3F9FF);
  static const Color border = Color(0xFFD8E9FF);
  static const Color green = Color(0xFF00AA91);

  int selectedMenu = 1;
  String bookCondition = 'Good';

  final borrowStudentController = TextEditingController();
  final borrowBookController = TextEditingController();
  final returnStudentController = TextEditingController();
  final returnBookController = TextEditingController();

  bool borrowStudentFound = false;
  bool borrowBookFound = false;
  bool returnStudentFound = false;
  bool returnBookFound = false;

  final List<Map<String, String>> dueBooks = [
    {
      'title': 'Atomic Habits',
      'author': 'James Clear',
      'due': 'Due in 2 days',
      'color': 'red',
    },
    {
      'title': 'Dune',
      'author': 'Frank Herbert',
      'due': 'Due in 5 days',
      'color': 'orange',
    },
    {
      'title': 'The Great Gatsby',
      'author': 'F. Scott Fitzgerald',
      'due': 'Due in 7 days',
      'color': 'blue',
    },
  ];

  @override
  void dispose() {
    borrowStudentController.dispose();
    borrowBookController.dispose();
    returnStudentController.dispose();
    returnBookController.dispose();
    super.dispose();
  }

  void message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: Row(
                children: [
                  _sidebar(),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (constraints.maxWidth >= 1050) {
                          return _wideLayout();
                        }
                        return _compactLayout();
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

  // HEADER

  Widget _header() {
    return Container(
      height: 68,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF073779),
            Color(0xFF0067D9),
          ],
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: blue,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              size: 33,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Text(
              'Library Management System',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () => message('You have 3 notifications.'),
                icon: const Icon(
                  Icons.notifications_active,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              Positioned(
                top: 1,
                right: 2,
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
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 15),
          const CircleAvatar(
            radius: 19,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.person,
              color: blue,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
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
              SizedBox(height: 4),
              Text(
                'Librarian',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.keyboard_arrow_down,
              color: Colors.white,
            ),
            onSelected: (value) {
              message(value == 'Logout'
                  ? 'Connect this action to your logout logic.'
                  : 'Profile selected.');
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

  // SIDEBAR

  Widget _sidebar() {
    return Container(
      width: 220,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF073779),
            Color(0xFF06458C),
            Color(0xFF0754AE),
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          _menuItem(Icons.home_rounded, 'Home', 0),
          _menuItem(Icons.swap_horiz_rounded, 'Borrow & Return', 1),
          _menuItem(
            Icons.notifications_active_rounded,
            'Notifications',
            2,
            badge: '3',
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.fromLTRB(22, 0, 10, 28),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.layers_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Read More,\nLearn More,\nGrow More.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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

  Widget _menuItem(
    IconData icon,
    String label,
    int index, {
    String? badge,
  }) {
    final selected = selectedMenu == index;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      child: Material(
        color: selected ? blue : Colors.transparent,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: () {
            setState(() => selectedMenu = index);

            if (index == 0) {
              message('Connect this item to your Home page.');
            } else if (index == 2) {
              message('Connect this item to your Notifications page.');
            }
          },
          child: SizedBox(
            height: 52,
            child: Row(
              children: [
                const SizedBox(width: 13),
                Icon(icon, color: Colors.white, size: 28),
                const SizedBox(width: 15),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (badge != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CircleAvatar(
                      radius: 11,
                      backgroundColor: Colors.red,
                      child: Text(
                        badge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                        ),
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

  // PAGE LAYOUT

  Widget _wideLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 7,
            child: Column(
              children: [
                _pageTitle(),
                const SizedBox(height: 15),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _borrowCard()),
                    const SizedBox(width: 14),
                    Expanded(child: _returnCard()),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _readingSummary(),
                const SizedBox(height: 14),
                _upcomingDueDates(),
                const SizedBox(height: 14),
                _recentNotifications(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _compactLayout() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          _pageTitle(),
          const SizedBox(height: 15),
          _borrowCard(),
          const SizedBox(height: 15),
          _returnCard(),
          const SizedBox(height: 15),
          _readingSummary(),
          const SizedBox(height: 15),
          _upcomingDueDates(),
          const SizedBox(height: 15),
          _recentNotifications(),
        ],
      ),
    );
  }

  Widget _pageTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back, Sara!',
              style: TextStyle(
                color: navy,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Borrow books, process returns, and keep track of your library activities.',
              style: TextStyle(
                color: Color(0xFF5288D9),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // BORROW BOOK FORM

  Widget _borrowCard() {
    return _panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _formHeader(
            Icons.menu_book_rounded,
            'Borrow Book',
            'Issue a book to a student',
            blue,
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                _searchField(
                  label: 'Student ID',
                  hint: 'Enter student ID (e.g. S-00123)',
                  controller: borrowStudentController,
                  icon: Icons.person,
                  onSearch: () {
                    if (borrowStudentController.text.trim().isEmpty) {
                      message('Enter a student ID first.');
                      return;
                    }
                    setState(() => borrowStudentFound = true);
                    message('Sample student record loaded.');
                  },
                ),
                const SizedBox(height: 20),
                _searchField(
                  label: 'Book Title or ISBN',
                  hint: 'Enter book title or ISBN',
                  controller: borrowBookController,
                  icon: Icons.search,
                  onSearch: () {
                    if (borrowBookController.text.trim().isEmpty) {
                      message('Enter a book title or ISBN first.');
                      return;
                    }
                    setState(() => borrowBookFound = true);
                    message('Sample book record loaded.');
                  },
                ),
                const SizedBox(height: 20),
                _informationBox(
                  title: 'Book Information',
                  icon: Icons.notifications_active_rounded,
                  color: blue,
                  rows: const [
                    ['Title:', 'The Great Gatsby'],
                    ['Author:', 'F. Scott Fitzgerald'],
                    ['ISBN:', '978-0132357059'],
                    ['Available Copies:', '4'],
                  ],
                ),
                const SizedBox(height: 14),
                _informationBox(
                  title: 'Student Information',
                  icon: Icons.person,
                  color: green,
                  background: const Color(0xFFEAF9F5),
                  rows: [
                    [
                      'Name:',
                      borrowStudentFound ? 'Abebe Kebede' : 'Abebe Kebede',
                    ],
                    ['Student ID:', 'S-00123'],
                    ['Department:', 'Computer Science'],
                  ],
                ),
                const SizedBox(height: 14),
                _borrowingDetails(),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: _confirmBorrow,
                    icon: const Icon(Icons.menu_book_rounded, size: 20),
                    label: const Text(
                      'Confirm Borrowing',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
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

  // RETURN BOOK FORM

  Widget _returnCard() {
    return _panel(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _formHeader(
            Icons.swap_horiz_rounded,
            'Return Book',
            'Process a book return and check for fines',
            green,
          ),
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              children: [
                _searchField(
                  label: 'Student ID',
                  hint: 'Enter student ID (e.g. S-00123)',
                  controller: returnStudentController,
                  icon: Icons.person,
                  onSearch: () {
                    if (returnStudentController.text.trim().isEmpty) {
                      message('Enter a student ID first.');
                      return;
                    }
                    setState(() => returnStudentFound = true);
                    message('Sample borrowing record loaded.');
                  },
                ),
                const SizedBox(height: 20),
                _searchField(
                  label: 'Book Title or ISBN',
                  hint: 'Enter book title or ISBN',
                  controller: returnBookController,
                  icon: Icons.search,
                  onSearch: () {
                    if (returnBookController.text.trim().isEmpty) {
                      message('Enter a book title or ISBN first.');
                      return;
                    }
                    setState(() => returnBookFound = true);
                    message('Sample return record loaded.');
                  },
                ),
                const SizedBox(height: 20),
                _informationBox(
                  title: 'Borrowing Record',
                  icon: Icons.description_rounded,
                  color: blue,
                  rows: const [
                    ['Student Name:', 'Abebe Kebede'],
                    ['Book Title:', 'The Great Gatsby'],
                    ['ISBN:', '978-0132357059'],
                    ['Borrow Date:', '2025-06-08'],
                    ['Due Date:', '2025-06-22'],
                  ],
                ),
                const SizedBox(height: 14),
                _fineBox(),
                const SizedBox(height: 14),
                _conditionBox(),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 42,
                  child: ElevatedButton.icon(
                    onPressed: _confirmReturn,
                    icon: const Icon(Icons.currency_exchange, size: 19),
                    label: const Text(
                      'Confirm Return',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7),
                      ),
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

  void _confirmBorrow() {
    if (borrowStudentController.text.trim().isEmpty ||
        borrowBookController.text.trim().isEmpty) {
      message('Enter the student ID and book title or ISBN.');
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Borrowing'),
        content: const Text(
          'This is a sample interface. Connect the confirmation to your '
          'database to save the borrowing transaction.',
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

  void _confirmReturn() {
    if (returnStudentController.text.trim().isEmpty ||
        returnBookController.text.trim().isEmpty) {
      message('Enter the student ID and book title or ISBN.');
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Return'),
        content: Text(
          'Selected book condition: $bookCondition.\n\n'
          'Connect this action to your database to record the return and '
          'calculate the final fine.',
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

  // FORM HEADERS AND INPUTS

  Widget _formHeader(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        children: [
          Container(
            height: 58,
            width: 58,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF5785CD),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    required VoidCallback onSearch,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: const TextStyle(
              color: navy,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(text: label),
              const TextSpan(
                text: ' *',
                style: TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
        const SizedBox(height: 7),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 37,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: border),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => onSearch(),
                  style: const TextStyle(
                    fontSize: 12,
                    color: navy,
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(icon, size: 18, color: navy),
                    hintText: hint,
                    hintStyle: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7398D2),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    isDense: true,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 9),
            SizedBox(
              height: 37,
              child: ElevatedButton.icon(
                onPressed: onSearch,
                icon: const Icon(Icons.search, size: 16),
                label: const Text(
                  'Search',
                  style: TextStyle(fontSize: 11),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(7),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // INFORMATION BOXES

  Widget _informationBox({
    required String title,
    required IconData icon,
    required Color color,
    required List<List<String>> rows,
    Color background = const Color(0xFFF0F7FF),
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  color: color == green ? const Color(0xFF008D85) : navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      row[0],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF2863B5),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 6,
                    child: Text(
                      row[1],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF245EB1),
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

  Widget _borrowingDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_month, color: blue, size: 20),
              SizedBox(width: 10),
              Text(
                'Borrowing Details',
                style: TextStyle(
                  color: navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _dateRow('Borrow Date:', '2025-06-08'),
          const SizedBox(height: 8),
          _dateRow('Due Date:', '2025-06-22 (14 days)'),
        ],
      ),
    );
  }

  Widget _dateRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF2863B5),
            ),
          ),
        ),
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: border),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_month,
                  size: 14,
                  color: blue,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF4777C4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // FINE DETAILS

  Widget _fineBox() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F1),
        border: Border.all(color: const Color(0xFFFFD8DC)),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_rounded,
            color: Color(0xFFE72E3D),
            size: 22,
          ),
          const SizedBox(width: 9),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overdue Fine',
                  style: TextStyle(
                    color: Color(0xFFE72E3D),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '\$2.00',
                  style: TextStyle(
                    color: Color(0xFFE72E3D),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'The book is 5 days overdue.',
                  style: TextStyle(
                    color: Color(0xFFB45B68),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fine Details',
                    style: TextStyle(
                      color: Color(0xFFE72E3D),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  _FineRow(label: 'Daily fine rate:', value: '\$0.40'),
                  SizedBox(height: 7),
                  _FineRow(label: 'Overdue days:', value: '5'),
                  SizedBox(height: 7),
                  _FineRow(label: 'Total fine:', value: '\$2.00'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BOOK CONDITION

  Widget _conditionBox() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.menu_book_rounded, color: navy, size: 20),
              SizedBox(width: 10),
              Text(
                'Book Condition',
                style: TextStyle(
                  color: navy,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 2,
            children: [
              _conditionOption('Good'),
              _conditionOption('Minor damage'),
              _conditionOption('Lost'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _conditionOption(String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<String>(
          value: value,
          groupValue: bookCondition,
          activeColor: blue,
          visualDensity: VisualDensity.compact,
          onChanged: (newValue) {
            if (newValue != null) {
              setState(() => bookCondition = newValue);
            }
          },
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF245EB1),
          ),
        ),
      ],
    );
  }

  // RIGHT PANEL: READING SUMMARY

  Widget _readingSummary() {
    return _panel(
      child: Column(
        children: [
          _panelTitle(
            Icons.menu_book_rounded,
            'My Reading Summary',
            action: 'View All',
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
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF477AC8),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // RIGHT PANEL: DUE DATES

  Widget _upcomingDueDates() {
    return _panel(
      child: Column(
        children: [
          _panelTitle(
            Icons.calendar_month_rounded,
            'Upcoming Due Dates',
            action: 'View All',
          ),
          const SizedBox(height: 8),
          for (final book in dueBooks) ...[
            const Divider(color: border, height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  _cover(book['title']!),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book['title']!,
                          style: const TextStyle(
                            color: navy,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          book['author']!,
                          style: const TextStyle(
                            color: Color(0xFF4C80CC),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: _dueBadge(
                      book['due']!,
                      book['color']!,
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

  Widget _cover(String title) {
    IconData icon = Icons.menu_book_rounded;

    if (title == 'Dune') {
      icon = Icons.auto_stories_rounded;
    }

    return Container(
      height: 56,
      width: 43,
      decoration: BoxDecoration(
        color: const Color(0xFFE7F1FF),
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, color: navy, size: 28),
    );
  }

  Widget _dueBadge(String text, String colorName) {
    Color color;
    Color foreground;

    switch (colorName) {
      case 'red':
        color = const Color(0xFFFFE9E9);
        foreground = const Color(0xFFFF4141);
        break;
      case 'orange':
        color = const Color(0xFFFFF3E0);
        foreground = const Color(0xFFFF9800);
        break;
      default:
        color = const Color(0xFFE7F2FF);
        foreground = blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: foreground,
          fontSize: 10,
        ),
      ),
    );
  }

  // RIGHT PANEL: NOTIFICATIONS

  Widget _recentNotifications() {
    return _panel(
      child: Column(
        children: [
          _panelTitle(
            Icons.notifications_active_rounded,
            'Recent Notifications',
            action: 'View All',
          ),
          const SizedBox(height: 8),
          _notification(
            Icons.notifications_active_rounded,
            const Color(0xFFFFE8EF),
            const Color(0xFFFF3D62),
            'Your book “Atomic Habits” is due in 2 days.',
            '2 hours ago',
          ),
          const Divider(color: border, height: 1),
          _notification(
            Icons.info_rounded,
            const Color(0xFFE7F2FF),
            blue,
            'New reservation for “The Martian” is now available.',
            '1 day ago',
          ),
          const Divider(color: border, height: 1),
          _notification(
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

  Widget _notification(
    IconData icon,
    Color backgroundColor,
    Color iconColor,
    String text,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: const TextStyle(
                    color: navy,
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  time,
                  style: const TextStyle(
                    color: Color(0xFF5688D3),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // REUSABLE PANEL HELPERS

  Widget _panel({
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(15),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6CA8EA).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _panelTitle(
    IconData icon,
    String title, {
    String? action,
  }) {
    return Row(
      children: [
        Icon(icon, color: blue, size: 25),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: navy,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        if (action != null)
          TextButton(
            onPressed: () => message('$title: view all selected.'),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  action,
                  style: const TextStyle(fontSize: 11),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_forward, size: 13),
              ],
            ),
          ),
      ],
    );
  }
}

class _FineRow extends StatelessWidget {
  final String label;
  final String value;

  const _FineRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFB45B68),
              fontSize: 10,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFFE72E3D),
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
