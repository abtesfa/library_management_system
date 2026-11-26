package com.library.library_backend.dto;

public class ReturnBookRequest {

    private String studentId;
    private String bookQuery;
    private String condition;

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

    public String getCondition() {
        return condition;
    }

    public void setCondition(String condition) {
        this.condition = condition;
    }
}