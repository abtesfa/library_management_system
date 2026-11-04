package com.library.library_backend.dto;

import java.time.LocalDate;

public class ActiveBorrowingResponse {

    private Integer borrowingId;
    private String studentId;
    private String bookTitle;
    private String isbn;
    private LocalDate borrowDate;
    private LocalDate dueDate;
    private LocalDate returnDate;
    private String status;
    private Integer renewalCount;

    public ActiveBorrowingResponse(
            Integer borrowingId,
            String studentId,
            String bookTitle,
            String isbn,
            LocalDate borrowDate,
            LocalDate dueDate,
            LocalDate returnDate,
            String status,
            Integer renewalCount
    ) {
        this.borrowingId = borrowingId;
        this.studentId = studentId;
        this.bookTitle = bookTitle;
        this.isbn = isbn;
        this.borrowDate = borrowDate;
        this.dueDate = dueDate;
        this.returnDate = returnDate;
        this.status = status;
        this.renewalCount = renewalCount;
    }

    public Integer getBorrowingId() {
        return borrowingId;
    }

    public String getStudentId() {
        return studentId;
    }

    public String getBookTitle() {
        return bookTitle;
    }

    public String getIsbn() {
        return isbn;
    }

    public LocalDate getBorrowDate() {
        return borrowDate;
    }

    public LocalDate getDueDate() {
        return dueDate;
    }

    public LocalDate getReturnDate() {
        return returnDate;
    }

    public String getStatus() {
        return status;
    }

    public Integer getRenewalCount() {
        return renewalCount;
    }
}