
package com.library.library_backend.dto;

import java.time.LocalDate;
import java.time.LocalDateTime;

public record ReservationResponse(
        Integer reservationId,
        String bookId,
        String bookTitle,
        String author,
        LocalDateTime reservedDate,
        LocalDate holdUntil,
        String pickupLocation,
        String status,
        Integer queuePosition
) {
}
