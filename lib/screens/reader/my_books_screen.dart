
import 'package:flutter/material.dart';

class MyBooksScreen extends StatelessWidget {
  const MyBooksScreen({super.key});

  static const blue = Color(0xFF0755C9);
  static const darkBlue = Color(0xFF073B86);

  final List<Map<String, String>> borrowedBooks = const [
    {
      'title': 'Atomic Habits',
      'author': 'James Clear',
      'borrowed': 'Oct 2, 2026',
      'due': 'Oct 10, 2026',
      'status': 'Due in 2 days',
    },
    {
      'title': 'Dune',
      'author': 'Frank Herbert',
      'borrowed': 'Sep 28, 2026',
      'due': 'Oct 13, 2026',
      'status': 'Due in 5 days',
    },
    {
      'title': 'The Great Gatsby',
      'author': 'F. Scott Fitzgerald',
      'borrowed': 'Sep 25, 2026',
      'due': 'Oct 15, 2026',
      'status': 'Due in 7 days',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FD),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'My Books',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: darkBlue,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Manage your borrowed books, due dates, and reading history.',
                style: TextStyle(color: Colors.blueGrey),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search my books...',
                  prefixIcon: const Icon(Icons.search, color: blue),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(9),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: const [
                  _StatCard(
                    title: 'Currently Borrowed',
                    value: '3',
                    icon: Icons.menu_book,
                    color: blue,
                  ),
                  _StatCard(
                    title: 'Due Soon',
                    value: '1',
                    icon: Icons.access_time,
                    color: Colors.orange,
                  ),
                  _StatCard(
                    title: 'Overdue',
                    value: '0',
                    icon: Icons.warning_amber,
                    color: Colors.red,
                  ),
                  _StatCard(
                    title: 'Completed',
                    value: '8',
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _section(
                'Currently Borrowed',
                Column(
                  children: borrowedBooks.map((book) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFE),
                        borderRadius: BorderRadius.circular(9),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 65,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5EEFF),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.menu_book,
                              color: blue,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book['title']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: darkBlue,
                                  ),
                                ),
                                Text(
                                  book['author']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Borrowed: ${book['borrowed']}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                Text(
                                  'Due: ${book['due']}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  book['status']!,
                                  style: const TextStyle(
                                    color: Colors.deepOrange,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Renewal requested for ${book['title']}',
                                  ),
                                ),
                              );
                            },
                            child: const Text('Renew'),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              _section(
                'Borrowing History',
                const Column(
                  children: [
                    _HistoryRow(
                      title: 'Clean Code',
                      borrowed: 'Sep 15, 2026',
                      returned: 'Oct 1, 2026',
                    ),
                    Divider(),
                    _HistoryRow(
                      title: 'Sapiens',
                      borrowed: 'Sep 10, 2026',
                      returned: 'Sep 27, 2026',
                    ),
                    Divider(),
                    _HistoryRow(
                      title: '1984',
                      borrowed: 'Sep 5, 2026',
                      returned: 'Sep 20, 2026',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: darkBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 27),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                      color: color,
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    )),
                Text(title,
                    style: const TextStyle(
                        fontSize: 11, color: Colors.blueGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  final String title;
  final String borrowed;
  final String returned;

  const _HistoryRow({
    required this.title,
    required this.borrowed,
    required this.returned,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(title, style: const TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: Text(borrowed, style: const TextStyle(fontSize: 11)),
          ),
          Expanded(
            child: Text(returned, style: const TextStyle(fontSize: 11)),
          ),
          const Text('Returned',
              style: TextStyle(color: Colors.green, fontSize: 11)),
        ],
      ),
    );
  }
}
