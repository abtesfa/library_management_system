
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

import '../../models/book.dart';
import '../../services/library_service.dart';
import '../../services/book_service.dart';

class AdminInventoryScreen extends StatefulWidget {
  const AdminInventoryScreen({super.key});

  @override
  State<AdminInventoryScreen> createState() =>
      _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends State<AdminInventoryScreen> {
  final BookService _bookService = BookService();
  final TextEditingController _searchController =
      TextEditingController();

  String _searchQuery = '';
  String _selectedInventoryFilter = 'all';

  static const Color primaryBlue = Color(0xFF1877F2);
  static const Color darkBlue = Color(0xFF0052CC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

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
  // FIELD LABEL WITH REQUIRED / OPTIONAL INDICATOR
  // =========================================================

  Widget _fieldLabel(
    String label, {
    bool isRequired = false,
  }) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          color: textMuted,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        children: [
          TextSpan(text: label),
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            const TextSpan(
              text: ' (Optional)',
              style: TextStyle(
                color: textMuted,
                fontSize: 11,
              ),
            ),
        ],
      ),
    );
  }

  // =========================================================
  // TOTAL COPIES DETAILS
  // =========================================================

  void _showCopiesBreakdown({
    required int totalBooks,
    required int totalCopies,
    required int availableCopies,
    required int onLoan,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.layers, color: primaryBlue),
              SizedBox(width: 10),
              Text(
                'Physical Copies Breakdown',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: 380,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _breakdownRow(
                  'Book Titles',
                  totalBooks.toString(),
                  Icons.menu_book,
                ),
                const Divider(height: 24),
                _breakdownRow(
                  'Total Physical Copies',
                  totalCopies.toString(),
                  Icons.layers,
                ),
                const Divider(height: 24),
                _breakdownRow(
                  'Available Copies',
                  availableCopies.toString(),
                  Icons.check_circle_outline,
                  color: Colors.green,
                ),
                const Divider(height: 24),
                _breakdownRow(
                  'Currently On Loan',
                  onLoan.toString(),
                  Icons.assignment_outlined,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _breakdownRow(
    String label,
    String value,
    IconData icon, {
    Color color = primaryBlue,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: textMuted,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: textDark,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ],
    );
  }

  // =========================================================
  // ADD NEW BOOK DIALOG
  // =========================================================

  Future<void> _showAddBookDialog() async {
    final formKey = GlobalKey<FormState>();

    final titleController = TextEditingController();
    final authorController = TextEditingController();
    final copiesController = TextEditingController(text: '1');
    final locationController = TextEditingController();

    try {
      final categoryResponse = await http
          .get(
            Uri.parse('${BookService.baseUrl}/categories'),
          )
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;

      if (categoryResponse.statusCode != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not load categories: ${categoryResponse.body}',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final List<dynamic> categories =
          jsonDecode(categoryResponse.body) as List<dynamic>;

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

      int? selectedCategoryId;

      final bool? result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          bool submitting = false;

          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: const Row(
                  children: [
                    Icon(
                      Icons.library_add,
                      color: primaryBlue,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Add New Book',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: textDark,
                      ),
                    ),
                  ],
                ),
                content: SizedBox(
                  width: 520,
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // BOOK TITLE - REQUIRED
                          _formField(
                            titleController,
                            'Book Title',
                            isRequired: true,
                          ),

                          // AUTHOR NAME - REQUIRED
                          _formField(
                            authorController,
                            'Author Name',
                            isRequired: true,
                          ),

                          // CATEGORY - REQUIRED
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 12,
                            ),
                            child: DropdownButtonFormField<int>(
                              initialValue: selectedCategoryId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                label: _fieldLabel(
                                  'Category',
                                  isRequired: true,
                                ),
                                prefixIcon: const Icon(
                                  Icons.category_outlined,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(8),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 14,
                                ),
                              ),
                              items: categories.map((category) {
                                final int id =
                                    (category['categoryId'] as num)
                                        .toInt();

                                final String name =
                                    category['categoryName'].toString();

                                return DropdownMenuItem<int>(
                                  value: id,
                                  child: Text(name),
                                );
                              }).toList(),
                              onChanged: submitting
                                  ? null
                                  : (value) {
                                      setDialogState(() {
                                        selectedCategoryId = value;
                                      });
                                    },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a category';
                                }
                                return null;
                              },
                            ),
                          ),

                          // NUMBER OF COPIES - REQUIRED
                          _formField(
                            copiesController,
                            'Number of Copies',
                            isRequired: true,
                            isNumber: true,
                            minimum: 1,
                          ),

                          // SHELF LOCATION - OPTIONAL
                          _formField(
                            locationController,
                            'Shelf Location',
                            hint: 'Example: Shelf A-02',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: submitting
                        ? null
                        : () {
                            Navigator.pop(dialogContext, false);
                          },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: textMuted),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: submitting
                        ? null
                        : () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            setDialogState(() {
                              submitting = true;
                            });

                            try {
                              final bookData = {
                                'title': titleController.text.trim(),
                                'authorName':
                                    authorController.text.trim(),
                                'categoryId': selectedCategoryId,
                                'numberOfCopies': int.parse(
                                  copiesController.text.trim(),
                                ),
                                'location':
                                    locationController.text
                                            .trim()
                                            .isEmpty
                                        ? null
                                        : locationController.text.trim(),
                              };

                              await _bookService.createBook(bookData);

                              if (!mounted) return;

                              Navigator.pop(dialogContext, true);
                            } catch (error) {
                              setDialogState(() {
                                submitting = false;
                              });

                              if (!mounted) return;

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Could not add book: $error',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    icon: submitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.save, size: 18),
                    label: Text(
                      submitting ? 'Saving...' : 'Save Book',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
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
          await context
              .read<LibraryService>()
              .loadBooksFromApi();
        } catch (error) {
          debugPrint('Inventory refresh failed: $error');
        }
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      titleController.dispose();
      authorController.dispose();
      copiesController.dispose();
      locationController.dispose();
    }
  }

  // =========================================================
  // REUSABLE FORM INPUT
  // =========================================================

  Widget _formField(
    TextEditingController controller,
    String label, {
    bool isRequired = false,
    bool isNumber = false,
    int maxLines = 1,
    int? minimum,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: isNumber
            ? TextInputType.number
            : TextInputType.text,
        decoration: InputDecoration(
          label: _fieldLabel(
            label,
            isRequired: isRequired,
          ),
          hintText: hint,
          prefixIcon: Icon(
            isNumber ? Icons.numbers : Icons.edit_outlined,
            color: textMuted,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
        ),
        validator: (value) {
          final text = value?.trim() ?? '';

          if (isRequired && text.isEmpty) {
            return '$label is required';
          }

          if (text.isNotEmpty && isNumber) {
            final number = int.tryParse(text);

            if (number == null) {
              return 'Enter a valid whole number';
            }

            if (minimum != null && number < minimum) {
              return 'Enter a number of at least $minimum';
            }
          }

          return null;
        },
      ),
    );
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

      final matchesSearch =
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.isbn.toLowerCase().contains(query) ||
          book.category.toLowerCase().contains(query);

      bool matchesFilter = true;

      if (_selectedInventoryFilter == 'available') {
        matchesFilter = book.availableCopies > 0;
      } else if (_selectedInventoryFilter == 'onLoan') {
        matchesFilter = book.totalCopies >
            book.availableCopies + book.reservedCopies;
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
                      color: const Color(0xFFEBF3FF),
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
                      color: Color(0xFF94A3B8),
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
                    hintText:
                        'Search by title, author, ISBN, category...',
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
                  color: const Color(0xFF3B82F6),
                  bg: const Color(0xFFEFF6FF),
                  selected: _selectedInventoryFilter == 'all',
                  onTap: () => _selectInventoryFilter('all'),
                ),
                _buildStatCard(
                  title: 'Total Copies',
                  count: totalCopies.toString(),
                  subtitle: 'physical copies',
                  icon: Icons.layers,
                  color: const Color(0xFF3B82F6),
                  bg: const Color(0xFFEFF6FF),
                  selected: false,
                  onTap: () => _showCopiesBreakdown(
                    totalBooks: totalBooks,
                    totalCopies: totalCopies,
                    availableCopies: availableCopies,
                    onLoan: onLoan,
                  ),
                ),
                _buildStatCard(
                  title: 'Available Copies',
                  count: availableCopies.toString(),
                  subtitle: 'available for loan',
                  icon: Icons.check_circle_outline,
                  color: const Color(0xFF10B981),
                  bg: const Color(0xFFECFDF5),
                  selected:
                      _selectedInventoryFilter == 'available',
                  onTap: () =>
                      _selectInventoryFilter('available'),
                ),
                _buildStatCard(
                  title: 'On Loan',
                  count: onLoan.toString(),
                  subtitle: 'not currently available',
                  icon: Icons.description_outlined,
                  color: const Color(0xFFF59E0B),
                  bg: const Color(0xFFFEF3C7),
                  selected:
                      _selectedInventoryFilter == 'onLoan',
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
                    if (i != cards.length - 1)
                      const SizedBox(width: 12),
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
                  onPressed: () =>
                      _selectInventoryFilter('all'),
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
                          color: Color(0xFF94A3B8),
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
                        const Color(0xFFF8FAFC),
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
                        final bool isAvailable =
                            book.availableCopies > 0;

                        final String status = isAvailable
                            ? 'Available'
                            : 'Unavailable';

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
                                  borderRadius:
                                      BorderRadius.circular(12),
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
  State<_InteractiveStatCard> createState() =>
      _InteractiveStatCardState();
}

class _InteractiveStatCardState
    extends State<_InteractiveStatCard> {
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
            color: highlighted
                ? Colors.white
                : const Color(0xFFE2E8F0),
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
                            color: Color(0xFF94A3B8),
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
                            color: Color(0xFF94A3B8),
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
  })  : backgroundColor = const Color(0xFF1877F2),
        foregroundColor = Colors.white;

  @override
  State<_HoverActionButton> createState() =>
      _HoverActionButtonState();
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
