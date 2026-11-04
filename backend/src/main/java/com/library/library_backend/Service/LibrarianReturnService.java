package com.library.library_backend.Service;

import com.library.library_backend.dto.ReturnBookRequest;
import com.library.library_backend.dto.ReturnBookResponse;
import com.library.library_backend.entity.Borrowing;
import com.library.library_backend.entity.BookCopy;
import com.library.library_backend.entity.LibrarySettings;
import com.library.library_backend.entity.book;
import com.library.library_backend.repository.BorrowingRepository;
import com.library.library_backend.repository.BookCopyRepository;
import com.library.library_backend.repository.BookRepository;
import com.library.library_backend.repository.LibrarySettingsRepository;
import com.library.library_backend.dto.ActiveBorrowingResponse;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

@Service
public class LibrarianReturnService {

    private final BorrowingRepository borrowingRepository;
    private final BookCopyRepository bookCopyRepository;
    private final BookRepository bookRepository;
    private final LibrarySettingsRepository settingsRepository;

    public LibrarianReturnService(
            BorrowingRepository borrowingRepository,
            BookCopyRepository bookCopyRepository,
            BookRepository bookRepository,
            LibrarySettingsRepository settingsRepository
    ) {
        this.borrowingRepository = borrowingRepository;
        this.bookCopyRepository = bookCopyRepository;
        this.bookRepository = bookRepository;
        this.settingsRepository = settingsRepository;
    }
    @Transactional(readOnly = true)
public ActiveBorrowingResponse findActiveBorrowing(
        String studentId,
        String bookQuery
) {
    if (studentId == null || studentId.isBlank()) {
        throw new IllegalArgumentException("Student ID is required.");
    }

    if (bookQuery == null || bookQuery.isBlank()) {
        throw new IllegalArgumentException("Book title or ISBN is required.");
    }

    Integer borrowingId = borrowingRepository
            .findActiveBorrowingId(
                    studentId.trim(),
                    bookQuery.trim()
            )
            .orElseThrow(() ->
                    new IllegalArgumentException(
                            "No active borrowing found for this student and book."
                    )
            );

    Borrowing borrowing = borrowingRepository.findById(borrowingId)
            .orElseThrow(() ->
                    new IllegalArgumentException("Borrowing record not found.")
            );

    BookCopy copy = bookCopyRepository.findById(borrowing.getCopyId())
            .orElseThrow(() ->
                    new IllegalArgumentException("Book copy not found.")
            );

    book selectedBook = bookRepository.findById(copy.getBookId())
            .orElseThrow(() ->
                    new IllegalArgumentException("Book not found.")
            );

    return new ActiveBorrowingResponse(
            borrowing.getBorrowingId(),
            studentId.trim(),
            selectedBook.getTitle(),
            selectedBook.getIsbn(),
            borrowing.getBorrowDate(),
            borrowing.getDueDate(),
            borrowing.getReturnDate(),
            borrowing.getStatus(),
            borrowing.getRenewalCount()
    );
}
    @Transactional
    public ReturnBookResponse returnBook(ReturnBookRequest request) {

        if (request.getStudentId() == null
                || request.getStudentId().isBlank()) {
            throw new IllegalArgumentException("Student ID is required.");
        }

        if (request.getBookQuery() == null
                || request.getBookQuery().isBlank()) {
            throw new IllegalArgumentException("Book title or ISBN is required.");
        }

        String condition = request.getCondition() == null
                ? "GOOD"
                : request.getCondition().trim().toUpperCase();

        if (!condition.equals("GOOD")
                && !condition.equals("MINOR_DAMAGE")
                && !condition.equals("LOST")) {
            throw new IllegalArgumentException("Invalid book condition.");
        }

        Integer borrowingId = borrowingRepository
                .findActiveBorrowingId(
                        request.getStudentId().trim(),
                        request.getBookQuery().trim()
                )
                .orElseThrow(() ->
                        new IllegalArgumentException(
                                "No active borrowing found for this student and book."
                        )
                );

        Borrowing borrowing = borrowingRepository.findById(borrowingId)
                .orElseThrow(() ->
                        new IllegalArgumentException("Borrowing record not found.")
                );

        BookCopy copy = bookCopyRepository.findById(borrowing.getCopyId())
                .orElseThrow(() ->
                        new IllegalArgumentException("Book copy not found.")
                );

        book selectedBook = bookRepository.findById(copy.getBookId())
                .orElseThrow(() ->
                        new IllegalArgumentException("Book not found.")
                );

        LibrarySettings settings = settingsRepository.findById(1)
                .orElseThrow(() ->
                        new IllegalStateException("Library settings not found.")
                );

        LocalDate returnDate = LocalDate.now();

        long overdueDays = Math.max(
                0,
                ChronoUnit.DAYS.between(borrowing.getDueDate(), returnDate)
        );

        BigDecimal fineAmount = settings.getFinePerDay()
                .multiply(BigDecimal.valueOf(overdueDays));

        borrowing.setReturnDate(returnDate);
        borrowing.setStatus("RETURNED");
        borrowing.setFineAmount(fineAmount);
        borrowing.setBookCondition(condition);

        borrowingRepository.save(borrowing);

        // A lost copy must not become available again.
        if (condition.equals("LOST")) {
            copy.setStatus("Lost");
        } else {
            copy.setStatus("Available");
        }

        bookCopyRepository.save(copy);

        return new ReturnBookResponse(
                borrowing.getBorrowingId(),
                request.getStudentId(),
                selectedBook.getTitle(),
                returnDate,
                overdueDays,
                fineAmount,
                condition,
                borrowing.getStatus()
        );
    }
}