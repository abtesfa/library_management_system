import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../books/domain/entities/book.dart';
import '../../domain/entities/student_dashboard.dart';
import '../../../library/presentation/providers/library_service.dart';
import '../../../../core/config/app_images.dart';
import '../../../../core/di/injector.dart';
import '../../../books/domain/usecases/get_available_books.dart';
import '../../domain/usecases/get_student_dashboard.dart';
import '../../../reservations/domain/usecases/create_reservation.dart';

class ReaderHomeScreen extends StatefulWidget {
  final VoidCallback onNavigateToMyBooks;

  const ReaderHomeScreen({
    super.key,
    required this.onNavigateToMyBooks,
  });

  @override
  State<ReaderHomeScreen> createState() => _ReaderHomeScreenState();
}

class _ReaderHomeScreenState extends State<ReaderHomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  final GetStudentDashboard _getStudentDashboardUseCase =
      injector.getStudentDashboard;

  final GetAvailableBooks _getAvailableBooksUseCase =
      injector.getAvailableBooks;

  final CreateReservation _createReservationUseCase =
      injector.createReservation;

  // Temporary test student ID.
  // Later, use the logged-in student's ID.
  final int _studentId = 1;

  late Future<StudentDashboard> _dashboardFuture;
  late Future<List<Book>> _booksFuture;

  String _searchQuery = '';

  // Tracks which book is currently being reserved.
  String? _reservingBookId;

  static const Color primaryBlue = Color(0xFFF25635);
  static const Color darkBlue = Color(0xFF514746);
  static const Color textDark = Color(0xFF171717);
  static const Color textMuted = Color(0xFF666666);
  static const Color borderColor = Color(0xFFD9D9D9);

  @override
  void initState() {
    super.initState();

    _dashboardFuture = _getStudentDashboardUseCase(_studentId);

    _booksFuture = _getAvailableBooksUseCase();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------
  // RESERVE BOOK THROUGH BACKEND
  // ---------------------------------------------------------

  Future<void> _reserveBook(Book book) async {
    if (_reservingBookId != null) return;

    // Use database Book_ID instead of ISBN.
    final int? bookId = int.tryParse(book.id);

    if (bookId == null || bookId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid book ID.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _reservingBookId = book.id;
    });

    try {
      final reservation = await _createReservationUseCase(
        studentId: _studentId.toString(),
        bookId: bookId,
      );

      if (!mounted) return;

      // A reserved copy is no longer available, so refresh every book list.
      context.read<LibraryService>().loadBooksFromApi();
      _refreshBooks();
      _refreshDashboard();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_reservationCreatedMessage(book.title, reservation)),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not reserve "${book.title}": $e',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _reservingBookId = null;
        });
      }
    }
  }

  String _reservationCreatedMessage(
    String title,
    Map<String, dynamic> reservation,
  ) {
    final minutes = (reservation['pickupHoldMinutes'] as num?)?.toInt();
    final holdUntil = reservation['holdUntil']?.toString();
    final deadline =
        holdUntil == null ? null : DateTime.tryParse(holdUntil)?.toLocal();

    if (minutes == null || deadline == null) {
      return 'Reservation for "$title" created successfully. '
          'Check My Reservations for your pickup deadline.';
    }

    final durationText = _formatDuration(minutes);
    final dateText =
        '${deadline.year}-${deadline.month.toString().padLeft(2, '0')}-'
        '${deadline.day.toString().padLeft(2, '0')} at '
        '${deadline.hour.toString().padLeft(2, '0')}:'
        '${deadline.minute.toString().padLeft(2, '0')}';
    return 'Reservation for "$title" created. You have $durationText to pick '
        'it up, by $dateText.';
  }

  String _formatDuration(int minutes) {
    if (minutes % 1440 == 0) {
      final days = minutes ~/ 1440;
      return '$days ${days == 1 ? 'day' : 'days'}';
    }
    if (minutes % 60 == 0) {
      final hours = minutes ~/ 60;
      return '$hours ${hours == 1 ? 'hour' : 'hours'}';
    }
    return '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
  }

  // ---------------------------------------------------------
  // REFRESH DASHBOARD
  // ---------------------------------------------------------

  void _refreshDashboard() {
    setState(() {
      _dashboardFuture = _getStudentDashboardUseCase(_studentId);
    });
  }

  // ---------------------------------------------------------
  // REFRESH BOOKS FROM BACKEND
  // ---------------------------------------------------------

  void _refreshBooks() {
    setState(() {
      _booksFuture = _getAvailableBooksUseCase();
    });
  }

  // ---------------------------------------------------------
  // FILTER BOOKS FROM DATABASE
  // ---------------------------------------------------------

  List<Book> _filterBooks(List<Book> books) {
    if (_searchQuery.trim().isEmpty) {
      return books;
    }

    final query = _searchQuery.toLowerCase().trim();

    return books.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.category.toLowerCase().contains(query);
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

  // ---------------------------------------------------------
  // MAIN BUILD
  // ---------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;

        return SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 16 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Heading
              FutureBuilder<StudentDashboard>(
                future: _dashboardFuture,
                builder: (context, snapshot) {
                  final name =
                      snapshot.hasData ? snapshot.data!.fullName : 'Student';

                  return Text(
                    'Welcome back, $name!',
                    style: const TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF514746),
                    ),
                  );
                },
              ),

              const SizedBox(height: 5),

              const Text(
                'Discover new books, continue your reading journey, '
                'and explore the library\'s resources.',
                style: TextStyle(
                  fontSize: 13,
                  color: textMuted,
                ),
              ),

              const SizedBox(height: 20),

              _buildSearchBar(compact),

              const SizedBox(height: 24),

              _buildHeroBanner(compact),

              const SizedBox(height: 28),

              const Text(
                'Your Reading Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 14),

              _buildDashboardStats(compact),

              const SizedBox(height: 30),

              // Recommended Books Heading
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'Recommended Books For You'
                          : 'Search Results',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _refreshBooks,
                    tooltip: 'Refresh books',
                    icon: const Icon(
                      Icons.refresh,
                      color: primaryBlue,
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    TextButton.icon(
                      onPressed: _clearSearch,
                      icon: const Icon(
                        Icons.close,
                        size: 16,
                      ),
                      label: const Text('Clear search'),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // Books loaded from backend
              FutureBuilder<List<Book>>(
                future: _booksFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(35),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return _buildBooksError();
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyBooks();
                  }

                  final filteredBooks = _filterBooks(snapshot.data!);

                  if (filteredBooks.isEmpty) {
                    return _buildNoSearchResults();
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    // Lets the hover lift and shadow show outside the grid.
                    clipBehavior: Clip.none,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: compact ? 1 : 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: compact ? 2.0 : 1.65,
                    ),
                    itemCount: filteredBooks.length,
                    itemBuilder: (context, index) {
                      final book = filteredBooks[index];

                      return _buildBookItem(context, book);
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------
  // DASHBOARD STATISTICS FROM BACKEND
  // ---------------------------------------------------------

  Widget _buildDashboardStats(bool compact) {
    return FutureBuilder<StudentDashboard>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 35,
                  color: Color(0xFFAAA898),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Unable to load reading statistics.',
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 13,
                  ),
                ),
                TextButton.icon(
                  onPressed: _refreshDashboard,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try again'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          return const Text(
            'No dashboard information available.',
            style: TextStyle(color: textMuted),
          );
        }

        final dashboard = snapshot.data!;

        final tiles = [
          _snapshotTile(
            'Currently Borrowed',
            '${dashboard.currentlyBorrowed} Books',
            Icons.menu_book_outlined,
            primaryBlue,
          ),
          _snapshotTile(
            'Due This Week',
            '${dashboard.dueThisWeek} Books',
            Icons.warning_amber_rounded,
            const Color(0xFFD97706),
          ),
          _snapshotTile(
            'Books Read This Year',
            '${dashboard.booksReadThisYear} Books',
            Icons.military_tech_outlined,
            const Color(0xFF059669),
          ),
        ];

        if (compact) {
          return Column(
            children: [
              for (int i = 0; i < tiles.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                tiles[i],
              ],
            ],
          );
        }

        return Row(
          children: [
            for (int i = 0; i < tiles.length; i++) ...[
              if (i > 0) const SizedBox(width: 16),
              Expanded(child: tiles[i]),
            ],
          ],
        );
      },
    );
  }

  // ---------------------------------------------------------
  // SEARCH BAR
  // ---------------------------------------------------------

  Widget _buildSearchBar(bool compact) {
    return Container(
      padding: EdgeInsets.all(compact ? 7 : 9),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF1E4),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFD9D9D9),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          const Icon(
            Icons.search,
            color: Color(0xFFF25635),
            size: 23,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim();
                });
              },
              onSubmitted: (_) => _searchBooks(),
              decoration: InputDecoration(
                hintText: 'Search for books, authors, or genres...',
                hintStyle: TextStyle(
                  color: const Color(0xFFAAA898),
                  fontSize: compact ? 12 : 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: _clearSearch,
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                        ),
                        tooltip: 'Clear search',
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _searchBooks,
            icon: const Icon(
              Icons.search,
              size: 17,
            ),
            label: Text(
              compact ? 'Go' : 'Search',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF25635),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 12 : 18,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // LIBRARY HERO BANNER (with hover animation)
  // ---------------------------------------------------------

  Widget _buildHeroBanner(bool compact) {
    return _HoverLift(
      radius: 16,
      child: _heroBannerBody(compact),
    );
  }

  Widget _heroBannerBody(bool compact) {
    return Container(
      height: compact ? 210 : 190,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: darkBlue,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            'https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&w=1600&q=85',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;

              return Container(
                color: const Color(0xFF514746),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(
                  color: Colors.white,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF514746),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.local_library,
                  size: 80,
                  color: Colors.white70,
                ),
              );
            },
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  darkBlue.withValues(alpha: 0.98),
                  darkBlue.withValues(alpha: 0.90),
                  darkBlue.withValues(alpha: 0.55),
                  darkBlue.withValues(alpha: 0.05),
                ],
                stops: const [0.0, 0.38, 0.68, 1.0],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(compact ? 20 : 28),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                width: compact ? 270 : 360,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good Books\nBuild Better Futures',
                      style: TextStyle(
                        fontSize: compact ? 23 : 27,
                        height: 1.25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Explore new worlds, gain new perspectives, '
                      'and keep reading!',
                      style: TextStyle(
                        fontSize: compact ? 12 : 13,
                        height: 1.7,
                        color: const Color(0xFFFBE2D9),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // READING STATISTICS TILE (with hover animation)
  // ---------------------------------------------------------

  Widget _snapshotTile(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return _HoverLift(
      child: _snapshotTileBody(title, value, icon, color),
    );
  }

  Widget _snapshotTileBody(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
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
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // BOOK COVER SELECTION
  // ---------------------------------------------------------

  String _coverForBook(Book book) {
    final title = book.title.toLowerCase();

    if (title.contains('clean code')) {
      return AppImages.cleanCode;
    } else if (title.contains('atomic habits')) {
      return AppImages.atomicHabits;
    } else if (title.contains('martian')) {
      return AppImages.theMartian;
    } else if (title.contains('design patterns')) {
      return AppImages.designPatterns;
    } else if (title.contains('think like a monk')) {
      return AppImages.thinkLikeAMonk;
    } else if (title.contains('dune')) {
      return AppImages.dune;
    } else if (title.contains('sapiens')) {
      return AppImages.sapiens;
    }

    return '';
  }

  // ---------------------------------------------------------
  // RECOMMENDED BOOK CARD (with hover animation)
  // ---------------------------------------------------------

  Widget _buildBookItem(BuildContext context, Book book) {
    return _HoverLift(
      child: _bookItemBody(context, book),
    );
  }

  Widget _bookItemBody(BuildContext context, Book book) {
    final coverUrl = _coverForBook(book);

    // Compare using Book_ID instead of ISBN.
    final isReserving = _reservingBookId == book.id;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            height: 115,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: coverUrl.isNotEmpty
                  ? Image.network(
                      coverUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return _bookPlaceholder();
                      },
                    )
                  : _bookPlaceholder(),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  book.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  book.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: textMuted,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book.location,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFFAAA898),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${book.availableCopies} copies available',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF059669),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 7),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: isReserving || _reservingBookId != null
                        ? null
                        : () => _reserveBook(book),
                    icon: isReserving
                        ? const SizedBox(
                            height: 15,
                            width: 15,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(
                            Icons.bookmark_add_outlined,
                            size: 15,
                          ),
                    label: Text(
                      isReserving ? 'Reserving...' : 'Reserve',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFF25635),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 5,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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

  // ---------------------------------------------------------
  // BOOKS ERROR STATE
  // ---------------------------------------------------------

  Widget _buildBooksError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.cloud_off_outlined,
            size: 45,
            color: Color(0xFFAAA898),
          ),
          const SizedBox(height: 12),
          const Text(
            'Unable to load books',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Please check your backend connection and try again.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: textMuted,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _refreshBooks,
            icon: const Icon(Icons.refresh),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // EMPTY BOOKS STATE
  // ---------------------------------------------------------

  Widget _buildEmptyBooks() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 48,
            color: Color(0xFFAAA898),
          ),
          SizedBox(height: 12),
          Text(
            'No available books',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'There are currently no books available for borrowing.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // NO SEARCH RESULTS STATE
  // ---------------------------------------------------------

  Widget _buildNoSearchResults() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(36),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Color(0xFFAAA898),
          ),
          SizedBox(height: 12),
          Text(
            'No books found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textDark,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Try another book title, author, or category.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // FALLBACK BOOK COVER
  // ---------------------------------------------------------

  Widget _bookPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF514746),
            Color(0xFFF25635),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      alignment: Alignment.center,
      child: const Icon(
        Icons.menu_book,
        color: Colors.white,
        size: 32,
      ),
    );
  }
}

// =============================================================
// HOVER ANIMATION (lift + shadow + blue border)
// Used by the hero banner, reading overview tiles and book cards.
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
