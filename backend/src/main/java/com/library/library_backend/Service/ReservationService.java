
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

        book selectedBook = bookRepository.findByIdForUpdate(bookId)
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

        Integer bookId = reservation.getBookId();
        bookRepository.findByIdForUpdate(bookId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Book not found"));

        // Re-check after acquiring the book lock so cancellation cannot race
        // with checkout or expiration of the same reservation.
        if (!isActive(reservation)) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "This reservation is no longer active.");
        }

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

    @Scheduled(fixedRate = 10000)
    @Transactional
    public void expireOverdueReservations() {

        LocalDateTime now = LocalDateTime.now();

        // First discover affected book IDs, then lock each book and re-read
        // its expired reservations. This serializes expiry with checkout,
        // cancellation, and other queue allocation operations.
        List<Reservation> candidates =
                reservationRepository.findExpiredReadyReservations(now);

        Set<Integer> affectedBooks = new HashSet<>();
        for (Reservation reservation : candidates) {
            affectedBooks.add(reservation.getBookId());
        }

        for (Integer bookId : affectedBooks) {
            bookRepository.findByIdForUpdate(bookId)
                    .orElseThrow(() -> new ResponseStatusException(
                            HttpStatus.NOT_FOUND, "Book not found"));

            List<Reservation> expiredForBook =
                    reservationRepository.findExpiredReadyReservationsByBookId(
                            bookId, LocalDateTime.now());

            for (Reservation reservation : expiredForBook) {
                Integer copyId = reservation.getAllocatedCopyId();

                reservation.setStatus("EXPIRED");
                reservation.setQueuePosition(null);
                reservation.setHoldUntil(null);
                reservation.setPickupLocation(null);
                reservation.setAllocatedCopyId(null);
                reservation.setEstimatedAvailableAt(null);

                reservationRepository.save(reservation);
                notificationService.deleteByReservationId(
                        reservation.getReservationId());

                if (copyId != null) {
                    releaseCopy(copyId);
                }
            }

            // The released copy is now immediately assigned to the oldest
            // WAITING reservation for this book, if one exists.
            allocateAvailableCopies(bookId);
            updateQueueEstimates(bookId);
        }
    }

    /**
     * Call this when a physical copy becomes available.
     * The oldest waiting reservation receives the copy first.
     */
    @Transactional
    public void lockBookForQueue(Integer bookId) {
        bookRepository.findByIdForUpdate(bookId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND, "Book not found"));
    }

    @Transactional
    public void processQueueForBook(Integer bookId) {
        lockBookForQueue(bookId);
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
            reservation.setQueuePosition(null);
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
     * Recalculates queue positions and forecasts when each WAITING reservation
     * could be allocated a copy. The forecast simulates each physical copy
     * independently and assumes a future reader collects at the end of the
     * pickup window, then borrows for the configured maximum duration.
     *
     * If a reader does not collect a READY_FOR_PICKUP copy,
     * expireOverdueReservations() releases it at Hold_Until and immediately
     * allocates it to the next WAITING reservation. That real event replaces
     * the conservative forecast with the new actual allocation.
     */
    private void updateQueueEstimates(Integer bookId) {

        List<Reservation> waiting = reservationRepository.findWaitingQueue(bookId);
        List<BookCopy> copies = bookCopyRepository.findAllByBookId(bookId);

        // Queue positions apply only to WAITING readers. READY reservations
        // have already received a copy and must not occupy a waiting position.
        List<Reservation> activeQueue = reservationRepository.findActiveQueue(bookId);
        int position = 1;
        for (Reservation reservation : activeQueue) {
            if ("WAITING".equalsIgnoreCase(reservation.getStatus())) {
                reservation.setQueuePosition(position++);
            } else {
                reservation.setQueuePosition(null);
            }
        }
        reservationRepository.saveAll(activeQueue);

        List<Integer> copyIds = copies.stream()
                .map(BookCopy::getCopyId)
                .filter(Objects::nonNull)
                .toList();

        Map<Integer, Borrowing> activeLoansByCopy = new HashMap<>();
        if (!copyIds.isEmpty()) {
            borrowingRepository.findByCopyIdInAndStatusIn(
                    copyIds, List.of("BORROWED", "OVERDUE"))
                    .forEach(loan -> activeLoansByCopy.put(loan.getCopyId(), loan));
        }

        LocalDateTime now = LocalDateTime.now();
        LibrarySettings settings = librarySettingsService.getSettings();
        int borrowingDays = settings.getMaxBorrowingDays();
        int holdMinutes = settings.getReservationHoldMinutes();

        // Each copy has its own next projected time at which it can be
        // allocated. Sorting these times implements earliest-copy-first.
        PriorityQueue<CopyForecast> availableCopies = new PriorityQueue<>(
                Comparator.comparing(CopyForecast::availableAt)
                        .thenComparing(CopyForecast::copyId));

        for (BookCopy copy : copies) {
            String status = copy.getStatus() == null
                    ? "" : copy.getStatus().trim().toLowerCase(Locale.ROOT);

            if ("available".equals(status)) {
                availableCopies.add(new CopyForecast(copy.getCopyId(), now));
                continue;
            }

            if ("borrowed".equals(status)) {
                Borrowing loan = activeLoansByCopy.get(copy.getCopyId());
                if (loan != null && loan.getDueDate() != null) {
                    LocalDateTime due = loan.getDueDate().atStartOfDay();
                    availableCopies.add(new CopyForecast(
                            copy.getCopyId(), due.isBefore(now) ? now : due));
                }
                // A copy marked Borrowed without a matching active loan is
                // deliberately excluded rather than producing a false date.
                continue;
            }

            if ("reserved".equals(status)) {
                Optional<Reservation> ready =
                        reservationRepository.findReadyReservationByCopyId(
                                copy.getCopyId());
                if (ready.isPresent() && ready.get().getHoldUntil() != null) {
                    LocalDateTime holdUntil = ready.get().getHoldUntil();
                    if (holdUntil.isBefore(now)) {
                        // Expiration processing will release and reallocate it.
                        availableCopies.add(new CopyForecast(copy.getCopyId(), now));
                    } else {
                        // Conservative branch: assume the current ready reader
                        // collects at the end of the hold window and completes
                        // a full borrowing cycle. If they do not collect, the
                        // scheduled expiry releases the copy earlier.
                        LocalDateTime nextFree = holdUntil.plusDays(borrowingDays);
                        availableCopies.add(new CopyForecast(
                                copy.getCopyId(), nextFree));
                    }
                }
            }
            // Lost/unknown statuses are intentionally not forecast as usable.
        }

        for (Reservation reservation : waiting) {
            CopyForecast forecast = availableCopies.poll();
            if (forecast == null) {
                reservation.setEstimatedAvailableAt(null);
                continue;
            }

            LocalDateTime readyAt = forecast.availableAt();
            reservation.setEstimatedAvailableAt(readyAt);

            // Assume this future reader collects at the end of their pickup
            // window. If not collected, expiry frees the copy at holdUntil and
            // the next reader is promoted immediately by the expiry workflow.
            LocalDateTime nextFree = readyAt
                    .plusMinutes(holdMinutes)
                    .plusDays(borrowingDays);

            availableCopies.add(new CopyForecast(
                    forecast.copyId(), nextFree));
        }

        reservationRepository.saveAll(waiting);
    }

    private record CopyForecast(Integer copyId, LocalDateTime availableAt) {}

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
