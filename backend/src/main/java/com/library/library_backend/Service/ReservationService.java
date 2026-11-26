package com.library.library_backend.Service;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

import org.springframework.http.HttpStatus;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import com.library.library_backend.dto.ReservationResponse;
import com.library.library_backend.entity.Reservation;
import com.library.library_backend.entity.Student;
import com.library.library_backend.entity.book;
import com.library.library_backend.repository.BookCopyRepository;
import com.library.library_backend.repository.BookRepository;
import com.library.library_backend.repository.ReservationRepository;
import com.library.library_backend.repository.StudentRepository;

@Service
public class ReservationService {

    private final ReservationRepository reservationRepository;
    private final NotificationService notificationService;
    private final StudentRepository studentRepository;
    private final BookRepository bookRepository;
    private final BookCopyRepository bookCopyRepository;
    private final LibrarySettingsService librarySettingsService;

    public ReservationService(
            ReservationRepository reservationRepository,
            NotificationService notificationService,
            StudentRepository studentRepository,
            BookRepository bookRepository,
            BookCopyRepository bookCopyRepository,
            LibrarySettingsService librarySettingsService) {

        this.reservationRepository = reservationRepository;
        this.notificationService = notificationService;
        this.studentRepository = studentRepository;
        this.bookRepository = bookRepository;
        this.bookCopyRepository = bookCopyRepository;
        this.librarySettingsService = librarySettingsService;
    }

    // --------------------------------------------------
    // CREATE RESERVATION AND NOTIFY LIBRARIAN
    // --------------------------------------------------

    @Transactional
    public Reservation createReservation(Integer userId, Integer bookId) {
        expireOverdueReservations();
        if (userId == null || userId <= 0 || bookId == null || bookId <= 0) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Valid student and book IDs are required.");
        }
        Student student = studentRepository.findByIdForUpdate(userId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Student not found"));
        if (!"ACTIVE".equalsIgnoreCase(student.getStatus())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "This student account is not active.");
        }
        book selectedBook = bookRepository.findByIdForUpdate(bookId).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Book not found"));
        if (reservationRepository.countActiveReservation(userId, bookId) > 0) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "You already have an active reservation for this book.");
        }
        int max = librarySettingsService.getSettings().getMaxBooksPerStudent();
        long loans = borrowingCount(userId);
        long reservations = reservationRepository.countActiveByUserId(userId);
        if (loans + reservations >= max) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Your borrowing capacity is full. Return a book or cancel an active reservation first.");
        }
        Reservation reservation = new Reservation();
        reservation.setUserId(userId);
        reservation.setBookId(bookId);
        reservation.setReservationDate(LocalDateTime.now());
        reservation.setQueuePosition(reservationRepository.getNextQueuePosition(bookId));
        reservation.setHoldUntil(null); // countdown starts only after a copy is allocated
        reservation.setPickupHoldMinutes(getReservationHoldMinutes());
        reservation.setStatus("WAITING");
        reservation.setPickupLocation(null);
        Reservation saved = reservationRepository.save(reservation);
        notificationService.createReservationNotification(saved.getReservationId(), student.getFullName(), selectedBook.getTitle());
        allocateAvailableCopies(bookId);
        return saved;
    }

    private long borrowingCount(Integer userId) {
        return studentRepository.countActiveLoans(userId);
    }

    @Transactional
    public void markFulfilled(Reservation reservation) {
        reservation.setStatus("FULFILLED");
        reservation.setHoldUntil(null);
        reservationRepository.save(reservation);
        notificationService.deleteByReservationId(reservation.getReservationId());
    }

    /** Allocate each available copy to the oldest eligible reservation. */
    @Transactional
    public void allocateAvailableCopies(Integer bookId) {
        List<Reservation> queue = reservationRepository.findWaitingQueue(bookId);
        for (Reservation reservation : queue) {
           var copy = bookCopyRepository.findFirstByBookIdAndStatusOrderByCopyIdAsc(bookId, "Available");
            if (copy.isEmpty()) break;
            int max = librarySettingsService.getSettings().getMaxBooksPerStudent();
            long loans = borrowingCount(reservation.getUserId());
            long active = reservationRepository.countActiveByUserId(reservation.getUserId());
            // Their waiting reservation already consumes one slot. If over capacity, skip without losing queue order.
            if (loans + active > max) continue;
            var allocatedCopy = copy.get();
            allocatedCopy.setStatus("Reserved");
            bookCopyRepository.save(allocatedCopy);
            reservation.setCopyId(allocatedCopy.getCopyId());
            reservation.setStatus("READY_FOR_PICKUP");
            reservation.setHoldUntil(LocalDateTime.now().plusMinutes(getReservationHoldMinutes()));
            reservation.setPickupLocation("Main Library");
            reservationRepository.save(reservation);
            notificationService.createStudentReservationReadyNotification(reservation.getUserId(), reservation.getReservationId(), bookRepository.findById(bookId).map(book::getTitle).orElse("Your reserved book"));
        }
    }

    // --------------------------------------------------
    // GET STUDENT RESERVATIONS
    // --------------------------------------------------

    @Transactional
    public List<ReservationResponse> getStudentReservations(Integer userId) {

        if (userId == null || userId <= 0) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Invalid student ID"
            );
        }

        // Make sure expired holds show up as EXPIRED
        expireOverdueReservations();

        List<Object[]> rows =
                reservationRepository.findReservationsByUserId(userId);

        return rows.stream()
                .map(row -> new ReservationResponse(
                        ((Number) row[0]).intValue(),
                        row[1] == null ? null : row[1].toString(),
                        row[2] == null ? null : row[2].toString(),
                        row[3] == null ? null : row[3].toString(),
                        toLocalDateTime(row[4]),
                        toLocalDateTime(row[5]),
                        row[6] == null ? null : row[6].toString(),
                        row[7] == null ? null : row[7].toString(),
                        row[8] == null ? 0 : ((Number) row[8]).intValue(),
                        estimateAvailability(row[7], row[8])
                ))
                .toList();
    }

    // --------------------------------------------------
    // CANCEL RESERVATION
    // --------------------------------------------------

    @Transactional
    public void cancelReservation(Integer userId, Integer reservationId) {

        Reservation reservation = reservationRepository
                .findById(reservationId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Reservation not found"
                ));

        if (userId == null || !reservation.getUserId().equals(userId)) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "You cannot cancel another student's reservation"
            );
        }

        String status = reservation.getStatus();

        if (!"WAITING".equalsIgnoreCase(status)
                && !"READY_FOR_PICKUP".equalsIgnoreCase(status)) {

            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "This reservation cannot be cancelled"
            );
        }

        reservation.setStatus("CANCELLED");
        reservation.setPickupLocation(null);
        if (reservation.getCopyId() != null) {
            bookCopyRepository.findById(reservation.getCopyId()).ifPresent(copy -> { copy.setStatus("Available"); bookCopyRepository.save(copy); });
        }

        reservationRepository.save(reservation);

        // Remove the matching notification from the librarian page
        notificationService.deleteByReservationId(reservationId);
        allocateAvailableCopies(reservation.getBookId());
    }

    // --------------------------------------------------
    // EXPIRE RESERVATIONS THAT HAVE PASSED THEIR PICKUP DEADLINE
    // Runs every minute, and also before reservations are
    // created, listed or borrowed.
    // --------------------------------------------------

    @Scheduled(fixedRate = 60_000)
    @Transactional
    public void expireOverdueReservations() {

        List<Reservation> expired =
                reservationRepository.findExpiredActiveReservations(
                        LocalDateTime.now()
                );

        for (Reservation reservation : expired) {

            reservation.setStatus("EXPIRED");
            reservation.setPickupLocation(null);
            if (reservation.getCopyId() != null) {
                bookCopyRepository.findById(reservation.getCopyId()).ifPresent(copy -> { copy.setStatus("Available"); bookCopyRepository.save(copy); });
            }
            reservationRepository.save(reservation);
            notificationService.deleteByReservationId(reservation.getReservationId());
            allocateAvailableCopies(reservation.getBookId());
        }
    }

    private java.time.LocalDate estimateAvailability(Object statusValue, Object queueValue) {
        if (statusValue == null || !"WAITING".equalsIgnoreCase(statusValue.toString())) return null;
        int position = queueValue instanceof Number n ? Math.max(1, n.intValue()) : 1;
        int borrowingDays = librarySettingsService.getSettings().getMaxBorrowingDays();
        // Planning estimate only: real return dates and renewals can change it.
        return java.time.LocalDate.now().plusDays((long) borrowingDays * position);
    }

    @Scheduled(fixedRate = 60_000)
    @Transactional
    public void allocateWaitingReservations() {
        for (Integer bookId : reservationRepository.findBookIdsWithWaitingReservations()) {
            allocateAvailableCopies(bookId);
        }
    }

    // --------------------------------------------------
    // DATE CONVERSION HELPERS
    // --------------------------------------------------

    private LocalDateTime toLocalDateTime(Object value) {

        if (value == null) {
            return null;
        }

        if (value instanceof Timestamp timestamp) {
            return timestamp.toLocalDateTime();
        }

        if (value instanceof LocalDateTime dateTime) {
            return dateTime;
        }

        if (value instanceof Date date) {
            return date.toLocalDate().atStartOfDay();
        }

        return LocalDateTime.parse(
                value.toString().replace(" ", "T")
        );
    }

    private int getReservationHoldMinutes() {
        return librarySettingsService.getReservationHoldMinutes();
    }
}