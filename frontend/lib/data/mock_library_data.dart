import '../models/book.dart';
import '../models/borrow_record.dart';
import '../models/staff.dart';

class MockLibraryData {
  static List<Book> getInitialBooks() {
    return [
      Book(
        id: 'b-1',
        title: 'Clean Code: A Handbook of Agile Software Craftsmanship',
        author: 'Robert C. Martin',
        isbn: '978-0132350884',
        category: 'Programming',
        totalCopies: 8,
        availableCopies: 5,
        status: 'Available',
        location: 'Shelf D1-04',
        coverTheme: 'cleancode',
      ),
      Book(
        id: 'b-2',
        title: 'Atomic Habits',
        author: 'James Clear',
        isbn: '978-0735211292',
        category: 'Self Improvement',
        totalCopies: 12,
        availableCopies: 3,
        status: 'Available',
        location: 'Shelf A1-12',
        coverTheme: 'atomic-habits',
      ),
      Book(
        id: 'b-3',
        title: 'The Martian',
        author: 'Andy Weir',
        isbn: '978-0553418026',
        category: 'Science Fiction',
        totalCopies: 6,
        availableCopies: 0,
        status: 'Borrowed',
        location: 'Shelf B2-01',
        coverTheme: 'the-martian',
      ),
      Book(
        id: 'b-4',
        title: 'Design Patterns: Elements of Reusable Object-Oriented Software',
        author: 'Erich Gamma, Richard Helm',
        isbn: '978-0201633610',
        category: 'Programming',
        totalCopies: 5,
        availableCopies: 2,
        status: 'Available',
        location: 'Shelf D2-11',
        coverTheme: 'design-patterns',
      ),
      Book(
        id: 'b-5',
        title: 'Think Like a Monk',
        author: 'Jay Shetty',
        isbn: '978-1982134488',
        category: 'Psychology',
        totalCopies: 7,
        availableCopies: 4,
        status: 'Available',
        location: 'Shelf C1-03',
        coverTheme: 'think-like-a-monk',
      ),
      Book(
        id: 'b-6',
        title: 'Dune',
        author: 'Frank Herbert',
        isbn: '978-0441172719',
        category: 'Science Fiction',
        totalCopies: 10,
        availableCopies: 6,
        status: 'Available',
        location: 'Shelf B1-09',
        coverTheme: 'dune',
      ),
      Book(
        id: 'b-7',
        title: 'Sapiens: A Brief History of Humankind',
        author: 'Yuval Noah Harari',
        isbn: '978-0062316097',
        category: 'History',
        totalCopies: 9,
        availableCopies: 4,
        status: 'Available',
        location: 'Shelf E2-05',
        coverTheme: 'sapiens',
      ),
    ];
  }

  static List<StaffMember> getInitialStaff() {
    return [
      StaffMember(
        id: 's-1',
        name: 'System Admin',
        employeeId: 'EMP-001',
        role: 'Administrator',
        email: 'admin@library.com',
        status: 'Active',
        canAddBooks: true,
        canWaiveFines: true,
        canManageStaff: true,
      ),
      StaffMember(
        id: 's-2',
        name: 'Ms. Sara Ahmed',
        employeeId: 'EMP-002',
        role: 'Chief Circulation Librarian',
        email: 'librarian@library.com',
        status: 'Active',
        canAddBooks: true,
        canWaiveFines: true,
        canManageStaff: false,
      ),
      StaffMember(
        id: 's-3',
        name: 'Daniel Teshome',
        employeeId: 'EMP-003',
        role: 'Cataloging Specialist',
        email: 'daniel@library.com',
        status: 'Active',
        canAddBooks: true,
        canWaiveFines: false,
        canManageStaff: false,
      ),
    ];
  }

  static List<BorrowRecord> getReaderBorrowedBooks() {
    return [
      BorrowRecord(
        id: 'rec-101',
        studentId: 'STU-9901',
        studentName: 'Abiye Tesfaye',
        bookId: 'b-1',
        bookTitle: 'Clean Code: A Handbook of Agile Software Craftsmanship',
        isbn: '978-0132350884',
        borrowDate: 'Oct 02, 2026',
        dueDate: 'Oct 26, 2026',
        status: 'Active',
        daysLeft: 9,
        fineAmount: 0.0,
      ),
      BorrowRecord(
        id: 'rec-102',
        studentId: 'STU-9901',
        studentName: 'Abiye Tesfaye',
        bookId: 'b-2',
        bookTitle: 'Atomic Habits',
        isbn: '978-0735211292',
        borrowDate: 'Sep 25, 2026',
        dueDate: 'Oct 19, 2026',
        status: 'Active',
        daysLeft: 2,
        fineAmount: 0.0,
      ),
    ];
  }

  static List<ReservationRecord> getReaderReservations() {
    return [
      ReservationRecord(
        id: 'res-1',
        bookId: 'b-3',
        bookTitle: 'The Martian',
        author: 'Andy Weir',
        reservedDate: 'Oct 10, 2026',
        holdUntil: 'Oct 22, 2026',
        pickupLocation: 'Main Desk Shelf B',
        status: 'Ready for Pickup',
        queuePosition: 1,
      ),
    ];
  }
}
