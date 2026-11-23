
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/borrow_record.dart';
import '../../data/datasources/borrowing_remote_data_source.dart';
import '../../../../core/di/injector.dart';
import '../../../library/presentation/providers/library_service.dart';
import '../../domain/usecases/get_my_books.dart';
import '../../domain/usecases/renew_book.dart';

class StudentMyBooksScreen extends StatefulWidget {
  final String studentId;

  const StudentMyBooksScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<StudentMyBooksScreen> createState() =>
      _StudentMyBooksScreenState();
}

class _StudentMyBooksScreenState extends State<StudentMyBooksScreen> {
  List<BorrowRecord> _borrowed = [];
  List<Map<String, dynamic>> _history = [];

  int _historyPage = 0;
  static const int _historyPageSize = 4;

  final BorrowingRemoteDataSource _historyDataSource =
      BorrowingRemoteDataSource();

  bool _historyLoading = true;

  final GetMyBooks _getMyBooksUseCase = injector.getMyBooks;
  final RenewBook _renewBookUseCase = injector.renewBook;

  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';

  bool _isLoading = true;
  String? _errorMessage;

  LibraryService? _libraryService;
  int _seenBorrowingsRevision = 0;

  String? _renewingId;

  // Page colors.
  static const Color primaryColor = Color(0xFFF25635);
  static const Color lightPrimaryColor = Color(0xFFFBE2D9);
  static const Color darkTextColor = Color(0xFF171717);
  static const Color secondaryTextColor = Color(0xFF666666);
  static const Color borderColor = Color(0xFFE5E7EB);
  static const Color successColor = Color(0xFF059669);
  static const Color successBackground = Color(0xFFECFDF5);

  @override
  void initState() {
    super.initState();
    _loadBorrowedBooks();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final service = context.read<LibraryService>();

    if (identical(service, _libraryService)) return;

    _libraryService?.removeListener(_handleBorrowingsChanged);

    _libraryService = service;
    _seenBorrowingsRevision = service.borrowingsRevision;

    service.addListener(_handleBorrowingsChanged);
  }

  void _handleBorrowingsChanged() {
    final service = _libraryService;

    if (!mounted ||
        service == null ||
        service.borrowingsRevision == _seenBorrowingsRevision) {
      return;
    }

    _seenBorrowingsRevision = service.borrowingsRevision;
    _loadBorrowedBooks();
  }

  @override
  void dispose() {
    _libraryService?.removeListener(_handleBorrowingsChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Load borrowed books and borrowing history.
  Future<void> _loadBorrowedBooks() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _historyLoading = true;
      _errorMessage = null;
    });

    try {
      final books = await _getMyBooksUseCase(widget.studentId);

      final history =
          await _historyDataSource.getBorrowingHistory(
        widget.studentId,
      );

      if (!mounted) return;

      setState(() {
        _borrowed = books;
        _history = history;
        _historyPage = 0;
        _isLoading = false;
        _historyLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
        _historyLoading = false;
      });
    }
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

  void _searchBooks() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });
  }

  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });
  }

  // Renew a borrowed book.
  Future<void> _renewBook(BorrowRecord record) async {
    if (_renewingId != null) return;

    setState(() {
      _renewingId = record.id;
    });

    try {
      final newDueDate =
          await _renewBookUseCase(widget.studentId, record.id);

      if (!mounted) return;

      _showSnackBar(
        '"${record.bookTitle}" renewed. New due date: $newDueDate.',
        isError: false,
      );

      await _loadBorrowedBooks();
    } catch (error) {
      if (!mounted) return;

      _showSnackBar(
        error.toString().replaceFirst('Exception: ', ''),
        isError: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _renewingId = null;
        });
      }
    }
  }

  void _showSnackBar(
    String message, {
    required bool isError,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? const Color(0xFFDC2626)
            : successColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Get a book cover from Open Library.
  String _getCoverUrl(String title) {
    final encodedTitle = Uri.encodeComponent(title);

    return 'https://covers.openlibrary.org/b/title/$encodedTitle-M.jpg';
  }

  // =============================================================
  // BORROWED BOOKS SECTION
  // =============================================================

  Widget _buildBorrowedBooksSection() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(
            color: primaryColor,
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD9D9D9),
          ),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.error_outline,
              size: 40,
              color: Colors.red,
            ),
            const SizedBox(height: 12),
            const Text(
              'Unable to load your borrowed books.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkTextColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: secondaryTextColor,
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _loadBorrowedBooks,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      );
    }

    if (_filteredBorrowed.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: _filteredBorrowed
          .map((book) => _buildBorrowedCard(book))
          .toList(),
    );
  }

  // =============================================================
  // MAIN PAGE
  // =============================================================

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
                  color: lightPrimaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bookmark_outline,
                  color: primaryColor,
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
                        color: darkTextColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage your borrowed books, due dates and reading history.',
                      style: TextStyle(
                        fontSize: 12,
                        color: secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Refresh borrowed books',
                onPressed: _isLoading ? null : _loadBorrowedBooks,
                icon: const Icon(
                  Icons.refresh,
                  color: primaryColor,
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
                color: Color(0xFFAAA898),
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search,
                color: secondaryTextColor,
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
                          color: secondaryTextColor,
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
                        backgroundColor: primaryColor,
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
                  color: Color(0xFFD9D9D9),
                  width: 1.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFFD9D9D9),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: primaryColor,
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          _buildBorrowedBooksSection(),

          const SizedBox(height: 24),

          _buildHistorySection(),
        ],
      ),
    );
  }

  // =============================================================
  // BORROWING HISTORY WITH PAGINATION
  // Four books per page, displayed in a 2 x 2 grid.
  // =============================================================

  Widget _buildHistorySection() {
    final totalPages =
        (_history.length / _historyPageSize).ceil();

    final safePage = totalPages == 0
        ? 0
        : (_historyPage >= totalPages
            ? totalPages - 1
            : _historyPage);

    final startIndex = safePage * _historyPageSize;

    final endIndex =
        (startIndex + _historyPageSize) < _history.length
            ? startIndex + _historyPageSize
            : _history.length;

    final paginatedHistory =
        _history.sublist(startIndex, endIndex);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // History header.
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: lightPrimaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.history_rounded,
                  color: primaryColor,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Borrowing History',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: darkTextColor,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Your previously returned books',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF777777),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: lightPrimaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_history.length} returned',
                  style: const TextStyle(
                    color: primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          if (_historyLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(
                  color: primaryColor,
                ),
              ),
            )
          else if (_history.isEmpty)
            _buildEmptyHistory()
          else ...[
            // Two-column history grid.
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: paginatedHistory.length,
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                mainAxisExtent: 220,
              ),
              itemBuilder: (context, index) {
                final item = paginatedHistory[index];

                final title =
                    item['bookTitle']?.toString() ?? 'Book';

                final fineValue =
                    item['fineAmount']?.toString() ?? '0';

                final fine =
                    double.tryParse(fineValue) ?? 0;

                return _buildHistoryCard(
                  title: title,
                  item: item,
                  fine: fine,
                );
              },
            ),

            const SizedBox(height: 18),

            const Divider(
              color: borderColor,
            ),

            const SizedBox(height: 8),

            // Pagination controls.
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                Text(
                  'Showing ${startIndex + 1}–$endIndex of ${_history.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF777777),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      tooltip: 'Previous page',
                      onPressed: safePage > 0
                          ? () {
                              setState(() {
                                _historyPage = safePage - 1;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: lightPrimaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${safePage + 1} / $totalPages',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Next page',
                      onPressed: safePage < totalPages - 1
                          ? () {
                              setState(() {
                                _historyPage = safePage + 1;
                              });
                            }
                          : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // =============================================================
  // INDIVIDUAL RETURNED BOOK HISTORY CARD
  // =============================================================

  Widget _buildHistoryCard({
    required String title,
    required Map<String, dynamic> item,
    required double fine,
  }) {
    final fineColor =
        fine > 0 ? const Color(0xFFDC2626) : successColor;

    final fineBackground =
        fine > 0 ? const Color(0xFFFEF2F2) : successBackground;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBF9),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFF5D5CA),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book title and returned badge.
          Row(
            children: [
              Container(
                width: 38,
                height: 42,
                decoration: BoxDecoration(
                  color: lightPrimaryColor,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: primaryColor,
                  size: 21,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: darkTextColor,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Returned status.
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 9,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: successBackground,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 12,
                    color: successColor,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Returned',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: successColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 13),

          // Borrowed date.
          _historyDateRow(
            label: 'Borrowed',
            value: item['borrowDate']?.toString() ?? 'N/A',
            icon: Icons.calendar_today_rounded,
          ),

          const SizedBox(height: 9),

          // Returned date.
          _historyDateRow(
            label: 'Returned',
            value: item['returnDate']?.toString() ?? 'N/A',
            icon: Icons.event_available_rounded,
          ),

          const SizedBox(height: 10),

          // Fine amount.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 9,
            ),
            decoration: BoxDecoration(
              color: fineBackground,
              borderRadius: BorderRadius.circular(9),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.payments_rounded,
                  size: 17,
                  color: fineColor,
                ),
                const SizedBox(width: 7),
                Text(
                  'Fine amount:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: fineColor,
                  ),
                ),
                const Spacer(),
                Text(
                  '${fine.toStringAsFixed(0)} ETB',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: fineColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Date information row inside each history card.
  Widget _historyDateRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: const TextStyle(
            fontSize: 11,
            color: secondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: darkTextColor,
            ),
          ),
        ),
      ],
    );
  }

  // =============================================================
  // EMPTY HISTORY STATE
  // =============================================================

  Widget _buildEmptyHistory() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 28),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF5F5F5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                size: 32,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'No borrowing history yet',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Your returned books will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // =============================================================
  // EMPTY BORROWED BOOKS OR SEARCH RESULTS
  // =============================================================

  Widget _buildEmptyState() {
    final hasNoBorrowedBooks = _borrowed.isEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFD9D9D9),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off,
            size: 42,
            color: Color(0xFFAAA898),
          ),
          const SizedBox(height: 12),
          Text(
            hasNoBorrowedBooks
                ? 'You have no borrowed books.'
                : 'No books found for "$_searchQuery".',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF666666),
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

  // =============================================================
  // INDIVIDUAL BORROWED BOOK CARD
  // =============================================================

  Widget _buildBorrowedCard(BorrowRecord book) {
    final bool isOverdue = book.daysLeft < 0;
    final bool isUrgent =
        book.daysLeft >= 0 && book.daysLeft <= 3;

    final bool isRenewing = _renewingId == book.id;
    final bool canRenew = !isOverdue && _renewingId == null;

    final String renewHint = isOverdue
        ? 'Overdue loans cannot be renewed. Please return the book.'
        : '${book.renewalsRemaining} renewal(s) remaining. The backend also checks the reservation queue.';

    final Color statusColor = isOverdue || isUrgent
        ? const Color(0xFFDC2626)
        : const Color(0xFFDB482B);

    final Color statusBackground = isOverdue || isUrgent
        ? const Color(0xFFFEF2F2)
        : lightPrimaryColor;

    final String dueStatus;

    if (isOverdue) {
      dueStatus =
          'Overdue by ${book.daysLeft.abs()} day${book.daysLeft.abs() == 1 ? '' : 's'}';
    } else if (book.daysLeft == 0) {
      dueStatus = 'Due today';
    } else {
      dueStatus =
          'Due: ${book.dueDate} (${book.daysLeft} days left)';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _HoverLift(
        radius: 16,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD9D9D9),
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
                            Color(0xFF514746),
                            Color(0xFFF25635),
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
                        color: darkTextColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'ISBN: ${book.isbn} · Borrowed: ${book.borrowDate}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Renewals remaining: ${book.renewalsRemaining}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: secondaryTextColor,
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
              Tooltip(
                message: renewHint,
                child: ElevatedButton.icon(
                  onPressed:
                      canRenew ? () => _renewBook(book) : null,
                  icon: const Icon(
                    Icons.refresh,
                    size: 14,
                  ),
                  label: Text(
                    isRenewing ? 'Renewing...' : 'Renew Loan',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        const Color(0xFFD9D9D9),
                    disabledForegroundColor:
                        const Color(0xFFAAA898),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// HOVER ANIMATION
// Used by borrowed book cards.
// =============================================================

class _HoverLift extends StatefulWidget {
  final Widget child;
  final double radius;

  const _HoverLift({
    required this.child,
    this.radius = 14,
  });

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) {
        setState(() => _isHovered = true);
      },
      onExit: (_) {
        setState(() => _isHovered = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          0,
          _isHovered ? -4 : 0,
          0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : const [],
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(
            color: _isHovered
                ? Colors.white
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
