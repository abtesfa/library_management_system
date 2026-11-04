
package com.library.library_backend.Service;

import com.library.library_backend.dto.MyBookResponse;
import com.library.library_backend.repository.MyBooksRepository;
import org.springframework.stereotype.Service;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
public class MyBooksService {

    private final MyBooksRepository myBooksRepository;

    public MyBooksService(MyBooksRepository myBooksRepository) {
        this.myBooksRepository = myBooksRepository;
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
