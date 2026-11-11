
package com.library.library_backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "library_settings")
public class LibrarySettings {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "setting_id")
    private Integer settingId;

    @Column(name = "library_name", nullable = false, length = 150)
    private String libraryName;

    @Column(name = "max_books_per_day", nullable = false)
    private Integer maxBooksPerDay;

    @Column(name = "max_borrowing_days", nullable = false)
    private Integer maxBorrowingDays;

    @Column(name = "renewal_limit", nullable = false)
    private Integer renewalLimit;

    @Column(name = "fine_per_day", nullable = false, precision = 10, scale = 2)
    private BigDecimal finePerDay;

    public LibrarySettings() {
    }

    public Integer getSettingId() {
        return settingId;
    }

    public void setSettingId(Integer settingId) {
        this.settingId = settingId;
    }

    public String getLibraryName() {
        return libraryName;
    }

    public void setLibraryName(String libraryName) {
        this.libraryName = libraryName;
    }

    public Integer getMaxBooksPerDay() {
        return maxBooksPerDay;
    }

    public void setMaxBooksPerDay(Integer maxBooksPerDay) {
        this.maxBooksPerDay = maxBooksPerDay;
    }

    public Integer getMaxBorrowingDays() {
        return maxBorrowingDays;
    }

    public void setMaxBorrowingDays(Integer maxBorrowingDays) {
        this.maxBorrowingDays = maxBorrowingDays;
    }

    public Integer getRenewalLimit() {
        return renewalLimit;
    }

    public void setRenewalLimit(Integer renewalLimit) {
        this.renewalLimit = renewalLimit;
    }

    public BigDecimal getFinePerDay() {
        return finePerDay;
    }

    public void setFinePerDay(BigDecimal finePerDay) {
        this.finePerDay = finePerDay;
    }
}