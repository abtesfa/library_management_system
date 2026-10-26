
import 'package:flutter/material.dart';
import '../../data/mock_library_data.dart';
import '../../models/book.dart';
import '../../config/app_images.dart';

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

  String _searchQuery = '';

  static const Color primaryBlue = Color(0xFF0052CC);
  static const Color darkBlue = Color(0xFF003B95);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Book> get _filteredBooks {
    final books = MockLibraryData.getInitialBooks();

    if (_searchQuery.trim().isEmpty) {
      return books;
    }

    final query = _searchQuery.toLowerCase().trim();

    return books.where((book) {
      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query);
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

  @override
  Widget build(BuildContext context) {
    final borrowed = MockLibraryData.getReaderBorrowedBooks();

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 700;

        return SingleChildScrollView(
          padding: EdgeInsets.all(compact ? 16 : 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Heading
              const Text(
                'Welcome back, Abiye!',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF103E91),
                ),
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

              // Search Bar
              _buildSearchBar(compact),

              const SizedBox(height: 24),

              // Library Hero Banner
              _buildHeroBanner(compact),

              const SizedBox(height: 28),

              // Reading Statistics
              const Text(
                'Your Reading Overview',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 14),

              if (compact)
                Column(
                  children: [
                    _snapshotTile(
                      'Currently Borrowed',
                      borrowed.length.toString(),
                      Icons.menu_book_outlined,
                      primaryBlue,
                    ),
                    const SizedBox(height: 12),
                    _snapshotTile(
                      'Due This Week',
                      '1 Book',
                      Icons.warning_amber_rounded,
                      const Color(0xFFD97706),
                    ),
                    const SizedBox(height: 12),
                    _snapshotTile(
                      'Books Read This Year',
                      '14 Books',
                      Icons.military_tech_outlined,
                      const Color(0xFF059669),
                    ),
                  ],
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: _snapshotTile(
                        'Currently Borrowed',
                        borrowed.length.toString(),
                        Icons.menu_book_outlined,
                        primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _snapshotTile(
                        'Due This Week',
                        '1 Book',
                        Icons.warning_amber_rounded,
                        const Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _snapshotTile(
                        'Books Read This Year',
                        '14 Books',
                        Icons.military_tech_outlined,
                        const Color(0xFF059669),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 30),

              // Recommended Books Heading
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _searchQuery.isEmpty
                          ? 'Recommended Books For You'
                          : 'Search Results (${_filteredBooks.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    TextButton.icon(
                      onPressed: _clearSearch,
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Clear search'),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // Recommended Books Grid
              if (_filteredBooks.isEmpty)
                Container(
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
                        color: Color(0xFF94A3B8),
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
                        'Try another book title or author.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: textMuted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: compact ? 1 : 3,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: compact ? 2.0 : 1.65,
                  ),
                  itemCount: _filteredBooks.length,
                  itemBuilder: (context, index) {
                    final book = _filteredBooks[index];

                    return _buildBookItem(context, book);
                  },
                ),
            ],
          ),
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),

          const Icon(
            Icons.search,
            color: Color(0xFF1877F2),
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
                  color: const Color(0xFF94A3B8),
                  fontSize: compact ? 12 : 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                ),
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
              backgroundColor: const Color(0xFF0866E8),
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
  // LIBRARY HERO BANNER
  // ---------------------------------------------------------

  Widget _buildHeroBanner(bool compact) {
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
          // Background Library Image
         Image.network(
  'https://images.unsplash.com/photo-1507842217343-583bb7270b66?auto=format&fit=crop&w=1600&q=85',
  fit: BoxFit.cover,
  width: double.infinity,
  height: double.infinity,
  loadingBuilder: (context, child, loadingProgress) {
    if (loadingProgress == null) return child;

    return Container(
      color: const Color(0xFF003B95),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        color: Colors.white,
      ),
    );
  },
  errorBuilder: (context, error, stackTrace) {
    return Container(
      color: const Color(0xFF003B95),
      alignment: Alignment.center,
      child: const Icon(
        Icons.local_library,
        size: 80,
        color: Colors.white70,
      ),
    );
  },
),
          // Dark Blue Overlay for Text Readability
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

          // Banner Text
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
                        color: const Color(0xFFE0ECFF),
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
  // READING STATISTICS TILE
  // ---------------------------------------------------------

  Widget _snapshotTile(
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
  // RECOMMENDED BOOK CARD
  // ---------------------------------------------------------

  Widget _buildBookItem(BuildContext context, Book book) {
    final coverUrl = _coverForBook(book);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Book Cover
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

          // Book Details
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
                    color: Color(0xFF94A3B8),
                  ),
                ),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Reservation submitted for "${book.title}"!',
                          ),
                          backgroundColor: primaryBlue,
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.bookmark_add_outlined,
                      size: 15,
                    ),
                    label: const Text(
                      'Reserve',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF1877F2),
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
  // FALLBACK BOOK COVER
  // ---------------------------------------------------------

  Widget _bookPlaceholder() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E3A8A),
            Color(0xFF2563EB),
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
