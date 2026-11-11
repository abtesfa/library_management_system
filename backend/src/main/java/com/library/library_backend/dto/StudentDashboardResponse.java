package com.library.library_backend.dto;

public class StudentDashboardResponse {

    private String fullName;
    private long currentlyBorrowed;
    private long dueThisWeek;
    private long booksReadThisYear;

    public StudentDashboardResponse(
            String fullName,
            long currentlyBorrowed,
            long dueThisWeek,
            long booksReadThisYear) {

        this.fullName = fullName;
        this.currentlyBorrowed = currentlyBorrowed;
        this.dueThisWeek = dueThisWeek;
        this.booksReadThisYear = booksReadThisYear;
    }

    public String getFullName() {
        return fullName;
    }

    public long getCurrentlyBorrowed() {
        return currentlyBorrowed;
    }

    public long getDueThisWeek() {
        return dueThisWeek;
    }

    public long getBooksReadThisYear() {
        return booksReadThisYear;
    }
}