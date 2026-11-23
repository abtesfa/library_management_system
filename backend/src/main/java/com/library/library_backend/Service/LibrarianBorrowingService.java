
package com.library.library_backend.Service;

import com.library.library_backend.dto.BorrowBookRequest;
import com.library.library_backend.dto.BorrowBookResponse;
import com.library.library_backend.entity.Borrowing;
import com.library.library_backend.entity.BookCopy;
import com.library.library_backend.entity.LibrarySettings;
import com.library.library_backend.entity.Reservation;
import com.library.library_backend.entity.book;
import com.library.library_backend.repository.BorrowingRepository;
import com.library.library_backend.repository.BookCopyRepository;
import com.library.library_backend.repository.BookRepository;
import com.library.library_backend.repository.StudentRepository;
import com.library.library_backend.repository.ReservationRepository;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.util.Optional;

@Service
public class LibrarianBorrowingService {

    private final BorrowingRepository borrowingRepository;
    private final BookCopyRepository bookCopyRepository;
    private final BookRepository bookRepository;
    private final StudentRepository studentRepository;
    private final LibrarySettingsService settingsService;
    private final ReservationRepository reservationRepository;
    private final ReservationService reservationService;

    public LibrarianBorrowingService(
            BorrowingRepository borrowingRepository,
            BookCopyRepository bookCopyRepository,
            BookRepository bookRepository,
            StudentRepository studentRepository,
            LibrarySettingsService settingsService,
            ReservationRepository reservationRepository,
            ReservationService reservationService,
            NotificationService notificationService) {

        this.borrowingRepository = borrowingRepository;
        this.bookCopyRepository = bookCopyRepository;
        this.bookRepository = bookRepository;
        this.studentRepository = studentRepository;
        this.settingsService = settingsService;
        this.reservationRepository = reservationRepository;
        this.reservationService = reservationService;
    }

    @Transactional
    public BorrowBookResponse borrowBook(BorrowBookRequest request) {

        reservationService.expireOverdueReservations();

        if (request.getStudentId() == null
                || request.getStudentId().isBlank()) {
            throw new IllegalArgumentException("Student ID is required.");
        }

        if (request.getBookQuery() == null
                || request.getBookQuery().isBlank()) {
            throw new IllegalArgumentException(
                    "Book title or ISBN is required.");
        }

        Integer userId = studentRepository
                .findUserIdByStudentId(request.getStudentId().trim())
                .orElseThrow(() -> new IllegalArgumentException(
                        "Student ID does not exist."));

        String query = request.getBookQuery().trim();

        Optional<book> bookResult = bookRepository.findByIsbn(query);

        if (bookResult.isEmpty()) {
            bookResult = bookRepository
                    .findByTitleContainingIgnoreCase(query)
                    .stream()
                    .findFirst();
        }

        book selectedBook = bookResult.orElseThrow(
                () -> new IllegalArgumentException("Book not found."));

        Integer bookId = selectedBook.getBookId();

        // Allocate any available copies to students already in the queue.
        reservationService.processQueueForBook(bookId);

        Optional<Reservation> ownReservation =
                reservationRepository.findActiveReservation(userId, bookId);

        BookCopy selectedCopy;

        if (ownReservation.isPresent()) {

            Reservation reservation = ownReservation.get();

            if (!"READY_FOR_PICKUP".equalsIgnoreCase(
                    reservation.getStatus())) {
                throw new IllegalArgumentException(
                        "Your reservation is still in the queue. "
                        + "You cannot borrow this book until it is ready.");
            }

            if (reservation.getAllocatedCopyId() == null) {
                throw new IllegalStateException(
                        "Your ready reservation has no allocated copy.");
            }

            selectedCopy = bookCopyRepository
                    .findById(reservation.getAllocatedCopyId())
                    .orElseThrow(() -> new IllegalStateException(
                            "The copy assigned to this reservation was not found."));

            if (!"Reserved".equalsIgnoreCase(selectedCopy.getStatus())) {
                throw new IllegalStateException(
                        "The assigned copy is no longer reserved.");
            }

        } else {

            if (reservationRepository.countActiveByBookId(bookId) > 0) {
                throw new IllegalArgumentException(
                        "This book has active reservations. "
                        + "The reservation queue must be served first.");
            }

            selectedCopy = bookCopyRepository
                    .findFirstByBookIdAndStatus(bookId, "Available")
                    .orElseThrow(() -> new IllegalArgumentException(
                            "No available copies of this book."));
        }

        LibrarySettings settings = settingsService.getSettings();

        LocalDate borrowDate = request.getBorrowDate() != null
                ? request.getBorrowDate()
                : LocalDate.now();

        if (borrowDate.isAfter(LocalDate.now())) {
            throw new IllegalArgumentException(
                    "Borrowing date cannot be in the future.");
        }

        long currentlyBorrowed =
                borrowingRepository.countCurrentlyBorrowed(userId);

        int maximumBooks = settings.getMaxBooksPerStudent();

        if (currentlyBorrowed >= maximumBooks) {
            throw new IllegalArgumentException(
                    "This student has already borrowed "
                    + currentlyBorrowed
                    + " books. The maximum allowed is "
                    + maximumBooks + ".");
        }

        LocalDate dueDate = borrowDate.plusDays(
                settings.getMaxBorrowingDays());

        Borrowing borrowing = new Borrowing();
        borrowing.setUserId(userId);
        borrowing.setCopyId(selectedCopy.getCopyId());
        borrowing.setBorrowDate(borrowDate);
        borrowing.setDueDate(dueDate);
        borrowing.setReturnDate(null);
        borrowing.setStatus("BORROWED");
        borrowing.setRenewalCount(0);

        Borrowing savedBorrowing = borrowingRepository.save(borrowing);

        if (ownReservation.isPresent()) {
            Reservation reservation = ownReservation.get();

            reservation.setStatus("FULFILLED");
            reservation.setQueuePosition(null);
            reservation.setEstimatedAvailableAt(null);
            reservation.setHoldUntil(null);
            reservation.setPickupLocation(null);
            reservation.setAllocatedCopyId(null);

            reservationRepository.save(reservation);
        }

        selectedCopy.setStatus("Borrowed");
        bookCopyRepository.save(selectedCopy);

        // The reservation has left the queue and the copy is now on loan.
        // Refresh remaining queue positions and their projected availability.
        reservationService.processQueueForBook(bookId);

        return new BorrowBookResponse(
                savedBorrowing.getBorrowingId(),
                request.getStudentId(),
                selectedBook.getTitle(),
                selectedBook.getIsbn(),
                selectedCopy.getCopyId(),
                borrowDate,
                dueDate,
                savedBorrowing.getStatus(),
                selectedCopy.getLocation()
        );
    }
}
