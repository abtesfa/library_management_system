
package com.library.library_backend.entity;

import jakarta.persistence.*;
import java.time.LocalDate;
import jakarta.persistence.Column;
import jakarta.persistence.Enumerated;
import jakarta.persistence.EnumType;
import java.math.BigDecimal;

@Entity
@Table(name = "borrowing")
public class Borrowing {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Borrowing_ID")
    private Integer borrowingId;

    @Column(name = "User_ID", nullable = false)
    private Integer userId;

    @Column(name = "Copy_ID", nullable = false)
    private Integer copyId;

    @Column(name = "Borrow_Date", nullable = false)
    private LocalDate borrowDate;
    @Column(name = "Fine_Amount", nullable = false)
private BigDecimal fineAmount = BigDecimal.ZERO;

@Enumerated(EnumType.STRING)
@Column(name = "Book_Condition", nullable = false)
private BookCondition bookCondition = BookCondition.GOOD;

    @Column(name = "Due_Date", nullable = false)
    private LocalDate dueDate;

    @Column(name = "Return_Date")
    private LocalDate returnDate;

    @Column(name = "Status", nullable = false)
    private String status = "BORROWED";

    @Column(name = "Renewal_Count")
    private Integer renewalCount;

    public Borrowing() {
    }

    public Integer getBorrowingId() {
        return borrowingId;
    }

    public void setBorrowingId(Integer borrowingId) {
        this.borrowingId = borrowingId;
    }

    public Integer getUserId() {
        return userId;
    }
    public BigDecimal getFineAmount() {
    return fineAmount;
}

public void setFineAmount(BigDecimal fineAmount) {
    this.fineAmount = fineAmount;
}

public BookCondition getBookCondition() {
    return bookCondition;
}

public void setBookCondition(String condition) {
    this.bookCondition = BookCondition.valueOf(condition);
}
    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Integer getCopyId() {
        return copyId;
    }

    public void setCopyId(Integer copyId) {
        this.copyId = copyId;
    }

    public LocalDate getBorrowDate() {
        return borrowDate;
    }

    public void setBorrowDate(LocalDate borrowDate) {
        this.borrowDate = borrowDate;
    }

    public LocalDate getDueDate() {
        return dueDate;
    }

    public void setDueDate(LocalDate dueDate) {
        this.dueDate = dueDate;
    }

    public LocalDate getReturnDate() {
        return returnDate;
    }

    public void setReturnDate(LocalDate returnDate) {
        this.returnDate = returnDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Integer getRenewalCount() {
        return renewalCount;
    }

    public void setRenewalCount(Integer renewalCount) {
        this.renewalCount = renewalCount;
    }
}
