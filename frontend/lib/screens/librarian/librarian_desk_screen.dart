
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/book.dart';
import '../../models/borrow_record.dart';
import '../../services/library_service.dart';

class LibrarianDeskScreen extends StatefulWidget {
  const LibrarianDeskScreen({super.key});

  @override
  State<LibrarianDeskScreen> createState() =>
      _LibrarianDeskScreenState();
}

class _LibrarianDeskScreenState extends State<LibrarianDeskScreen> {
  final _borrowStudentController = TextEditingController();
  final _borrowBookController = TextEditingController();
  final _returnStudentController = TextEditingController();
  final _returnBookController = TextEditingController();

  DateTime _borrowDate = DateTime.now();

  Book? _selectedBook;
  BorrowRecord? _selectedRecord;

  String _bookCondition = 'Good';

  final bool _isSearchingBorrowBook = false;
  bool _isSearchingReturnBook = false;

  @override
  void dispose() {
    _borrowStudentController.dispose();
    _borrowBookController.dispose();
    _returnStudentController.dispose();
    _returnBookController.dispose();
    super.dispose();
  }

  // -------------------- DATE FORMATTING --------------------

  String _formatDate(DateTime date) {
    return '${date.year}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  // -------------------- MESSAGES --------------------

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message)),
      );
  }

  // -------------------- BORROW DATE --------------------

  Future<void> _selectBorrowDate() async {
    final today = DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: _borrowDate,
      firstDate: DateTime(today.year - 5),
      lastDate: DateTime(today.year + 2),
      helpText: 'Select borrowing date',
    );

    if (selected != null && mounted) {
      setState(() {
        _borrowDate = selected;
      });
    }
  }

  // -------------------- SEARCH BOOK TO BORROW --------------------

  void _searchBorrowBook(LibraryService service) {
    final query = _borrowBookController.text.trim();

    if (query.isEmpty) {
      _showMessage('Enter a book title or ISBN.');
      return;
    }

    final book = service.findBook(query);

    setState(() {
      _selectedBook = book;
    });

    if (book == null) {
      _showMessage('Book not found. Check the title or ISBN.');
    } else if (book.availableCopies <= 0) {
      _showMessage('No copies of this book are available.');
    }
  }

  // -------------------- CONFIRM BORROWING --------------------

  Future<void> _confirmBorrow(LibraryService service) async {
    if (service.isProcessingBorrow) return;

    final studentId = _borrowStudentController.text.trim();
    final query = _borrowBookController.text.trim();

    if (studentId.isEmpty || query.isEmpty) {
      _showMessage('Enter the Student ID and book title or ISBN.');
      return;
    }

    final book = service.findBook(query);

    if (book == null) {
      _showMessage('Book not found. Search again.');
      return;
    }

    if (book.availableCopies <= 0) {
      _showMessage('This book has no available copies.');
      return;
    }

    final success = await service.borrowBook(
      book.id,
      studentId,
      studentId,
      borrowDate: _borrowDate,
    );

    if (!mounted) return;

    if (!success) {
      _showMessage(
        service.operationError ??
            'Borrowing failed. Please check the details.',
      );
      return;
    }

    final dueDate = _borrowDate.add(
      Duration(days: service.settings.maxBorrowDays),
    );

    setState(() {
      _selectedBook = null;
      _borrowBookController.clear();
    });

    _showMessage(
      'Borrowing confirmed. Due date: ${_formatDate(dueDate)}',
    );
  }

  // -------------------- SEARCH ACTIVE BORROWING --------------------

  Future<void> _searchReturnBook(LibraryService service) async {
    if (_isSearchingReturnBook) return;

    final studentId = _returnStudentController.text.trim();
    final query = _returnBookController.text.trim();

    if (studentId.isEmpty || query.isEmpty) {
      _showMessage('Enter the Student ID and book title or ISBN.');
      return;
    }

    setState(() {
      _isSearchingReturnBook = true;
      _selectedRecord = null;
    });

    try {
      final record = await service.findActiveBorrowing(
        studentId,
        query,
      );

      if (!mounted) return;

      setState(() {
        _selectedRecord = record;
      });

      if (record == null) {
        _showMessage(
          service.operationError ??
              'No active borrowing found for this student and book.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSearchingReturnBook = false;
        });
      }
    }
  }

  // -------------------- CONFIRM RETURN --------------------

  Future<void> _confirmReturn(LibraryService service) async {
    if (service.isProcessingReturn || _isSearchingReturnBook) {
      return;
    }

    final studentId = _returnStudentController.text.trim();
    final query = _returnBookController.text.trim();

    if (studentId.isEmpty || query.isEmpty) {
      _showMessage('Enter the Student ID and book title or ISBN.');
      return;
    }

    // Always retrieve the latest active borrowing from the backend.
    setState(() {
      _isSearchingReturnBook = true;
    });

    BorrowRecord? record;

    try {
      record = await service.findActiveBorrowing(
        studentId,
        query,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSearchingReturnBook = false;
        });
      }
    }

    if (!mounted) return;

    if (record == null) {
      setState(() {
        _selectedRecord = null;
      });

      _showMessage(
        service.operationError ??
            'No active borrowing found. Search again.',
      );
      return;
    }

    setState(() {
      _selectedRecord = record;
    });

    final daysOverdue = service.overdueDays(record);
    final estimatedFine = service.calculateFine(record);

    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm book return'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Book: ${record!.bookTitle}'),
              Text('Student ID: ${record.studentId}'),
              Text('Due date: ${record.dueDate}'),
              Text('Overdue days: $daysOverdue'),
              Text(
                'Daily fine rate: '
                'ETB ${service.settings.finePerDay.toStringAsFixed(2)}',
              ),
              Text(
                'Estimated fine: '
                'ETB ${estimatedFine.toStringAsFixed(2)}',
              ),
              Text('Condition: $_bookCondition'),
              const SizedBox(height: 12),
              const Text('Do you want to confirm this return?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Confirm return'),
            ),
          ],
        );
      },
    );

    if (!mounted || approved != true) return;

    // Convert the selected condition into the backend enum format.
    final condition = switch (_bookCondition) {
      'Minor damage' => 'MINOR_DAMAGE',
      'Lost' => 'LOST',
      _ => 'GOOD',
    };

    final success = await service.returnBookWithFine(
      record.id,
      studentId: studentId,
      bookQuery: query,
      condition: condition,
    );

    if (!mounted) return;

    if (!success) {
      _showMessage(
        service.operationError ??
            'The return could not be completed.',
      );
      return;
    }

    setState(() {
      _selectedRecord = null;
      _returnBookController.clear();
      _bookCondition = 'Good';
    });

    // Use the fine returned by the backend when available.
    final response = service.lastReturnResponse;

    final backendFine = response?['fineAmount'] ??
        response?['fine'] ??
        response?['Fine_Amount'];

    final fineMessage = backendFine != null
        ? 'ETB $backendFine'
        : 'ETB ${estimatedFine.toStringAsFixed(2)}';

    _showMessage(
      'Return completed. Fine recorded: $fineMessage.',
    );
  }

  // -------------------- MAIN BUILD --------------------

  @override
  Widget build(BuildContext context) {
    return Consumer<LibraryService>(
      builder: (context, service, child) {
        final maxDays = service.settings.maxBorrowDays;

        final dueDate = _borrowDate.add(
          Duration(days: maxDays),
        );

        final record = _selectedRecord;

        final overdueDays = record == null
            ? 0
            : service.overdueDays(record);

        final fine = record == null
            ? 0.0
            : service.calculateFine(record);

        return LayoutBuilder(
          builder: (context, constraints) {
            final isNarrow = constraints.maxWidth < 850;

            final borrowCard = _buildBorrowCard(
              service,
              dueDate,
              maxDays,
            );

            final returnCard = _buildReturnCard(
              service,
              record,
              overdueDays,
              fine,
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to the Librarian Desk',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Borrow books, process returns, and keep track '
                    'of library activities.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (isNarrow)
                    Column(
                      children: [
                        borrowCard,
                        const SizedBox(height: 20),
                        returnCard,
                      ],
                    )
                  else
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: borrowCard),
                        const SizedBox(width: 20),
                        Expanded(child: returnCard),
                      ],
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // -------------------- BORROW CARD --------------------

  Widget _buildBorrowCard(
    LibraryService service,
    DateTime dueDate,
    int maxDays,
  ) {
    final book = _selectedBook;

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(
            Icons.book_outlined,
            'Borrow Book',
            'Issue a book to a student',
            const Color(0xFF1877F2),
          ),
          const SizedBox(height: 22),

          _label('Student ID *'),
          const SizedBox(height: 6),
          TextField(
            controller: _borrowStudentController,
            decoration: _inputDecoration(
              'Enter student ID',
              Icons.person_outline,
            ),
          ),

          const SizedBox(height: 16),
          _label('Book Title or ISBN *'),
          const SizedBox(height: 6),
          TextField(
            controller: _borrowBookController,
            onSubmitted: (_) => _searchBorrowBook(service),
            onChanged: (_) => setState(() => _selectedBook = null),
            decoration: _inputDecoration(
              'Enter book title or ISBN',
              Icons.search,
            ),
          ),

          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: service.isProcessingBorrow
                ? null
                : () => _searchBorrowBook(service),
            icon: const Icon(Icons.search),
            label: const Text('Find book'),
          ),

          if (book != null) ...[
            const SizedBox(height: 12),
            _infoBox(
              background: const Color(0xFFF8FAFC),
              children: [
                _infoRow('Title', book.title),
                _infoRow('Author', book.author),
                _infoRow('ISBN', book.isbn),
                _infoRow(
                  'Available copies',
                  '${book.availableCopies}',
                ),
                _infoRow('Location', book.location),
              ],
            ),
          ],

          const SizedBox(height: 18),
          _label('Borrow Date *'),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: service.isProcessingBorrow
                  ? null
                  : _selectBorrowDate,
              icon: const Icon(Icons.calendar_month),
              label: Text(_formatDate(_borrowDate)),
            ),
          ),

          const SizedBox(height: 12),
          _infoBox(
            background: const Color(0xFFEFF6FF),
            children: [
              _infoRow(
                'Maximum borrowing period',
                '$maxDays days',
              ),
              _infoRow(
                'Calculated due date',
                _formatDate(dueDate),
              ),
            ],
          ),

          const SizedBox(height: 20),
          _actionButton(
            label: service.isProcessingBorrow
                ? 'Processing...'
                : 'Confirm Borrowing',
            icon: Icons.book,
            color: const Color(0xFF1877F2),
            onPressed: service.isProcessingBorrow
                ? null
                : () => _confirmBorrow(service),
          ),
        ],
      ),
    );
  }

  // -------------------- RETURN CARD --------------------

  Widget _buildReturnCard(
    LibraryService service,
    BorrowRecord? record,
    int overdueDays,
    double fine,
  ) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _heading(
            Icons.swap_horiz,
            'Return Book',
            'Process a return and check fines',
            const Color(0xFF10B981),
          ),
          const SizedBox(height: 22),

          _label('Student ID *'),
          const SizedBox(height: 6),
          TextField(
            controller: _returnStudentController,
            decoration: _inputDecoration(
              'Enter student ID',
              Icons.person_outline,
            ),
          ),

          const SizedBox(height: 16),
          _label('Book Title or ISBN *'),
          const SizedBox(height: 6),
          TextField(
            controller: _returnBookController,
            onSubmitted: (_) => _searchReturnBook(service),
            onChanged: (_) => setState(() => _selectedRecord = null),
            decoration: _inputDecoration(
              'Enter book title or ISBN',
              Icons.search,
            ),
          ),

          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _isSearchingReturnBook ||
                    service.isProcessingReturn
                ? null
                : () => _searchReturnBook(service),
            icon: _isSearchingReturnBook
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.search),
            label: Text(
              _isSearchingReturnBook
                  ? 'Searching...'
                  : 'Find active borrowing',
            ),
          ),

          const SizedBox(height: 18),
          _label('Book Condition'),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ['Good', 'Minor damage', 'Lost'].map(
              (condition) {
                return ChoiceChip(
                  label: Text(condition),
                  selected: _bookCondition == condition,
                  onSelected: service.isProcessingReturn
                      ? null
                      : (_) {
                          setState(() {
                            _bookCondition = condition;
                          });
                        },
                );
              },
            ).toList(),
          ),

          const SizedBox(height: 18),
          if (record == null)
            _infoBox(
              background: const Color(0xFFF8FAFC),
              children: const [
                Text(
                  'Search by Student ID and book title or ISBN '
                  'to display the borrowing details and any fine.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            )
          else
            _infoBox(
              background: overdueDays > 0
                  ? const Color(0xFFFEF2F2)
                  : const Color(0xFFECFDF5),
              children: [
                Text(
                  overdueDays > 0
                      ? 'Overdue Fine'
                      : 'No Overdue Fine',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: overdueDays > 0
                        ? Colors.red
                        : Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'ETB ${fine.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: overdueDays > 0
                        ? Colors.red
                        : Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 10),
                _infoRow('Book', record.bookTitle),
                _infoRow('Student ID', record.studentId),
                _infoRow('Due date', record.dueDate),
                _infoRow(
                  'Daily fine rate',
                  'ETB ${service.settings.finePerDay.toStringAsFixed(2)}',
                ),
                _infoRow('Overdue days', '$overdueDays'),
                _infoRow(
                  'Estimated fine',
                  'ETB ${fine.toStringAsFixed(2)}',
                ),
              ],
            ),

          const SizedBox(height: 20),
          _actionButton(
            label: service.isProcessingReturn
                ? 'Processing...'
                : 'Confirm Return',
            icon: Icons.swap_horiz,
            color: const Color(0xFF10B981),
            onPressed: service.isProcessingReturn ||
                    _isSearchingReturnBook
                ? null
                : () => _confirmReturn(service),
          ),
        ],
      ),
    );
  }

  // -------------------- REUSABLE UI COMPONENTS --------------------

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: child,
    );
  }

  Widget _heading(
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 18),
      isDense: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _infoBox({
    required Color background,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: color.withValues(alpha: 0.5),
          disabledForegroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
