package com.library.library_backend.dto;

import java.time.LocalDate;

public record MyBookResponse(
        Integer borrowingId,
        String bookTitle,
        String isbn,
        LocalDate borrowDate,
        LocalDate dueDate,
        LocalDate returnDate,
        String status,
        Integer renewalCount,
        String location
) {}