
package com.library.library_backend.Service;

import com.library.library_backend.dto.ReservationResponse;
import com.library.library_backend.entity.Reservation;
import com.library.library_backend.entity.Student;
import com.library.library_backend.entity.book;
import com.library.library_backend.repository.ReservationRepository;
import com.library.library_backend.repository.StudentRepository;
import com.library.library_backend.repository.BookRepository;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class ReservationService {

    private final ReservationRepository reservationRepository;
    private final NotificationService notificationService;
    private final StudentRepository studentRepository;
    private final BookRepository bookRepository;

    public ReservationService(
            ReservationRepository reservationRepository,
            NotificationService notificationService,
            StudentRepository studentRepository,
            BookRepository bookRepository) {

        this.reservationRepository = reservationRepository;
        this.notificationService = notificationService;
        this.studentRepository = studentRepository;
        this.bookRepository = bookRepository;
    }

    // --------------------------------------------------
    // CREATE RESERVATION AND NOTIFY LIBRARIAN
    // --------------------------------------------------

    @Transactional
    public Reservation createReservation(Integer userId, Integer bookId) {

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

        // Create reservation
        Reservation reservation = new Reservation();

        reservation.setUserId(userId);
        reservation.setBookId(bookId);

        reservation.setQueuePosition(
                reservationRepository.getNextQueuePosition(bookId)
        );

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

        List<Object[]> rows =
                reservationRepository.findReservationsByUserId(userId);

        return rows.stream()
                .map(row -> new ReservationResponse(
                        ((Number) row[0]).intValue(),
                        row[1] == null ? null : row[1].toString(),
                        row[2] == null ? null : row[2].toString(),
                        row[3] == null ? null : row[3].toString(),
                        toLocalDateTime(row[4]),
                        toLocalDate(row[5]),
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

        reservationRepository.save(reservation);
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

    private LocalDate toLocalDate(Object value) {

        if (value == null) {
            return null;
        }

        if (value instanceof Date date) {
            return date.toLocalDate();
        }

        if (value instanceof LocalDate date) {
            return date;
        }

        if (value instanceof Timestamp timestamp) {
            return timestamp.toLocalDateTime().toLocalDate();
        }

        return LocalDate.parse(value.toString());
    }
}
