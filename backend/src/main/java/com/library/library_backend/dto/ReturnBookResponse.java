package com.library.library_backend.dto;

import java.math.BigDecimal;
import java.time.LocalDate;

public class ReturnBookResponse {

    private Integer borrowingId;
    private String studentId;
    private String bookTitle;
    private LocalDate returnDate;
    private long overdueDays;
    private BigDecimal fineAmount;
    private String condition;
    private String status;

    public ReturnBookResponse(
            Integer borrowingId,
            String studentId,
            String bookTitle,
            LocalDate returnDate,
            long overdueDays,
            BigDecimal fineAmount,
            String condition,
            String status
    ) {
        this.borrowingId = borrowingId;
        this.studentId = studentId;
        this.bookTitle = bookTitle;
        this.returnDate = returnDate;
        this.overdueDays = overdueDays;
        this.fineAmount = fineAmount;
        this.condition = condition;
        this.status = status;
    }

    public Integer getBorrowingId() { return borrowingId; }
    public String getStudentId() { return studentId; }
    public String getBookTitle() { return bookTitle; }
    public LocalDate getReturnDate() { return returnDate; }
    public long getOverdueDays() { return overdueDays; }
    public BigDecimal getFineAmount() { return fineAmount; }
    public String getCondition() { return condition; }
    public String getStatus() { return status; }
}