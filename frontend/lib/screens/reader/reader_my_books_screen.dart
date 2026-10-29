
import 'package:flutter/material.dart';
import '../../data/mock_library_data.dart';
import '../../models/borrow_record.dart';

class ReaderMyBooksScreen extends StatefulWidget {
  const ReaderMyBooksScreen({super.key});

  @override
  State<ReaderMyBooksScreen> createState() =>
      _ReaderMyBooksScreenState();
}

class _ReaderMyBooksScreenState extends State<ReaderMyBooksScreen> {
  late List<BorrowRecord> _borrowed;

  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _borrowed = MockLibraryData.getReaderBorrowedBooks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Filter borrowed books by title or ISBN.
  List<BorrowRecord> get _filteredBorrowed {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return _borrowed;
    }

    return _borrowed.where((book) {
      return book.bookTitle.toLowerCase().contains(query) ||
          book.isbn.toLowerCase().contains(query);
    }).toList();
  }

  // Search button action.
  void _searchBooks() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  // Clear the search field.
  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });
  }

  // Renew a borrowed book.
  void _renewBook(BorrowRecord record) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '"${record.bookTitle}" renewal requested.',
        ),
        backgroundColor: const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Get a book cover from Open Library.
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
          // Page header.
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bookmark_outline,
                  color: Color(0xFF0052CC),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Books',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage your borrowed books, due dates and reading history.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Search bar.
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            onSubmitted: (_) => _searchBooks(),
            decoration: InputDecoration(
              hintText: 'Search by book title or ISBN...',
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: Color(0xFF64748B),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        tooltip: 'Clear search',
                        onPressed: _clearSearch,
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF64748B),
                          size: 20,
                        ),
                      ),
                    ElevatedButton.icon(
                      onPressed: _searchBooks,
                      icon: const Icon(
                        Icons.search,
                        size: 20,
                      ),
                      label: const Text(
                        'Search',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0668F9),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFCBD5E1),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF0052CC),
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Borrowed books and tips panel.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Borrowed books list.
              Expanded(
                flex: 3,
                child: Column(
                  children: _filteredBorrowed.isEmpty
                      ? [
                          _buildEmptyState(),
                        ]
                      : _filteredBorrowed
                          .map((book) => _buildBorrowedCard(book))
                          .toList(),
                ),
              ),

              const SizedBox(width: 24),

              // Book Care & Return Tips.
              Expanded(
                flex: 2,
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            color: Color(0xFF0052CC),
                            size: 24,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Book Care & Return Tips',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Help keep our library books in good condition.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 24),

                      _bookCareTip(
                        icon: Icons.calendar_month_rounded,
                        title: 'Return Books on Time',
                        description:
                            'Return borrowed books by their due dates to avoid overdue fines.',
                        color: const Color(0xFF2563EB),
                        background: const Color(0xFFEFF6FF),
                      ),

                      const SizedBox(height: 22),

                      _bookCareTip(
                        icon: Icons.favorite_border_rounded,
                        title: 'Keep Books Safe',
                        description:
                            'Protect books from water, dirt, torn pages and other damage.',
                        color: const Color(0xFF059669),
                        background: const Color(0xFFECFDF5),
                      ),

                      const SizedBox(height: 22),

                      _bookCareTip(
                        icon: Icons.autorenew_rounded,
                        title: 'Renew Before Due Dates',
                        description:
                            'If you need more time, renew eligible books before they are due.',
                        color: const Color(0xFF7C3AED),
                        background: const Color(0xFFF5F3FF),
                      ),

                      const SizedBox(height: 22),

                      _bookCareTip(
                        icon: Icons.bookmark_outline_rounded,
                        title: 'Handle Books Carefully',
                        description:
                            'Keep pages clean and avoid writing or marking inside library books.',
                        color: const Color(0xFFD97706),
                        background: const Color(0xFFFFF7ED),
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

  // Empty search results.
  Widget _buildEmptyState() {
    final hasNoBorrowedBooks = _borrowed.isEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off,
            size: 42,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 12),
          Text(
            hasNoBorrowedBooks
                ? 'You have no borrowed books.'
                : 'No books found for "$_searchQuery".',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 14,
            ),
          ),
          if (!hasNoBorrowedBooks && _searchQuery.isNotEmpty) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: _clearSearch,
              child: const Text('Clear Search'),
            ),
          ],
        ],
      ),
    );
  }

  // Book care tip item.
  Widget _bookCareTip({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required Color background,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Individual borrowed book card.
  Widget _buildBorrowedCard(BorrowRecord book) {
    final bool isOverdue = book.daysLeft < 0;
    final bool isUrgent = book.daysLeft >= 0 && book.daysLeft <= 3;

    final Color statusColor = isOverdue || isUrgent
        ? const Color(0xFFDC2626)
        : const Color(0xFF1D4ED8);

    final Color statusBackground = isOverdue || isUrgent
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFEFF6FF);

    final String dueStatus;

    if (isOverdue) {
      dueStatus =
          'Overdue by ${book.daysLeft.abs()} day${book.daysLeft.abs() == 1 ? '' : 's'}';
    } else if (book.daysLeft == 0) {
      dueStatus = 'Due today';
    } else {
      dueStatus = 'Due: ${book.dueDate} (${book.daysLeft} days left)';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          // Book cover.
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              _getCoverUrl(book.bookTitle),
              width: 60,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 80,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF1E3A8A),
                        Color(0xFF2563EB),
                      ],
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

          // Book details.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.bookTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF0F172A),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'ISBN: ${book.isbn} · Borrowed: ${book.borrowDate}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),

                const SizedBox(height: 9),

                Wrap(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusBackground,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        dueStatus,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Renewal button.
          ElevatedButton.icon(
            onPressed: () => _renewBook(book),
            icon: const Icon(
              Icons.refresh,
              size: 14,
            ),
            label: const Text('Renew Loan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0052CC),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
