
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
import java.util.Map;
import java.util.LinkedHashMap;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

@Service
public class MyBooksService {


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
        int renewalLimit = settingsRepository.findById(1)
                .map(LibrarySettings::getRenewalLimit).orElse(0);

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
                        Math.max(0, renewalLimit - toInteger(row[7])),
                        toStringValue(row[8])
                ))
                .toList();
    }


    public List<Map<String, Object>> getBorrowingHistory(Integer userId) {
        return myBooksRepository.findBorrowingHistory(userId).stream().map(row -> {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("borrowingId", row[0]); item.put("bookTitle", row[1]); item.put("isbn", row[2]);
            item.put("borrowDate", row[3]); item.put("originalDueDate", row[4]); item.put("finalDueDate", row[5]); item.put("returnDate", row[6]);
            item.put("status", row[7]); item.put("renewalCount", row[8]); item.put("location", row[9]); item.put("fineAmount", row[10]);
            return item;
        }).toList();
    }


    public Page<Map<String, Object>> getBorrowingHistoryPage(Integer userId, Pageable pageable) {
        return myBooksRepository.findBorrowingHistoryPage(userId, pageable).map(this::historyRow);
    }

    private Map<String, Object> historyRow(Object[] row) {
        Map<String, Object> item = new LinkedHashMap<>();
        item.put("borrowingId", row[0]); item.put("bookTitle", row[1]); item.put("isbn", row[2]);
        item.put("borrowDate", row[3]); item.put("originalDueDate", row[4]); item.put("finalDueDate", row[5]); item.put("returnDate", row[6]);
        item.put("status", row[7]); item.put("renewalCount", row[8]); item.put("location", row[9]); item.put("fineAmount", row[10]);
        return item;
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

        int maxRenewals = settings.getRenewalLimit();

        if (maxRenewals == 0) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Renewals are not allowed."
            );
        }

        int renewals = borrowing.getRenewalCount() == null
                ? 0
                : borrowing.getRenewalCount();

        if (myBooksRepository.hasActiveReservationForBook(userId, borrowing.getCopyId())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "This book has students waiting in the reservation queue, so it cannot be renewed.");
        }

        if (renewals >= maxRenewals) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "This loan has already been renewed. "
                            + "The configured renewal limit has been reached."
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
