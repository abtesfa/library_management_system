import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/book.dart';
import '../../../library/presentation/providers/library_service.dart';
import '../../../../core/di/injector.dart';
import '../../../../core/error/api_exception.dart';
import '../../domain/usecases/create_book.dart';
import '../../domain/usecases/get_categories.dart';
import '../widgets/add_book_dialog.dart';

class AdminInventoryScreen extends StatefulWidget {
  const AdminInventoryScreen({super.key});

  @override
  State<AdminInventoryScreen> createState() => _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends State<AdminInventoryScreen> {
  final CreateBook _createBookUseCase = injector.createBook;
  final GetCategories _getCategoriesUseCase = injector.getCategories;
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedInventoryFilter = 'all';

  static const Color primaryBlue = Color(0xFFF25635);
  static const Color darkBlue = Color(0xFFF25635);
  static const Color textDark = Color(0xFF171717);
  static const Color textMuted = Color(0xFF666666);
  static const Color borderColor = Color(0xFFD9D9D9);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =========================================================
  // SEARCH AND FILTER
  // =========================================================

  void _performSearch() {
    setState(() {
      _searchQuery = _searchController.text.trim();
    });

    FocusScope.of(context).unfocus();
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _selectInventoryFilter(String filter) {
    setState(() {
      _selectedInventoryFilter = filter;

      if (filter == 'all') {
        _searchController.clear();
        _searchQuery = '';
      }
    });
  }

  // =========================================================
  // ADD NEW BOOK DIALOG
  // =========================================================

  Future<void> _showAddBookDialog() async {
    try {
      final List<dynamic> categories = await _getCategoriesUseCase();

      if (!mounted) return;

      if (categories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'No categories found. Please add a category first.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final bool? result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (_) => AddBookDialog(
          categories: categories,
          createBook: _createBookUseCase,
          lookupBook: injector.lookupBookByIsbn,
        ),
      );

      if (result == true && mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Book and physical copies added successfully!',
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
            ),
          );

        try {
          await context.read<LibraryService>().loadBooksFromApi();
        } catch (error) {
          debugPrint('Inventory refresh failed: $error');
        }
      }
    } on ApiException catch (error) {
      // The server refused to list categories.
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: Colors.red,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // =========================================================
  // MAIN INVENTORY SCREEN
  // =========================================================

  @override
  Widget build(BuildContext context) {
    final libraryService = context.watch<LibraryService>();
    final List<Book> books = libraryService.books;

    // SEARCH + SELECTED CARD FILTER
    final List<Book> filteredBooks = books.where((book) {
      final query = _searchQuery.toLowerCase();

      final matchesSearch = book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.isbn.toLowerCase().contains(query) ||
          book.category.toLowerCase().contains(query);

      bool matchesFilter = true;

      if (_selectedInventoryFilter == 'available') {
        matchesFilter = book.availableCopies > 0;
      } else if (_selectedInventoryFilter == 'onLoan') {
        matchesFilter =
            book.totalCopies > book.availableCopies + book.reservedCopies;
      }

      return matchesSearch && matchesFilter;
    }).toList();

    // INVENTORY STATISTICS
    final int totalBooks = books.length;

    final int totalCopies = books.fold(
      0,
      (sum, book) => sum + book.totalCopies,
    );

    final int availableCopies = books.fold(
      0,
      (sum, book) => sum + book.availableCopies,
    );

    final int reservedCopies = books.fold(
      0,
      (sum, book) => sum + book.reservedCopies,
    );

    final int onLoan = totalCopies - availableCopies - reservedCopies;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          LayoutBuilder(
            builder: (context, constraints) {
              final bool compact = constraints.maxWidth < 750;

              final headerContent = Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBE2D9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.menu_book,
                      color: darkBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Book Inventory',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Manage book titles, authors, categories, physical copies, shelf locations, and availability status.',
                          style: TextStyle(
                            fontSize: 13,
                            color: textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

              final addButton = _HoverActionButton(
                label: 'Add New Book',
                icon: Icons.add,
                onPressed: _showAddBookDialog,
              );

              if (compact) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    headerContent,
                    const SizedBox(height: 16),
                    addButton,
                  ],
                );
              }

              return Row(
                children: [
                  Expanded(child: headerContent),
                  const SizedBox(width: 12),
                  addButton,
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // SEARCH BAR
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool compact = constraints.maxWidth < 500;

                final searchField = TextField(
                  controller: _searchController,

                  // IMMEDIATE SEARCH WHILE TYPING
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.trim();
                    });
                  },

                  onSubmitted: (_) => _performSearch(),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                      color: Color(0xFFAAA898),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: textMuted,
                            ),
                            tooltip: 'Clear search',
                            onPressed: _clearSearch,
                          )
                        : null,
                    hintText: 'Search by title, author, ISBN, category...',
                    border: InputBorder.none,
                    isDense: true,
                  ),
                );

                final searchButton = _HoverActionButton(
                  label: 'Search',
                  icon: Icons.search,
                  onPressed: _performSearch,
                );

                if (compact) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      searchField,
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerRight,
                        child: searchButton,
                      ),
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: searchField),
                    const SizedBox(width: 12),
                    searchButton,
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // INTERACTIVE STATISTICS CARDS
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isNarrow = constraints.maxWidth < 900;

              final cards = [
                _buildStatCard(
                  title: 'Total Books',
                  count: totalBooks.toString(),
                  subtitle: 'titles in collection',
                  icon: Icons.book,
                  color: const Color(0xFFF25635),
                  bg: const Color(0xFFFBE2D9),
                  selected: _selectedInventoryFilter == 'all',
                  onTap: () => _selectInventoryFilter('all'),
                ),
                _buildStatCard(
                  title: 'Total Copies Available',
                  count: availableCopies.toString(),
                  subtitle: 'available for loan',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF10B981),
                  bg: const Color(0xFFECFDF5),
                  selected: _selectedInventoryFilter == 'available',
                  onTap: () => _selectInventoryFilter('available'),
                ),
                _buildStatCard(
                  title: 'On Loan',
                  count: onLoan.toString(),
                  subtitle: 'not currently available',
                  icon: Icons.description_outlined,
                  color: const Color(0xFFF59E0B),
                  bg: const Color(0xFFFEF3C7),
                  selected: _selectedInventoryFilter == 'onLoan',
                  onTap: () => _selectInventoryFilter('onLoan'),
                ),
              ];

              if (isNarrow) {
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  children: cards,
                );
              }

              return Row(
                children: [
                  for (int i = 0; i < cards.length; i++) ...[
                    Expanded(child: cards[i]),
                    if (i != cards.length - 1) const SizedBox(width: 12),
                  ],
                ],
              );
            },
          ),

          const SizedBox(height: 12),

          // ACTIVE FILTER INDICATOR
          if (_selectedInventoryFilter != 'all')
            Row(
              children: [
                const Icon(
                  Icons.filter_alt,
                  color: primaryBlue,
                  size: 17,
                ),
                const SizedBox(width: 6),
                Text(
                  _selectedInventoryFilter == 'available'
                      ? 'Showing books with available copies'
                      : 'Showing books currently on loan',
                  style: const TextStyle(
                    color: primaryBlue,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => _selectInventoryFilter('all'),
                  child: const Text('Clear filter'),
                ),
              ],
            ),

          const SizedBox(height: 12),

          // INVENTORY TABLE
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Book Inventory List',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textDark,
                          ),
                        ),
                      ),
                      Text(
                        'Showing ${filteredBooks.length} of ${books.length}',
                        style: const TextStyle(
                          color: textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                if (libraryService.isLoadingBooks)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (libraryService.booksError != null)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Could not load books: ${libraryService.booksError}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            libraryService.loadBooksFromApi();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                      ],
                    ),
                  )
                else if (filteredBooks.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.menu_book_outlined,
                          size: 48,
                          color: Color(0xFFAAA898),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          books.isEmpty
                              ? 'No books found in the database.'
                              : 'No books match the selected filter or search.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: textMuted,
                            fontSize: 14,
                          ),
                        ),
                        if (_searchQuery.isNotEmpty ||
                            _selectedInventoryFilter != 'all') ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                                _selectedInventoryFilter = 'all';
                              });
                            },
                            icon: const Icon(Icons.clear),
                            label: const Text('Clear Filters'),
                          ),
                        ],
                      ],
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(
                        const Color(0xFFFBF1E4),
                      ),
                      columns: const [
                        DataColumn(
                          label: Text(
                            'Title',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Author',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'ISBN',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Category',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Total',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Available',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Status',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        DataColumn(
                          label: Text(
                            'Location',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      rows: filteredBooks.map((book) {
                        final bool isAvailable = book.availableCopies > 0;

                        final String status =
                            isAvailable ? 'Available' : 'Unavailable';

                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                book.title,
                                style: const TextStyle(
                                  color: primaryBlue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            DataCell(Text(book.author)),
                            DataCell(
                              Text(
                                book.isbn,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                            DataCell(Text(book.category)),
                            DataCell(
                              Text(book.totalCopies.toString()),
                            ),
                            DataCell(
                              Text(book.availableCopies.toString()),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isAvailable
                                      ? const Color(0xFFDCFCE7)
                                      : const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    color: isAvailable
                                        ? const Color(0xFF166534)
                                        : const Color(0xFFB91C1C),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            DataCell(Text(book.location)),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================
  // INTERACTIVE STATISTICS CARD
  // =========================================================

  Widget _buildStatCard({
    required String title,
    required String count,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bg,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return _InteractiveStatCard(
      title: title,
      count: count,
      subtitle: subtitle,
      icon: icon,
      color: color,
      backgroundColor: bg,
      selected: selected,
      onTap: onTap,
    );
  }
}

// =============================================================
// INTERACTIVE STATISTICS CARD WITH HOVER ANIMATION
// =============================================================

class _InteractiveStatCard extends StatefulWidget {
  final String title;
  final String count;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color backgroundColor;
  final bool selected;
  final VoidCallback onTap;

  const _InteractiveStatCard({
    required this.title,
    required this.count,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.backgroundColor,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_InteractiveStatCard> createState() => _InteractiveStatCardState();
}

class _InteractiveStatCardState extends State<_InteractiveStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final bool highlighted = _isHovered || widget.selected;

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
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: highlighted ? Colors.white : const Color(0xFFD9D9D9),
            width: 1,
          ),
          boxShadow: highlighted
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: widget.backgroundColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      widget.icon,
                      color: widget.color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFAAA898),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.count,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          widget.subtitle,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFFAAA898),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (highlighted)
                    Icon(
                      widget.selected
                          ? Icons.check_circle
                          : Icons.arrow_forward_ios,
                      size: 15,
                      color: widget.color,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================
// REUSABLE ANIMATED HOVER BUTTON
// =============================================================

class _HoverActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const _HoverActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  })  : backgroundColor = const Color(0xFFF25635),
        foregroundColor = Colors.white;

  @override
  State<_HoverActionButton> createState() => _HoverActionButtonState();
}

class _HoverActionButtonState extends State<_HoverActionButton> {
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
          _isHovered ? -3 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: widget.onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.icon,
                    size: 18,
                    color: widget.foregroundColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.foregroundColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
