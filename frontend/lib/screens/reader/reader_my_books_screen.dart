import 'package:flutter/material.dart';
import '../../data/mock_library_data.dart';
import '../../models/borrow_record.dart';

class ReaderMyBooksScreen extends StatefulWidget {
  const ReaderMyBooksScreen({super.key});

  @override
  State<ReaderMyBooksScreen> createState() => _ReaderMyBooksScreenState();
}

class _ReaderMyBooksScreenState extends State<ReaderMyBooksScreen> {
  late List<BorrowRecord> _borrowed;

  @override
  void initState() {
    super.initState();
    _borrowed = MockLibraryData.getReaderBorrowedBooks();
  }

  void _renewBook(BorrowRecord record) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Successfully renewed "${record.bookTitle}" (+14 days)!'),
        backgroundColor: const Color(0xFF059669),
      ),
    );
  }

  String _getCoverUrl(String title) {
    final encodedTitle = Uri.encodeComponent(title);

    return 'https://covers.openlibrary.org/b/title/$encodedTitle-M.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bookmark_outline,
                    color: Color(0xFF0052CC), size: 24),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Books',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A)),
                  ),
                  Text(
                    'Track currently borrowed titles, loan due dates, and one-click renewals',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Active Borrows Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Borrowed List
              Expanded(
                flex: 3,
                child: Column(
                  children:
                      _borrowed.map((b) => _buildBorrowedCard(b)).toList(),
                ),
              ),
              const SizedBox(width: 24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBorrowedCard(BorrowRecord b) {
    final isUrgent = b.daysLeft <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              _getCoverUrl(b.bookTitle),
              width: 60,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 80,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
                    ),
                  ),
                  child: const Icon(
                    Icons.book,
                    color: Colors.white70,
                    size: 28,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  b.bookTitle,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Text(
                  'ISBN: ${b.isbn} · Borrowed: ${b.borrowDate}',
                  style:
                      const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isUrgent
                            ? const Color(0xFFFEF2F2)
                            : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Due: ${b.dueDate} (${b.daysLeft} days left)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isUrgent
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF1D4ED8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _renewBook(b),
            icon: const Icon(Icons.refresh, size: 14),
            label: const Text('Renew Loan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0052CC),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
