import 'package:flutter/material.dart';
import '../../models/book.dart';
import 'package:library_management_system/widgets/dialogs/add_books_dialog.dart';
import '../../models/inventory_summary.dart';
import '../../services/book_service.dart';

class AdminInventoryScreen extends StatefulWidget {
  const AdminInventoryScreen({super.key});

  @override
  State<AdminInventoryScreen> createState() => _AdminInventoryScreenState();
}

class _AdminInventoryScreenState extends State<AdminInventoryScreen> {
  Future<InventorySummary> _summaryFuture = BookService.fetchInventorySummary();
  Future<List<Book>> _booksFuture = BookService.fetchBooks();

  @override
  void initState() {
    super.initState();
    _fetchSummary();
    _loadData();
  }

  void _loadData() {
    setState(() {
      _summaryFuture = BookService.fetchInventorySummary();
      _booksFuture = BookService.fetchBooks();
    });
  }

  void _fetchSummary() {
    setState(() {
      _summaryFuture = BookService.fetchInventorySummary();
    });
  }

  final TextEditingController _searchController = TextEditingController();
 

  void _openAddBookDialog() async {
    final Map<String, dynamic>? result = await showDialog(
      context: context,
      builder: (context) => const AddBookDialog(),
    );

    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adding book to database...'),
          duration: Duration(seconds: 1),
        ),
      );
      
      final bool success = await BookService.addBook(
        title: result['title'],
        author: result['author'],
        category: result['category'],
        totalCopies: result['copies'],
        location: result['location'],
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully added "${result['title']}"!'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh both the metric cards and the books catalog table
          _loadData();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to save book. Check backend console.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBF3FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.menu_book,
                        color: Color(0xFF0052CC), size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Book Inventory',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A)),
                      ),
                    ],
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: _openAddBookDialog,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add New Book'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search & Filter Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search,
                          size: 20, color: Color(0xFF94A3B8)),
                      hintText:
                          'Search by title, author, ISBN, or categories...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
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

          // 5 KPI Stat Cards
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Live Statistics Section
              FutureBuilder<InventorySummary>(
                future: _summaryFuture,
                builder: (context, snapshot) {
                  final isLoading =
                      snapshot.connectionState == ConnectionState.waiting;
                  final summary = snapshot.data ?? InventorySummary.empty();

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildMetricCard(
                            title: 'Total Books',
                            count: summary.totalBooks,
                            icon: Icons.menu_book,
                            color: Colors.blue,
                            isLoading: isLoading,
                          ),
                          _buildMetricCard(
                            title: 'Total Copies',
                            count: summary.totalCopies,
                            icon: Icons.copy,
                            color: Colors.indigo,
                            isLoading: isLoading,
                          ),
                          _buildMetricCard(
                            title: 'Available',
                            count: summary.availableCopies,
                            icon: Icons.check_circle_outline,
                            color: Colors.green,
                            isLoading: isLoading,
                          ),
                          _buildMetricCard(
                            title: 'On Loan',
                            count: summary.onLoanCopies,
                            icon: Icons.timelapse,
                            color: Colors.orange,
                            isLoading: isLoading,
                          ),
                          _buildMetricCard(
                            title: 'Reserved',
                            count: summary.reservedCopies,
                            icon: Icons.bookmark_border,
                            color: Colors.purple,
                            isLoading: isLoading,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              // Your existing book table or list widget goes below here...
            ],
          ),

          const SizedBox(height: 24),

          // Inventory Table
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Book Inventory List',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),

                // >>> PASTE THE TABLE FutureBuilder HERE <<<
                FutureBuilder<List<Book>>(
                  future: _booksFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error loading catalog: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red),
                        ),
                      );
                    }

                    final books = snapshot.data ?? [];
                    if (books.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.0),
                          child: Text('No books found in the database.'),
                        ),
                      );
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: const [
                          DataColumn(label: Text('Cover')),
                          DataColumn(label: Text('Title & ISBN')),
                          DataColumn(label: Text('Author')),
                          DataColumn(label: Text('Category')),
                          DataColumn(label: Text('Copies')),
                          DataColumn(label: Text('Location')),
                          DataColumn(label: Text('Status')),
                        ],
                        rows: books.map((book) {
                          return DataRow(
                            cells: [
                              DataCell(
                                book.coverTheme != null &&
                                        book.coverTheme!.isNotEmpty
                                    ? Image.network(
                                        book.coverTheme!,
                                        width: 30,
                                        height: 45,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.book, size: 30),
                                      )
                                    : const Icon(Icons.book, size: 30),
                              ),
                              DataCell(
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(book.title,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    Text(book.isbn,
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600)),
                                  ],
                                ),
                              ),
                              DataCell(Text(book.author)),
                              DataCell(Text(book.category)),
                              DataCell(Text(
                                  '${book.availableCopies} / ${book.totalCopies}')),
                              DataCell(Text(book.location)),
                              DataCell(Text(book.status)),
                            ],
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ],
            ),
          )
        ]));
  }

  Widget _buildMetricCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required bool isLoading,
  }) {
    return Container(
      width: 170,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          const SizedBox(height: 12),
          isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              : Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
        ],
      ),
    );
  }
}
