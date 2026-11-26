package com.library.library_backend.dto;

import java.time.LocalDate;

/** Result of a successful loan renewal. */
public record RenewBookResponse(
        Integer borrowingId,
        LocalDate dueDate,
        Integer renewalCount
) {}
