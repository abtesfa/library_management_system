
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

  bool _isSearchingReturnBook = false;

  static const Color primaryBlue = Color(0xFF1877F2);
  static const Color successGreen = Color(0xFF10B981);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);

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
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
  }

  // -------------------- REQUIRED FIELD VALIDATION --------------------

  bool _validateBorrowFields() {
    final studentId = _borrowStudentController.text.trim();
    final bookTitle = _borrowBookController.text.trim();

    if (studentId.isEmpty) {
      _showMessage('Student ID is required.');
      return false;
    }

    if (bookTitle.isEmpty) {
      _showMessage('Book Title is required.');
      return false;
    }

    return true;
  }

  bool _validateReturnFields() {
    final studentId = _returnStudentController.text.trim();
    final bookTitle = _returnBookController.text.trim();

    if (studentId.isEmpty) {
      _showMessage('Student ID is required.');
      return false;
    }

    if (bookTitle.isEmpty) {
      _showMessage('Book Title is required.');
      return false;
    }

    return true;
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
      _showMessage('Book Title is required.');
      return;
    }

    final book = service.findBook(query);

    setState(() {
      _selectedBook = book;
    });

    if (book == null) {
      _showMessage('Book not found. Check the title.');
    }
  }

  // -------------------- CONFIRM BORROWING --------------------

  Future<void> _confirmBorrow(LibraryService service) async {
    if (service.isProcessingBorrow) return;

    if (!_validateBorrowFields()) return;

    final studentId = _borrowStudentController.text.trim();
    final query = _borrowBookController.text.trim();

    final book = service.findBook(query);

    if (book == null) {
      _showMessage('Book not found. Search again.');
      return;
    }

    final success = await service.borrowBook(
      book.id,
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
      _borrowStudentController.clear();
      _borrowBookController.clear();
    });

    _showMessage(
      'Borrowing confirmed. Due date: ${_formatDate(dueDate)}',
    );
  }

  // -------------------- SEARCH ACTIVE BORROWING --------------------

  Future<void> _searchReturnBook(LibraryService service) async {
    if (_isSearchingReturnBook) return;

    if (!_validateReturnFields()) return;

    final studentId = _returnStudentController.text.trim();
    final query = _returnBookController.text.trim();

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
    } catch (e) {
      if (mounted) {
        _showMessage('Unable to search borrowing records.');
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

    if (!_validateReturnFields()) return;

    final studentId = _returnStudentController.text.trim();
    final query = _returnBookController.text.trim();

    // Retrieve the latest active borrowing from the backend.
    setState(() {
      _isSearchingReturnBook = true;
    });

    BorrowRecord? record;

    try {
      record = await service.findActiveBorrowing(
        studentId,
        query,
      );
    } catch (e) {
      if (mounted) {
        _showMessage('Unable to retrieve the borrowing record.');
      }
      return;
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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

    // Convert the selected condition into backend enum format.
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
      _returnStudentController.clear();
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
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Borrow books, process returns, and keep track '
                    'of library activities.',
                    style: TextStyle(
                      fontSize: 13,
                      color: textMuted,
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
            primaryBlue,
          ),
          const SizedBox(height: 22),

          _label('Student ID', isRequired: true),
          const SizedBox(height: 6),
          TextField(
            controller: _borrowStudentController,
            decoration: _inputDecoration(
              'Enter student ID',
              Icons.person_outline,
            ),
          ),

          const SizedBox(height: 16),
          _label('Book Title', isRequired: true),
          const SizedBox(height: 6),
          TextField(
            controller: _borrowBookController,
            onSubmitted: (_) => _searchBorrowBook(service),
            onChanged: (_) {
              setState(() => _selectedBook = null);
            },
            decoration: _inputDecoration(
              'Enter book title',
              Icons.search,
            ),
          ),

          const SizedBox(height: 10),
          _actionButton(
            label: 'Find book',
            icon: Icons.search,
            color: primaryBlue,
            outlined: true,
            onPressed: service.isProcessingBorrow
                ? null
                : () => _searchBorrowBook(service),
          ),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              return SizeTransition(
                sizeFactor: animation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: book == null
                ? const SizedBox(
                    key: ValueKey('no-book'),
                  )
                : Container(
                    key: ValueKey('book-${book.id}'),
                    margin: const EdgeInsets.only(top: 12),
                    child: _infoBox(
                      background: const Color(0xFFF8FAFC),
                      children: [
                        _infoRow('Title', book.title),
                        _infoRow('Author', book.author),
                        _infoRow('ISBN', book.isbn),
                        _infoRow(
                          'Available copies',
                          '${book.availableCopies}',
                        ),
                        if (book.reservedCopies > 0)
                          _infoRow(
                            'Reserved copies',
                            '${book.reservedCopies}',
                          ),
                        _infoRow('Location', book.location),
                        if (book.availableCopies <= 0)
                          const Padding(
                            padding: EdgeInsets.only(top: 8),
                            child: Text(
                              'No free copies. Only a student with a '
                              'reservation can borrow this book.',
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),

          const SizedBox(height: 18),
          _label('Borrow Date', isRequired: true),
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: service.isProcessingBorrow
                  ? null
                  : _selectBorrowDate,
              icon: const Icon(Icons.calendar_month),
              label: Text(_formatDate(_borrowDate)),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryBlue,
                side: const BorderSide(color: borderColor),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),

          const SizedBox(height: 12),
          _infoBox(
            background: const Color(0xFFEFF6FF),
            children: [
              _infoRow(
                'Maximum Loan Duration',
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
            color: primaryBlue,
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
            successGreen,
          ),
          const SizedBox(height: 22),

          _label('Student ID', isRequired: true),
          const SizedBox(height: 6),
          TextField(
            controller: _returnStudentController,
            decoration: _inputDecoration(
              'Enter student ID',
              Icons.person_outline,
            ),
          ),

          const SizedBox(height: 16),
          _label('Book Title', isRequired: true),
          const SizedBox(height: 6),
          TextField(
            controller: _returnBookController,
            onSubmitted: (_) => _searchReturnBook(service),
            onChanged: (_) {
              setState(() => _selectedRecord = null);
            },
            decoration: _inputDecoration(
              'Enter book title',
              Icons.search,
            ),
          ),

          const SizedBox(height: 10),
          _actionButton(
            label: _isSearchingReturnBook
                ? 'Searching...'
                : 'Find active borrowing',
            icon: _isSearchingReturnBook
                ? Icons.hourglass_top
                : Icons.search,
            color: successGreen,
            outlined: true,
            onPressed: _isSearchingReturnBook ||
                    service.isProcessingReturn
                ? null
                : () => _searchReturnBook(service),
          ),

          const SizedBox(height: 18),
          _label('Book Condition', isRequired: true),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Good', 'Minor damage', 'Lost'].map(
              (condition) {
                final selected = _bookCondition == condition;

                final conditionColor = switch (condition) {
                  'Good' => successGreen,
                  'Minor damage' => Colors.orange,
                  'Lost' => Colors.red,
                  _ => primaryBlue,
                };

                return ChoiceChip(
                  label: Text(condition),
                  selected: selected,
                  showCheckmark: true,
                  selectedColor: conditionColor.withValues(alpha: 0.15),
                  backgroundColor: const Color(0xFFF8FAFC),
                  side: BorderSide(
                    color: selected
                        ? conditionColor
                        : borderColor,
                  ),
                  labelStyle: TextStyle(
                    color: selected
                        ? conditionColor
                        : textMuted,
                    fontWeight: selected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
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

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: SizeTransition(
                  sizeFactor: animation,
                  child: child,
                ),
              );
            },
            child: record == null
                ? _infoBox(
                    key: const ValueKey('empty-return'),
                    background: const Color(0xFFF8FAFC),
                    children: const [
                      Text(
                        'Search by Student ID and book title '
                        'to display the borrowing details and any fine.',
                        style: TextStyle(
                          fontSize: 13,
                          color: textMuted,
                        ),
                      ),
                    ],
                  )
                : _infoBox(
                    key: ValueKey('return-${record.id}'),
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
          ),

          const SizedBox(height: 20),
          _actionButton(
            label: service.isProcessingReturn
                ? 'Processing...'
                : 'Confirm Return',
            icon: Icons.swap_horiz,
            color: successGreen,
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
    return _InteractiveDeskCard(child: child);
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
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 22),
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
                  color: textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: textMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Required fields show a red asterisk.
  Widget _label(
    String text, {
    bool isRequired = false,
  }) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: textDark,
        ),
        children: [
          TextSpan(text: text),
          if (isRequired)
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon,
  ) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFF94A3B8),
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icon,
        size: 18,
        color: textMuted,
      ),
      filled: true,
      fillColor: const Color(0xFFFAFCFF),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(
          color: primaryBlue,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget _infoBox({
    Key? key,
    required Color background,
    required List<Widget> children,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor),
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
                color: textMuted,
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
                color: textDark,
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
    bool outlined = false,
  }) {
    return _InteractiveDeskButton(
      label: label,
      icon: icon,
      color: color,
      onPressed: onPressed,
      outlined: outlined,
    );
  }
}

// ============================================================
// INTERACTIVE HOVER CARD
// ============================================================

class _InteractiveDeskCard extends StatefulWidget {
  final Widget child;

  const _InteractiveDeskCard({
    required this.child,
  });

  @override
  State<_InteractiveDeskCard> createState() =>
      _InteractiveDeskCardState();
}

class _InteractiveDeskCardState
    extends State<_InteractiveDeskCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        setState(() => _isHovered = true);
      },
      onExit: (_) {
        setState(() => _isHovered = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        transform: Matrix4.translationValues(
          0,
          _isHovered ? -5 : 0,
          0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? Colors.white
                : const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? Colors.black.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.03),
              blurRadius: _isHovered ? 10 : 8,
              offset: Offset(0, _isHovered ? 4 : 3),
            ),
          ],
        ),
        child: widget.child,
      ),
    );
  }
}

// ============================================================
// INTERACTIVE BUTTON WITH HOVER ANIMATION
// ============================================================

class _InteractiveDeskButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;
  final bool outlined;

  const _InteractiveDeskButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  State<_InteractiveDeskButton> createState() =>
      _InteractiveDeskButtonState();
}

class _InteractiveDeskButtonState
    extends State<_InteractiveDeskButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final disabled = widget.onPressed == null;

    return MouseRegion(
      onEnter: (_) {
        if (!disabled) {
          setState(() => _isHovered = true);
        }
      },
      onExit: (_) {
        setState(() => _isHovered = false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        transform: Matrix4.translationValues(
          0,
          _isHovered ? -2 : 0,
          0,
        ),
        width: double.infinity,
        child: widget.outlined
            ? OutlinedButton.icon(
                onPressed: widget.onPressed,
                icon: Icon(widget.icon, size: 18),
                label: Text(widget.label),
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.color,
                  side: BorderSide(
                    color: _isHovered
                        ? widget.color
                        : widget.color.withValues(alpha: 0.45),
                  ),
                  backgroundColor: _isHovered
                      ? widget.color.withValues(alpha: 0.06)
                      : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              )
            : ElevatedButton.icon(
                onPressed: widget.onPressed,
                icon: Icon(widget.icon, size: 18),
                label: Text(widget.label),
                style: ElevatedButton.styleFrom(
                  backgroundColor: widget.color,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                      widget.color.withValues(alpha: 0.5),
                  disabledForegroundColor: Colors.white,
                  elevation: _isHovered ? 5 : 1,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
              ),
      ),
    );
  }
}
