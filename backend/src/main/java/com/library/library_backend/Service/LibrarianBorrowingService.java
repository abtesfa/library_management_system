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
import com.library.library_backend.repository.LibrarySettingsRepository;

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
    private final LibrarySettingsRepository settingsRepository;
    private final ReservationRepository reservationRepository;
    private final ReservationService reservationService;

    public LibrarianBorrowingService(
            BorrowingRepository borrowingRepository,
            BookCopyRepository bookCopyRepository,
            BookRepository bookRepository,
            StudentRepository studentRepository,
            LibrarySettingsRepository settingsRepository,
            ReservationRepository reservationRepository,
            ReservationService reservationService
    ) {
        this.borrowingRepository = borrowingRepository;
        this.bookCopyRepository = bookCopyRepository;
        this.bookRepository = bookRepository;
        this.studentRepository = studentRepository;
        this.settingsRepository = settingsRepository;
        this.reservationRepository = reservationRepository;
        this.reservationService = reservationService;
    }

    @Transactional
    public BorrowBookResponse borrowBook(BorrowBookRequest request) {

        // 0. Release copies held by expired reservations.
        reservationService.expireOverdueReservations();

        // 1. Validate the request.
        if (request.getStudentId() == null
                || request.getStudentId().isBlank()) {
            throw new IllegalArgumentException("Student ID is required.");
        }

        if (request.getBookQuery() == null
                || request.getBookQuery().isBlank()) {
            throw new IllegalArgumentException(
                    "Book title or ISBN is required."
            );
        }

        // 2. Find the student by Student ID.
        // Account status is not checked here.
        Integer userId = studentRepository
                .findUserIdByStudentId(request.getStudentId().trim())
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "Student ID does not exist."
                        )
                );

        // 3. Find the book by ISBN first, then by title.
        String query = request.getBookQuery().trim();

        Optional<book> bookResult = bookRepository.findByIsbn(query);

        if (bookResult.isEmpty()) {
            bookResult = bookRepository
                    .findByTitleContainingIgnoreCase(query)
                    .stream()
                    .findFirst();
        }

        book selectedBook = bookResult.orElseThrow(() ->
                new IllegalArgumentException("Book not found.")
        );

        // 4. Find an available copy.
        BookCopy availableCopy = bookCopyRepository
                .findFirstByBookIdAndStatus(
                        selectedBook.getBookId(),
                        "Available"
                )
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "No available copies of this book."
                        )
                );

        // 4b. A student without their own reservation may only take
        // a copy that is not held for someone else.
        Optional<Reservation> ownReservation = reservationRepository
                .findActiveReservation(userId, selectedBook.getBookId());

        if (ownReservation.isEmpty()) {
            long free = bookCopyRepository.countByBookIdAndStatus(
                    selectedBook.getBookId(), "Available")
                    - reservationRepository.countActiveByBookId(
                            selectedBook.getBookId());

            if (free <= 0) {
                throw new IllegalArgumentException(
                        "All available copies are reserved for other students."
                );
            }
        }

        // 5. Read library settings.
        LibrarySettings settings = settingsRepository.findById(1)
                .orElseThrow(() ->
                        new IllegalStateException(
                                "Library settings record was not found."
                        )
                );

        // 6. Determine the borrowing date.
        LocalDate borrowDate = request.getBorrowDate() != null
                ? request.getBorrowDate()
                : LocalDate.now();

        if (borrowDate.isAfter(LocalDate.now())) {
            throw new IllegalArgumentException(
                    "Borrowing date cannot be in the future."
            );
        }

        // 7. Check the daily borrowing limit.
        long borrowedToday = borrowingRepository
                .countBooksBorrowedOnDate(userId, borrowDate);

        if (borrowedToday >= settings.getMaxBooksPerDay()) {
            throw new IllegalArgumentException(
                    "Student has reached the daily borrowing limit of "
                            + settings.getMaxBooksPerDay() + " books."
            );
        }

        // 8. Calculate the due date.
        LocalDate dueDate = borrowDate.plusDays(
                settings.getMaxBorrowingDays()
        );

        // 9. Create the borrowing record.
        Borrowing borrowing = new Borrowing();

        borrowing.setUserId(userId);
        borrowing.setCopyId(availableCopy.getCopyId());
        borrowing.setBorrowDate(borrowDate);
        borrowing.setDueDate(dueDate);
        borrowing.setReturnDate(null);
        borrowing.setStatus("BORROWED");
        borrowing.setRenewalCount(0);

        Borrowing savedBorrowing =
                borrowingRepository.save(borrowing);

        // 9b. The student's reservation has now been fulfilled.
        if (ownReservation.isPresent()) {
            Reservation reservation = ownReservation.get();
            reservation.setStatus("FULFILLED");
            reservationRepository.save(reservation);
        }

        // 10. Update the book copy status.
        availableCopy.setStatus("Borrowed");
        bookCopyRepository.save(availableCopy);

        // 11. Return the result.
        return new BorrowBookResponse(
                savedBorrowing.getBorrowingId(),
                request.getStudentId(),
                selectedBook.getTitle(),
                selectedBook.getIsbn(),
                availableCopy.getCopyId(),
                borrowDate,
                dueDate,
                savedBorrowing.getStatus(),
                availableCopy.getLocation()
        );
    }
}