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

final TextEditingController _searchController = TextEditingController();

String _searchQuery = '';

List<BorrowRecord> get _filteredBorrowed {
  if (_searchQuery.trim().isEmpty) {
    return _borrowed;
  }

  final query = _searchQuery.toLowerCase().trim();

  return _borrowed.where((book) {
    return book.bookTitle.toLowerCase().contains(query) ||
        book.isbn.toLowerCase().contains(query);
  }).toList();
}

@override
void dispose() {
  _searchController.dispose();
  super.dispose();
}

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
                child: const Icon(Icons.bookmark_outline, color: Color(0xFF0052CC), size: 24),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Books',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    'Manage your borrowed books,due dates and reading history',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
                   const SizedBox(height: 24),

          // Search borrowed books
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search by book title or ISBN...',
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF0052CC),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      tooltip: 'Clear search',
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE2E8F0),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE2E8F0),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF0052CC),
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Active Borrows Grid

          // Active Borrows Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Borrowed List
              Expanded(
                flex: 3,
                child: Column(
                  children: _filteredBorrowed.isEmpty
    ? [
        Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                const Icon(
                  Icons.search_off,
                  size: 42,
                  color: Color(0xFF94A3B8),
                ),
                const SizedBox(height: 12),
                Text(
                  _borrowed.isEmpty
                      ? 'You have no borrowed books.'
                      : 'No books found for "$_searchQuery".',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ]
    : _filteredBorrowed.map((b) => _buildBorrowedCard(b)).toList(),
                ),
              ),
              const SizedBox(width: 24),

              // Reading Progress Side Gauge
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Semester Reading Goal',
                        style: TextStyle(fontSize: 15,
                         fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                      ),
                      SizedBox(height: 18),
                      Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 110,
                              height: 110,
                              child: CircularProgressIndicator(
                                value: 0.70,
                                strokeWidth: 10,
                                backgroundColor: Color(0xFFE2E8F0),
                                valueColor: AlwaysStoppedAnimation(Color(0xFF0052CC)),
                              ),
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text('70%', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                                Text('14 / 20 Books', style: TextStyle(fontSize: 10, color: Color(0xFF64748B))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 18),
                      Divider(color: Color(0xFFE2E8F0)),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Active Books Loaned', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          Text('2', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                        ],
                      ),
                      SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Outstanding Fines', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          Text('\ETB 0.00', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
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
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 4),
                Text(
                  'ISBN: ${b.isbn} · Borrowed: ${b.borrowDate}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isUrgent ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Due: ${b.dueDate} (${b.daysLeft} days left)',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isUrgent ? const Color(0xFFDC2626) : const Color(0xFF1D4ED8),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}
