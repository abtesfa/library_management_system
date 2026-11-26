package com.library.library_backend.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "book_copy")
public class BookCopy {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Copy_ID")
    private Integer copyId;

    @Column(name = "Book_ID", nullable = false)
    private Integer bookId;

    @Column(name = "Status", nullable = false)
    private String status;

    @Column(name = "Location", length = 100)
    private String location;

    public BookCopy() {
    }

    public Integer getCopyId() {
        return copyId;
    }

    public void setCopyId(Integer copyId) {
        this.copyId = copyId;
    }

    public Integer getBookId() {
        return bookId;
    }

    public void setBookId(Integer bookId) {
        this.bookId = bookId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getLocation() {
        return location;
    }

    public void setLocation(String location) {
        this.location = location;
    }
}