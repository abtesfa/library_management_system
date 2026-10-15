import 'package:flutter/material.dart';

import '../models/reservation.dart';

class ReservationProvider extends ChangeNotifier {
  // Active queue hold
  final Reservation _activeReservation = const Reservation(
    id: 'r1',
    bookTitle: 'The Great Gatsby',
    author: 'F. Scott Fitzgerald',
    category: 'Fiction',
    isbn: '978-0743273567',
    reservedDate: 'May 15, 2026',
    pickupByDate: 'May 29, 2026',
    pickupLocation: 'Central Library',
    countdownText: 'Expires in 10 days',
    status: ReservationStatus.active,
  );

  // Ready for pickup hold
  final Reservation _readyForPickup = const Reservation(
    id: 'r2',
    bookTitle: 'Atomic Habits',
    author: 'James Clear',
    category: 'Self-Help',
    isbn: '978-0735211292',
    reservedDate: 'May 12, 2026',
    pickupByDate: 'May 26, 2026',
    pickupLocation: 'Central Library',
    countdownText: 'Ready for 3 days',
    status: ReservationStatus.readyForPickup,
  );

  // Reservation history entries
  final List<Reservation> _history = [
    const Reservation(
      id: 'h1',
      bookTitle: 'Dune',
      author: 'Frank Herbert',
      category: 'Science Fiction',
      isbn: '978-0441013593',
      reservedDate: 'Apr 20, 2026',
      pickupByDate: 'Apr 27, 2026',
      pickupLocation: 'Central Library',
      countdownText: '',
      status: ReservationStatus.completed,
      completedDate: 'Apr 27, 2026',
    ),
    const Reservation(
      id: 'h2',
      bookTitle: 'Clean Code',
      author: 'Robert C. Martin',
      category: 'Computer Science',
      isbn: '978-0132350884',
      reservedDate: 'Apr 10, 2026',
      pickupByDate: 'Apr 17, 2026',
      pickupLocation: 'Central Library',
      countdownText: '',
      status: ReservationStatus.completed,
      completedDate: 'Apr 17, 2026',
    ),
    const Reservation(
      id: 'h3',
      bookTitle: 'Sapiens',
      author: 'Yuval Noah Harari',
      category: 'History',
      isbn: '978-0062316097',
      reservedDate: 'Mar 25, 2026',
      pickupByDate: 'Apr 2, 2026',
      pickupLocation: 'Central Library',
      countdownText: '',
      status: ReservationStatus.completed,
      completedDate: 'Apr 2, 2026',
    ),
    const Reservation(
      id: 'h4',
      bookTitle: '1984',
      author: 'George Orwell',
      category: 'Dystopian',
      isbn: '978-0451524935',
      reservedDate: 'Mar 10, 2026',
      pickupByDate: 'Mar 17, 2026',
      pickupLocation: 'Central Library',
      countdownText: '',
      status: ReservationStatus.completed,
      completedDate: 'Mar 17, 2026',
    ),
    const Reservation(
      id: 'h5',
      bookTitle: 'Thinking, Fast and Slow',
      author: 'Daniel Kahneman',
      category: 'Psychology',
      isbn: '978-0374533557',
      reservedDate: 'Feb 20, 2026',
      pickupByDate: 'Feb 28, 2026',
      pickupLocation: 'Central Library',
      countdownText: '',
      status: ReservationStatus.completed,
      completedDate: 'Feb 28, 2026',
    ),
  ];

  Reservation get activeReservation => _activeReservation;
  Reservation get readyForPickup => _readyForPickup;
  List<Reservation> get history => _history;

  int get activeCount => 1;
  int get readyCount => 1;
  int get upcomingCount => 0;
  int get completedCount => 5;

  void cancelReservation(String id) {
    // Will be wired to DELETE /api/v1/reservations/{id}
    notifyListeners();
  }

  void markAsPickedUp(String id) {
    // Will be wired to Spring Boot checkout endpoint
    notifyListeners();
  }
}
