import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final BookService _bookService = BookService();
bool _isAddingBook = false;
  }

Future<void> _showAddBookDialog() async {
  final formKey = GlobalKey<FormState>();

  final isbnController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final authorIdController = TextEditingController();
  final publisherIdController = TextEditingController();
  final categoryIdController = TextEditingController();
  final editionController = TextEditingController();
  final priceController = TextEditingController();
  final yearController = TextEditingController();
  final coverImageController = TextEditingController();
  final copiesController = TextEditingController(text: '1');
  final locationController = TextEditingController();

  try {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool submitting = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.library_add, color: Color(0xFF1877F2)),
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
                        _formField(
                          isbnController,
                          'ISBN',
                          requiredField: true,
                        ),
                        _formField(
                          titleController,
                          'Book Title',
                          requiredField: true,
                        ),
                        _formField(
                          descriptionController,
                          'Description',
                          maxLines: 3,
                        ),
                        const SizedBox(height: 8),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Book Information',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1877F2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _formField(
                          authorIdController,
                          'Author ID',
                          requiredField: true,
                          isNumber: true,
                        ),
                        _formField(
                          publisherIdController,
                          'Publisher ID',
                          requiredField: true,
                          isNumber: true,
                        ),
                        _formField(
                          categoryIdController,
                          'Category ID',
                          requiredField: true,
                          isNumber: true,
                        ),
                        _formField(
                          editionController,
                          'Edition',
                        ),
                        _formField(
                          priceController,
                          'Price',
                          isNumber: true,
                        ),
                        _formField(
                          yearController,
                          'Publication Year',
                          isNumber: true,
                        ),
                        _formField(
                          coverImageController,
                          'Cover Image URL',
                        ),
                        const Divider(height: 28),
                        const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Physical Copies',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1877F2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _formField(
                          copiesController,
                          'Number of Copies',
                          requiredField: true,
                          isNumber: true,
                          minimum: 1,
                        ),
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
                      : () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton.icon(
                  onPressed: submitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) {
                            return;
                          }

                          setDialogState(() => submitting = true);

                          final bookData = {
                            'isbn': isbnController.text.trim(),
                            'title': titleController.text.trim(),
                            'description':
                                descriptionController.text.trim(),
                            'authorId':
                                int.parse(authorIdController.text.trim()),
                            'publisherId':
                                int.parse(publisherIdController.text.trim()),
                            'categoryId':
                                int.parse(categoryIdController.text.trim()),
                            'edition': editionController.text.trim(),
                            'price': priceController.text.trim().isEmpty
                                ? null
                                : double.parse(priceController.text.trim()),
                            'publicationYear':
                                yearController.text.trim().isEmpty
                                    ? null
                                    : int.parse(
                                        yearController.text.trim(),
                                      ),
                            'coverImage': coverImageController.text.trim(),
                            'numberOfCopies':
                                int.parse(copiesController.text.trim()),
                            'location': locationController.text.trim(),
                          };

                          try {
                            await _bookService.createBook(bookData);

                            if (!mounted) return;

                            Navigator.pop(dialogContext, true);
                          } catch (error) {
                            setDialogState(() => submitting = false);

                            ScaffoldMessenger.of(context).showSnackBar(
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
                  label: Text(submitting ? 'Saving...' : 'Save Book'),
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

    if (result == true && mounted) {
      await context.read<LibraryService>().loadBooksFromApi();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book and physical copies added successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  } finally {
    isbnController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    authorIdController.dispose();
    publisherIdController.dispose();
    categoryIdController.dispose();
    editionController.dispose();
    priceController.dispose();
    yearController.dispose();
    coverImageController.dispose();
    copiesController.dispose();
    locationController.dispose();
  }
}

// Reusable form input
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
          ? const TextInputType.numberWithOptions(decimal: true)
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
          if (minimum != null) {
            final number = int.tryParse(text);
            if (number == null || number < minimum) {
              return 'Enter a whole number of at least $minimum';
            }
          } else if (label == 'Price') {
            final number = double.tryParse(text);
            if (number == null || number < 0) {
              return 'Enter a valid non-negative price';
            }
          } else if (int.tryParse(text) == null) {
            return 'Enter a valid whole number';
          }
        }

        return null;
      },
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final libraryService = context.watch<LibraryService>();
    final List<Book> books = libraryService.books;

    // Search books using title, author, ISBN, or category.
    final List<Book> filteredBooks = books.where((book) {
      final query = _searchQuery.toLowerCase();

      return book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.isbn.toLowerCase().contains(query) ||
          book.category.toLowerCase().contains(query);
    }).toList();

    // Calculate statistics from the actual book records.
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
              ElevatedButton.icon(
                onPressed: _showAddBookDialog,
                icon: const Icon(Icons.add, size: 18),
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
                          'Search by title, author, ISBN, or category...',
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
                  icon: const Icon(Icons.search, size: 16),
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
              final bool isNarrow = constraints.maxWidth < 900;

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

  // STATISTICS CARD
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