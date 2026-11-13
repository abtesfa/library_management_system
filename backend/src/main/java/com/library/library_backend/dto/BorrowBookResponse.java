package com.library.library_backend.dto;

import java.time.LocalDate;

public class BorrowBookResponse {

    private Integer borrowingId;
    private String studentId;
    private String bookTitle;
    private String isbn;
    private Integer copyId;
    private LocalDate borrowDate;
    private LocalDate dueDate;
    private String status;
    private String location;

    public BorrowBookResponse(
            Integer borrowingId,
            String studentId,
            String bookTitle,
            String isbn,
            Integer copyId,
            LocalDate borrowDate,
            LocalDate dueDate,
            String status,
            String location
    ) {
        this.borrowingId = borrowingId;
        this.studentId = studentId;
        this.bookTitle = bookTitle;
        this.isbn = isbn;
        this.copyId = copyId;
        this.borrowDate = borrowDate;
        this.dueDate = dueDate;
        this.status = status;
        this.location = location;
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

    public Integer getCopyId() {
        return copyId;
    }

    public LocalDate getBorrowDate() {
        return borrowDate;
    }

    public LocalDate getDueDate() {
        return dueDate;
    }

    public String getStatus() {
        return status;
    }

    public String getLocation() {
        return location;
    }
}