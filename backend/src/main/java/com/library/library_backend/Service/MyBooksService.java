
package com.library.library_backend.Service;

import com.library.library_backend.dto.MyBookResponse;
import com.library.library_backend.dto.RenewBookResponse;
import com.library.library_backend.entity.Borrowing;
import com.library.library_backend.entity.LibrarySettings;
import com.library.library_backend.repository.BorrowingRepository;
import com.library.library_backend.repository.MyBooksRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;
import com.library.library_backend.entity.NotificationType;
import com.library.library_backend.repository.LibrarySettingsRepository;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class MyBooksService {

    /** A loan can be renewed once, even if the settings allow more. */
    

    private final MyBooksRepository myBooksRepository;
    private final BorrowingRepository borrowingRepository;
    private final LibrarySettingsRepository settingsRepository;
    private final NotificationService notificationService;
   public MyBooksService(
        MyBooksRepository myBooksRepository,
        BorrowingRepository borrowingRepository,
        LibrarySettingsRepository settingsRepository,
    NotificationService notificationService) {

    this.myBooksRepository = myBooksRepository;
    this.borrowingRepository = borrowingRepository;
    this.settingsRepository = settingsRepository;
    this.notificationService = notificationService;
}

    public List<MyBookResponse> getMyBooks(Integer userId) {

    // Get the renewal limit configured by the administrator.
    LibrarySettings settings = settingsRepository.findById(1)
            .orElseThrow(() -> new IllegalStateException(
                    "Library settings record was not found."
            ));

    int renewalLimit = settings.getRenewalLimit() == null
            ? 0
            : settings.getRenewalLimit();

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
                    toStringValue(row[8]),
                    renewalLimit
            ))
            .toList();
}

    /**
 * Renews a student's active loan only on its exact due date.
 * The number of renewals is controlled by library settings.
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

        // A book can only be renewed on its exact due date.
LocalDate today = LocalDate.now(
        java.time.ZoneId.of("Africa/Addis_Ababa")
);

LocalDate dueDate = borrowing.getDueDate();

if (today.isBefore(dueDate)) {
    throw new ResponseStatusException(
            HttpStatus.CONFLICT,
            "You can only renew this book on its due date: "
                    + dueDate
    );
}

if (today.isAfter(dueDate)) {
    throw new ResponseStatusException(
            HttpStatus.CONFLICT,
            "This book is overdue and cannot be renewed. "
                    + "Please return it."
    );
}

// Retrieve the renewal limit configured by the administrator.
LibrarySettings settings = settingsRepository.findById(1)
        .orElseThrow(() -> new IllegalStateException(
                "Library settings record was not found."
        ));

int maxRenewals = settings.getRenewalLimit() == null
        ? 0
        : settings.getRenewalLimit();

if (maxRenewals == 0) {
    throw new ResponseStatusException(
            HttpStatus.CONFLICT,
            "The library currently does not allow book renewals."
    );
}

// Count how many times this borrowing has already been renewed.
int renewals = borrowing.getRenewalCount() == null
        ? 0
        : borrowing.getRenewalCount();

if (renewals >= maxRenewals) {
    throw new ResponseStatusException(
            HttpStatus.CONFLICT,
            "You have reached the maximum renewal limit of "
                    + maxRenewals + " for this book."
    );
}
        borrowing.setDueDate(
                borrowing.getDueDate().plusDays(settings.getMaxBorrowingDays())
        );
        borrowing.setRenewalCount(renewals + 1);

        Borrowing saved = borrowingRepository.save(borrowing);
        // Remove notifications based on the previous due date.
// The scheduler will create a new one if the extended due date
// still falls within the notification window.
notificationService.deleteByBorrowingIdAndType(
        borrowingId,
        NotificationType.DUE_SOON
);

notificationService.deleteByBorrowingIdAndType(
        borrowingId,
        NotificationType.OVERDUE
);

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
