import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/entities/reservation_record.dart';
import '../../../library/presentation/providers/library_service.dart';
import '../../../../core/di/injector.dart';
import '../../domain/usecases/get_reservations.dart';
import '../../domain/usecases/cancel_reservation.dart';

class ReaderReservationsScreen extends StatefulWidget {
  const ReaderReservationsScreen({super.key});

  @override
  State<ReaderReservationsScreen> createState() =>
      _ReaderReservationsScreenState();
}

class _ReaderReservationsScreenState extends State<ReaderReservationsScreen> {
  final GetReservations _getReservationsUseCase = injector.getReservations;

  final CancelReservation _cancelReservationUseCase =
      injector.cancelReservation;

  // Temporary student ID.
  // Later, use the logged-in student's ID.
  final String _studentId = '1';

  List<ReservationRecord> _reservations = [];

  bool _isLoading = true;
  String? _errorMessage;
  String? _cancellingReservationId;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  // ---------------------------------------------------------
  // CONVERT BACKEND STATUS INTO DISPLAY STATUS
  // ---------------------------------------------------------

  String _displayStatus(String status) {
    switch (status.toUpperCase()) {
      case 'WAITING':
        return 'In Queue';

      case 'READY_FOR_PICKUP':
        return 'Ready for Pickup';

      case 'COMPLETED':
        return 'Completed';

      case 'CANCELLED':
        return 'Cancelled';

      case 'EXPIRED':
        return 'Expired';

      default:
        return status;
    }
  }

  String _formatPickupDeadline(String? value) {
    if (value == null) return 'Not assigned';
    final deadline = DateTime.tryParse(value)?.toLocal();
    if (deadline == null) return value;
    return '${deadline.year}-${deadline.month.toString().padLeft(2, '0')}-'
        '${deadline.day.toString().padLeft(2, '0')} at '
        '${deadline.hour.toString().padLeft(2, '0')}:'
        '${deadline.minute.toString().padLeft(2, '0')}';
  }

  String _pickupTimeRemainingText(ReservationRecord reservation) {
    final reservedAt = DateTime.tryParse(reservation.reservedDate);
    final holdUntil = reservation.holdUntil == null
        ? null
        : DateTime.tryParse(reservation.holdUntil!);
    if (reservedAt == null || holdUntil == null) {
      return 'Pick up by: ${_formatPickupDeadline(reservation.holdUntil)}';
    }

    final minutes = holdUntil.difference(reservedAt).inMinutes;
    final duration = minutes % 1440 == 0
        ? '${minutes ~/ 1440} ${minutes ~/ 1440 == 1 ? 'day' : 'days'}'
        : minutes % 60 == 0
            ? '${minutes ~/ 60} ${minutes ~/ 60 == 1 ? 'hour' : 'hours'}'
            : '$minutes ${minutes == 1 ? 'minute' : 'minutes'}';
    return 'You have $duration to pick it up (by '
        '${_formatPickupDeadline(reservation.holdUntil)})';
  }

  // ---------------------------------------------------------
  // CHECK WHETHER RESERVATION CAN BE CANCELLED
  // ---------------------------------------------------------

  bool _canCancel(String status) {
    final normalizedStatus = status.toUpperCase();

    return normalizedStatus == 'WAITING' ||
        normalizedStatus == 'READY_FOR_PICKUP';
  }

  // ---------------------------------------------------------
  // LOAD RESERVATIONS FROM SPRING BOOT
  // ---------------------------------------------------------

  Future<void> _loadReservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final reservations = await _getReservationsUseCase(_studentId);

      if (!mounted) return;

      setState(() {
        _reservations = reservations;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // ---------------------------------------------------------
  // CANCEL RESERVATION
  // ---------------------------------------------------------

  Future<void> _cancelReservation(ReservationRecord r) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Reservation?'),
          content: Text(
            'Are you sure you want to cancel your reservation '
            'for "${r.bookTitle}"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep Reservation'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Cancel Hold',
                style: TextStyle(color: Color(0xFFDC2626)),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() {
      _cancellingReservationId = r.id;
    });

    try {
      await _cancelReservationUseCase(
        _studentId,
        r.id,
      );

      if (!mounted) return;

      setState(() {
        _reservations.removeWhere(
          (item) => item.id == r.id,
        );
        _cancellingReservationId = null;
      });

      // The held copy is available again, so refresh the book lists.
      context.read<LibraryService>().loadBooksFromApi();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Reservation for "${r.bookTitle}" cancelled successfully.',
          ),
          backgroundColor: const Color(0xFF059669),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _cancellingReservationId = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not cancel reservation: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ---------------------------------------------------------
  // MAIN BUILD
  // ---------------------------------------------------------

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
                  color: const Color(0xFFFBE2D9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  color: Color(0xFFF25635),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Book Reservations',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF171717),
                      ),
                    ),
                    Text(
                      'Manage active book holds, queue rankings, and pickup notifications',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _isLoading ? null : _loadReservations,
                tooltip: 'Refresh reservations',
                icon: const Icon(
                  Icons.refresh,
                  color: Color(0xFFF25635),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Loading state
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(
                  color: Color(0xFFF25635),
                ),
              ),
            )

          // Error state
          else if (_errorMessage != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFCA5A5),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 40,
                    color: Color(0xFFDC2626),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Unable to load reservations',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF171717),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadReservations,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF25635),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )

          // Empty state
          else if (_reservations.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(36),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFD9D9D9),
                ),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 40,
                    color: Color(0xFFAAA898),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No active reservations right now.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
            )

          // Reservation cards
          else
            ..._reservations.map(
              (r) => _buildReservationCard(r),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------
  // RESERVATION CARD (with hover animation)
  // ---------------------------------------------------------

  Widget _buildReservationCard(ReservationRecord r) {
    final isCancelling = _cancellingReservationId == r.id;

    final canCancel = _canCancel(r.status);
    final displayStatus = _displayStatus(r.status);

    // The bottom spacing is outside the hover widget so the
    // blue border only wraps the card itself.
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: _HoverLift(
        radius: 16,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFD9D9D9),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF059669),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          r.bookTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF171717),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            displayStatus,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF059669),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Author: ${r.author} · Reserved On: ${r.reservedDate}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (r.pickupLocation != null)
                      Text(
                        'Pickup Location: ${r.pickupLocation} · '
                        '${_pickupTimeRemainingText(r)}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF25635),
                        ),
                      )
                    else if (r.status.toUpperCase() == 'EXPIRED')
                      const Text(
                        'Expired: the pickup deadline has passed.',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFDC2626),
                        ),
                      ),
                    if (r.queuePosition > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Queue Position: ${r.queuePosition}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (canCancel)
                OutlinedButton(
                  onPressed: isCancelling ? null : () => _cancelReservation(r),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFDC2626),
                    side: const BorderSide(
                      color: Color(0xFFFCA5A5),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: isCancelling
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Cancel Hold'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// =============================================================
// HOVER ANIMATION (lift + shadow + blue border)
// Used by the reservation cards.
// =============================================================

class _HoverLift extends StatefulWidget {
  final Widget child;
  final double radius;

  const _HoverLift({
    required this.child,
    this.radius = 14,
  });

  @override
  State<_HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<_HoverLift> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: Matrix4.translationValues(
          0,
          _isHovered ? -4 : 0,
          0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ]
              : const [],
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.radius),
          border: Border.all(
            color: _isHovered ? Colors.white : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
