package com.library.library_backend.Service;

import java.time.LocalDate;
import java.util.Optional;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.library.library_backend.dto.BorrowBookRequest;
import com.library.library_backend.dto.BorrowBookResponse;
import com.library.library_backend.entity.BookCopy;
import com.library.library_backend.entity.Borrowing;
import com.library.library_backend.entity.LibrarySettings;
import com.library.library_backend.entity.Reservation;
import com.library.library_backend.entity.Student;
import com.library.library_backend.entity.book;
import com.library.library_backend.repository.BookCopyRepository;
import com.library.library_backend.repository.BookRepository;
import com.library.library_backend.repository.BorrowingRepository;
import com.library.library_backend.repository.LibrarySettingsRepository;
import com.library.library_backend.repository.ReservationRepository;
import com.library.library_backend.repository.StudentRepository;

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
        // Lock the student row so borrowing and reservation capacity checks serialize.
        Student lockedStudent = studentRepository
                .findByStudentIdForUpdate(request.getStudentId().trim())
                .orElseThrow(() -> new IllegalArgumentException("Student ID does not exist."));
        Integer userId = lockedStudent.getUserId();

        if (!"ACTIVE".equalsIgnoreCase(lockedStudent.getStatus())) {
            throw new IllegalArgumentException("This student account is not active.");
        }

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
        selectedBook = bookRepository.findByIdForUpdate(selectedBook.getBookId())
                .orElseThrow(() -> new IllegalArgumentException("Book not found."));
        reservationService.allocateAvailableCopies(selectedBook.getBookId());

        // 4. Find an available copy.
        Optional<Reservation> ownReservation = reservationRepository
                .findActiveReservation(userId, selectedBook.getBookId());

        BookCopy availableCopy;
        if (ownReservation.isPresent()
                && !"READY_FOR_PICKUP".equalsIgnoreCase(ownReservation.get().getStatus())) {
            throw new IllegalArgumentException("Your reservation is still in the queue. Wait until you receive the ready-for-pickup notification.");
        }
        if (ownReservation.isPresent()
                && "READY_FOR_PICKUP".equalsIgnoreCase(ownReservation.get().getStatus())
                && ownReservation.get().getCopyId() != null) {
            availableCopy = bookCopyRepository.findById(ownReservation.get().getCopyId())
                    .orElseThrow(() -> new IllegalArgumentException("Reserved copy was not found."));
        } else {
            availableCopy = bookCopyRepository.findFirstByBookIdAndStatusOrderByCopyIdAsc(selectedBook.getBookId(), "Available")
                    .orElseThrow(() -> new IllegalArgumentException("No unallocated available copies of this book."));
        }

        // Students without their own reservation cannot bypass an existing queue.
        if (ownReservation.isEmpty() && !reservationRepository.findWaitingQueue(selectedBook.getBookId()).isEmpty()) {
            throw new IllegalArgumentException("This book has students waiting in the reservation queue. Please reserve it.");
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

        // 7. Enforce the per-student capacity. Active loans include
        // overdue loans. Active reservations also consume capacity.
        // When this loan fulfils the student's own reservation, that
        // reservation is converted into a loan and must not be counted twice.
        long currentlyBorrowed = borrowingRepository.countCurrentlyBorrowed(userId);
        long activeReservations = reservationRepository.countActiveByUserId(userId);
        long capacityInUse = currentlyBorrowed + activeReservations;

        boolean exceedsCapacity = ownReservation.isPresent()
                ? capacityInUse > settings.getMaxBooksPerStudent()
                : capacityInUse >= settings.getMaxBooksPerStudent();

        if (exceedsCapacity) {
            throw new IllegalArgumentException(
                    "Student has reached the maximum borrowing capacity of "
                            + settings.getMaxBooksPerStudent()
                            + " books, including active reservations."
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
        borrowing.setOriginalDueDate(dueDate);
        borrowing.setReturnDate(null);
        borrowing.setStatus("BORROWED");
        borrowing.setRenewalCount(0);

        Borrowing savedBorrowing =
                borrowingRepository.save(borrowing);

        // 9b. The student's reservation has now been fulfilled.
        if (ownReservation.isPresent()) {
            Reservation reservation = ownReservation.get();
            reservationService.markFulfilled(reservation);
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