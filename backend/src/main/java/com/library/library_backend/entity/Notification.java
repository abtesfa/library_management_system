
package com.library.library_backend.entity;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
public class Notification {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "notification_id")
    private Integer notificationId;

    @Column(nullable = false, length = 150)
    private String title;

    @Column(nullable = false, columnDefinition = "TEXT")
    private String message;

    @Column(columnDefinition = "TEXT")
    private String details;

    @Enumerated(EnumType.STRING)
    @Column(name = "notification_type", nullable = false)
    private NotificationType notificationType;

    @Column(name = "created_at", insertable = false, updatable = false)
    private LocalDateTime createdAt;

    @Column(name = "is_read", nullable = false)
    private Boolean isRead = false;

    // New notification recipient fields
    @Column(name = "recipient_type", nullable = false, length = 20)
    private String recipientType = "ALL";

    @Column(name = "recipient_id")
    private Integer recipientId;

    @Column(name = "reservation_id")
    private Integer reservationId;

    @Column(name = "borrowing_id")
    private Integer borrowingId;

    @Column(name = "announcement_priority", length = 20)
    private String announcementPriority;

    @Column(name = "audience_positions", columnDefinition = "TEXT")
    private String audiencePositions;

    @Column(name = "valid_from")
    private java.time.LocalDate validFrom;

    @Column(name = "valid_until")
    private java.time.LocalDate validUntil;

    @Column(name = "is_archived", nullable = false)
    private Boolean archived = false;

    public Notification() {
    }

    public Integer getNotificationId() {
        return notificationId;
    }

    public void setNotificationId(Integer notificationId) {
        this.notificationId = notificationId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public String getDetails() {
        return details;
    }

    public void setDetails(String details) {
        this.details = details;
    }

    public NotificationType getNotificationType() {
        return notificationType;
    }

    public void setNotificationType(NotificationType notificationType) {
        this.notificationType = notificationType;
    }

    public LocalDateTime getCreatedAt() {
        return createdAt;
    }

    public Boolean getIsRead() {
        return isRead;
    }

    public void setIsRead(Boolean isRead) {
        this.isRead = isRead;
    }

    public String getRecipientType() {
        return recipientType;
    }

    public void setRecipientType(String recipientType) {
        this.recipientType = recipientType;
    }

    public Integer getRecipientId() {
        return recipientId;
    }

    public void setRecipientId(Integer recipientId) {
        this.recipientId = recipientId;
    }

    public Integer getReservationId() {
        return reservationId;
    }

    public void setReservationId(Integer reservationId) {
        this.reservationId = reservationId;
    }

    public String getAnnouncementPriority() { return announcementPriority; }
    public void setAnnouncementPriority(String value) { this.announcementPriority = value; }
    public String getAudiencePositions() { return audiencePositions; }
    public void setAudiencePositions(String value) { this.audiencePositions = value; }
    public java.time.LocalDate getValidFrom() { return validFrom; }
    public void setValidFrom(java.time.LocalDate value) { this.validFrom = value; }
    public java.time.LocalDate getValidUntil() { return validUntil; }
    public void setValidUntil(java.time.LocalDate value) { this.validUntil = value; }
    public Boolean getArchived() { return archived; }
    public void setArchived(Boolean value) { this.archived = value; }

    public Integer getBorrowingId() {
        return borrowingId;
    }

    public void setBorrowingId(Integer borrowingId) {
        this.borrowingId = borrowingId;
    }
}
