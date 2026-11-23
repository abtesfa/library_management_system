package com.library.library_backend.dto;

import java.util.List;

public record BorrowingHistoryPageResponse(
        List<MyBookResponse> records,
        int page,
        int pageSize,
        boolean hasNext
) {}