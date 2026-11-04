package com.library.library_backend.dto;

import java.time.LocalDate;

public class BorrowBookRequest {

    private String studentId;
    private String bookQuery;
    private LocalDate borrowDate;

    public String getStudentId() {
        return studentId;
    }

    public void setStudentId(String studentId) {
        this.studentId = studentId;
    }

    public String getBookQuery() {
        return bookQuery;
    }

    public void setBookQuery(String bookQuery) {
        this.bookQuery = bookQuery;
    }

    public LocalDate getBorrowDate() {
        return borrowDate;
    }

    public void setBorrowDate(LocalDate borrowDate) {
        this.borrowDate = borrowDate;
    }
}