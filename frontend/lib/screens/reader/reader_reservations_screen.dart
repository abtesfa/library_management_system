import 'package:flutter/material.dart';
import '../../data/mock_library_data.dart';
import '../../models/borrow_record.dart';

class ReaderReservationsScreen extends StatefulWidget {
  const ReaderReservationsScreen({super.key});

  @override
  State<ReaderReservationsScreen> createState() => _ReaderReservationsScreenState();
}

class _ReaderReservationsScreenState extends State<ReaderReservationsScreen> {
  late List<ReservationRecord> _reservations;

  @override
  void initState() {
    super.initState();
    _reservations = MockLibraryData.getReaderReservations();
  }

  void _cancelReservation(ReservationRecord r) {
    setState(() {
      _reservations.removeWhere((item) => item.id == r.id);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reservation for "${r.bookTitle}" cancelled.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.calendar_month_outlined, color: Color(0xFF0052CC), size: 24),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Book Reservations',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    'Manage active book holds, queue rankings, and pickup notifications',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (_reservations.isEmpty)
            Container(
              padding: const EdgeInsets.all(36),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.inbox_outlined, size: 40, color: Color(0xFF94A3B8)),
                  SizedBox(height: 10),
                  Text('No active reservations right now.', style: TextStyle(fontSize: 14, color: Color(0xFF64748B))),
                ],
              ),
            )
          else
            ..._reservations.map((r) => _buildReservationCard(r)),
        ],
      ),
    );
  }

  Widget _buildReservationCard(ReservationRecord r) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.check_circle_outline, color: Color(0xFF059669), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      r.bookTitle,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        r.status,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Author: ${r.author} · Reserved On: ${r.reservedDate}',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pickup Location: ${r.pickupLocation} (Hold until: ${r.holdUntil})',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF0052CC)),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () => _cancelReservation(r),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFDC2626),
              side: const BorderSide(color: Color(0xFFFCA5A5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Cancel Hold'),
          ),
        ],
      ),
    );
  }
}
