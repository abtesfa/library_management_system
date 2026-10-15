import 'package:flutter/material.dart';
import '../../models/reservation.dart';
import '../../providers/reservation_provider.dart';

class ReservationManagementScreen extends StatefulWidget {
  const ReservationManagementScreen({super.key});

  @override
  State<ReservationManagementScreen> createState() =>
      _ReservationManagementScreenState();
}

class _ReservationManagementScreenState
    extends State<ReservationManagementScreen> {
  late final ReservationProvider _provider;
  final TextEditingController _searchController = TextEditingController();
  String _filter = 'All';

  @override
  void initState() {
    super.initState();
    _provider = ReservationProvider();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _provider.dispose();
    super.dispose();
  }

  Future<void> _showAddDialog() async {
    final formKey = GlobalKey<FormState>();
    final bookController = TextEditingController();
    final readerController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add reservation'),
        content: Form(
          key: formKey,
          child: SizedBox(
            width: 380,
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
                const SizedBox(height: 14),
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
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(dialogContext, true);
              }
            },
            child: const Text('Add reservation'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _provider.addReservation(
        bookTitle: bookController.text,
        readerName: readerController.text,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reservation added')),
      );
    }

    bookController.dispose();
    readerController.dispose();
  }

  String _statusText(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return 'Pending';
      case ReservationStatus.ready:
        return 'Ready for pickup';
      case ReservationStatus.cancelled:
        return 'Cancelled';
      case ReservationStatus.fulfilled:
        return 'Completed';
    }
  }

  Color _statusColor(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return Colors.orange;
      case ReservationStatus.ready:
        return Colors.green;
      case ReservationStatus.cancelled:
        return Colors.red;
      case ReservationStatus.fulfilled:
        return Colors.blue;
    }
  }

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _provider,
      builder: (context, _) {
        final query = _searchController.text.toLowerCase().trim();

        final reservations = _provider.reservations.where((r) {
          final matchesSearch = r.bookTitle.toLowerCase().contains(query) ||
              r.readerName.toLowerCase().contains(query) ||
              r.id.toLowerCase().contains(query);

          final matchesFilter = _filter == 'All' ||
              _statusText(r.status) == _filter;

          return matchesSearch && matchesFilter;
        }).toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FB),
          body: SafeArea(
            child: Padding(
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
                              'Reservation Management',
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF172B4D),
                              ),
                            ),
                            SizedBox(height: 6),
                            Text(
                              'Manage book reservations and pickup status.',
                              style: TextStyle(color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      ),
                      FilledButton.icon(
                        onPressed: _showAddDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('New reservation'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 12,
                    children: [
                      _summaryCard(
                        'Total reservations',
                        '${_provider.reservations.length}',
                        Icons.bookmark_outline,
                        const Color(0xFF0052CC),
                      ),
                      _summaryCard(
                        'Pending',
                        '${_provider.pendingCount}',
                        Icons.hourglass_empty,
                        Colors.orange,
                      ),
                      _summaryCard(
                        'Ready for pickup',
                        '${_provider.readyCount}',
                        Icons.check_circle_outline,
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search book, reader, or reservation ID',
                            prefixIcon: const Icon(Icons.search),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 190,
                        child: DropdownButtonFormField<String>(
                          initialValue: _filter,
                          decoration: const InputDecoration(
                            labelText: 'Status',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'All',
                              child: Text('All statuses'),
                            ),
                            DropdownMenuItem(
                              value: 'Pending',
                              child: Text('Pending'),
                            ),
                            DropdownMenuItem(
                              value: 'Ready for pickup',
                              child: Text('Ready for pickup'),
                            ),
                            DropdownMenuItem(
                              value: 'Cancelled',
                              child: Text('Cancelled'),
                            ),
                            DropdownMenuItem(
                              value: 'Completed',
                              child: Text('Completed'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _filter = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: Card(
                      elevation: 0,
                      clipBehavior: Clip.antiAlias,
                      child: reservations.isEmpty
                          ? const Center(
                              child: Text('No reservations found.'),
                            )
                          : SingleChildScrollView(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columns: const [
                                    DataColumn(label: Text('Reservation ID')),
                                    DataColumn(label: Text('Book')),
                                    DataColumn(label: Text('Reader')),
                                    DataColumn(label: Text('Date')),
                                    DataColumn(label: Text('Status')),
                                    DataColumn(label: Text('Actions')),
                                  ],
                                  rows: reservations.map((r) {
                                    final active =
                                        r.status == ReservationStatus.pending ||
                                        r.status == ReservationStatus.ready;

                                    return DataRow(
                                      cells: [
                                        DataCell(Text(r.id)),
                                        DataCell(Text(r.bookTitle)),
                                        DataCell(Text(r.readerName)),
                                        DataCell(Text(_date(r.reservationDate))),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _statusColor(r.status)
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              _statusText(r.status),
                                              style: TextStyle(
                                                color: _statusColor(r.status),
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (r.status ==
                                                  ReservationStatus.pending)
                                                IconButton(
                                                  tooltip: 'Mark ready',
                                                  onPressed: () =>
                                                      _provider.markReady(r.id),
                                                  icon: const Icon(
                                                    Icons.check_circle_outline,
                                                    color: Colors.green,
                                                  ),
                                                ),
                                              if (r.status ==
                                                  ReservationStatus.ready)
                                                IconButton(
                                                  tooltip: 'Complete pickup',
                                                  onPressed: () =>
                                                      _provider.markFulfilled(r.id),
                                                  icon: const Icon(
                                                    Icons.done_all,
                                                    color: Colors.blue,
                                                  ),
                                                ),
                                              if (active)
                                                IconButton(
                                                  tooltip: 'Cancel reservation',
                                                  onPressed: () =>
                                                      _confirmCancel(r),
                                                  icon: const Icon(
                                                    Icons.cancel_outlined,
                                                    color: Colors.red,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return SizedBox(
      width: 220,
      child: Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.12),
                foregroundColor: color,
                child: Icon(icon),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 5),
                    Text(
                      value,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
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

  Future<void> _confirmCancel(Reservation reservation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel reservation?'),
        content: Text(
          'Cancel the reservation for "${reservation.bookTitle}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep reservation'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Cancel reservation'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      _provider.cancelReservation(reservation.id);
    }
  }
}