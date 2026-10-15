
import 'package:flutter/material.dart';

const Color _blue = Color(0xFF0052CC);
const Color _navy = Color(0xFF142B4A);
const Color _background = Color(0xFFF5F7FB);

class LibraryBook {
  LibraryBook({
    required this.title,
    required this.author,
    required this.isbn,
    required this.category,
    required this.quantity,
    required this.available,
  });

  String title;
  String author;
  String isbn;
  String category;
  int quantity;
  int available;

  String get status =>
      available == 0 ? 'Unavailable' : 'Available';
}

class BookInventoryScreen extends StatefulWidget {
  const BookInventoryScreen({super.key});

  @override
  State<BookInventoryScreen> createState() =>
      _BookInventoryScreenState();
}

class _BookInventoryScreenState extends State<BookInventoryScreen> {
  final TextEditingController _searchController =
      TextEditingController();

  String _category = 'All categories';
  String _status = 'All statuses';

  final List<LibraryBook> _books = [
    LibraryBook(
      title: 'Clean Code',
      author: 'Robert C. Martin',
      isbn: '9780132350884',
      category: 'Technology',
      quantity: 12,
      available: 8,
    ),
    LibraryBook(
      title: 'Introduction to Algorithms',
      author: 'Thomas H. Cormen',
      isbn: '9780262046305',
      category: 'Technology',
      quantity: 10,
      available: 4,
    ),
    LibraryBook(
      title: 'Database System Concepts',
      author: 'Abraham Silberschatz',
      isbn: '9780078022159',
      category: 'Education',
      quantity: 8,
      available: 0,
    ),
    LibraryBook(
      title: 'The Great Gatsby',
      author: 'F. Scott Fitzgerald',
      isbn: '9780743273565',
      category: 'Literature',
      quantity: 15,
      available: 11,
    ),
    LibraryBook(
      title: 'Physics Fundamentals',
      author: 'David Halliday',
      isbn: '9781118230718',
      category: 'Science',
      quantity: 6,
      available: 3,
    ),
  ];

  final List<String> _categories = [
    'All categories',
    'Technology',
    'Education',
    'Literature',
    'Science',
    'History',
  ];

  List<LibraryBook> get _filteredBooks {
    final query = _searchController.text.toLowerCase();

    return _books.where((book) {
      final matchesSearch =
          book.title.toLowerCase().contains(query) ||
          book.author.toLowerCase().contains(query) ||
          book.isbn.toLowerCase().contains(query);

      final matchesCategory =
          _category == 'All categories' ||
          book.category == _category;

      final matchesStatus =
          _status == 'All statuses' ||
          book.status == _status;

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }

  int get _totalCopies =>
      _books.fold(0, (sum, book) => sum + book.quantity);

  int get _availableCopies =>
      _books.fold(0, (sum, book) => sum + book.available);

  int get _borrowedCopies => _totalCopies - _availableCopies;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showBookDialog({LibraryBook? book}) {
    final formKey = GlobalKey<FormState>();
    final title = TextEditingController(text: book?.title ?? '');
    final author = TextEditingController(text: book?.author ?? '');
    final isbn = TextEditingController(text: book?.isbn ?? '');
    final quantity = TextEditingController(
      text: book?.quantity.toString() ?? '1',
    );
    final available = TextEditingController(
      text: book?.available.toString() ?? '1',
    );
    String category = book?.category ?? 'Technology';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(book == null ? 'Add new book' : 'Edit book'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _formField(title, 'Book title'),
                    _formField(author, 'Author'),
                    _formField(isbn, 'ISBN'),
                    DropdownButtonFormField<String>(
                      value: category,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: _categories
                          .where((item) => item != 'All categories')
                          .map((item) => DropdownMenuItem(
                                value: item,
                                child: Text(item),
                              ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() => category = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _formField(
                      quantity,
                      'Total copies',
                      numeric: true,
                    ),
                    _formField(
                      available,
                      'Available copies',
                      numeric: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;

                final total = int.parse(quantity.text);
                final inStock = int.parse(available.text);

                if (inStock > total) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Available copies cannot exceed total copies.',
                      ),
                    ),
                  );
                  return;
                }

                setState(() {
                  if (book == null) {
                    _books.add(
                      LibraryBook(
                        title: title.text.trim(),
                        author: author.text.trim(),
                        isbn: isbn.text.trim(),
                        category: category,
                        quantity: total,
                        available: inStock,
                      ),
                    );
                  } else {
                    book.title = title.text.trim();
                    book.author = author.text.trim();
                    book.isbn = isbn.text.trim();
                    book.category = category;
                    book.quantity = total;
                    book.available = inStock;
                  }
                });

                Navigator.pop(dialogContext);
              },
              child: const Text('Save book'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _formField(
    TextEditingController controller,
    String label, {
    bool numeric = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType:
            numeric ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return 'This field is required';
          }
          if (numeric && int.tryParse(value) == null) {
            return 'Enter a valid number';
          }
          if (numeric && int.parse(value) < 0) {
            return 'Cannot be negative';
          }
          return null;
        },
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon,
      Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.10),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        color: Colors.blueGrey, fontSize: 12)),
                const SizedBox(height: 6),
                Text(value,
                    style: const TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                        color: _navy)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final books = _filteredBooks;

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Book Inventory',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: _navy,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Manage your library collection and availability.',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => _showBookDialog(),
                    icon: const Icon(Icons.add),
                    label: const Text('Add book'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth > 900
                      ? 4
                      : constraints.maxWidth > 550
                          ? 2
                          : 1;

                  return GridView.count(
                    crossAxisCount: columns,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio:
                        columns == 1 ? 4.0 : 2.0,
                    children: [
                      _statCard('Book titles', '${_books.length}',
                          Icons.menu_book, _blue),
                      _statCard('Total copies', '$_totalCopies',
                          Icons.library_books, Colors.purple),
                      _statCard('Available copies',
                          '$_availableCopies', Icons.check_circle,
                          Colors.green),
                      _statCard('Borrowed copies', '$_borrowedCopies',
                          Icons.assignment_turned_in, Colors.orange),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE8EDF5)),
                ),
                child: Column(
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final narrow = constraints.maxWidth < 650;

                        final search = TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search title, author, ISBN...',
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 12),
                          ),
                        );

                        final category = DropdownButtonFormField<String>(
                          value: _category,
                          decoration: const InputDecoration(
                            labelText: 'Category',
                            border: OutlineInputBorder(),
                          ),
                          items: _categories
                              .map((item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _category = value!),
                        );

                        final status = DropdownButtonFormField<String>(
                          value: _status,
                          decoration: const InputDecoration(
                            labelText: 'Availability',
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            'All statuses',
                            'Available',
                            'Unavailable',
                          ]
                              .map((item) => DropdownMenuItem(
                                    value: item,
                                    child: Text(item),
                                  ))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _status = value!),
                        );

                        if (narrow) {
                          return Column(
                            children: [
                              search,
                              const SizedBox(height: 12),
                              category,
                              const SizedBox(height: 12),
                              status,
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(flex: 3, child: search),
                            const SizedBox(width: 12),
                            Expanded(child: category),
                            const SizedBox(width: 12),
                            Expanded(child: status),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                            const Color(0xFFF1F5FB)),
                        columns: const [
                          DataColumn(label: Text('BOOK')),
                          DataColumn(label: Text('ISBN')),
                          DataColumn(label: Text('CATEGORY')),
                          DataColumn(label: Text('COPIES')),
                          DataColumn(label: Text('STATUS')),
                          DataColumn(label: Text('ACTIONS')),
                        ],
                        rows: books.map((book) {
                          return DataRow(cells: [
                            DataCell(
                              SizedBox(
                                width: 190,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(book.title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600)),
                                    Text(book.author,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.blueGrey,
                                            fontSize: 12)),
                                  ],
                                ),
                              ),
                            ),
                            DataCell(Text(book.isbn)),
                            DataCell(Text(book.category)),
                            DataCell(Text(
                                '${book.available}/${book.quantity}')),
                            DataCell(
                              Chip(
                                label: Text(book.status),
                                backgroundColor: book.available > 0
                                    ? const Color(0xFFE2F7EB)
                                    : const Color(0xFFFFE7E7),
                                side: BorderSide.none,
                                labelStyle: TextStyle(
                                  color: book.available > 0
                                      ? Colors.green.shade800
                                      : Colors.red.shade800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            DataCell(
                              Row(
                                children: [
                                  IconButton(
                                    tooltip: 'Edit',
                                    onPressed: () =>
                                        _showBookDialog(book: book),
                                    icon: const Icon(Icons.edit_outlined,
                                        color: _blue),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete',
                                    onPressed: () async {
                                      final confirmed =
                                          await showDialog<bool>(
                                        context: context,
                                        builder: (dialogContext) =>
                                            AlertDialog(
                                          title: const Text('Delete book?'),
                                          content: Text(
                                              'Remove "${book.title}"?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(
                                                      dialogContext, false),
                                              child: const Text('Cancel'),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(
                                                      dialogContext, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirmed == true && mounted) {
                                        setState(() => _books.remove(book));
                                      }
                                    },
                                    icon: const Icon(Icons.delete_outline,
                                        color: Colors.red),
                                  ),
                                ],
                              ),
                            ),
                          ]);
                        }).toList(),
                      ),
                    ),
                    if (books.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('No books match your search.'),
                      ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${books.length} book records',
                        style: const TextStyle(color: Colors.blueGrey),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
