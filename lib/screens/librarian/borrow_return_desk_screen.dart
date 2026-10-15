
import 'package:flutter/material.dart';

import '../../models/borrow_record.dart';
import '../../providers/circulation_provider.dart';

class BorrowReturnDeskScreen extends StatefulWidget {
  const BorrowReturnDeskScreen({super.key});

  @override
  State<BorrowReturnDeskScreen> createState() =>
      _BorrowReturnDeskScreenState();
}

class _BorrowReturnDeskScreenState
    extends State<BorrowReturnDeskScreen> {
  final CirculationProvider _provider = CirculationProvider();
  final TextEditingController _searchController =
      TextEditingController();

  String _search = '';

  @override
  void dispose() {
    _provider.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _issueBook() async {
    final bookController = TextEditingController();
    final readerController = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 14));

    final formKey = GlobalKey<FormState>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Issue a book'),
          content: SizedBox(
            width: 420,
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: bookController,
                    decoration: const InputDecoration(
                      labelText: 'Book title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Enter a book title'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: readerController,
                    decoration: const InputDecoration(
                      labelText: 'Reader name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.trim().isEmpty
                            ? 'Enter a reader name'
                            : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Expanded(child: Text('Due date')),
                      Text(
                        '${dueDate.day}/${dueDate.month}/${dueDate.year}',
                      ),
                      IconButton(
                        tooltip: 'Choose due date',
                        icon: const Icon(Icons.calendar_month),
                        onPressed: () async {
                          final selected = await showDatePicker(
                            context: context,
                            initialDate: dueDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(
                              const Duration(days: 365),
                            ),
                          );

                          if (selected != null) {
                            setDialogState(() => dueDate = selected);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  Navigator.pop(dialogContext, true);
                }
              },
              child: const Text('Issue book'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _provider.issueBook(
          bookTitle: bookController.text,
          readerName: readerController.text,
          dueDate: dueDate,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book issued successfully')),
      );
    }

    bookController.dispose();
    readerController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecords = _provider.records.where((record) {
      final query = _search.toLowerCase();

      return record.bookTitle.toLowerCase().contains(query) ||
          record.readerName.toLowerCase().contains(query) ||
          record.id.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _statCard('Active loans', _provider.activeCount,
                    Icons.menu_book, const Color(0xFF0052CC)),
                _statCard('Overdue', _provider.overdueCount,
                    Icons.warning_amber, Colors.red),
                _statCard('Returned', _provider.returnedCount,
                    Icons.assignment_turned_in, Colors.green),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search books, readers, or loan ID...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onChanged: (value) =>
                        setState(() => _search = value),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _issueBook,
                  icon: const Icon(Icons.add),
                  label: const Text('Issue book'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                clipBehavior: Clip.antiAlias,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Loan ID')),
                      DataColumn(label: Text('Book')),
                      DataColumn(label: Text('Reader')),
                      DataColumn(label: Text('Borrowed')),
                      DataColumn(label: Text('Due date')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: filteredRecords.map((record) {
                      return DataRow(
                        cells: [
                          DataCell(Text(record.id)),
                          DataCell(Text(record.bookTitle)),
                          DataCell(Text(record.readerName)),
                          DataCell(Text(_formatDate(record.borrowDate))),
                          DataCell(Text(_formatDate(record.dueDate))),
                          DataCell(_statusBadge(record.status)),
                          DataCell(
                            record.returnDate == null
                                ? TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _provider.returnBook(record.id);
                                      });
                                    },
                                    child: const Text('Return'),
                                  )
                                : const Text('Completed'),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    String title,
    int value,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      width: 210,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 6),
                  Text(
                    '$value',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(BorrowStatus status) {
    final color = switch (status) {
      BorrowStatus.borrowed => Colors.blue,
      BorrowStatus.returned => Colors.green,
      BorrowStatus.overdue => Colors.red,
    };

    final label = switch (status) {
      BorrowStatus.borrowed => 'Borrowed',
      BorrowStatus.returned => 'Returned',
      BorrowStatus.overdue => 'Overdue',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}
