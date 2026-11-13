package com.library.library_backend.Service;

import com.library.library_backend.dto.ReservationResponse;
import com.library.library_backend.entity.Reservation;
import com.library.library_backend.entity.Student;
import com.library.library_backend.entity.book;
import com.library.library_backend.repository.BookCopyRepository;
import com.library.library_backend.repository.BookRepository;
import com.library.library_backend.repository.ReservationRepository;
import com.library.library_backend.repository.StudentRepository;

import org.springframework.http.HttpStatus;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.List;

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

        // Free copies held by reservations that already ran out of time
        expireOverdueReservations();

        if (userId == null || userId <= 0) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Invalid student ID"
            );
        }

        if (bookId == null || bookId <= 0) {
            throw new ResponseStatusException(
                    HttpStatus.BAD_REQUEST,
                    "Invalid Book ID"
            );
        }

        // Find the student
        Student student = studentRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Student not found"
                ));

        // Find the book
        book selectedBook = bookRepository.findById(bookId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Book not found"
                ));

        // Prevent duplicate active reservations
        if (reservationRepository.countActiveReservation(userId, bookId) > 0) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "You already have an active reservation for this book"
            );
        }

        // A copy must be free: available copies minus copies that
        // are already held by other active reservations.
        long availableCopies = bookCopyRepository
                .countByBookIdAndStatus(bookId, "Available");

        long reservedCopies =
                reservationRepository.countActiveByBookId(bookId);

        if (availableCopies - reservedCopies <= 0) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "No copies of this book are available to reserve"
            );
        }

        // Create reservation
        Reservation reservation = new Reservation();

        reservation.setUserId(userId);
        reservation.setBookId(bookId);

        reservation.setQueuePosition(
                reservationRepository.getNextQueuePosition(bookId)
        );

        int pickupHoldMinutes = getReservationHoldMinutes();
        LocalDateTime reservedAt = LocalDateTime.now();
        reservation.setReservationDate(reservedAt);
        reservation.setHoldUntil(reservedAt.plusMinutes(pickupHoldMinutes));
        reservation.setPickupHoldMinutes(pickupHoldMinutes);
        reservation.setStatus("WAITING");
        reservation.setPickupLocation("Main Library");

        // Save reservation first
        Reservation savedReservation =
                reservationRepository.save(reservation);

        // Automatically notify librarian
        notificationService.createReservationNotification(
                savedReservation.getReservationId(),
                student.getFullName(),
                selectedBook.getTitle()
        );

        return savedReservation;
    }

    // --------------------------------------------------
    // GET STUDENT RESERVATIONS
    // --------------------------------------------------

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
                        row[8] == null ? 0 : ((Number) row[8]).intValue()
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

        reservationRepository.save(reservation);

        // Remove the matching notification from the librarian page
        notificationService.deleteByReservationId(reservationId);
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
            reservationRepository.save(reservation);

            // Remove it from the librarian notification page
            notificationService.deleteByReservationId(
                    reservation.getReservationId()
            );
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