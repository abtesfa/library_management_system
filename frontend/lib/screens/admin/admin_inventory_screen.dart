
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      // LOAD CATEGORIES FROM SPRING BOOT / MYSQL
      final categoryResponse = await http
          .get(
            Uri.parse(
              'http://localhost:8080/api/books/categories',
            ),
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

      // SHOW ADD BOOK DIALOG
      final bool? result = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          bool submitting = false;

          return StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return AlertDialog(
                title: const Row(
                  children: [
                    Icon(
                      Icons.library_add,
                      color: Color(0xFF1877F2),
                    ),
                    SizedBox(width: 10),
                    Text('Add New Book'),
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
                          // BOOK TITLE
                          _formField(
                            titleController,
                            'Book Title',
                            requiredField: true,
                          ),

                          // AUTHOR NAME
                          _formField(
                            authorController,
                            'Author Name',
                            requiredField: true,
                          ),

                          // CATEGORY DROPDOWN
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 12,
                            ),
                            child: DropdownButtonFormField<int>(
                              initialValue: selectedCategoryId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                labelText: 'Category',
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

                          // NUMBER OF COPIES
                          _formField(
                            copiesController,
                            'Number of Copies',
                            requiredField: true,
                            isNumber: true,
                            minimum: 1,
                          ),

                          // SHELF LOCATION
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

                // DIALOG ACTIONS
                actions: [
                  // CANCEL BUTTON
                  TextButton(
                    onPressed: submitting
                        ? null
                        : () {
                            Navigator.pop(dialogContext, false);
                          },
                    child: const Text('Cancel'),
                  ),

                  // SAVE BOOK BUTTON
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
                              // PREPARE BOOK DATA
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
                                        : locationController.text
                                            .trim(),
                              };

                              // SEND BOOK DATA TO SPRING BOOT
                              await _bookService.createBook(bookData);

                              if (!mounted) return;

                              // CLOSE DIALOG AFTER SUCCESSFUL SAVE
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
                        : const Icon(
                            Icons.save,
                            size: 18,
                          ),
                    label: Text(
                      submitting ? 'Saving...' : 'Save Book',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1877F2),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              );
            },
          );
        },
      );

      // =====================================================
      // SHOW SUCCESS MESSAGE AFTER BOOK IS SAVED
      // =====================================================

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

        // REFRESH INVENTORY AFTER SHOWING SUCCESS
        try {
          await context
              .read<LibraryService>()
              .loadBooksFromApi();
        } catch (error) {
          debugPrint(
            'Inventory refresh failed: $error',
          );
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
    bool requiredField = false,
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
          labelText: label,
          hintText: hint,
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

          if (requiredField && text.isEmpty) {
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

    // SEARCH BOOKS
    final List<Book> filteredBooks = books.where((book) {
      final query = _searchQuery.toLowerCase();

      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.isbn.toLowerCase().contains(query) ||
          book.category.toLowerCase().contains(query);
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

    final int onLoan = totalCopies - availableCopies;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
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
                        color: Color(0xFF0052CC),
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
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Manage book titles, authors, categories, physical copies, shelf locations, and availability status.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // ADD NEW BOOK BUTTON
              ElevatedButton.icon(
                onPressed: _showAddBookDialog,
                icon: const Icon(
                  Icons.add,
                  size: 18,
                ),
                label: const Text('Add New Book'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
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
          ),

          const SizedBox(height: 20),

          // SEARCH BAR
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim();
                      });
                    },
                    decoration: const InputDecoration(
                      prefixIcon: Icon(
                        Icons.search,
                        size: 20,
                        color: Color(0xFF94A3B8),
                      ),
                      hintText:
                          'Search by title, author, category...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),

                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _searchQuery =
                          _searchController.text.trim();
                    });
                  },
                  icon: const Icon(
                    Icons.search,
                    size: 16,
                  ),
                  label: const Text('Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1877F2),
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // INVENTORY STATISTICS
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isNarrow =
                  constraints.maxWidth < 900;

              final cards = [
                _buildStatCard(
                  'Total Books',
                  totalBooks.toString(),
                  'titles in collection',
                  Icons.book,
                  const Color(0xFF3B82F6),
                  const Color(0xFFEFF6FF),
                ),
                _buildStatCard(
                  'Total Copies',
                  totalCopies.toString(),
                  'physical copies',
                  Icons.layers,
                  const Color(0xFF3B82F6),
                  const Color(0xFFEFF6FF),
                ),
                _buildStatCard(
                  'Available Copies',
                  availableCopies.toString(),
                  'available for loan',
                  Icons.check_circle_outline,
                  const Color(0xFF10B981),
                  const Color(0xFFECFDF5),
                ),
                _buildStatCard(
                  'On Loan',
                  onLoan.toString(),
                  'not currently available',
                  Icons.description_outlined,
                  const Color(0xFFF59E0B),
                  const Color(0xFFFEF3C7),
                ),
              ];

              if (isNarrow) {
                return GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2.5,
                  children: cards,
                );
              }

              return Row(
                children: [
                  for (int i = 0; i < cards.length; i++) ...[
                    Expanded(
                      child: cards[i],
                    ),
                    if (i != cards.length - 1)
                      const SizedBox(width: 12),
                  ],
                ],
              );
            },
          ),

          const SizedBox(height: 24),

          // INVENTORY TABLE
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // TABLE HEADER
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Book Inventory List',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      Text(
                        'Showing ${filteredBooks.length} of ${books.length}',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(height: 1),

                // LOADING STATE
                if (libraryService.isLoadingBooks)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )

                // ERROR STATE
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
                          style: const TextStyle(
                            color: Colors.red,
                          ),
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

                // EMPTY STATE
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
                              : 'No books match your search.',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )

                // BOOK DATA
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor:
                          WidgetStateProperty.all(
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
                                  color: Color(0xFF1877F2),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),

                            DataCell(
                              Text(book.author),
                            ),

                            DataCell(
                              Text(
                                book.isbn,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),

                            DataCell(
                              Text(book.category),
                            ),

                            DataCell(
                              Text(
                                book.totalCopies.toString(),
                              ),
                            ),

                            DataCell(
                              Text(
                                book.availableCopies.toString(),
                              ),
                            ),

                            DataCell(
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(
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

                            DataCell(
                              Text(book.location),
                            ),
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
  // STATISTICS CARD
  // =========================================================

  Widget _buildStatCard(
    String title,
    String count,
    String subtitle,
    IconData icon,
    Color color,
    Color bg,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: bg,
              shape: BoxShape.circle,
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
                    fontSize: 11,
                    color: Color(0xFF64748B),
                  ),
                ),

                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),

                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
