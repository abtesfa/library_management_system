
package com.library.library_backend.Service;

import com.library.library_backend.dto.ReservationResponse;
import com.library.library_backend.entity.*;
import com.library.library_backend.repository.*;

import org.springframework.http.HttpStatus;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.sql.Date;
import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.*;

@Service
public class ReservationService {

    private final ReservationRepository reservationRepository;
    private final NotificationService notificationService;
    private final StudentRepository studentRepository;
    private final BookRepository bookRepository;
    private final BookCopyRepository bookCopyRepository;
    private final BorrowingRepository borrowingRepository;
    private final LibrarySettingsService librarySettingsService;

    public ReservationService(
            ReservationRepository reservationRepository,
            NotificationService notificationService,
            StudentRepository studentRepository,
            BookRepository bookRepository,
            BookCopyRepository bookCopyRepository,
            BorrowingRepository borrowingRepository,
            LibrarySettingsService librarySettingsService) {

        this.reservationRepository = reservationRepository;
        this.notificationService = notificationService;
        this.studentRepository = studentRepository;
        this.bookRepository = bookRepository;
        this.bookCopyRepository = bookCopyRepository;
        this.borrowingRepository = borrowingRepository;
        this.librarySettingsService = librarySettingsService;
    }

    @Transactional
    public Reservation createReservation(Integer userId, Integer bookId) {

        expireOverdueReservations();

        Student student = studentRepository.findById(userId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Student not found"));

        book selectedBook = bookRepository.findById(bookId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Book not found"));

        if (reservationRepository.countActiveReservation(userId, bookId) > 0) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "You already have an active reservation for this book.");
        }

        LibrarySettings settings = librarySettingsService.getSettings();

        long borrowed = borrowingRepository.countCurrentlyBorrowed(userId);
        long activeReservations =
                reservationRepository.countActiveByUserId(userId);

        long remainingCapacity = Math.max(
                0,
                settings.getMaxBooksPerStudent()
                        - borrowed
                        - activeReservations
        );

        if (remainingCapacity <= 0) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "You have reached your reservation limit. "
                    + "Return a borrowed book or wait for an active "
                    + "reservation to finish.");
        }

        Reservation reservation = new Reservation();
        reservation.setUserId(userId);
        reservation.setBookId(bookId);
        reservation.setReservationDate(LocalDateTime.now());
        reservation.setStatus("WAITING");
        reservation.setHoldUntil(null);
        reservation.setAllocatedCopyId(null);
        reservation.setPickupLocation(null);

        Reservation saved = reservationRepository.save(reservation);

        notificationService.createReservationNotification(
                saved.getReservationId(),
                student.getFullName(),
                selectedBook.getTitle()
        );

        allocateAvailableCopies(bookId);
        updateQueueEstimates(bookId);

        return reservationRepository.findById(saved.getReservationId())
                .orElse(saved);
    }

    @Transactional
public List<ReservationResponse> getStudentReservations(Integer userId) {

    expireOverdueReservations();

    List<Object[]> rows =
            reservationRepository.findReservationsByUserId(userId);

    // Keep the existing stream mapping below this point.

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
                        toLocalDateTime(row[9])
                ))
                .toList();
    }

    @Transactional
    public void cancelReservation(Integer userId, Integer reservationId) {

        Reservation reservation = reservationRepository.findById(reservationId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Reservation not found"));

        if (!reservation.getUserId().equals(userId)) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "You cannot cancel another student's reservation.");
        }

        if (!isActive(reservation)) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "This reservation is no longer active.");
        }

        Integer bookId = reservation.getBookId();
        Integer copyId = reservation.getAllocatedCopyId();

        reservation.setStatus("CANCELLED");
        reservation.setHoldUntil(null);
        reservation.setPickupLocation(null);
        reservation.setAllocatedCopyId(null);
        reservation.setEstimatedAvailableAt(null);

        reservationRepository.save(reservation);
        notificationService.deleteByReservationId(reservationId);

        if (copyId != null) {
            releaseCopy(copyId);
        }

        allocateAvailableCopies(bookId);
        updateQueueEstimates(bookId);
    }

    @Scheduled(fixedRate = 60000)
    @Transactional
    public void expireOverdueReservations() {

        List<Reservation> expired =
                reservationRepository.findExpiredReadyReservations(
                        LocalDateTime.now());

        Set<Integer> affectedBooks = new HashSet<>();

        for (Reservation reservation : expired) {

            Integer copyId = reservation.getAllocatedCopyId();

            reservation.setStatus("EXPIRED");
            reservation.setHoldUntil(null);
            reservation.setPickupLocation(null);
            reservation.setAllocatedCopyId(null);

            reservationRepository.save(reservation);
            notificationService.deleteByReservationId(
                    reservation.getReservationId());

            if (copyId != null) {
                releaseCopy(copyId);
            }

            affectedBooks.add(reservation.getBookId());
        }

        for (Integer bookId : affectedBooks) {
            allocateAvailableCopies(bookId);
            updateQueueEstimates(bookId);
        }
    }

    /**
     * Call this when a physical copy becomes available.
     * The oldest waiting reservation receives the copy first.
     */
    @Transactional
    public void processQueueForBook(Integer bookId) {
        allocateAvailableCopies(bookId);
        updateQueueEstimates(bookId);
    }

    private void allocateAvailableCopies(Integer bookId) {

        List<BookCopy> availableCopies =
                bookCopyRepository
                        .findAllByBookIdAndStatusOrderByCopyIdAsc(
                                bookId, "Available");

        List<Reservation> waiting =
                reservationRepository.findWaitingQueue(bookId);

        int count = Math.min(availableCopies.size(), waiting.size());

        for (int i = 0; i < count; i++) {

            BookCopy copy = availableCopies.get(i);
            Reservation reservation = waiting.get(i);

            LocalDateTime now = LocalDateTime.now();
            int holdMinutes =
                    librarySettingsService.getReservationHoldMinutes();

            copy.setStatus("Reserved");
            bookCopyRepository.save(copy);

            reservation.setStatus("READY_FOR_PICKUP");
            reservation.setAllocatedCopyId(copy.getCopyId());
            reservation.setPickupLocation(copy.getLocation());
            reservation.setHoldUntil(now.plusMinutes(holdMinutes));
            reservation.setEstimatedAvailableAt(now);

            reservationRepository.save(reservation);

            book selectedBook = bookRepository.findById(bookId)
                    .orElseThrow(() -> new IllegalStateException(
                            "Book not found: " + bookId));

            notificationService.createReservationReadyNotification(
                    reservation.getReservationId(),
                    reservation.getUserId(),
                    selectedBook.getTitle(),
                    reservation.getHoldUntil()
            );
        }
    }

    /**
     * Waiting students receive estimates based on borrowed copies'
     * due dates. READY_FOR_PICKUP students have already been assigned
     * a physical copy and therefore do not need an estimate.
     */
    private void updateQueueEstimates(Integer bookId) {

        List<Reservation> waiting =
                reservationRepository.findWaitingQueue(bookId);

        List<Date> dueDates =
                borrowingRepository.findExpectedReturnDatesByBookId(bookId);

        LocalDateTime now = LocalDateTime.now();

        for (int i = 0; i < waiting.size(); i++) {

            Reservation reservation = waiting.get(i);

            LocalDateTime estimate = null;

            if (i < dueDates.size() && dueDates.get(i) != null) {
                estimate = dueDates.get(i).toLocalDate().atStartOfDay();
            }

            reservation.setEstimatedAvailableAt(estimate);
            reservationRepository.save(reservation);
        }

        List<Reservation> active =
                reservationRepository.findActiveQueue(bookId);

        int position = 1;

        for (Reservation reservation : active) {
            reservation.setQueuePosition(position++);
            reservationRepository.save(reservation);
        }
    }

    private void releaseCopy(Integer copyId) {

        BookCopy copy = bookCopyRepository.findById(copyId)
                .orElse(null);

        if (copy != null && "Reserved".equalsIgnoreCase(copy.getStatus())) {
            copy.setStatus("Available");
            bookCopyRepository.save(copy);
        }
    }

    private boolean isActive(Reservation reservation) {
        return "WAITING".equalsIgnoreCase(reservation.getStatus())
                || "READY_FOR_PICKUP".equalsIgnoreCase(
                        reservation.getStatus());
    }

    private LocalDateTime toLocalDateTime(Object value) {

        if (value == null) return null;

        if (value instanceof Timestamp timestamp) {
            return timestamp.toLocalDateTime();
        }

        if (value instanceof LocalDateTime dateTime) {
            return dateTime;
        }

        if (value instanceof Date date) {
            return date.toLocalDate().atStartOfDay();
        }

        if (value instanceof java.sql.Date date) {
            return date.toLocalDate().atStartOfDay();
        }

        return LocalDateTime.parse(
                value.toString().replace(" ", "T"));
    }
}
