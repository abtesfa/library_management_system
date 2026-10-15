
import 'package:flutter/material.dart';

class ReaderReservationsScreen extends StatefulWidget {
  const ReaderReservationsScreen({super.key});

  @override
  State<ReaderReservationsScreen> createState() =>
      _ReaderReservationsScreenState();
}

class _ReaderReservationsScreenState
    extends State<ReaderReservationsScreen> {
  static const blue = Color(0xFF0755C9);
  static const darkBlue = Color(0xFF073B86);

  final List<Map<String, String>> reservations = [
    {
      'title': 'The Great Gatsby',
      'author': 'F. Scott Fitzgerald',
      'reserved': 'May 15, 2026',
      'pickup': 'May 29, 2026',
      'status': 'Active',
    },
    {
      'title': 'Atomic Habits',
      'author': 'James Clear',
      'reserved': 'May 12, 2026',
      'pickup': 'May 26, 2026',
      'status': 'Ready for Pickup',
    },
  ];

  final history = const [
    ['Dune', 'Frank Herbert', 'Completed on Apr 27, 2026'],
    ['Clean Code', 'Robert C. Martin', 'Completed on Apr 17, 2026'],
    ['Sapiens', 'Yuval Noah Harari', 'Completed on Apr 2, 2026'],
  ];

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

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
                'Reservations',
                style: TextStyle(
                  color: darkBlue,
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'View and manage your active reservations and reservation history.',
                style: TextStyle(color: Colors.blueGrey),
              ),
              const SizedBox(height: 20),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search by book title, author, or ISBN...',
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
                  _ReservationStat(
                    title: 'Active Reservations',
                    value: '1',
                    icon: Icons.menu_book,
                  ),
                  _ReservationStat(
                    title: 'Ready for Pickup',
                    value: '1',
                    icon: Icons.hourglass_top,
                  ),
                  _ReservationStat(
                    title: 'Upcoming',
                    value: '0',
                    icon: Icons.access_time,
                  ),
                  _ReservationStat(
                    title: 'Completed',
                    value: '5',
                    icon: Icons.check_circle,
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _panel(
                'Active Reservations',
                Column(
                  children: reservations.map((reservation) {
                    final ready =
                        reservation['status'] == 'Ready for Pickup';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFE),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 62,
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
                                  reservation['title']!,
                                  style: const TextStyle(
                                    color: darkBlue,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  reservation['author']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.blueGrey,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Reserved: ${reservation['reserved']}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                Text(
                                  'Pickup by: ${reservation['pickup']}',
                                  style: const TextStyle(fontSize: 11),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  reservation['status']!,
                                  style: TextStyle(
                                    color: ready ? Colors.green : blue,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              if (ready)
                                ElevatedButton(
                                  onPressed: () => showMessage(
                                    'Pickup requested for ${reservation['title']}',
                                  ),
                                  child: const Text('Mark Picked Up'),
                                ),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    reservations.remove(reservation);
                                  });
                                  showMessage('Reservation cancelled.');
                                },
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              _panel(
                'Reservation History',
                Column(
                  children: history.map((item) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFE5EEFF),
                        child: Icon(Icons.menu_book, color: blue),
                      ),
                      title: Text(
                        item[0],
                        style: const TextStyle(
                          color: darkBlue,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(item[1]),
                      trailing: Text(
                        item[2],
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
              _panel(
                'Reservation Policies',
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('• You can reserve up to 3 books at a time.'),
                    SizedBox(height: 10),
                    Text('• You will be notified when your book is ready.'),
                    SizedBox(height: 10),
                    Text('• Reserved books are held for 7 days.'),
                    SizedBox(height: 10),
                    Text('• Cancel reservations you no longer need.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _panel(String title, Widget child) {
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
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _ReservationStat extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _ReservationStat({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 165,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0755C9), size: 27),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF073B86),
                  ),
                ),
                Text(title,
                    style: const TextStyle(
                        fontSize: 10, color: Colors.blueGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
