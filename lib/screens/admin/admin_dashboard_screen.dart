
import 'package:flutter/material.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  static const Color blue = Color(0xFF0052CC);
  static const Color navy = Color(0xFF142B4A);
  static const Color background = Color(0xFFF5F7FB);

  Widget _statCard(
    String title,
    String value,
    String caption,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7ECF4)),
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
                    color: Colors.blueGrey,
                    fontSize: 13,
                  ),
                ),
              ),
              CircleAvatar(
                radius: 19,
                backgroundColor: color.withValues(alpha: 0.10),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: navy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            caption,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _panel({
    required String title,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE7ECF4)),
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
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: navy,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _activity(
    IconData icon,
    Color color,
    String title,
    String subtitle,
    String time,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 19,
            backgroundColor: color.withValues(alpha: 0.10),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.blueGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _inventoryBar(
    String label,
    int amount,
    int total,
    Color color,
  ) {
    final ratio = total == 0 ? 0.0 : amount / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text(
                '$amount',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: ratio.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFFE9EEF6),
              color: color,
            ),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Administrator Dashboard',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: navy,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Overview of your library and its daily activity.',
                style: TextStyle(color: Colors.blueGrey),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth > 1000
                      ? 4
                      : constraints.maxWidth > 600
                          ? 2
                          : 1;

                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: columns == 1 ? 2.5 : 1.5,
                    children: [
                      _statCard(
                        'Total book copies',
                        '1,284',
                        'Across all categories',
                        Icons.menu_book_outlined,
                        blue,
                      ),
                      _statCard(
                        'Registered readers',
                        '486',
                        'Reader accounts',
                        Icons.people_outline,
                        Colors.purple,
                      ),
                      _statCard(
                        'Active loans',
                        '172',
                        'Books currently borrowed',
                        Icons.assignment_outlined,
                        Colors.orange,
                      ),
                      _statCard(
                        'Overdue books',
                        '18',
                        'Require attention',
                        Icons.warning_amber_rounded,
                        Colors.red,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              LayoutBuilder(
                builder: (context, constraints) {
                  final wide = constraints.maxWidth > 850;

                  final inventory = _panel(
                    title: 'Inventory overview',
                    trailing: const Icon(
                      Icons.pie_chart_outline,
                      color: blue,
                    ),
                    child: Column(
                      children: [
                        _inventoryBar(
                          'Available copies',
                          920,
                          1284,
                          Colors.green,
                        ),
                        _inventoryBar(
                          'Borrowed copies',
                          300,
                          1284,
                          blue,
                        ),
                        _inventoryBar(
                          'Reserved copies',
                          46,
                          1284,
                          Colors.orange,
                        ),
                        _inventoryBar(
                          'Unavailable copies',
                          18,
                          1284,
                          Colors.red,
                        ),
                      ],
                    ),
                  );

                  final activity = _panel(
                    title: 'Recent activity',
                    trailing: TextButton(
                      onPressed: () {},
                      child: const Text('View all'),
                    ),
                    child: Column(
                      children: [
                        _activity(
                          Icons.menu_book,
                          blue,
                          'Book borrowed',
                          'A reader borrowed a technology book.',
                          'Today',
                        ),
                        _activity(
                          Icons.assignment_return_outlined,
                          Colors.green,
                          'Book returned',
                          'A borrowed book was returned.',
                          'Today',
                        ),
                        _activity(
                          Icons.person_add_alt_1,
                          Colors.purple,
                          'Reader registered',
                          'A new reader account was created.',
                          'Yesterday',
                        ),
                        _activity(
                          Icons.notifications_active_outlined,
                          Colors.orange,
                          'Overdue reminder',
                          'An overdue reminder was generated.',
                          'Yesterday',
                        ),
                      ],
                    ),
                  );

                  if (wide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: inventory),
                        const SizedBox(width: 18),
                        Expanded(child: activity),
                      ],
                    );
                  }

                  return Column(
                    children: [
                      inventory,
                      const SizedBox(height: 18),
                      activity,
                    ],
                  );
                },
              ),
              const SizedBox(height: 22),
              _panel(
                title: 'Quick actions',
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    FilledButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Add book'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.people_outline),
                      label: const Text('Manage staff'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.settings_outlined),
                      label: const Text('LMS settings'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.bar_chart_outlined),
                      label: const Text('Reports'),
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
}
