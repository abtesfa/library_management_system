
package com.library.library_backend.entity;

import jakarta.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "reservations")
public class Reservation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "Reservation_ID")
    private Integer reservationId;

    @Column(name = "User_ID", nullable = false)
    private Integer userId;

    @Column(name = "Book_ID", nullable = false)
    private Integer bookId;

    @Column(name = "Reservation_Date")
    private LocalDateTime reservationDate;

    @Column(name = "Queue_Position")
    private Integer queuePosition;

    @Column(name = "Status")
    private String status;

    @Column(name = "Pickup_Location")
    private String pickupLocation;

    @Column(name = "Hold_Until")
    private LocalDate holdUntil;

    public Reservation() {
    }

    public Integer getReservationId() {
        return reservationId;
    }

    public void setReservationId(Integer reservationId) {
        this.reservationId = reservationId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Integer getBookId() {
        return bookId;
    }

    public void setBookId(Integer bookId) {
        this.bookId = bookId;
    }

    public LocalDateTime getReservationDate() {
        return reservationDate;
    }

    public void setReservationDate(LocalDateTime reservationDate) {
        this.reservationDate = reservationDate;
    }

    public Integer getQueuePosition() {
        return queuePosition;
    }

    public void setQueuePosition(Integer queuePosition) {
        this.queuePosition = queuePosition;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPickupLocation() {
        return pickupLocation;
    }

    public void setPickupLocation(String pickupLocation) {
        this.pickupLocation = pickupLocation;
    }

    public LocalDate getHoldUntil() {
        return holdUntil;
    }

    public void setHoldUntil(LocalDate holdUntil) {
        this.holdUntil = holdUntil;
    }
}
