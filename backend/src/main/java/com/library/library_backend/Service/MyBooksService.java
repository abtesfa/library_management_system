
package com.library.library_backend.Service;

import com.library.library_backend.dto.MyBookResponse;
import com.library.library_backend.dto.RenewBookResponse;
import com.library.library_backend.entity.Borrowing;
import com.library.library_backend.entity.LibrarySettings;
import com.library.library_backend.entity.NotificationType;
import com.library.library_backend.repository.BorrowingRepository;
import com.library.library_backend.repository.BookCopyRepository;
import com.library.library_backend.repository.LibrarySettingsRepository;
import com.library.library_backend.repository.MyBooksRepository;
import com.library.library_backend.repository.ReservationRepository;
import com.library.library_backend.dto.BorrowingHistoryPageResponse;

import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.ZoneId;
import java.util.List;

@Service
public class MyBooksService {

    private final MyBooksRepository myBooksRepository;
    private final BorrowingRepository borrowingRepository;
    private final LibrarySettingsRepository settingsRepository;
    private final NotificationService notificationService;
    private final BookCopyRepository bookCopyRepository;
    private final ReservationRepository reservationRepository;

    public MyBooksService(
            MyBooksRepository myBooksRepository,
            BorrowingRepository borrowingRepository,
            LibrarySettingsRepository settingsRepository,
            NotificationService notificationService,
            BookCopyRepository bookCopyRepository,
            ReservationRepository reservationRepository) {

        this.myBooksRepository = myBooksRepository;
        this.borrowingRepository = borrowingRepository;
        this.settingsRepository = settingsRepository;
        this.notificationService = notificationService;
        this.bookCopyRepository = bookCopyRepository;
        this.reservationRepository = reservationRepository;
    }

    
public List<MyBookResponse> getMyBooks(Integer userId) {

    List<Object[]> rows =
            myBooksRepository.findCurrentBorrowings(userId);

    LibrarySettings settings = settingsRepository.findById(1)
            .orElseThrow(() -> new IllegalStateException(
                    "Library settings record was not found."
            ));

    int renewalLimit = settings.getRenewalLimit();

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
                    toStringValue(row[8]),
                    renewalLimit,
                    toStringValue(row[9])
            ))
            .toList();
}


    @Transactional
    public RenewBookResponse renewBook(
            Integer userId,
            Integer borrowingId) {

        Borrowing borrowing = borrowingRepository.findById(borrowingId)
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "Borrowing record not found."));

        if (!borrowing.getUserId().equals(userId)) {
            throw new ResponseStatusException(
                    HttpStatus.FORBIDDEN,
                    "You cannot renew another student's loan.");
        }

        if (!"BORROWED".equalsIgnoreCase(borrowing.getStatus())) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "Only currently borrowed books can be renewed.");
        }

        LocalDate today = LocalDate.now(
                ZoneId.of("Africa/Addis_Ababa"));

        LocalDate dueDate = borrowing.getDueDate();

        if (today.isBefore(dueDate)) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "You can only renew this book on its due date: "
                    + dueDate);
        }

        if (today.isAfter(dueDate)) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "This book is overdue and cannot be renewed. "
                    + "Please return it.");
        }

        // A reservation by any student prevents renewal.
        var copy = bookCopyRepository.findById(borrowing.getCopyId())
                .orElseThrow(() -> new ResponseStatusException(
                        HttpStatus.NOT_FOUND,
                        "The borrowed book copy was not found."));

        long activeReservations =
                reservationRepository.countActiveByBookId(copy.getBookId());

        if (activeReservations > 0) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "This book has an active reservation and cannot be renewed.");
        }

        LibrarySettings settings = settingsRepository.findById(1)
                .orElseThrow(() -> new IllegalStateException(
                        "Library settings record was not found."));

        int maxRenewals = settings.getRenewalLimit() == null
                ? 0
                : settings.getRenewalLimit();

        if (maxRenewals == 0) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "The library currently does not allow book renewals.");
        }

        int renewals = borrowing.getRenewalCount() == null
                ? 0
                : borrowing.getRenewalCount();

        if (renewals >= maxRenewals) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "You have reached the maximum renewal limit of "
                    + maxRenewals + " for this book.");
        }

        borrowing.setDueDate(
                borrowing.getDueDate().plusDays(
                        settings.getMaxBorrowingDays()));

        borrowing.setRenewalCount(renewals + 1);

        Borrowing saved = borrowingRepository.save(borrowing);

        notificationService.deleteByBorrowingIdAndType(
                borrowingId,
                NotificationType.DUE_SOON);

        notificationService.deleteByBorrowingIdAndType(
                borrowingId,
                NotificationType.OVERDUE);

        return new RenewBookResponse(
                saved.getBorrowingId(),
                saved.getDueDate(),
                saved.getRenewalCount());
    }

    private Integer toInteger(Object value) {
        if (value == null) return 0;
        return ((Number) value).intValue();
    }

    private String toStringValue(Object value) {
        return value == null ? null : value.toString();
    }

    private LocalDate toLocalDate(Object value) {

        if (value == null) return null;

        if (value instanceof LocalDate date) {
            return date;
        }

        if (value instanceof java.sql.Date date) {
            return date.toLocalDate();
        }

        if (value instanceof Timestamp timestamp) {
            return timestamp.toLocalDateTime().toLocalDate();
        }

        if (value instanceof String string) {
            return LocalDate.parse(string);
        }

        throw new IllegalArgumentException(
                "Unsupported date type: " + value.getClass().getName());
    }
    public BorrowingHistoryPageResponse getBorrowingHistory(
        Integer userId,
        int page
) {
    final int pageSize = 5;

    if (page < 0) {
        throw new ResponseStatusException(
                HttpStatus.BAD_REQUEST,
                "Page number cannot be negative."
        );
    }

    int offset = page * pageSize;

    // Fetch one extra record to determine whether another page exists.
    List<Object[]> rows =
            myBooksRepository.findReturnedBorrowings(
                    userId,
                    pageSize + 1,
                    offset
            );

    LibrarySettings settings = settingsRepository.findById(1)
            .orElseThrow(() -> new IllegalStateException(
                    "Library settings record was not found."
            ));

    int renewalLimit = settings.getRenewalLimit();

    boolean hasNext = rows.size() > pageSize;

    List<MyBookResponse> records = rows.stream()
            .limit(pageSize)
            .map(row -> new MyBookResponse(
                    toInteger(row[0]),
                    toStringValue(row[1]),
                    toStringValue(row[2]),
                    toLocalDate(row[3]),
                    toLocalDate(row[4]),
                    toLocalDate(row[5]),
                    toStringValue(row[6]),
                    toInteger(row[7]),
                    toStringValue(row[8]),
                    renewalLimit,
                    toStringValue(row[9])
            ))
            .toList();

    return new BorrowingHistoryPageResponse(
            records,
            page,
            pageSize,
            hasNext
    );
}
}
