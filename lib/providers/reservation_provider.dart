import 'package:flutter/material.dart';
import '../models/reservation.dart';

class ReservationProvider extends ChangeNotifier {
  final List<Reservation> _reservations = [
    Reservation(
      id: 'RES-001',
      bookTitle: 'Clean Code',
      readerName: 'Abel Tesfaye',
      reservationDate: DateTime.now().subtract(
        const Duration(days: 1),
      ),
    ),
    Reservation(
      id: 'RES-002',
      bookTitle: 'Computer Networks',
      readerName: 'Sara Bekele',
      reservationDate: DateTime.now(),
      status: ReservationStatus.ready,
      expirationDate: DateTime.now().add(
        const Duration(days: 2),
      ),
    ),
  ];

  List<Reservation> get reservations =>
      List.unmodifiable(_reservations);

  int get pendingCount => _reservations
      .where((r) => r.status == ReservationStatus.pending)
      .length;

  int get readyCount => _reservations
      .where((r) => r.status == ReservationStatus.ready)
      .length;

  void addReservation({
    required String bookTitle,
    required String readerName,
  }) {
    final reservation = Reservation(
      id: 'RES-${DateTime.now().millisecondsSinceEpoch}',
      bookTitle: bookTitle.trim(),
      readerName: readerName.trim(),
      reservationDate: DateTime.now(),
    );

    _reservations.insert(0, reservation);
    notifyListeners();
  }

  void cancelReservation(String id) {
    final index = _reservations.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final current = _reservations[index];
    if (current.status == ReservationStatus.fulfilled ||
        current.status == ReservationStatus.cancelled) {
      return;
    }

    _reservations[index] = current.copyWith(
      status: ReservationStatus.cancelled,
    );
    notifyListeners();
  }

  void markReady(String id, {int validDays = 2}) {
    final index = _reservations.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final current = _reservations[index];
    if (current.status != ReservationStatus.pending) return;

    _reservations[index] = current.copyWith(
      status: ReservationStatus.ready,
      expirationDate: DateTime.now().add(Duration(days: validDays)),
    );
    notifyListeners();
  }

  void markFulfilled(String id) {
    final index = _reservations.indexWhere((r) => r.id == id);
    if (index == -1) return;

    final current = _reservations[index];
    if (current.status != ReservationStatus.ready) return;

    _reservations[index] = current.copyWith(
      status: ReservationStatus.fulfilled,
    );
    notifyListeners();
  }
}