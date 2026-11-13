import '../../features/books/data/datasources/book_remote_data_source.dart';
import '../../features/books/data/datasources/google_books_remote_data_source.dart';
import '../../features/books/data/repositories/book_repository_impl.dart';
import '../../features/books/domain/repositories/book_repository.dart';
import '../../features/books/domain/usecases/create_book.dart';
import '../../features/books/domain/usecases/find_book.dart';
import '../../features/books/domain/usecases/get_all_books.dart';
import '../../features/books/domain/usecases/get_available_books.dart';
import '../../features/books/domain/usecases/get_categories.dart';
import '../../features/books/domain/usecases/lookup_book_by_isbn.dart';
import '../../features/borrowing/data/datasources/borrowing_remote_data_source.dart';
import '../../features/borrowing/data/repositories/borrowing_repository_impl.dart';
import '../../features/borrowing/domain/repositories/borrowing_repository.dart';
import '../../features/borrowing/domain/usecases/borrow_book.dart';
import '../../features/borrowing/domain/usecases/calculate_fine.dart';
import '../../features/borrowing/domain/usecases/calculate_overdue_days.dart';
import '../../features/borrowing/domain/usecases/find_active_borrowing.dart';
import '../../features/borrowing/domain/usecases/get_my_books.dart';
import '../../features/borrowing/domain/usecases/renew_book.dart';
import '../../features/borrowing/domain/usecases/return_book.dart';
import '../../features/dashboard/data/datasources/student_dashboard_remote_data_source.dart';
import '../../features/dashboard/data/repositories/student_dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/student_dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_student_dashboard.dart';
import '../../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/get_notifications.dart';
import '../../features/notifications/domain/usecases/mark_notification_as_read.dart';
import '../../features/reservations/data/datasources/reservation_remote_data_source.dart';
import '../../features/reservations/data/repositories/reservation_repository_impl.dart';
import '../../features/reservations/domain/repositories/reservation_repository.dart';
import '../../features/reservations/domain/usecases/cancel_reservation.dart';
import '../../features/reservations/domain/usecases/create_reservation.dart';
import '../../features/reservations/domain/usecases/get_reservations.dart';
import '../../features/settings/data/datasources/settings_remote_data_source.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_settings.dart';
import '../../features/settings/domain/usecases/get_system_settings.dart';
import '../../features/settings/domain/usecases/update_settings.dart';
import '../../features/staff/data/datasources/staff_remote_data_source.dart';
import '../../features/staff/data/repositories/staff_repository_impl.dart';
import '../../features/staff/domain/repositories/staff_repository.dart';
import '../../features/staff/domain/usecases/add_staff.dart';
import '../../features/staff/domain/usecases/get_all_staff.dart';
import '../../features/staff/domain/usecases/update_staff.dart';
import '../../features/staff/domain/usecases/update_staff_status.dart';

/// Wires data sources -> repositories -> use cases.
///
/// Everything is created lazily the first time it is used. Presentation code
/// only asks for use cases (`injector.getAllBooks`, ...) and never sees the
/// data layer.
class Injector {
  Injector._();

  // ---------------------------------------------------------------------------
  // Data sources
  // ---------------------------------------------------------------------------
  late final BookRemoteDataSource _bookRemote = BookRemoteDataSource();
  late final GoogleBooksRemoteDataSource _googleBooksRemote =
      GoogleBooksRemoteDataSource();
  late final BorrowingRemoteDataSource _borrowingRemote =
      BorrowingRemoteDataSource();
  late final ReservationRemoteDataSource _reservationRemote =
      ReservationRemoteDataSource();
  late final StaffRemoteDataSource _staffRemote = StaffRemoteDataSource();
  late final SettingsRemoteDataSource _settingsRemote =
      SettingsRemoteDataSource();
  late final NotificationRemoteDataSource _notificationRemote =
      NotificationRemoteDataSource();
  late final StudentDashboardRemoteDataSource _dashboardRemote =
      StudentDashboardRemoteDataSource();

  // ---------------------------------------------------------------------------
  // Repositories
  // ---------------------------------------------------------------------------
  late final BookRepository _bookRepository =
      BookRepositoryImpl(_bookRemote, _googleBooksRemote);
  late final BorrowingRepository _borrowingRepository =
      BorrowingRepositoryImpl(_borrowingRemote);
  late final ReservationRepository _reservationRepository =
      ReservationRepositoryImpl(_reservationRemote);
  late final StaffRepository _staffRepository =
      StaffRepositoryImpl(_staffRemote);
  late final SettingsRepository _settingsRepository =
      SettingsRepositoryImpl(_settingsRemote);
  late final NotificationRepository _notificationRepository =
      NotificationRepositoryImpl(_notificationRemote);
  late final StudentDashboardRepository _dashboardRepository =
      StudentDashboardRepositoryImpl(_dashboardRemote);

  // ---------------------------------------------------------------------------
  // Use cases: books
  // ---------------------------------------------------------------------------
  late final GetAllBooks getAllBooks = GetAllBooks(_bookRepository);
  late final GetAvailableBooks getAvailableBooks =
      GetAvailableBooks(_bookRepository);
  late final CreateBook createBook = CreateBook(_bookRepository);
  late final GetCategories getCategories = GetCategories(_bookRepository);
  late final LookupBookByIsbn lookupBookByIsbn =
      LookupBookByIsbn(_bookRepository);
  final FindBook findBook = const FindBook();

  // ---------------------------------------------------------------------------
  // Use cases: borrowing
  // ---------------------------------------------------------------------------
  late final BorrowBook borrowBook = BorrowBook(_borrowingRepository);
  late final FindActiveBorrowing findActiveBorrowing =
      FindActiveBorrowing(_borrowingRepository);
  late final ReturnBook returnBook = ReturnBook(_borrowingRepository);
  late final GetMyBooks getMyBooks = GetMyBooks(_borrowingRepository);
  late final RenewBook renewBook = RenewBook(_borrowingRepository);
  final CalculateOverdueDays calculateOverdueDays =
      const CalculateOverdueDays();
  late final CalculateFine calculateFine = CalculateFine(calculateOverdueDays);

  // ---------------------------------------------------------------------------
  // Use cases: reservations
  // ---------------------------------------------------------------------------
  late final CreateReservation createReservation =
      CreateReservation(_reservationRepository);
  late final GetReservations getReservations =
      GetReservations(_reservationRepository);
  late final CancelReservation cancelReservation =
      CancelReservation(_reservationRepository);

  // ---------------------------------------------------------------------------
  // Use cases: staff
  // ---------------------------------------------------------------------------
  late final GetAllStaff getAllStaff = GetAllStaff(_staffRepository);
  late final AddStaff addStaff = AddStaff(_staffRepository);
  late final UpdateStaff updateStaff = UpdateStaff(_staffRepository);
  late final UpdateStaffStatus updateStaffStatus =
      UpdateStaffStatus(_staffRepository);

  // ---------------------------------------------------------------------------
  // Use cases: settings
  // ---------------------------------------------------------------------------
  late final GetSettings getSettings = GetSettings(_settingsRepository);
  late final GetSystemSettings getSystemSettings =
      GetSystemSettings(_settingsRepository);
  late final UpdateSettings updateSettings =
      UpdateSettings(_settingsRepository);

  // ---------------------------------------------------------------------------
  // Use cases: notifications
  // ---------------------------------------------------------------------------
  late final GetNotifications getNotifications =
      GetNotifications(_notificationRepository);
  late final MarkNotificationAsRead markNotificationAsRead =
      MarkNotificationAsRead(_notificationRepository);

  // ---------------------------------------------------------------------------
  // Use cases: student dashboard
  // ---------------------------------------------------------------------------
  late final GetStudentDashboard getStudentDashboard =
      GetStudentDashboard(_dashboardRepository);
}

/// App-wide access point for use cases.
final Injector injector = Injector._();
