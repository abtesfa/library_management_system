
package com.library.library_backend.entity;

import jakarta.persistence.*;
import java.math.BigDecimal;
import jakarta.persistence.Lob;
import jakarta.persistence.Column;

@Entity
@Table(name = "library_settings")
public class LibrarySettings {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "setting_id")
    private Integer settingId;

    @Column(name = "library_name", nullable = false, length = 150)
    private String libraryName;

    @Column(name = "school_email", length = 255)
    private String schoolEmail;

    @Column(name = "school_location", length = 500)
    private String schoolLocation;

    @Column(name = "max_books_per_student", nullable = false)
private Integer maxBooksPerStudent;

    @Column(name = "max_borrowing_days", nullable = false)
    private Integer maxBorrowingDays;

    @Column(name = "renewal_limit", nullable = false)
    private Integer renewalLimit;

    @Column(name = "fine_per_day", nullable = false, precision = 10, scale = 2)
    private BigDecimal finePerDay;

    @Lob
    @Column(name = "library_logo", columnDefinition = "LONGBLOB")
    private byte[] libraryLogo;

    @Column(
        name = "reservation_hold_minutes",
        nullable = false,
        columnDefinition = "INT NOT NULL DEFAULT 1440"
    )
    private Integer reservationHoldMinutes = 1440;

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

    public String getSchoolEmail() {
        return schoolEmail;
    }

    public void setSchoolEmail(String schoolEmail) {
        this.schoolEmail = schoolEmail;
    }

    public String getSchoolLocation() {
        return schoolLocation;
    }

    public void setSchoolLocation(String schoolLocation) {
        this.schoolLocation = schoolLocation;
    }

    public Integer getMaxBooksPerStudent() {
        return maxBooksPerStudent;
    }

    public void setMaxBooksPerStudent(Integer maxBooksPerStudent) {
        this.maxBooksPerStudent = maxBooksPerStudent;
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

    public Integer getReservationHoldMinutes() {
        return reservationHoldMinutes;
    }

    public void setReservationHoldMinutes(Integer reservationHoldMinutes) {
        this.reservationHoldMinutes = reservationHoldMinutes;
    }
    public byte[] getLibraryLogo() { return libraryLogo; }
    public void setLibraryLogo(byte[] libraryLogo) { this.libraryLogo = libraryLogo; }
}