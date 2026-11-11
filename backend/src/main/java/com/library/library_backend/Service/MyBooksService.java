
package com.library.library_backend.Service;

import com.library.library_backend.dto.MyBookResponse;
import com.library.library_backend.dto.RenewBookResponse;
import com.library.library_backend.entity.Borrowing;
import com.library.library_backend.entity.LibrarySettings;
import com.library.library_backend.repository.BorrowingRepository;
import com.library.library_backend.repository.LibrarySettingsRepository;
import com.library.library_backend.repository.MyBooksRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class MyBooksService {

    /** A loan can be renewed once, even if the settings allow more. */
    private static final int MAX_RENEWALS = 1;

    private final MyBooksRepository myBooksRepository;
    private final BorrowingRepository borrowingRepository;
    private final LibrarySettingsRepository settingsRepository;

    public MyBooksService(
            MyBooksRepository myBooksRepository,
            BorrowingRepository borrowingRepository,
            LibrarySettingsRepository settingsRepository) {

        this.myBooksRepository = myBooksRepository;
        this.borrowingRepository = borrowingRepository;
        this.settingsRepository = settingsRepository;
    }

    public List<MyBookResponse> getMyBooks(Integer userId) {

        List<Object[]> rows =
                myBooksRepository.findCurrentBorrowings(userId);

        return rows.stream()
                .map(row -> new MyBookResponse(
                        toInteger(row[0]),
                        toStringValue(row[1]),
                        toStringValue(row[2]),
                        toLocalDate(row[3]),
                        toLocalDate(row[4]),
                        toLocalDate(row[5]),
                        toStringValue(row[6]),
                        toInteger(row[7]),
                        toStringValue(row[8])
                ))
                .toList();
    }

    /**
     * Extends a student's loan by one borrowing period.
     *
     * Rejected when the loan is not the student's, is not active, is already
     * overdue, or has already been renewed.
     */
    @Transactional
    public RenewBookResponse renewBook(Integer userId, Integer borrowingId) {

        Borrowing borrowing = borrowingRepository.findById(borrowingId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Borrowing record not found."
                ));

        if (!borrowing.getUserId().equals(userId)) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "You cannot renew another student's loan."
            );
        }

        if (!"BORROWED".equalsIgnoreCase(borrowing.getStatus())) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Only books that are currently borrowed can be renewed."
            );
        }

        // The due day itself still counts as on time.
        if (LocalDate.now().isAfter(borrowing.getDueDate())) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "This loan is overdue and cannot be renewed. "
                            + "Please return the book."
            );
        }

        LibrarySettings settings = settingsRepository.findById(1)
                .orElseThrow(() -> new IllegalStateException(
                        "Library settings record was not found."
                ));

        int maxRenewals = Math.min(MAX_RENEWALS, settings.getRenewalLimit());

        if (maxRenewals == 0) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Renewals are not allowed."
            );
        }

        int renewals = borrowing.getRenewalCount() == null
                ? 0
                : borrowing.getRenewalCount();

        if (renewals >= maxRenewals) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "This loan has already been renewed. "
                            + "Only one renewal is allowed."
            );
        }

        borrowing.setDueDate(
                borrowing.getDueDate().plusDays(settings.getMaxBorrowingDays())
        );
        borrowing.setRenewalCount(renewals + 1);

        Borrowing saved = borrowingRepository.save(borrowing);

        return new RenewBookResponse(
                saved.getBorrowingId(),
                saved.getDueDate(),
                saved.getRenewalCount()
        );
    }

    private Integer toInteger(Object value) {
        if (value == null) {
            return 0;
        }

        return ((Number) value).intValue();
    }

    private String toStringValue(Object value) {
        return value == null ? null : value.toString();
    }

    private LocalDate toLocalDate(Object value) {

        if (value == null) {
            return null;
        }

        if (value instanceof LocalDate) {
            return (LocalDate) value;
        }

        if (value instanceof java.sql.Date) {
            return ((java.sql.Date) value).toLocalDate();
        }

        if (value instanceof Timestamp) {
            return ((Timestamp) value).toLocalDateTime().toLocalDate();
        }

        if (value instanceof LocalDateTime) {
            return ((LocalDateTime) value).toLocalDate();
        }

        if (value instanceof String) {
            return LocalDate.parse((String) value);
        }

        throw new IllegalArgumentException(
                "Unsupported date type: " + value.getClass().getName()
        );
    }
}
