import 'package:flutter/material.dart';
import '../../domain/entities/borrow_record.dart';
import '../../../../core/di/injector.dart';
import '../../domain/usecases/get_my_books.dart';
import '../../domain/usecases/renew_book.dart';
import '../../domain/entities/borrowing_history_page.dart';
import '../../domain/usecases/get_borrowing_history.dart';

class ReaderMyBooksScreen extends StatefulWidget {
  final String studentId;

  const ReaderMyBooksScreen({
    super.key,
    required this.studentId,
  });

  @override
  State<ReaderMyBooksScreen> createState() => _ReaderMyBooksScreenState();
}

class _ReaderMyBooksScreenState extends State<ReaderMyBooksScreen> {
  List<BorrowRecord> _borrowed = [];

  final GetMyBooks _getMyBooksUseCase = injector.getMyBooks;
  final RenewBook _renewBookUseCase = injector.renewBook;
  final GetBorrowingHistory _getBorrowingHistoryUseCase =
    injector.getBorrowingHistory;

BorrowingHistoryPage? _historyPage;

bool _isHistoryLoading = true;
String? _historyError;
int _historyPageIndex = 0;

  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  bool _isLoading = true;
  String? _errorMessage;

  /// ID of the loan being renewed right now, if any.
  String? _renewingId;

  @override
void initState() {
  super.initState();

  _loadBorrowedBooks();
  _loadHistoryPage(0);
}

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Load borrowed books from the Spring Boot backend.
  Future<void> _loadBorrowedBooks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final books = await _getMyBooksUseCase(widget.studentId);

      if (!mounted) return;

      setState(() {
        _borrowed = books;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString();
        _isLoading = false;
      });
    }
  }
  
  Future<void> _loadHistoryPage(int page) async {
  setState(() {
    _isHistoryLoading = true;
    _historyError = null;
  });

  try {
    final result = await _getBorrowingHistoryUseCase(
      widget.studentId,
      page,
    );

    if (!mounted) return;

    setState(() {
      _historyPage = result;
      _historyPageIndex = result.page;
      _isHistoryLoading = false;
    });
  } catch (error) {
    if (!mounted) return;

    setState(() {
      _historyError = error.toString();
      _isHistoryLoading = false;
    });
  }
}

Future<void> _refreshAll() async {
  await Future.wait([
    _loadBorrowedBooks(),
    _loadHistoryPage(_historyPageIndex),
  ]);
}

String _formatHistoryDate(String? value) {
  if (value == null || value.isEmpty) {
    return 'Not available';
  }

  final date = DateTime.tryParse(value);

  if (date == null) return value;

  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');

  return '$day/$month/${date.year}';
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
  
  Widget _buildHistorySection() {
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section heading.
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFBE2D9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.history_rounded,
                color: Color(0xFFF25635),
                size: 22,
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
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF171717),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Books you have previously borrowed and returned.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
            if (_historyPage != null)
              Text(
                '${_historyPage!.records.length} books',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                ),
              ),
          ],
        ),

        const SizedBox(height: 24),

        // Loading.
        if (_isHistoryLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(
                color: Color(0xFFF25635),
              ),
            ),
          )

        // Error.
        else if (_historyError != null)
          Center(
            child: Column(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                  size: 36,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Unable to load borrowing history.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () =>
                      _loadHistoryPage(_historyPageIndex),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          )

        // No history.
        else if (_historyPage == null ||
            _historyPage!.records.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 42,
                    color: Color(0xFFAAA898),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No borrowing history yet.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            ),
          )

        // History records.
        else
          Column(
            children: _historyPage!.records
                .map(_buildHistoryCard)
                .toList(),
          ),

        // Pagination.
        if (!_isHistoryLoading &&
            _historyError == null &&
            _historyPage != null &&
            _historyPage!.records.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Divider(color: Color(0xFFE5E5E5)),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Page ${_historyPageIndex + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                ),
              ),

              Row(
                children: [
                  // Previous button.
                  OutlinedButton.icon(
                    onPressed: _historyPageIndex > 0
                        ? () => _loadHistoryPage(
                              _historyPageIndex - 1,
                            )
                        : null,
                    icon: const Icon(
                      Icons.chevron_left,
                      size: 18,
                    ),
                    label: const Text('Previous'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          const Color(0xFFF25635),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Next button.
                  ElevatedButton.icon(
                    onPressed: _historyPage!.hasNext
                        ? () => _loadHistoryPage(
                              _historyPageIndex + 1,
                            )
                        : null,
                    icon: const Icon(
                      Icons.chevron_right,
                      size: 18,
                    ),
                    label: const Text('Next'),
                    iconAlignment: IconAlignment.end,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          const Color(0xFFF25635),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          const Color(0xFFE5E5E5),
                      disabledForegroundColor:
                          const Color(0xFF999999),
                      elevation: 0,
                    ),
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

Widget _buildHistoryCard(BorrowRecord book) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE5E5E5),
        ),
      ),
      child: Row(
        children: [
          // Book cover.
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: book.coverImage != null &&
                    book.coverImage!.trim().isNotEmpty
                ? Image.network(
                    book.coverImage!.trim(),
                    width: 48,
                    height: 64,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        _buildBookCoverPlaceholder(),
                  )
                : _buildBookCoverPlaceholder(),
          ),

          const SizedBox(width: 16),

          // Book information.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.bookTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF171717),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  'ISBN: ${book.isbn}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF666666),
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 20,
                  runSpacing: 8,
                  children: [
                    _historyDateItem(
                      'Borrowed',
                      book.borrowDate,
                      Icons.login_rounded,
                    ),
                    _historyDateItem(
                      'Returned',
                      book.returnDate,
                      Icons.assignment_turned_in_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Returned status.
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Returned',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF059669),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _historyDateItem(
  String label,
  String? date,
  IconData icon,
) {
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        icon,
        size: 14,
        color: const Color(0xFF888888),
      ),
      const SizedBox(width: 5),
      Text(
        '$label: ${_formatHistoryDate(date)}',
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF666666),
        ),
      ),
    ],
  );
}


  Widget _buildBookCoverPlaceholder() {
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
  }

  // Clear the search field.
  void _clearSearch() {
    _searchController.clear();

    setState(() {
      _searchQuery = '';
    });
  }

  // Renew a borrowed book through the backend.
  // The server allows one renewal per loan and rejects overdue loans.
  Future<void> _renewBook(BorrowRecord record) async {
    if (_renewingId != null) return;

    setState(() => _renewingId = record.id);

    try {
      final newDueDate = await _renewBookUseCase(widget.studentId, record.id);

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
      if (mounted) setState(() => _renewingId = null);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? const Color(0xFFDC2626) : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Get a book cover from Open Library.

  // Loading, error, empty and successful states.
  Widget _buildBorrowedBooksSection() {
    if (_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(
            color: Color(0xFFF25635),
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
                color: Color(0xFF171717),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF666666),
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
      children:
          _filteredBorrowed.map((book) => _buildBorrowedCard(book)).toList(),
    );
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
                  color: const Color(0xFFFBE2D9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.bookmark_outline,
                  color: Color(0xFFF25635),
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
                        color: Color(0xFF171717),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Manage your borrowed books, due dates and reading history.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),

              // Refresh button.
              IconButton(
                tooltip: 'Refresh borrowed books',
                onPressed: _isLoading || _isHistoryLoading
    ? null
    : _refreshAll,
                icon: const Icon(
                  Icons.refresh,
                  color: Color(0xFFF25635),
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
                color: Color(0xFF666666),
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
                          color: Color(0xFF666666),
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
                        backgroundColor: const Color(0xFFF25635),
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
                  color: Color(0xFFF25635),
                  width: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Borrowed books and tips panel.
          
              // Borrowed books list.
              Expanded(
                flex: 3,
                child: _buildBorrowedBooksSection(),
              ),

              

              // Book Care & Return Tips (with hover animation).
              
            
        
          const SizedBox(height: 32),

_buildHistorySection(),
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
                  color: Color(0xFF171717),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  height: 1.5,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Individual borrowed book card (with hover animation).
  Widget _buildBorrowedCard(BorrowRecord book) {
    final bool isOverdue = book.daysLeft < 0;

    final bool isDueToday = book.daysLeft == 0;
    final bool isUrgent = book.daysLeft >= 0 && book.daysLeft <= 3;

    final int renewalLimit = book.renewalLimit;
    final int renewalsUsed = book.renewalCount;

    final int renewalsRemaining =
        (renewalLimit - renewalsUsed).clamp(0, renewalLimit);

    final bool renewalLimitReached = renewalsUsed >= renewalLimit;

    final bool isRenewing = _renewingId == book.id;

    final bool canRenew = isDueToday &&
    !renewalLimitReached &&
    !book.hasActiveReservation &&
    !isRenewing &&
    _renewingId == null &&
    book.status.toUpperCase() == 'ACTIVE';

    String renewHint;

    if (renewalLimitReached) {
      renewHint = 'You have used all $renewalLimit allowed renewals.';
    } else if (isOverdue) {
      renewHint = 'This book is overdue and cannot be renewed.';
    } else if (!isDueToday) {
      renewHint = 'You can renew this book only on its due date.';
    } else {
      renewHint = 'You can renew this book today.';
    }

    final Color statusColor = isOverdue || isUrgent
        ? const Color(0xFFDC2626)
        : const Color(0xFFDB482B);

    final Color statusBackground = isOverdue || isUrgent
        ? const Color(0xFFFEF2F2)
        : const Color(0xFFFBE2D9);

    final String dueStatus;
    if (book.hasActiveReservation) {
  renewHint = 'This book has an active reservation and cannot be renewed.';
} else if (renewalLimitReached) {
  renewHint = 'You have used all $renewalLimit allowed renewals.';
} else if (isOverdue) {
  renewHint = 'This book is overdue and cannot be renewed.';
} else if (!isDueToday) {
  renewHint = 'You can renew this book only on its due date.';
} else {
  renewHint = 'You can renew this book today.';
}
    if (isOverdue) {
      dueStatus =
          'Overdue by ${book.daysLeft.abs()} day${book.daysLeft.abs() == 1 ? '' : 's'}';
    } else if (book.daysLeft == 0) {
      dueStatus = 'Due today';
    } else {
      dueStatus = 'Due: ${book.dueDate} (${book.daysLeft} days left)';
    }

    // The bottom spacing is outside the hover widget so the
    // blue border only wraps the card itself.
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
              // Book cover from the database.
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: book.coverImage != null &&
                        book.coverImage!.trim().isNotEmpty
                    ? Image.network(
                        book.coverImage!.trim(),
                        width: 60,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildBookCoverPlaceholder();
                        },
                      )
                    : _buildBookCoverPlaceholder(),
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
                        color: Color(0xFF171717),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'ISBN: ${book.isbn} · Borrowed: ${book.borrowDate}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF666666),
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
              // Renewal button and renewal allowance.
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Tooltip(
                    message: renewHint,
                    child: ElevatedButton.icon(
                      onPressed: canRenew ? () => _renewBook(book) : null,
                      icon: const Icon(
                        Icons.refresh,
                        size: 14,
                      ),
                      label: Text(
  isRenewing
      ? 'Renewing...'
      : book.hasActiveReservation
          ? 'Reserved'
          : renewalLimitReached
              ? 'Limit Reached'
              : 'Renew Loan',
),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF25635),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFFD9D9D9),
                        disabledForegroundColor: const Color(0xFFAAA898),
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

                  const SizedBox(height: 8),

                  // Renewal count based on administrator settings.
                  Text(
                    'Renewals used: $renewalsUsed / $renewalLimit',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF666666),
                    ),
                  ),

                  Text(
                    '$renewalsRemaining remaining',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      color: renewalsRemaining > 0
                          ? const Color(0xFF059669)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// HOVER ANIMATION (lift + shadow + blue border)
// Used by the borrowed book cards and the tips panel.
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
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
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
            color: _isHovered ? Colors.white : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
